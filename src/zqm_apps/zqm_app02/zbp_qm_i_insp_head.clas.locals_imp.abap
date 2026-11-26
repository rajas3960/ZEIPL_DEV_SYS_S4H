CLASS lhc_InspHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR InspHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR InspHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR InspHead RESULT result.
    METHODS updateresult FOR MODIFY
      IMPORTING keys FOR ACTION InspHead~updateresult RESULT result.
    METHODS Createresult FOR MODIFY
      IMPORTING keys FOR ACTION InspHead~Createresult RESULT result.
    METHODS UpdateUD FOR MODIFY
      IMPORTING keys FOR ACTION InspHead~UpdateUD RESULT result.
    METHODS PostInvoice FOR MODIFY
      IMPORTING keys FOR ACTION InspHead~PostInvoice RESULT result.
    METHODS UpInsp FOR MODIFY
      IMPORTING keys FOR ACTION InspHead~UpInsp RESULT result.

ENDCLASS.

CLASS lhc_InspHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF ZQM_I_INSP_HEAD IN LOCAL MODE
            ENTITY InspHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
******************************************************************
        result = VALUE #( for ls_key in keys
                     ( %tky = ls_key-%tky

                     %action = VALUE #( Createresult = COND #( WHEN ls_head-Createindicator  is not INITIAL or ls_head-Inspindicator is INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                                       updateresult = COND #(
                                                when ls_head-Updateindicator is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                WHEN ls_head-Createindicator is NOT INITIAL
                                                then if_abap_behv=>fc-o-enabled
                                                ELSE if_abap_behv=>fc-o-disabled )

                                       UpdateUD = COND #( WHEN ls_head-Udcodeindicator is not INITIAL
                                                            then if_abap_behv=>fc-o-disabled
                                                          when ls_head-Createindicator is not INITIAL
                                                                and ls_head-Updateindicator is NOT INITIAL
                                                then if_abap_behv=>fc-o-enabled
                                                ELSE if_abap_behv=>fc-o-disabled )

                                       PostInvoice = COND #( when ls_head-Postinvoiceflag is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                WHEN ( ls_head-Createindicator is INITIAL and ls_head-Updateindicator is INITIAL
                                                            and ls_head-Udcodeindicator is INITIAL )
                                                            then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )

                                       UpInsp = COND #( when ls_head-Inspindicator is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )

                                        Edit = COND #( WHEN ls_head-Postinvoiceflag  is not INITIAL or ls_head-Inspindicator is INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled ) )


                                         ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD updateresult.
*****************************************************************************
            READ ENTITIES OF zqm_i_insp_head IN LOCAL MODE
            ENTITY InspHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY InspHead BY \_InspResult
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************
            DATA(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
*****************************************************************************
            sort lt_inspresult ASCENDING BY Boocharacteristic.

            if lt_inspresult is NOT INITIAL.

            MODIFY ENTITY i_inspectionresulttp_2
              UPDATE
              FIELDS (
                        InspectionResultStatus
                        InspectionResultMeanValue
                        InspectionValuationResult
                        InspectionResultHasMeanValue
                        InspectionResultOriginalValue
                        InspResultValidValuesNumber
                      )
              WITH VALUE #(
                          FOR ls_inspresult IN lt_inspresult
                            (
                          inspectionlot               = ls_inspresult-Inspectionlot
                          inspplanoperationinternalid = ls_inspresult-Booperationid
                          inspectioncharacteristic    = ls_inspresult-Boocharacteristic
                          InspectionResultStatus      = '5'
                          InspectionResultMeanValue   = ls_inspresult-Inspresultmeanvalue
                          InspectionResultOriginalValue = ls_inspresult-Inspresultoriginalvalue
                          InspectionValuationResult   = 'A'

                          InspResultValidValuesNumber = '1'
                          InspectionResultHasMeanValue = 'X'
                        )
                      )
              MAPPED DATA(gs_mapped)
              FAILED   DATA(gs_failed)
              REPORTED DATA(gs_reported).

              if gs_failed-inspectionresult is INITIAL.
                MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                ENTITY InspHead
                UPDATE
                FIELDS ( updateindicator )
                WITH VALUE #( for key in keys
                             ( %tky = ls_head-%tky
                             updateindicator = 'X'
                             %control-updateindicator = if_abap_behv=>mk-on

                             ) ).

            data(lv_success_msg) = |Result Updated successfully.|.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-insphead .
              ENDIF.
            ENDIF.

