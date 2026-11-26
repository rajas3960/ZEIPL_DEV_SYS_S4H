CLASS lhc_ZSD_I_GATEHEAD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsd_i_gatehead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zsd_i_gatehead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zsd_i_gatehead RESULT result.

    METHODS print FOR MODIFY
      IMPORTING keys FOR ACTION zsd_i_gatehead~print RESULT result.

    METHODS SalesOrder FOR MODIFY
      IMPORTING keys FOR ACTION zsd_i_gatehead~SalesOrder RESULT result.
    METHODS headmodify FOR DETERMINE ON SAVE
      IMPORTING keys FOR ZSD_I_GATEHEAD~headmodify.
    METHODS GateCheckIn FOR MODIFY
      IMPORTING keys FOR ACTION ZSD_I_GATEHEAD~GateCheckIn RESULT result.

ENDCLASS.

CLASS lhc_ZSD_I_GATEHEAD IMPLEMENTATION.

  METHOD get_instance_features.
**********************************************************************
        READ ENTITIES OF zsd_i_gatehead IN LOCAL MODE
        ENTITY zsd_i_gatehead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(gt_head)
        FAILED FINAL(gt_failed).
**********************************************************************
        data(gs_head) =   VALUE #( gt_head[ 1 ] OPTIONAL ).
**********************************************************************
        result = VALUE #( for ls_keys in keys
                        ( %tky = ls_keys-%tky

                        %action = VALUE #( GateCheckIn = COND #( WHEN gs_head-Gateentryno is not INITIAL
                                                                        or gs_head-Gateentryid is INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )
                                           SalesOrder = COND #( when gs_head-Gateentryno is not INITIAL
                                                then if_abap_behv=>fc-o-enabled
                                                ELSE if_abap_behv=>fc-o-disabled ) )

                                                 ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD print.
********************************************************************

*        select * from I_MAINTNOTIFICATIONITEMCAUSETP WITH PRIVILEGED ACCESS
*        into table @data(test).


