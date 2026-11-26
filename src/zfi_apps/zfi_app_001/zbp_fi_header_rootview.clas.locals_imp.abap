CLASS lhc_zfi_item_rootview DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zfi_item_rootview RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zfi_item_rootview RESULT result.

    METHODS MatdesInput FOR MODIFY
       keys FOR ACTION zfi_item_rootview~MatdesInput RESULT result.

ENDCLASS.

CLASS lhc_zfi_item_rootview IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD MatdesInput.

************************************************************************
    READ ENTITIES OF zfi_header_rootview IN LOCAL MODE
       ENTITY Head
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_head)
       ENTITY zfi_item_rootview
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_item)
       FAILED DATA(lt_failed).
**********************************************************************
    DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
    SORT lt_item ASCENDING BY CompanyCode FiscalYear AccountingDocument LedgerGLLineItem.
    DATA(gt_keys) = keys.
    DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
    DATA: lv_text TYPE c LENGTH 40,
          lv_hsn  TYPE c LENGTH 10,
          lv_qty  TYPE p LENGTH 7 DECIMALS 3,
          lv_unit TYPE c LENGTH 3,
          lv_rate TYPE p LENGTH 8 DECIMALS 2.

    DATA: up_item  TYPE TABLE OF zfi_matdes_db,
          ups_item TYPE zfi_matdes_db.
**********************************************************************
    lv_text = gs_keys-%param-purchaseorderitemtext.
    lv_hsn  = gs_keys-%param-hsncode.
    lv_qty  = gs_keys-%param-quantity.
    lv_unit = gs_keys-%param-baseunit.
    lv_rate = gs_keys-%param-rate.
**********************************************************************

    LOOP AT lt_item INTO DATA(ls_item).
    CLEAR ups_item.

    ups_item-accountingdocument = ls_item-accountingdocument.
    ups_item-fiscalyear        = ls_item-fiscalyear.
    ups_item-companycode       = ls_item-companycode.
    ups_item-ledgergllineitem  = ls_item-ledgergllineitem.
    ups_item-purchaseorderitemtext = lv_text.
    ups_item-hsncode = lv_hsn.
    ups_item-quantity = lv_qty.
    ups_item-baseunit = lv_unit.
    ups_item-rate = lv_rate.

    APPEND ups_item TO up_item.
    zbp_fi_header_rootview=>upform2 = up_item.

   ENDLOOP.		

    result = VALUE #( FOR ls_ord IN lt_item
            ( %tky   = ls_ord-%tky
              %param = ls_ord ) ).

************************************************************************

    ENDMETHOD.

ENDCLASS.

CLASS lhc_Head DEFINITION INHERITING FROM cl_abap_behavior_handler.
PRIVATE SECTION.

  METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
    IMPORTING keys REQUEST requested_authorizations FOR Head RESULT result.

  METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
    IMPORTING REQUEST requested_authorizations FOR Head RESULT result.
  METHODS get_instance_features FOR INSTANCE FEATURES
    IMPORTING keys REQUEST requested_features FOR Head RESULT result.

  METHODS pdf FOR MODIFY
    IMPORTING keys FOR ACTION Head~pdf RESULT result.

ENDCLASS.

CLASS lhc_Head IMPLEMENTATION.

METHOD get_instance_authorizations.
ENDMETHOD.

METHOD get_global_authorizations.
ENDMETHOD.

METHOD get_instance_features.
ENDMETHOD.

METHOD pdf.

***********************************************************************************************
  DATA: lt_upform TYPE TABLE OF zfi_debitnote_db,
        ls_upform TYPE zfi_debitnote_db,
        formtype  TYPE c LENGTH 50.
**********************************************************************************************
  READ ENTITIES OF zfi_header_rootview IN LOCAL MODE ENTITY Head
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT FINAL(gt_head)
  FAILED FINAL(gt_failed).
**************************************************************************************************
  DATA(ls_header) = VALUE #( gt_head[ 1 ] OPTIONAL ).
  DATA(gt_keys) = keys.
  DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
**************************************************************************************************
  IF ls_header-AccountingDocument IS NOT INITIAL.

    TRY.
        "Initialize Template Store Client
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
         iv_name                  = 'ZADS_CS'
         iv_service_instance_name = 'ZADS_OUT_REST'
        ).

        DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZFI_DEBIT_FORM_SD_NEW'
                                                              iv_root_node = 'ZFI_FORM_OUTPUT' ) .

        DATA: printque TYPE c LENGTH 32.

        printque = 'ADOBE_DEFAULT'.

        TRY.
            lo_store->get_schema_by_name( iv_form_name = 'ZDEBIT_NOTE' ).
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
****************************************************************************************************************
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
***********************************************************************************************************
        DATA(lt_keys)     = lo_fdp_util->get_keys( ).
        lt_keys[ name = 'ACCOUNTINGDOCUMENT' ]-value = gt_head[ 1 ]-AccountingDocument.
        lt_keys[ name = 'FISCALYEAR' ]-value = gt_head[ 1 ]-FiscalYear.
        lt_keys[ name = 'COMPANYCODE' ]-value = gt_head[ 1 ]-CompanyCode.