*******************************************************************
    result = VALUE #( FOR ls_hd IN lt_insphead
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************

  ENDMETHOD.

  METHOD Createresult.
*****************************************************************************
            READ ENTITIES OF zqm_i_insp_head IN LOCAL MODE
            ENTITY InspHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY InspHead BY \_InspResult
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************
            data(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
*****************************************************************************
            sort lt_inspresult ASCENDING BY Boocharacteristic.

            if lt_inspresult is not INITIAL.

            MODIFY ENTITIES OF i_inspectionlottp_2
            FORWARDING PRIVILEGED
            ENTITY InspectionCharacteristic
            CREATE BY \_InspectionResult
                FIELDS ( inspectionresultstatus  )

            WITH VALUE #(
                          FOR ls_inspresult IN lt_inspresult INDEX INTO lv_index
                          (
                            InspectionLot               = ls_inspresult-InspectionLot
                            InspPlanOperationInternalID = ls_inspresult-BoOperationID
                            InspectionCharacteristic    = ls_inspresult-BooCharacteristic

                        %target = VALUE #(
                                          (
                            %cid = |CID{ lv_index }|
                            InspectionLot               = ls_inspresult-InspectionLot
                            InspPlanOperationInternalID = ls_inspresult-BoOperationID
                            InspectionCharacteristic    = ls_inspresult-BooCharacteristic
                            inspectionresultstatus  = '2'
                          )
                            )
                          )
                        )
            FAILED   DATA(ls_failed)
            MAPPED   DATA(ls_mapped)
            REPORTED DATA(ls_reported).


            if ls_mapped-inspectionresult is NOT INITIAL.


                MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                ENTITY InspHead
                UPDATE
                FIELDS ( Createindicator )
                WITH VALUE #( for key in keys
                             ( %tky = ls_head-%tky
                             Createindicator = 'X'
                             %control-Createindicator = if_abap_behv=>mk-on

                             ) ).

            data(lv_success_msg) = |created successfully.|.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-insphead .

            ENDIF.

              ENDIF.
*******************************************************************
    result = VALUE #( FOR ls_hd IN lt_insphead
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************
  ENDMETHOD.

  METHOD UpdateUD.
*****************************************************************************
            READ ENTITIES OF zqm_i_insp_head IN LOCAL MODE
            ENTITY InspHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY InspHead BY \_InspResult
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************
            DATA(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
*******************************************************************
            select SINGLE value_low,text FROM ZQM_UD_VH WITH PRIVILEGED ACCESS
            where value_low = @gs_keys-%param-Usagedecisioncode
            INTO @DATA(ls_ud).

            LOOP at lt_insphead ASSIGNING FIELD-SYMBOL(<ls_insphead>).
            if <ls_insphead> is ASSIGNED.

                MODIFY ENTITY I_InspectionLotTP_2
                  EXECUTE RecordUsageDecision
                  FROM VALUE #(
                      ( %key-inspectionlot = <ls_insphead>-Inspectionlot
                        %param-selectedcodesetplant = <ls_insphead>-Plant
                        %param-%control-selectedcodesetplant = if_abap_behv=>mk-on
                        %param-insplotusgedcsnselectedset = 'ZUD01'
                        %param-%control-insplotusgedcsnselectedset = if_abap_behv=>mk-on
                        %param-insplotusagedecisioncodegroup = 'ZUD01'
                        %param-%control-insplotusagedecisioncodegroup = if_abap_behv=>mk-on
                        %param-inspectionlotusagedecisioncode = gs_keys-%param-Usagedecisioncode
                        %param-%control-inspectionlotusagedecisioncode = if_abap_behv=>mk-on
*                        %param-insplotiscompletionforced = 'X'
*                        %param-%control-insplotiscompletionforced = if_abap_behv=>mk-on
                        )
                      )
              RESULT   DATA(ls_result)
              FAILED   DATA(ls_failed)
              REPORTED DATA(ls_reported).


              if ls_result is not INITIAL.
                MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                ENTITY InspHead
                UPDATE
                FIELDS ( Udcodeindicator Usagedecisioncode Usagedecisiontext )
                WITH VALUE #( for key in keys
                             ( %tky = ls_head-%tky
                             Udcodeindicator = 'X'
                             Usagedecisioncode = gs_keys-%param-Usagedecisioncode
                             usagedecisiontext = ls_ud-text
                             %control-Udcodeindicator = if_abap_behv=>mk-on
                             %control-Usagedecisioncode = if_abap_behv=>mk-on
                             %control-Usagedecisiontext = if_abap_behv=>mk-on
                             ) ).

            data(lv_success_msg) = |Usage Decision Completed.|.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-insphead .
              ENDIF.

            ENDIF.
            ENDLOOP.