*        data: lt_upform type table of ZSD_GATE_HTB,
*              ls_upform type ZSD_GATE_HTB.
*******************************************************************
*        READ ENTITIES OF zsd_i_gatehead IN LOCAL MODE
*        ENTITY zsd_i_gatehead
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT FINAL(gt_head)
*        FAILED FINAL(gt_failed).
*********************************************************************
*        DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
**        DATA(gt_keys) = keys.
**        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
*********************************************************************
**        formtype = gs_keys-%param-FormType.
*********************************************************************
*
*        if ls_header-Uuid is not INITIAL.
*
*        TRY.
*            "Initialize Template Store Client
*            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
*             iv_name                  = 'ZADS_CS'
*             iv_service_instance_name = 'ZADS_OUT_REST'
*            ).
*
*            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZSD_FORM_SD'
*                                                                  iv_root_node = 'ZHEAD_FORM_CE' ) .
*
*            data: printque type c LENGTH 32.
*
*              printque = 'ADOBE_DEFAULT'.
*
*            TRY.
*                lo_store->get_schema_by_name( iv_form_name = 'ZTEST' ).
*                "   out->write( 'Schema found in form' ).
*              CATCH zcx_fp_tmpl_store_error INTO DATA(lo_tmpl_error).
*                "  out->write( 'No schema in form found' ).
*                IF lo_tmpl_error->mv_http_status_code = 404 OR lo_tmpl_error->mv_http_status_code = 403 .
*                  "Upload service definition
**                  lo_store->set_schema(
**                    iv_form_name = 'GATEFORM'
**                    is_data      = VALUE #( note = '' schema_name = 'schema' xsd_schema = lo_fdp_util->get_xsd( ) )
**                  ).
*                ELSE.
*
*                ENDIF.
*            ENDTRY.
***********************************************************************
*              TYPES: BEGIN OF ty_schema_body,
*                 xsd_schema  TYPE xstring,
*                 schema_name TYPE c LENGTH 30,
*                 note        TYPE c LENGTH 280,
*               END OF ty_schema_body.
*
*        " TODO: variable is assigned but never used (ABAP cleaner)
*        DATA lv_xdp TYPE ty_schema_body.
*        lv_xdp = VALUE #( note        = ''
*                          schema_name = 'schema'
*                          xsd_schema  = lo_fdp_util->get_xsd( ) ).
***********************************************************************
*
*            DATA(lt_keys)     = lo_fdp_util->get_keys( ).
*            lt_keys[ name = 'UUID' ]-value = gt_head[ 1 ]-Uuid.
***********************************************************************
*            data(lt_xsd) = lo_fdp_util->get_xsd( ).
***********************************************************************
*            "Convert the XSD File converstion for Form Purpose
*             data(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).
***********************************************************************
*            TRY.
*                DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
*                "out->write( 'Service data retrieved' ).
*              CATCH cx_fp_fdp_error INTO DATA(lo_exception).
*            ENDTRY..
*
*
********************************************************************
*            DATA(ls_template) = lo_store->get_template_by_name(
*              iv_get_binary    = abap_true
*              iv_form_name     = 'ZTEST'
*              iv_template_name = 'TEST'
*            ).
******************************************************************************
*            cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
*                                       "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
*                                                 iv_xml_data     = lv_xml
*                                                 iv_xdp_layout   = ls_template-xdp_template
*                                                 is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
*                                       IMPORTING
*                                       " TODO: variable is assigned but never used (ABAP cleaner)
*                                                 ev_trace_string = DATA(lv_trace)
*                                                 ev_pdf          = DATA(lv_pdf) ).
******************************************************************************
*            DATA: lv_name TYPE c LENGTH 120.
*            lv_name = |Form-{ gt_head[ 1 ]-Uuid }|.
******************************************************************************
*            cl_print_queue_utils=>create_queue_item_by_data(
*              iv_qname            = printque
*              iv_print_data       = lv_pdf
*              iv_name_of_main_doc = lv_name
*              iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
*            ).
*
*          CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
*            " out->write( 'Exception occurred.' ).
*        ENDTRY.
******************************************************************************
*        "out->write( 'Finished processing.' ).
*          data: gt_att type table of ZSD_GATE_HTB,
*                gs_att type ZSD_GATE_HTB.
******************************************************************************
*                if lv_pdf is not iNITIAL.
*
*                 GET TIME STAMP FIELD DATA(ts).
*                    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
*                TRY.
*                    DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
*                CATCH cx_abap_context_info_error.
*                DATA(ls_x1) = 1.
*                ENDTRY.
*                    DATA(lv_cbuser) = 'CB' && lv_user.
*
******************************************************************************
*                    movE-CORRESPONDING ls_header to gs_att.
*
*                    gs_att-attachment = lv_pdf.
*                    gs_att-filename = lv_name.
*                    gs_att-mimetype = 'application/pdf'.
*
*                 APPEND gs_att to gt_att.
*                 zbp_sd_i_gatehead=>upform = gt_att.
*                endif.
*
*        endif.
***********************************************************************
*    result = VALUE #( FOR ls_ord IN gt_head
*                         ( %tky   = ls_ord-%tky
*                           %param = ls_ord ) ).
*
*
*
*
  ENDMETHOD.

  METHOD SalesOrder.
***********************************************************************
            data: lv_cus type ZSD_GATE_SHTB-customer,
                  lv_so type ZSD_GATE_SHTB-salesdocument,
                  lv_soitem type ZSD_GATE_SITB-salesitem.
***********************************************************************
            READ ENTITIES OF zsd_i_gatehead IN LOCAL MODE
            ENTITY zsd_i_gatehead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_head)
            fAILED FINAL(gt_failed).

*******************************************************************
        DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
        DATA(gt_keys) = keys.
        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
        lv_cus = gs_keys-%param-Customer.
        lv_so = gs_keys-%param-Salesdocument.
        lv_soitem = gs_keys-%param-SalesDocumentItem.
*******************************************************************

                select single salesdocument,gateentryno from ZSD_GATE_SHTB with PRIVILEGED ACCESS
                where salesdocument = @lv_so
                into @DATA(wa_salesdb).

                select single salesdocument, salesitem from zsd_gate_sitb WITH PRIVILEGED ACCESS
                where salesdocument = @lv_so
                and salesitem = @lv_soitem
                into @DATA(wa_salesitemdb).
*******************************************************************
        if lv_so is not INITIAL and lv_soitem is not INITIAL.

                select a~salesdocument,
                        a~soldtoparty,
                        b~CustomerName
                        from i_salesdocument as a
                        inner join i_customer as b on a~soldtoparty = b~customer
                        where a~salesdocument = @lv_so
                        into TABLE @DATA(lt_so).
