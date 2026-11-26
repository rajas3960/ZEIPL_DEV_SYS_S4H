CLASS lhc_zmainte_itm_i DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS url FOR DETERMINE ON SAVE
       keys FOR zmainte_itm_i~url.

ENDCLASS.

CLASS lhc_zmainte_itm_i IMPLEMENTATION.

  METHOD url.
************************************************************************
*    DATA : ls_item TYPE zmaint_item_db.
*    DATA : lt_itm TYPE TABLE OF zmaint_item_db.
    DATA : ls_item TYPE ZMAINT_IDB.
    DATA : lt_itm TYPE TABLE OF ZMAINT_IDB.
*************************************************************************
    READ ENTITIES OF zmainte_hdr_i IN LOCAL MODE
    ENTITY zmainte_itm_i
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(mt_item).
*************************************************************************
    IF mt_item IS INITIAL.
      RETURN.
    ENDIF.
************************************************************************
    LOOP AT mt_item INTO DATA(ms_item).
      IF ms_item-maintenancenotification IS INITIAL.
        CONTINUE.
      ENDIF.
**********************************************************************
      CLEAR ls_item.
      ls_item = CORRESPONDING #( ms_item ).
**********************************************************************
      APPEND
        ls_item TO lt_itm.
      zbp_mainte_hdr_i=>gt_itm = lt_itm.
**********************************************************************
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_ZMAINTE_HDR_I DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zmainte_hdr_i RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zmainte_hdr_i RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zmainte_hdr_i RESULT result.

    METHODS pdf FOR MODIFY
       keys FOR ACTION zmainte_hdr_i~pdf RESULT result.

    METHODS UpdateItem FOR MODIFY
       keys FOR ACTION zmainte_hdr_i~UpdateItem RESULT result.
    METHODS ExcelUpload FOR MODIFY
       keys FOR ACTION zmainte_hdr_i~ExcelUpload RESULT result.
    METHODS attachment FOR DETERMINE ON SAVE
       keys FOR zmainte_hdr_i~attachment.

ENDCLASS.

CLASS lhc_ZMAINTE_HDR_I IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD pdf.
***********************************************************************
    DATA: lt_upform TYPE TABLE OF zmaint_db,
          ls_upform TYPE zmaint_db,
          formtype  TYPE c LENGTH 50,
          lt_item   TYPE TABLE OF zmaint_itxt_db,
          ls_item   TYPE zmaint_itxt_db.
**********************************************************************
    READ ENTITIES OF zmainte_hdr_i IN LOCAL MODE
    ENTITY zmainte_hdr_i
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    ENTITY zmainte_hdr_i BY \_item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_hdr)
    FAILED FINAL(gt_failed).
**********************************************************************
    DATA(ls_header) = VALUE #( gt_hdr[ 1 ] OPTIONAL ).
**********************************************************************
    DATA(gt_keys) = keys.
    DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL  ).
**********************************************************************
    SELECT * FROM I_MaintNotificationItemTP_2 WITH PRIVILEGED ACCESS
       WHERE MaintenanceNotification = @ls_header-MaintenanceNotification
       INTO  TABLE @DATA(it_item).

    lt_item = CORRESPONDING #( it_item ).

    IF lt_item IS NOT INITIAL.
      SORT lt_item ASCENDING BY MaintenanceNotificationItem.
      DELETE FROM zmaint_itxt_db WHERE MaintenanceNotification = @ls_header-MaintenanceNotification.
      MODIFY zmaint_itxt_db FROM TABLE @lt_item.
    ENDIF.
**********************************************************************
    IF ls_header-maintenancenotification IS NOT INITIAL.

      TRY.
          "Initialize Template Store Client
          DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
           iv_name                  = 'ZADS_CS'
           iv_service_instance_name = 'ZADS_OUT_REST'
          ).

          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZMAINTE_FORM_SD'
                                                                iv_root_node = 'ZMAINTE_CE' ) .

          DATA: printque TYPE c LENGTH 32.

          printque = 'ADOBE_DEFAULT'.

          TRY.
              lo_store->get_schema_by_name( iv_form_name = 'ZPM_RCA_FORM' ).
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
          lt_keys[ name = 'MAINTENANCENOTIFICATION' ]-value = gt_hdr[ 1 ]-maintenancenotification.
**********************************************************************
          DATA(lt_xsd) = lo_fdp_util->get_xsd( ).
**********************************************************************
          "Convert the XSD File converstion for Form Purpose
          DATA(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

          TRY.
              DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
              DATA(lv_text1) = cl_web_http_utility=>decode_utf8( encoded = lv_xml ).
              "out->write( 'Service data retrieved' ).
            CATCH cx_fp_fdp_error INTO DATA(lo_exception).
          ENDTRY.
**********************************************************************
          DATA(ls_template) = lo_store->get_template_by_name(
                iv_get_binary    = abap_true
                iv_form_name     = 'ZPM_RCA_FORM'
                iv_template_name = 'ZRCA_FORM'
              ).
**********************************************************************
          cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                     "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                               iv_xml_data     = lv_xml
                                               iv_xdp_layout   = ls_template-xdp_template
                                               is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                     IMPORTING
                                     " TODO: variable is assigned but never used (ABAP cleaner)
                                               ev_trace_string = DATA(lv_trace)
                                               ev_pdf          = DATA(lv_pdf) ).