*******************************************************************
    result = VALUE #( FOR ls_hd IN lt_insphead
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************
  ENDMETHOD.

  METHOD PostInvoice.
*********************************************************************
                READ ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                ENTITY InspHead
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT FINAL(lt_po)
                FAILED FINAL(lt_failed).
**************************************************************************
            DATA(ls_po) = VALUE #( lt_po[ 1 ] OPTIONAL ).
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).

**************************************************************************
            data: lv_json type STANDARD TABLE OF string,
                  lv_url type string,
                  lv_auth type string,
                  lv_message_err type string,
                  lv_invoice    TYPE belnr_d,
                  lv_fiscalyear TYPE gjahr.
**************************************************************************
          DATA: lt_items      TYPE STANDARD TABLE OF string,
                lv_item_str   TYPE string,
                lv_items_json TYPE string.
         DATA lv_post_isodate TYPE string.
         DATA lv_docu_isodate TYPE string.
         DATA lv_amt TYPE I_PurchaseOrderItemAPI01-NetAmount.
         DATA lv_toamt TYPE I_PurchaseOrderItemAPI01-NetAmount.
***************************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date1) TIME DATA(lv_time).

                if ls_po-Taxcode is NOT INITIAL.

*                    select single * from ZQM_PO_TAX WITH PRIVILEGED ACCESS
*                    where PurchaseOrder = @ls_po-Purchaseorder
*                    and PurchaseOrderItem = @ls_po-Purchaseorderitem
*                    into @DATA(ls_taxamt).
**                lv_amt = ls_po-Totalamt + ls_taxamt-IGSTAmount + ls_taxamt-CGSTAmount + ls_taxamt-SGSTAmount.
                  case ls_po-Taxcode.
                        when '1C'.
                            lv_amt = ( ls_po-Totalamt * 18 ) / 100.
                        when '1A'.
                            lv_amt = ( ls_po-Totalamt * 5 ) / 100.
                        when '1B'.
                            lv_amt = ( ls_po-Totalamt * 12 ) / 100.
                        when '1H'.
                            lv_amt = ( ls_po-Totalamt * 18 ) / 100.
                        when '1F'.
                            lv_amt = ( ls_po-Totalamt * 5 ) / 100.
                        when '1G'.
                            lv_amt = ( ls_po-Totalamt * 12 ) / 100.
                        when others.
                            lv_amt = '0.00'.

                   ENDCASE.

*                  lv_amt =
                ENDIF.

                lv_toamt = ls_po-Totalamt + lv_amt.

                lv_docu_isodate = |{ lv_date1 DATE = ISO }|.
                lv_post_isodate = |{ gs_keys-%param-PostingDate DATE = ISO }|.
                data(lv_suppitem) = '1'.
                data(lv_subDebitCredit) = 'X'.
                data(lv_busplace) = '2100'.
                data(tax) = 'true'.
                data(lv_sts) = 'A'.
***************************************************************************
                if ls_po-Taxcode is not INITIAL.
                    data(taxcode) = ls_po-Taxcode.
                ELSE.
                    taxcode = '10'.
                ENDIF.
***************************************************************************
                if ls_po-Paymentterms is not INITIAL.
                data(lv_pay) = ls_po-Paymentterms.
                ELSE.
                lv_pay = '0001'.
                ENDIF.
