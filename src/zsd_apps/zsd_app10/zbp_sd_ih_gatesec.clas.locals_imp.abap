CLASS lhc_GateSecHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR GateSecHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR GateSecHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR GateSecHead RESULT result.

    METHODS GatePrint FOR MODIFY
       keys FOR ACTION GateSecHead~GatePrint RESULT result.

    METHODS headmodify FOR DETERMINE ON SAVE
       keys FOR GateSecHead~headmodify.
    METHODS CancelGateEntry FOR MODIFY
      keys FOR ACTION GateSecHead~CancelGateEntry RESULT result.

ENDCLASS.

CLASS lhc_GateSecHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
            ENTITY GateSecHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
******************************************************************
                result = VALUE #( for ls_key in keys
                     ( %tky = ls_key-%tky

                     %update = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                     %delete = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                     %action = VALUE #( CancelGateEntry = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                       Edit = COND #( when ls_head-Cancelgateentry is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )


                                            ) ) ).




  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GatePrint.
***********************************************************************
   READ ENTITIES OF ZSD_IH_GATESEC IN LOCAL MODE
          ENTITY GateSecHead
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT FINAL(gt_head)
          FAILED FINAL(gt_failed).
***********************************************************************
          DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
          DATA(gt_keys) = keys.
          DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
***********************************************************************
    if ls_header-Gateentryid is not INITIAL.

        TRY.
            "Initialize Template Store Client
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_name                  = 'ZADS_CS'
             iv_service_instance_name = 'ZADS_OUT_REST'
            ).

            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZSD_WEIGHT_SLIP_CE'
                                                                  iv_root_node = 'ZSD_HCE_GATESEC' ) .

           data: printque type c LENGTH 32.

              printque = 'ADOBE_DEFAULT'.

            TRY.
                lo_store->get_schema_by_name( iv_form_name = 'ZSD_ENTRY_SLIP' ).
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

***********************************************************************
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

***********************************************************************
               DATA(lt_keys)     = lo_fdp_util->get_keys( ).
            lt_keys[ name = 'UUID' ]-value = gt_head[ 1 ]-Uuid.
***********************************************************************
         data(lt_xsd) = lo_fdp_util->get_xsd( ).
***********************************************************************
*           "Convert the XSD File converstion for Form Purpose
             data(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

                TRY.
                DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
                "out->write( 'Service data retrieved' ).
              CATCH cx_fp_fdp_error INTO DATA(lo_exception).
            ENDTRY.
***********************************************************************
        DATA(ls_template) = lo_store->get_template_by_name(
              iv_get_binary    = abap_true
              iv_form_name     = 'ZSD_ENTRY_SLIP'
              iv_template_name = 'ENTRY_SLIP'
            ).
***********************************************************************
cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                       "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                 iv_xml_data     = lv_xml
                                                 iv_xdp_layout   = ls_template-xdp_template
                                                 is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                       IMPORTING
                                       " TODO: variable is assigned but never used (ABAP cleaner)
                                                 ev_trace_string = DATA(lv_trace)
                                                 ev_pdf          = DATA(lv_pdf) ).




***********************************************************************
             DATA: lv_name TYPE c LENGTH 120.
            lv_name = |Entry Slip-{ gt_head[ 1 ]-Gateentryid }|.
***********************************************************************
                cl_print_queue_utils=>create_queue_item_by_data(
              iv_qname            = printque
              iv_print_data       = lv_pdf
              iv_name_of_main_doc = lv_name
              iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
            ).

          CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
            " out->write( 'Exception occurred.' ).
        ENDTRY.
***********************************************************************
           if lv_pdf is not iNITIAL.

                    MODIFY ENTITIES OF ZSD_IH_GATESEC IN LOCAL MODE
                    ENTITY GateSecHead
                    UPDATE
                    FIELDS ( Attachment Mimetype Filename )
                        WITH VALUE #( for key in keys
                                   (   %tky = ls_header-%tky
                                    Attachment = lv_pdf
                                    Mimetype = 'application/pdf'
                                    Filename = lv_name
                                    %control-Attachment = if_abap_behv=>mk-on
                                    %control-Mimetype = if_abap_behv=>mk-on
                                    %control-Filename = if_abap_behv=>mk-on
                                    )  ).

                endif.