**********************************************************************
          DATA: lv_name TYPE c LENGTH 120.
          lv_name = |Maint-{ gt_hdr[ 1 ]-maintenancenotification }|.
*             DATA: lv_pdf TYPE xstring.
**********************************************************************
          cl_print_queue_utils=>create_queue_item_by_data(
                iv_qname            = printque
                iv_print_data       = lv_pdf
                iv_name_of_main_doc = lv_name
                iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
              ).

        CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
          " out->write( 'Exception occurred.' ).
      ENDTRY.
**********************************************************************
      "out->write( 'Finished processing.' ).
      DATA: gt_att TYPE TABLE OF zmaint_db,
            gs_att TYPE zmaint_db.
**********************************************************************
      IF lv_pdf IS NOT INITIAL.

        GET TIME STAMP FIELD DATA(ts).
        CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
        TRY.
            DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
          CATCH cx_abap_context_info_error.
            DATA(ls_x1) = 1.
        ENDTRY.
        DATA(lv_cbuser) = 'CB' && lv_user.
**********************************************************************
        gs_att-maintenancenotification = ls_header-maintenancenotification.
        gs_att-attachment = lv_pdf.
        gs_att-filename = lv_name.
        gs_att-mimetype = 'application/pdf'.


        APPEND gs_att TO gt_att.
        zbp_mainte_hdr_i=>upform = gt_att.
      ENDIF.
    ENDIF.
**********************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
       (
         %tky   = ls_ord-%tky
         %param =  ls_ord ) ).

***********************************************************************
  ENDMETHOD.

  METHOD UpdateItem.
*************************************************************************************************
    DATA: gt_item TYPE TABLE FOR CREATE zmainte_hdr_i\_item,
          ls_itm  LIKE LINE OF gt_item.
**********************************************************************
    READ ENTITIES OF zmainte_hdr_i
    IN LOCAL MODE
    ENTITY zmainte_hdr_i
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).
**********************************************************************
    DATA(ls_hdr) = lt_hdr[ 1 ].
**********************************************************************
    SELECT * FROM I_MaintNotificationItemCauseTP AS Item
        WHERE Item~MaintenanceNotification = @ls_hdr-MaintenanceNotification
        INTO TABLE @DATA(lt_item).
**********************************************************************

""new code added on 23.11.2026
TYPES: BEGIN OF ty_output,
         maintenance_notification     TYPE c LENGTH 12,
         maintenance_notificationitem TYPE c LENGTH 5,
         why1 TYPE c LENGTH 50,
         why2 TYPE c LENGTH 50,
         why3 TYPE c LENGTH 50,
         why4 TYPE c LENGTH 50,
         why5 TYPE c LENGTH 50,
       END OF ty_output.

DATA: lt_output TYPE STANDARD TABLE OF ty_output,
      ls_output TYPE ty_output.

DATA(lt_input) =  lt_item[].

SORT lt_input BY maintenancenotification
                 maintenancenotificationitem.

LOOP AT lt_input INTO DATA(ls_input)
     GROUP BY (
       notification = ls_input-maintenancenotification
       item         = ls_input-maintenancenotificationitem
     )
     INTO DATA(ls_group).

  CLEAR ls_output.

  ls_output-maintenance_notification = ls_group-notification.
  ls_output-maintenance_notificationitem = ls_group-item.

  LOOP AT GROUP ls_group INTO DATA(ls_row).

    CASE ls_row-maintnotificationcausecode.

      WHEN 'WHY1'.
        ls_output-why1 = ls_row-maintnotifcausetext.

      WHEN 'WHY2'.
        ls_output-why2 = ls_row-maintnotifcausetext.

      WHEN 'WHY3'.
        ls_output-why3 = ls_row-maintnotifcausetext.

      WHEN 'WHY4'.
        ls_output-why4 = ls_row-maintnotifcausetext.

      WHEN 'WHY5'.
        ls_output-why5 = ls_row-maintnotifcausetext.

    ENDCASE.

  ENDLOOP.

  APPEND ls_output TO lt_output.

ENDLOOP.

*    DATA:ls_item TYPE zmaint_item_db.