***************************************************************************

            data(ls_json) = '{ "CompanyCode": "' && ls_po-Companycode &&
                    '","DocumentDate": "' && lv_docu_isodate &&
                    'T00:00","PostingDate": "' && lv_post_isodate &&
                    'T00:00' &&
                    '","DocumentCurrency": "' && ls_po-Documentcurrency &&
                    '","InvoiceGrossAmount": "' && lv_toamt &&
                    '","InvoicingParty": "' && ls_po-Suppllier &&
                    '","SupplierInvoiceIDByInvcgParty": "' && gs_keys-%param-Reference &&
                    '","BusinessPlace": "' && lv_busplace &&
                    '","PaymentTerms": "' && lv_pay &&
                    '","SupplierInvoiceStatus": "' && lv_sts &&
                    '","TaxIsCalculatedAutomatically": ' && tax &&
                    ',"TaxDeterminationDate": "' && lv_post_isodate &&
                    'T00:00' &&
                    '","SupplierInvoiceIsCreditMemo": "' && lv_subDebitCredit &&
                    '","to_SuplrInvcItemPurOrdRef": { ' &&
                '"results": [ ' &&
                        ' { ' &&
                            ' "SupplierInvoiceItem": "' && lv_suppitem &&
                            '","PurchaseOrder": "' && ls_po-Purchaseorder &&
                            '","PurchaseOrderItem": "' && ls_po-Purchaseorderitem &&
                            '","ReferenceDocument": "' && ls_po-Materialdocument &&
                            '","ReferenceDocumentFiscalYear": "' && ls_po-Materialdocumentyear &&
                            '","ReferenceDocumentItem": "' && ls_po-Materialdocumentitem &&
                            '","IsSubsequentDebitCredit": "' && lv_subDebitCredit &&
                            '","DocumentCurrency": "' && ls_po-Documentcurrency &&
                            '","SupplierInvoiceItemAmount": "' && ls_po-Totalamt &&
                            '","QuantityInPurchaseOrderUnit": "' && ls_po-Inspectionlotqty &&
                            '","PurchaseOrderQuantityUnit": "' && ls_po-Baseunit &&
                            '","TaxCode": "' && taxcode &&
                        '" }' &&
                            ']' &&
                        '}' &&
                    '}'.

***************************************************************************
TRY.
          CONSTANTS lc_dev TYPE string VALUE 'https://my437525-api.s4hana.cloud.sap/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice'.
          CONSTANTS lc_qas TYPE string VALUE 'https://my437734-api.s4hana.cloud.sap/sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader'.
          CONSTANTS lc_prd TYPE string VALUE 'https://my443992-api.s4hana.cloud.sap/sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader'.
***************************************************************************
            try.
                DATA(system_url) = cl_abap_context_info=>get_system_url( ).
                catch CX_ABAP_CONTEXT_INFO_ERROR  INTO DATA(lx_erro1).
                 DATA(lv_err1) = lx_erro1->get_text( ).
            endtry.
***************************************************************************
          IF system_url CS 'my437525'.
            lv_url = lc_dev.
          ELSEIF system_url CS 'my437734'.
            lv_url = lc_qas.
             ELSEIF system_url CS 'my443992'.
            lv_url = lc_prd.
          ENDIF.
***************************************************************************
          "create http destination by url; API endpoint for API sandbox
          DATA(lo_http_destination) =
               cl_http_destination_provider=>create_by_url( lv_url ).

          "create HTTP client by destination
          DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
          DATA(lo_web_http_client_post) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

          "adding headers with API Key for API Sandbox
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
          DATA(lo_web_http_request_post) = lo_web_http_client->get_http_request( ).

          lv_auth = 'INTEGRATION_001:Eipl@#sarabap1234567'.

          DATA(lv_auth_base64) = cl_web_http_utility=>encode_base64( lv_auth ).

          lo_web_http_request->set_header_fields(
            VALUE #(

            ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
            ( name  = 'Content-Type' value = 'application/json' )
            ( name  = 'X-CSRF-Token' value = 'fetch' )
             )
          ).

          DATA(lo_web_http_response_get) = lo_web_http_client->execute( if_web_http_client=>get ).

          DATA(lv_response_get) = lo_web_http_response_get->get_header_fields( ).


          DATA(lv_xcsrf) = lo_web_http_response_get->get_header_field(  'x-csrf-token' ).

          lo_web_http_request_post->set_header_fields(
            VALUE #(

            ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
            ( name  = 'Content-Type' value = 'application/json' )
            ( name  = 'X-CSRF-Token' value = lv_xcsrf )
             )
          ).

          lo_web_http_request_post->set_text( ls_json ).
          "set request method and execute request
          DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
          DATA(lv_response) = lo_web_http_response->get_text( ).

***********************************************************************
            DATA(lo_regex) = cl_abap_regex=>create_pcre( pattern = '<message[^>]*>([^<]*)</message>' ).

            FIND REGEX lo_regex
             IN lv_response
             SUBMATCHES lv_message_err.


            if lv_message_err is not INITIAL.

             APPEND VALUE #( %tky = ls_po-%tky )
                 TO failed-insphead.

              APPEND VALUE #(
                %tky = ls_po-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                          text     = lv_message_err
                       )
              ) TO reported-insphead .

            endif.
************************************************************************

            FIND FIRST OCCURRENCE OF PCRE
                `SupplierInvoice='([^']+)',FiscalYear='([^']+)'`
            IN lv_response
            SUBMATCHES lv_invoice lv_fiscalyear.