*******************************************************************************************************************
        DATA(lt_xsd) = lo_fdp_util->get_xsd( ).
*****************************************************************************************************************
*               *           "Convert the XSD File converstion for Form Purpose
        DATA(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

        TRY.
            DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
            DATA(lv_text1) = cl_web_http_utility=>decode_utf8( encoded = lv_xml ).
            "out->write( 'Service data retrieved' ).
          CATCH cx_fp_fdp_error INTO DATA(lx_error).
                DATA(lv_error_text) = lx_error->get_text( ).
*                INTO DATA(lo_exception).
        ENDTRY.
**************************************************************************************************************
        DATA(ls_template) = lo_store->get_template_by_name(
             iv_get_binary    = abap_true
             iv_form_name     = 'ZDEBIT_NOTE'
             iv_template_name = 'ZDEBIT_NOTE_EIPL'
           ).
**************************************************************************
        cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                         "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                   iv_xml_data     = lv_xml
                                                   iv_xdp_layout   = ls_template-xdp_template
                                                   is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                         IMPORTING
                                         " TODO: variable is assigned but never used (ABAP cleaner)
                                                   ev_trace_string = DATA(lv_trace)
                                                   ev_pdf          = DATA(lv_pdf) ).




********************************************************************************************************************
        DATA: lv_name TYPE c LENGTH 120.
        lv_name = |Debit-{ gt_head[ 1 ]-AccountingDocument }|.
*             DATA: lv_pdf TYPE xstring.
***************************************************************************************************************************
        cl_print_queue_utils=>create_queue_item_by_data(
          iv_qname            = printque
          iv_print_data       = lv_pdf
          iv_name_of_main_doc = lv_name
          iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
        ).

      CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util INTO DATA(lv_error).
        DATA(lv_error_text1) = lv_error->get_text( ).
        " out->write( 'Exception occurred.' ).
    ENDTRY.
***************************************************************************************************************************
    "out->write( 'Finished processing.' ).
    DATA: gt_att TYPE TABLE OF zfi_debitnote_db,
          gs_att TYPE zfi_debitnote_db.
***************************************************************************************************************************
    IF lv_pdf IS NOT INITIAL.

      GET TIME STAMP FIELD DATA(ts).
      CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
      TRY.
          DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
        CATCH cx_abap_context_info_error.
          DATA(ls_x1) = 1.
      ENDTRY.
      DATA(lv_cbuser) = 'CB' && lv_user.
**************************************************************************************************************************
      gs_att-accountingdocument = ls_header-AccountingDocument.
      gs_att-fiscalyear = ls_header-FiscalYear.
      gs_att-companycode = ls_header-CompanyCode.
      gs_att-accountingdocumenttype = ls_header-AccountingDocumentType.

      gs_att-createdby = lv_cbuser.
      gs_att-createdat = lv_time.
      gs_att-attachment = lv_pdf.
      gs_att-filename = lv_name.
      gs_att-mimetype = 'application/pdf'.

      APPEND gs_att TO gt_att.
      zbp_fi_header_rootview=>upform = gt_att.
    ENDIF.

  ENDIF.
*********************************************************************************************************************
  result = VALUE #( FOR ls_ord IN gt_head
            ( %tky   = ls_ord-%tky
              %param = ls_ord ) ).


ENDMETHOD.

ENDCLASS.

CLASS lsc_ZFI_HEADER_ROOTVIEW DEFINITION INHERITING FROM cl_abap_behavior_saver.
PROTECTED SECTION.

  METHODS save_modified REDEFINITION.

  METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZFI_HEADER_ROOTVIEW IMPLEMENTATION.

METHOD save_modified.
*****************************************************************************************************************
  IF  zbp_fi_header_rootview=>upform IS NOT INITIAL.
    MODIFY zfi_debitnote_db FROM TABLE @zbp_fi_header_rootview=>upform.
  ENDIF.
******************************************************************************************************************
  IF  zbp_fi_header_rootview=>upform2 IS NOT INITIAL.
    MODIFY ZFI_MATDES_DB FROM TABLE @zbp_fi_header_rootview=>upform2.
  ENDIF.

ENDMETHOD.

METHOD cleanup_finalize.
ENDMETHOD.

ENDCLASS.