*******************************************************************
                 select  a~SalesDocument,
                                a~SalesDocumentItem,
                                a~plant,
                                a~Product,
                                a~Batch,
                                a~OrderQuantity,
                                a~BaseUnit,
                                b~PlantName,
                                c~ProductName
                                from I_SalesDocumentItem as a
                                LEFT OUTER JOIN I_Plant as b on a~Plant = b~Plant
                                LEFT OUTER JOIN I_ProductText as c on a~Product = c~Product
                                where a~SalesDocument = @lv_so
                                and a~SalesDocumentItem = @lv_soitem
                                into table @data(lt_soitem).
        endif.
*******************************************************************
        if lt_so is not INITIAL and wa_salesdb-salesdocument is INITIAL
                        and wa_salesitemdb-salesitem is INITIAL.

                MODIFY ENTITIES OF zsd_i_gatehead IN LOCAL MODE
                ENTITY zsd_i_gatehead
                CREATE BY \_SalesHead
                AUTO FILL CID
                FIELDS ( salesdocument gateentryno companycode customer customername )
                WITH VALUE #(  for ls_head in gt_head
                               (
                                    %is_draft = ls_head-%is_draft
                                    %key =  CORRESPONDING #( ls_head )
                                    %target = VALUE #( for ls_so in lt_so INDEX INTO iv_idx
                                                   (
                                                     %cid = |CID{ iv_idx }|
                                                     Salesdocument = lv_so
                                                     Gateentryno = ls_head-Gateentryno
                                                     Companycode = ls_head-Companycode
                                                     Customer = ls_so-SoldToParty
                                                     Customername = ls_so-CustomerName
                                                     ) )
                                                     ) )

                CREATE BY \_SalesItem
                AUTO FILL CID
                FIELDS ( Salesdocument Salesitem Gateentryno Plant
                        Plantname Material Materialdesc Baseunit Batch Quantity )
                WITH VALUE #( for ls_head in gt_head
                                (  %is_draft = ls_head-%is_draft
                                    %key =  CORRESPONDING #( ls_head )

                                   %target = VALUE #( for ls_poitem in lt_soitem
                                    ( %cid = |CID{ ls_poitem-SalesDocumentItem }|

                                       Salesdocument = ls_poitem-SalesDocument
                                       Salesitem = ls_poitem-SalesDocumentItem
                                       Gateentryno = ls_head-Gateentryno
                                       Plant = ls_poitem-Plant
                                       Plantname = ls_poitem-PlantName
                                       Material = ls_poitem-Product
                                       materialdesc = ls_poitem-ProductName
                                       batch = ls_poitem-Batch
                                       baseunit = ls_poitem-BaseUnit
                                       quantity = ls_poitem-OrderQuantity ) )
                                    ) )


                        REPORTED reported
                        failed failed
                        MAPPED mapped.
*******************************************************************
                elseif wa_salesdb-salesdocument is not INITIAL and wa_salesitemdb-salesitem is INITIAL.

                MODIFY ENTITIES OF zsd_i_gatehead IN LOCAL MODE
                ENTITY zsd_i_gatehead
                CREATE BY \_SalesItem
                AUTO FILL CID
                FIELDS ( Salesdocument Salesitem Gateentryno Plant
                        Plantname Material Materialdesc Baseunit Batch Quantity )
                WITH VALUE #( for ls_head in gt_head
                                (  %is_draft = ls_head-%is_draft
                                    %key =  CORRESPONDING #( ls_head )
                                   %target = VALUE #( for ls_poitem in lt_soitem
                                    ( %cid = |CID{ ls_poitem-SalesDocumentItem }|
                                       Salesdocument = ls_poitem-SalesDocument
                                       Salesitem = ls_poitem-SalesDocumentItem
                                       Gateentryno = ls_head-Gateentryno
                                       Plant = ls_poitem-Plant
                                       Plantname = ls_poitem-PlantName
                                       Material = ls_poitem-Product
                                       materialdesc = ls_poitem-ProductName
                                       batch = ls_poitem-Batch
                                       baseunit = ls_poitem-BaseUnit
                                       quantity = ls_poitem-OrderQuantity ) )
                                    ) )
                          REPORTED reported
                          fAILED failed
                          MAPPED mapped.
********************************************************************
        else.
              data(lv_msg) = |Order Already Exists-{ wa_salesdb-gateentryno }|.
              APPEND VALUE #( %tky = ls_header-%tky ) TO failed-zsd_i_gatehead.
              APPEND VALUE #( %tky = ls_header-%tky
              %state_area = 'Validate_Head'
              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = lv_msg )
                               ) TO reported-zsd_i_gatehead.
        endif.