************************************************************************

            if lv_invoice is not INITIAL and lv_fiscalyear is NOT INITIAL.

                MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                ENTITY InspHead
                UPDATE
                FIELDS ( Supplierinvoice Fiscalyear Postinvoiceflag
                          Reference Postingdate )
                WITH VALUE #( for key in keys
                             ( %tky = ls_po-%tky
                             Supplierinvoice = lv_invoice
                             Fiscalyear = lv_fiscalyear
                             Reference = gs_keys-%param-Reference
                             Postingdate = gs_keys-%param-PostingDate
                             Postinvoiceflag = 'X'
                             %control-Supplierinvoice = if_abap_behv=>mk-on
                             %control-Fiscalyear = if_abap_behv=>mk-on
                             %control-Postinvoiceflag = if_abap_behv=>mk-on
                             %control-Reference = if_abap_behv=>mk-on
                             %control-Postingdate = if_abap_behv=>mk-on
                             ) ).

            data(lv_success_msg) = |Park Invoice-{ lv_invoice } created successfully.|.
              APPEND VALUE #(
                %tky = ls_po-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-insphead .

            ENDIF.

    CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(lv_check).

        DATA(lv_error) = lv_check.
ENDTRY.
*************************************************************************
    result = VALUE #( FOR ls_ord IN lt_po
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD UpInsp.
****************************************************************************

            READ ENTITIES OF zqm_i_insp_head IN LOCAL MODE
            ENTITY InspHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_head)
            ENTITY InspHead BY \_InspResult
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_result)
            FAILED FINAL(lt_failed).

***************************************************************************
            data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

*            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
*            if <ls_head> is ASSIGNED.

                    select single MaterialDocumentYear,MaterialDocument,MaterialDocumentItem
                         from I_MaterialDocumentItem_2 WITH PRIVILEGED ACCESS
                    WHERE PurchaseOrder = @ls_head-Purchaseorder
                    AND PurchaseOrderItem = @ls_head-Purchaseorderitem
                    and ReversedMaterialDocument is INITIAL
                    and GoodsMovementIsCancelled is INITIAL
                    INTo @Data(lv_matdoc).

                    select single InspectionLot,InspLotCreatedOnLocalDate,
                                  PurchasingDocument,PurchasingDocumentItem,
                                  InspectionLotQuantity,InspectionLotType,MaterialDocument,
                                  MaterialDocumentYear,MaterialDocumentItem
                                  from I_InspectionLot WITH PRIVILEGED ACCESS
                                  where MaterialDocument = @lv_matdoc-MaterialDocument
                                  and MaterialDocumentItem = @lv_matdoc-MaterialDocumentItem
                                  and MaterialDocumentYear = @lv_matdoc-MaterialDocumentYear
                                  into @Data(wa_insp).

           if wa_insp is INITIAL.

            data(lv_success_msg) = |First, create the Goods Receipt (GR)|.
              APPEND value #( %tky = ls_head-%tky )
                    to failed-insphead.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                          text     = lv_success_msg
                       )
              ) TO reported-insphead .

           ELSE.


                    MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                    ENTITY InspHead
                    UPDATE
                    FIELDS ( Inspectionlot Inspectiondate Inspindicator
                             Inspectionlotqty Inspectionlottype Materialdocument
                             Materialdocumentitem Materialdocumentyear )
                    WITH VALUE #( for key in keys
                                    ( %tky = ls_head-%tky
                                    Inspectionlot = wa_insp-InspectionLot
                                    Inspectiondate = wa_insp-InspLotCreatedOnLocalDate
                                    Inspectionlotqty = wa_insp-InspectionLotQuantity
                                    Inspectionlottype = wa_insp-InspectionLotType
                                    Materialdocument = wa_insp-MaterialDocument
                                    Materialdocumentitem = wa_insp-MaterialDocumentItem
                                    Materialdocumentyear = wa_insp-MaterialDocumentYear
                                    Inspindicator = 'X'

                                    %control-Inspectionlot = if_abap_behv=>mk-on
                                    %control-Inspectiondate = if_abap_behv=>mk-on
                                    %control-Inspectionlotqty = if_abap_behv=>mk-on
                                    %control-Inspectionlottype = if_abap_behv=>mk-on
                                    %control-Materialdocument = if_abap_behv=>mk-on
                                    %control-Materialdocumentitem = if_abap_behv=>mk-on
                                    %control-Materialdocumentyear = if_abap_behv=>mk-on
                                    %control-Inspindicator = if_abap_behv=>mk-on
                                    ) ).

            LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
            if <ls_result> is ASSIGNED.

                    MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                    ENTITY InspResult
                    UPDATE
                    FIELDS ( Inspectionlot  )
                    WITH VALUE #( for key in keys
                                    ( %tky = <ls_result>-%tky
                                    Inspectionlot = wa_insp-InspectionLot
                                    %control-Inspectionlot = if_abap_behv=>mk-on
                                    ) ).
            ENDIF.
            ENDLOOP.

           endif.