*
        endif.

***********************************************************************
       result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD headmodify.
***********************************************************************
        data: seqno type ZSD_APP05_HDB-gateentrysequence,
              gateno type ZSD_APP05_HDB-gateentryno,
              sydate type ZSD_APP05_HDB-gateentrydate,
              gateid type ZSD_APP05_HDB-gateentryid,
              transportid TYPE n LENGTH 10.
***********************************************************************
        READ ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
        ENTITY GateSecHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(gt_head)
        FAILED FINAL(gt_failed).

***********************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
        LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
            IF <fs_head> is ASSIGNED.

***********************************************************************
               if <fs_head>-Gateentrytype is not INITIAL.
                    select SINGLE value_low,text from ZSD_TYPE_VH WITH PRIVILEGED ACCESS
                    where value_low = @<fs_head>-Gateentrytype
                    into @DATA(gs_gatetype).
               endif.
***********************************************************************
                if <fs_head>-Gateno is NOT INITIAL.
                    select SINGLE * from ZSD_GATENO_VH WITH PRIVILEGED ACCESS
                    where value_low = @<fs_head>-Gateno
                    INTO @DATA(gs_gateno).

                ENDIF.
***********************************************************************
                if <fs_head>-Transportid is not INITIAL.
                    transportid = <fs_head>-Transportid.
                    SELECT SINGLE * FROM ZSD_BP_ZTRP_VH WITH PRIVILEGED ACCESS
                    WHERE Transporterid = @transportid
                    INTO @DATA(ls_traname).
                ENDIF.
                if <fs_head>-Modeoftransport is not INITIAL.
                    SELECT SINGLE * FROM ZSD_MODE_TVH WITH PRIVILEGED ACCESS
                    WHERE value_low = @<fs_head>-Modeoftransport
                    INTO @DATA(modeoftran).
                ENDIF.
***********************************************************************
        SELECT SINGLE MAX( gateentryid ) AS gateentryid
            FROM ZSD_APP05_HDB
            INTO @DATA(gs_id).

        if gs_id is not INITIAL.
            gateid = gs_id + 1.
         else.
            gateid = '1000000001'.
        endif.

************************************************************************
           MODIFY ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
           ENTITY GateSecHead
           UPDATE
           FIELDS ( Gateentryid Gateentryiddate Gateentryidtime Gateentrytypetext Gatenodes
                    Vehicletype Transportname Modeoftransporttext )
           WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         Gateentryid = gateid
                         Gateentryiddate = lv_date
                         gateentryidtime = lv_time
                         Gateentrytypetext = gs_gatetype-text
                         Gatenodes = gs_gateno-text
                         Vehicletype = 'R'
                         Transportname = ls_traname-Transportername
                         Modeoftransporttext = modeoftran-text

                         %control-Gateentryid = if_abap_behv=>mk-on
                         %control-Gateentryiddate = if_abap_behv=>mk-on
                         %control-Gateentrytypetext = if_abap_behv=>mk-on
                         %control-Gatenodes = if_abap_behv=>mk-on
                         %control-Vehicletype = if_abap_behv=>mk-on
                         %control-Transportname = if_abap_behv=>mk-on
                         %control-Modeoftransporttext = if_abap_behv=>mk-on
                         ) ).
************************************************************************

            endif.
        ENDLOOP.

  ENDMETHOD.

  METHOD CancelGateEntry.
************************************************************************
            READ ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
            ENTITY GateSecHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(gt_head)
            FAILED DATA(gt_failed).
************************************************************************
            LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<gs_head>).
            if <gs_head> is ASSIGNED.

           MODIFY ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
           ENTITY GateSecHead
           UPDATE
           FIELDS ( Cancelgateentry )
           WITH VALUE #( for key IN keys
                            ( %tky = <gs_head>-%tky
                            Cancelgateentry = 'X'

                           %control-Cancelgateentry = if_abap_behv=>mk-on
                         ) ).

            ENDIF.
            ENDLOOP.
************************************************************************
       result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateSecItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR GateSecItem RESULT result.

ENDCLASS.

CLASS lhc_GateSecItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
