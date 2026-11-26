CLASS lhc_ZMAINT_HDR_I DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zmaint_hdr_i RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zmaint_hdr_i RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zmaint_hdr_i RESULT result.

    METHODS pdf FOR MODIFY
      IMPORTING keys FOR ACTION zmaint_hdr_i~pdf RESULT result.
    METHODS updateitem FOR MODIFY
      IMPORTING keys FOR ACTION zmaint_hdr_i~updateitem RESULT result.

ENDCLASS.

CLASS lhc_ZMAINT_HDR_I IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD pdf.

**********************************************************************************************
    DATA: lt_upform TYPE TABLE OF zmaint_table,
          ls_upform TYPE zmaint_table,
          formtype  TYPE c LENGTH 50,
          lt_item   TYPE TABLE OF zmaint_ides_db,
          		  ls_item   TYPE zmaint_ides_db.

**********************************************************************************************

***********************************************************************************************
    READ ENTITIES OF zmaint_hdr_i IN LOCAL MODE
    ENTITY zmaint_hdr_i
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    ENTITY zmaint_hdr_i BY \_item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_hdr)
    FAILED FINAL(gt_failed).

***********************************************************************************************
    DATA(ls_header) = VALUE #( gt_hdr[ 1 ] OPTIONAL ).
*****************************added 14-07-2026******************************************************************
*    DATA(ls_head) = VALUE #( lt_head[ 1 ]  OPTIONAL ).
***********************************************************************************************
    DATA(gt_keys) = keys.
    DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL  ).

***********************************************************************************************
    SELECT * FROM I_MaintNotificationItemTP_2 WITH PRIVILEGED ACCESS
        WHERE MaintenanceNotification = @ls_header-MaintenanceNotification
        INTO  TABLE @DATA(it_item).

    lt_item = CORRESPONDING #( it_item ).

    IF lt_item IS NOT INITIAL.
      	  SORT lt_item ASCENDING BY MaintenanceNotificationItem.
      	  DELETE FROM zmaint_ides_db WHERE MaintenanceNotification = @ls_header-MaintenanceNotification.
      	  MODIFY zmaint_ides_db FROM TABLE @lt_item.
    	  ENDIF.
    	
********************************added 14-07-2026***************************************************************
*     DATA: lt_operation TYPE TABLE OF I_MaintOrderOperationBasic,
*      ls_operation TYPE I_MaintOrderOperationBasic.
*
*      DATA:ls_item1 TYPE zmaint_itm_db.
*
*SELECT *
*  FROM I_MaintOrderOperationBasic
*  WITH PRIVILEGED ACCESS
*  WHERE MaintenanceOrder = @ls_head-MaintenanceOrder
*  INTO TABLE @lt_operation.
*
*IF lt_operation IS NOT INITIAL.
*
*  SORT lt_operation BY MaintenanceOrderOperation ASCENDING.
*
*  LOOP AT lt_operation INTO ls_operation.
*
*    ls_head-MaintenanceOrder          = ls_operation-MaintenanceOrder.
*    ls_item1-operationdescription     = ls_operation-OperationDescription.
*
*    APPEND ls_item1 TO zbp_maint_hdr_i=>gt_item1.
*      CLEAR:ls_operation.
*    ENDLOOP.
*
*
*
*ENDIF.




**********************************************************************

************************************************************************************************
    IF ls_header-maintenancenotification IS NOT INITIAL.

      TRY.
          "Initialize Template Store Client
          DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
           iv_name                  = 'ZADS_CS'
           iv_service_instance_name = 'ZADS_OUT_REST'
          ).

          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZMAINT_FORM_SD'
                                                                iv_root_node = 'ZMAINT_CUSENTITY' ) .

          DATA: printque TYPE c LENGTH 32.

          printque = 'ADOBE_DEFAULT'.

          TRY.
              lo_store->get_schema_by_name( iv_form_name = 'ZBREAKDOWN_FORM' ).
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

************************************************************************************************
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

**************************************************************************************************
          DATA(lt_keys)     = lo_fdp_util->get_keys( ).
          lt_keys[ name = 'MAINTENANCENOTIFICATION' ]-value = gt_hdr[ 1 ]-maintenancenotification.

**************************************************************************************************
          DATA(lt_xsd) = lo_fdp_util->get_xsd( ).

**************************************************************************************************
*                  "Convert the XSD File converstion for Form Purpose
          DATA(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

          TRY.
              DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
               DATA(lv_text1) = cl_web_http_utility=>decode_utf8( encoded = lv_xml ).
              "out->write( 'Service data retrieved' ).
            CATCH cx_fp_fdp_error INTO DATA(lo_exception).
          ENDTRY.

****************************************************************************************************
          DATA(ls_template) = lo_store->get_template_by_name(
               iv_get_binary    = abap_true
               iv_form_name     = 'ZBREAKDOWN_FORM'
               iv_template_name = 'ZBREAKDOWN_FORM_EIPL'
             ).
*****************************************************************************************************
          cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                              "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                        iv_xml_data     = lv_xml
                                                        iv_xdp_layout   = ls_template-xdp_template
                                                        is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                              IMPORTING
                                              " TODO: variable is assigned but never used (ABAP cleaner)
                                                        ev_trace_string = DATA(lv_trace)
                                                        ev_pdf          = DATA(lv_pdf) ).