*    SORT lt_item ASCENDING BY MaintenanceNotificationCause.
***********************************************************************
*    IF lt_item IS NOT INITIAL.
***********************************************************************
*
*      LOOP AT lt_item INTO DATA(ls).
*        ls_item-maintenancenotification = ls-MaintenanceNotification.
*        ls_item-maintenancenotificationcause = ls-MaintenanceNotificationCause.
*        ls_item-maintenancenotificationitem = ls-MaintenanceNotificationItem.
*        ls_item-maintnotificationcausecode = ls-maintnotificationcausecode.
*        ls_item-maintnotifcausetext        = ls-MaintNotifCauseText.
*        APPEND ls_item TO zbp_mainte_hdr_i=>gt_item.
*        CLEAR:ls.
*      ENDLOOP.
*
***********************************************************************
*    ELSE.
*      APPEND VALUE #(
*          %tky = ls_hdr-%tky
*      ) TO failed-zmainte_hdr_i.
*
*      APPEND VALUE #(
*        %msg = new_message_with_text(
*          severity = if_abap_behv_message=>severity-error
*          text     = 'No data found in the item table.'
*        )
*      ) TO reported-zmainte_hdr_i.
*
*      RETURN.
*    ENDIF.

 DATA:ls_item TYPE ZMAINT_IDB.
 SORT lt_output ASCENDING BY maintenance_notificationitem.

    IF lt_output IS NOT INITIAL.
**********************************************************************

      LOOP AT lt_output INTO DATA(ls).
        ls_item-maintenancenotification = ls-maintenance_notification.
        ls_item-maintenancenotificationitem = ls-maintenance_notificationitem.
        ls_item-why1        = ls-why1.
        ls_item-why2        = ls-why2.
        ls_item-why3        = ls-why3.
        ls_item-why4        = ls-why4.
        ls_item-why5        = ls-why5.
        APPEND ls_item TO zbp_mainte_hdr_i=>tt_item.
        CLEAR:ls.
      ENDLOOP.

**********************************************************************
    ELSE.
      APPEND VALUE #(
          %tky = ls_hdr-%tky
      ) TO failed-zmainte_hdr_i.

      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'No data found in the item table.'
        )
      ) TO reported-zmainte_hdr_i.

      RETURN.
    ENDIF.

**********************************************************************
    result = VALUE #( FOR ls2 IN lt_hdr ( %tky = ls2-%tky
        %param = ls2 ) ).
**********************************************************************

  ENDMETHOD.

  METHOD ExcelUpload.
  ENDMETHOD.


  METHOD attachment.
**********************************************************************
    DATA: ls_header TYPE zmaint_hd.
    DATA: mt_hdr TYPE TABLE OF zmaint_hd.
**********************************************************************
    " READ ALL HEADER DATA
**********************************************************************
    READ ENTITIES OF zmainte_hdr_i
      IN LOCAL MODE
      ENTITY zmainte_hdr_i
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    IF lt_hdr IS INITIAL.
      RETURN.
    ENDIF.
**********************************************************************
    " LOOP HEADER DATA
**********************************************************************
    LOOP AT lt_hdr INTO DATA(ls_hdr).
      IF ls_hdr-MaintenanceNotification IS INITIAL.
        CONTINUE.
      ENDIF.
**********************************************************************
      "MAP ALL HEADER FIELDS
**********************************************************************
      CLEAR ls_header.
      ls_header = CORRESPONDING #( ls_hdr ).

      "Remove existing buffered header
      DELETE zbp_mainte_hdr_i=>mt_hdr
        WHERE maintenancenotification =
              ls_hdr-MaintenanceNotification.
**********************************************************************
      "Append complete header data
      APPEND
      ls_header TO mt_hdr.
      zbp_mainte_hdr_i=>mt_hdr = mt_hdr.
**********************************************************************
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZMAINTE_HDR_I DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.
CLASS lsc_ZMAINTE_HDR_I IMPLEMENTATION.

  METHOD save_modified.
***********************************************************************
    " PDF Part
    IF  zbp_mainte_hdr_i=>upform IS NOT INITIAL.
      MODIFY zmaint_db FROM TABLE @zbp_mainte_hdr_i=>upform.
    ENDIF.
**********************************************************************
    " Item Part
    IF zbp_mainte_hdr_i=>gt_item IS NOT INITIAL.
      MODIFY zmaint_item_db FROM TABLE @zbp_mainte_hdr_i=>gt_item.
    ENDIF.

    if zbp_mainte_hdr_i=>tt_item is NOT INITIAL.
      MODIFY ZMAINT_IDB FROM TABLE @zbp_mainte_hdr_i=>tt_item.
    ENDIF.
**********************************************************************
    " Upload part
    IF  zbp_mainte_hdr_i=>mt_hdr IS NOT INITIAL.
      MODIFY zmaint_hd FROM TABLE @zbp_mainte_hdr_i=>mt_hdr.
    ENDIF.
**********************************************************************
*  " URL part
    IF  zbp_mainte_hdr_i=>gt_itm IS NOT INITIAL.
*      MODIFY zmaint_item_db FROM TABLE @zbp_mainte_hdr_i=>gt_itm.      "old one
      MODIFY ZMAINT_IDB FROM TABLE @zbp_mainte_hdr_i=>gt_itm.       "new one
    ENDIF.
**********************************************************************

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
