CLASS lhc_MainHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MainHeader RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR MainHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR MainHeader RESULT result.

    METHODS pdf FOR MODIFY
      IMPORTING keys FOR ACTION MainHeader~pdf RESULT result.

ENDCLASS.

CLASS lhc_MainHeader IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD pdf.

**********************************************************************
        data : lv_base64 TYPE string,
               lv_token TYPE string,
               lv_message type string.

**********************************************************************
        READ ENTITIES OF zreservation_hdr_i IN LOCAL MODE
            ENTITY MainHeader
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT data(lt_head)
            ENTITY MainHeader BY \_item

            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item).
***********************************************************************

          data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

            if ls_head-Requino is NOT INITIAL.

        TRY.
            "Initialize Template Store Client
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_name                  = 'ZADS_CS'
             iv_service_instance_name = 'ZADS_OUT_REST'
            ).

            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZRES_FORM_SD'
                                                                  iv_root_node = 'ZRES_HDR_CE'

                                                                  ) .
**********************************************************************
            data: printque type c LENGTH 32.

              printque = 'ADOBE_DEFAULT'.
**********************************************************************
            TRY.
                lo_store->get_schema_by_name( iv_form_name = 'ZRESERVATION_FORM' ).
                "   out->write( 'Schema found in form' ).
              CATCH zcx_fp_tmpl_store_error INTO DATA(lo_tmpl_error).
                "  out->write( 'No schema in form found' ).
                IF lo_tmpl_error->mv_http_status_code = 404 OR lo_tmpl_error->mv_http_status_code = 403 .
                  "Upload service definition
*                  lo_store->set_schema(
*                    iv_form_name = 'GATEFORM'
*                    is_data      = VALUE #( note = '' schema_name = 'schema' xsd_schema = lo_fdp_util->get_xsd( ) )
*                  ).
                ELSE.

                ENDIF.
            ENDTRY.
**********************************************************************
        TYPES: BEGIN OF ty_schema_body,
                 xsd_schema  TYPE xstring,
                 schema_name TYPE c LENGTH 30,
                 note        TYPE c LENGTH 280,
               END OF ty_schema_body.
        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA lv_xdp TYPE ty_schema_body.
        lv_xdp = VALUE #( note        = ''
                          schema_name = 'schema'
                          xsd_schema  = lo_fdp_util->get_xsd( ) ).
**********************************************************************

            DATA(lt_keys)     = lo_fdp_util->get_keys( ).
            lt_keys[ name = 'RESERVATION' ]-value = lt_head[ 1 ]-Requino.
            data(lt_xsd) = lo_fdp_util->get_xsd( ).
            data(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).
**********************************************************************
            TRY.
                DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
               DATA(lv_text1) = cl_web_http_utility=>decode_utf8( encoded = lv_xml ).
                "out->write( 'Service data retrieved' ).
              CATCH cx_fp_fdp_error INTO DATA(lo_exception).
              data(lo_error3) = 3.
            ENDTRY..

*****************************************************************************
            DATA(ls_template) = lo_store->get_template_by_name(
              iv_get_binary    = abap_true
              iv_form_name     = 'ZRESERVATION_FORM'
              iv_template_name = 'RES_FORM'
            ).

            cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                       "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                 iv_xml_data     = lv_xml
                                                 iv_xdp_layout   = ls_template-xdp_template
                                                 is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                       IMPORTING
                                       " TODO: variable is assigned but never used (ABAP cleaner)
                                                 ev_trace_string = DATA(lv_trace)
                                                 ev_pdf          = DATA(lv_pdf) ).


            DATA: lv_name TYPE c LENGTH 120.
            lv_name = |Reservation { lt_head[ 1 ]-Requino }|.

            DATA(lv_gno) = VALUE #( lt_head[ 1 ]-Requino OPTIONAL ).

**********************************************************************
            cl_print_queue_utils=>create_queue_item_by_data(
              iv_qname            = printque
              iv_print_data       = lv_pdf
              iv_name_of_main_doc = lv_name
              iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
            ).

          CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
            " out->write( 'Exception occurred.' ).
            data(lo_error) = 2.
        ENDTRY.
        "out->write( 'Finished processing.' ).
    if lv_pdf is not iNITIAL.
        data: gt_formupdate TYPE TABLE OF zreser_table,
              gs_formupdate TYPE zreser_table.
**********************************************************************

        data(gs_head) = lt_head[ 1 ].
        data(coaform) = |Reservation-{ gs_head-Requino }|.
**********************************************************************
*       MOVE-CORRESPONDING gs_head to gs_formupdate.
        gs_formupdate-reservation = gs_head-Requino.
        gs_formupdate-attachment =  lv_pdf.
        gs_formupdate-filename =  coaform.
        gs_formupdate-mimetype =  'application/pdf'.

        APPEND gs_formupdate TO gt_formupdate.
        zbp_reservation_hdr_i=>gt_header = gt_formupdate.
    endif.



            endif.

            result = VALUE #( for ls_output in lt_head ( %tky = ls_output-%tky
                                                            %param = ls_output ) ).

******************************************************************************
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZRESERVATION_HDR_I DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZRESERVATION_HDR_I IMPLEMENTATION.

  METHOD save_modified.
  IF zbp_reservation_hdr_i=>gt_header IS NOT INITIAL.
  MODIFY zreser_table FROM TABLE @zbp_reservation_hdr_i=>gt_header.
  ENDIF .
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