**********************************************************************************************************
          DATA: lv_name TYPE c LENGTH 120.
          lv_name = |Maint-{ gt_hdr[ 1 ]-maintenancenotification }|.
*             DATA: lv_pdf TYPE xstring.

***********************************************************************************************************

          cl_print_queue_utils=>create_queue_item_by_data(
                      iv_qname            = printque
                      iv_print_data       = lv_pdf
                      iv_name_of_main_doc = lv_name
                      iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
                    ).

        CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
          " out->write( 'Exception occurred.' ).
      ENDTRY.

*************************************************************************************************************

      "out->write( 'Finished processing.' ).
      DATA: gt_att TYPE TABLE OF zmaint_table,
            gs_att TYPE zmaint_table.


****************************************************************************************************************
      IF lv_pdf IS NOT INITIAL.

        GET TIME STAMP FIELD DATA(ts).
        CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
        TRY.
            DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
          CATCH cx_abap_context_info_error.
            DATA(ls_x1) = 1.
        ENDTRY.
        DATA(lv_cbuser) = 'CB' && lv_user.

***************************************************************************************************************

        gs_att-maintenancenotification = ls_header-maintenancenotification.
        gs_att-attachment = lv_pdf.
        gs_att-filename = lv_name.
        gs_att-mimetype = 'application/pdf'.


        APPEND gs_att TO gt_att.
        zbp_maint_hdr_i=>upform = gt_att.
      ENDIF.
    ENDIF.

*****************************************************************************************************************

    result = VALUE #( FOR ls_ord IN lt_head
    (
      %tky   = ls_ord-%tky
      %param =  ls_ord ) ).


  ENDMETHOD.

  METHOD UpdateItem.

*************************************************************************************************
    DATA: gt_item TYPE TABLE FOR CREATE zmaint_hdr_i\_item,
          ls_itm  LIKE LINE OF gt_item.
**********************************************************************
    READ ENTITIES OF zmaint_hdr_i
    IN LOCAL MODE
    ENTITY zmaint_hdr_i
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).
**********************************************************************
    DATA(ls_hdr) = lt_hdr[ 1 ].

**********************************************************************
    SELECT * FROM I_MaintNotificationItemCauseTP AS Item
        WHERE Item~MaintenanceNotification = @ls_hdr-MaintenanceNotification
        INTO TABLE @DATA(lt_item).


**********************************************************************
    DATA:ls_item TYPE zmaint_itm_db.

    SORT lt_item ASCENDING BY MaintenanceNotificationCause.
**********************************************************************
"error message

     IF lt_item IS NOT INITIAL.
***********************************************************************

    LOOP AT lt_item INTO DATA(ls).
      ls_item-maintenancenotification = ls-MaintenanceNotification.
      ls_item-maintenancenotificationcause = ls-MaintenanceNotificationCause.
      ls_item-maintenancenotificationitem = ls-MaintenanceNotificationItem.
*    ls_item-maintenanceplanningplant = ls-maintenanceplanningplant.
      ls_item-maintnotificationcausecode = ls-maintnotificationcausecode.
      ls_item-maintnotifcausetext        = ls-MaintNotifCauseText.
*      ls_item-operationdescription    = ls_operation-OperationDescription.
      APPEND ls_item TO zbp_maint_hdr_i=>gt_item.
      CLEAR:ls.
    ENDLOOP.

***********************************************************************
     ELSE.
      APPEND VALUE #(
          %tky = ls_hdr-%tky
      ) TO failed-zmaint_hdr_i.

  APPEND VALUE #(
    %msg = new_message_with_text(
      severity = if_abap_behv_message=>severity-error
      text     = 'No data found in the item table.'
    )
  ) TO reported-zmaint_hdr_i.

  RETURN.
  ENDIF.
*******************************************************************

**********************************************************************
    result = VALUE #( FOR ls2 IN lt_hdr ( %tky = ls2-%tky
      %param = ls2 ) ).


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMAINT_HDR_I DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMAINT_HDR_I IMPLEMENTATION.

  METHOD save_modified.
**********************************************************************
*  IF zbp_maint_hdr_i=>GT_HDR IS NOT INITIAL.
**********************************************************************
    IF zbp_maint_hdr_i=>gt_item IS NOT INITIAL.
      MODIFY zmaint_itm_db FROM TABLE @zbp_maint_hdr_i=>gt_item.
    ENDIF.
*  ENDIF.

***************************added 14-07-2026*******************************************
*    IF zbp_maint_hdr_i=>gt_item1 IS NOT INITIAL.
*      MODIFY zmaint_itm_db FROM TABLE @zbp_maint_hdr_i=>gt_item1.
*    ENDIF.
**********************************************************************

**********************************************************************
    IF  zbp_maint_hdr_i=>upform IS NOT INITIAL.
      MODIFY zmaint_table FROM TABLE @zbp_maint_hdr_i=>upform.
    ENDIF.
***********************************************************************
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