***********************************************************************

            READ ENTITIES OF zsd_i_gatehead IN LOCAL MODE
            ENTITY zsd_i_gatehead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_sohead)
            fAILED FINAL(gt_sofailed).

    result = VALUE #( FOR ls_ord IN gt_sohead
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD headmodify.
***********************************************************************
        data: seqno type ZSD_GATE_HTB-gateentrysequence,
              gateno type ZSD_GATE_HTB-gateentryno,
              sydate type ZSD_GATE_HTB-gateentrydate,
              gateid type ZSD_GATE_HTB-gateentryid.
***********************************************************************
        READ ENTITIES OF zsd_i_gatehead IN LOCAL MODE
        ENTITY zsd_i_gatehead
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
                    select SINGLE value_low,text from ZGATE_TYPE_VH WITH PRIVILEGED ACCESS
                    where value_low = @<fs_head>-Gateentrytype
                    into @DATA(gs_gatetype).
               endif.
***********************************************************************
        SELECT SINGLE MAX( gateentryid ) AS gateentryid
            FROM zsd_gate_htb
            INTO @DATA(gs_id).

        if gs_id is not INITIAL.
            gateid = gs_id + 1.
         else.
            gateid = '1000000001'.
        endif.

************************************************************************
           MODIFY ENTITIES OF zsd_i_gatehead IN LOCAL MODE
           ENTITY zsd_i_gatehead
           UPDATE
           FIELDS ( Gateentryid Gateentryiddate Gateentrytypetext )
           WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         Gateentryid = gateid
                         Gateentryiddate = lv_date
                         Gateentrytypetext = gs_gatetype-text

                         %control-Gateentryid = if_abap_behv=>mk-on
                         %control-Gateentryiddate = if_abap_behv=>mk-on
                         %control-Gateentrytypetext = if_abap_behv=>mk-on
                         ) ).
************************************************************************

            endif.
        ENDLOOP.

  ENDMETHOD.

  METHOD GateCheckIn.
***********************************************************************
        data: seqno type ZSD_GATE_HTB-gateentrysequence,
              gateno type ZSD_GATE_HTB-gateentryno,
              sydate type ZSD_GATE_HTB-gateentrydate.
***********************************************************************
        READ ENTITIES OF zsd_i_gatehead IN LOCAL MODE
        ENTITY zsd_i_gatehead
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
        SELECT SINGLE MAX( gateentrysequence ) AS gateentrysequence,
              gateentrydate
            FROM zsd_gate_htb
            WHERE gateentrydate = @lv_date
            GROUP BY gateentrydate
            INTO @DATA(gs_seqno).
***********************************************************************
            if sy-subrc = 0 and gs_seqno-gateentrysequence is not INITIAL.
                seqno = gs_seqno-gateentrysequence + 1.
                gateno = |{ <fs_head>-Gateentrytype }{ lv_date }-{ seqno }|.
            else.
                seqno = '001'.
                gateno = |{ <fs_head>-Gateentrytype }{ lv_date }-{ seqno }|.
            endif.

***********************************************************************
           MODIFY ENTITIES OF zsd_i_gatehead IN LOCAL MODE
           ENTITY zsd_i_gatehead
           UPDATE
           FIELDS ( Gateentryno Gateentrysequence Gateentrydate Gateentrytime )
           WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         gateentryno = gateno
                         gateentrysequence = seqno
                         gateentrydate = lv_date
                         gateentrytime = lv_time
                         %control-Gateentryno = if_abap_behv=>mk-on
                         %control-Gateentrysequence = if_abap_behv=>mk-on
                         %control-Gateentrydate = if_abap_behv=>mk-on
                         %control-Gateentrytime = if_abap_behv=>mk-on
                         ) ).
***********************************************************************
            endif.
        ENDLOOP.
***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEHEAD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsd_i_sgatehead RESULT result.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEHEAD IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsd_i_sgateitem RESULT result.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEITEM IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZSD_I_GATEHEAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSD_I_GATEHEAD IMPLEMENTATION.

  METHOD save_modified.
*        if zbp_sd_i_gatehead=>upform is not INITIAL.
*            moDIFY ZSD_GATE_HTB FROM TABLE @zbp_sd_i_gatehead=>upform.
*        endIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