*            endif.
*            endloop.
*********************************************************************
    result = VALUE #( FOR ls_hd IN lt_head
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************

  ENDMETHOD.

ENDCLASS.

CLASS lhc_InspResult DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR InspResult RESULT result.
    METHODS update FOR DETERMINE ON MODIFY
      IMPORTING keys FOR inspresult~update.

ENDCLASS.

CLASS lhc_InspResult IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD Update.
*****************************************************************************
            DATA : lv_value type i,
                   lv_value1 TYPE p DECIMALS 2,
                   lv_text   TYPE string,
                   lv_amt TYPE ZQM_SLAB_DB-fromslabamt,
                   lv_final type ZQM_MIC_DB-amtvalue.

            READ ENTITIES OF zqm_i_insp_head IN LOCAL MODE
            ENTITY InspHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY InspResult
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************

            data(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
            sort lt_inspresult ASCENDING BY Boocharacteristic.
            loop AT lt_inspresult ASSIGNING FIELD-SYMBOL(<ls_result>).
            if <ls_result> is ASSIGNED.

                    if <ls_result>-Inspresultmeanvalue is not INITIAL.

                            lv_value = TRUNC( <ls_result>-Inspresultmeanvalue * 1000 ).
                            lv_value1 = ( lv_value / 1000 ).
                            lv_amt = lv_value1.
                            lv_text = |{ lv_value1 DECIMALS = 2 }|.

                            IF lv_text CP '*.00'.
                                REPLACE FIRST OCCURRENCE OF '.00' IN lv_text WITH ''.
                            ENDIF.
*****************************************************************************
                    if lv_amt is not INITIAL.
                    select single * from @lt_inspresult as res
                    left outer join ZQM_SLAB_DB as h on res~uuid = h~uuid
                                and res~plangroup = h~plangroup
                                and res~boocharacteristic = h~boocharacteristic
                                and @lv_amt between h~toslabamt and h~fromslabamt
                    where res~Uuid = @<ls_result>-Uuid
                    and res~plangroup = @<ls_result>-Plangroup
                    and res~boocharacteristic = @<ls_result>-Boocharacteristic
                    and h~minusplus = 'Minus'
                    into @DATA(ls_slab).

                    if ls_slab-h is INITIAL.

                    select single * from @lt_inspresult as res
                    left outer join ZQM_SLAB_DB as h on res~uuid = h~uuid
                                and res~plangroup = h~plangroup
                                and res~boocharacteristic = h~boocharacteristic
                    and @lv_amt between  h~fromslabamt and h~toslabamt
                    where res~Uuid = @<ls_result>-Uuid
                    and res~plangroup = @<ls_result>-Plangroup
                    and res~boocharacteristic = @<ls_result>-Boocharacteristic
                    and h~minusplus = 'Plus'
                    into @ls_slab.
                    ENDif.

                            if ls_slab-h is not INITIAL.
                            lv_final = ls_head-Orderquantity * ls_slab-h-amountnew.
                            ENDIF.

                    ENDIF.
*****************************************************************************
                    if lv_text is NOT INITIAL.

                    MODIFY ENTITIES OF zqm_i_insp_head IN LOCAL MODE
                    ENTITY InspResult
                    UPDATE
                    FIELDS ( Inspresultoriginalvalue Amtvalue )
                    WITH VALUE #( for key in keys
                                ( %tky = <ls_result>-%tky
                                   Inspresultoriginalvalue = lv_text
                                   Amtvalue = lv_final
                                   %control-Inspresultoriginalvalue = if_abap_behv=>mk-on
                                   %control-Amtvalue = if_abap_behv=>mk-on
                                   ) ).

                    ENDIF.
                    CLear lv_final.
                    ENDIF.
            ENDIF.
*****************************************************************************
            ENDLOOP.
  ENDMETHOD.

ENDCLASS.
