CLASS lhc_zmm_c_apps08_iv DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS gt_curr_net FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zmm_c_apps08_iv~gt_curr_net.
    METHODS gt_netmat FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zmm_c_apps08_iv~gt_netmat.
    METHODS gt_data1 FOR DETERMINE ON SAVE
      IMPORTING keys FOR zmm_c_apps08_iv~gt_data1.

ENDCLASS.

CLASS lhc_zmm_c_apps08_iv IMPLEMENTATION.

  METHOD gt_curr_net.
**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE ENTITY
    zmm_c_apps08_iv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item).

**********************************************************************

    IF lt_item IS NOT INITIAL.
      MODIFY ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
      ENTITY zmm_c_apps08_iv
      UPDATE FROM VALUE #( ( %tky = lt_item[ 1 ]-%tky
        curr = 'INR'
        %control-curr = if_abap_behv=>mk-on
         ) )
        MAPPED DATA(lt_mapped)
        FAILED DATA(lt_faields)
        REPORTED DATA(lt_reportd).

    ENDIF.


  ENDMETHOD.

  METHOD gt_netmat.
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE ENTITY
   zmm_c_apps08_iv
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(lt_item).

**********************************************************************

    IF lt_item IS NOT INITIAL.
      MODIFY ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
      ENTITY zmm_c_apps08_iv
      UPDATE FROM VALUE #( ( %tky = lt_item[ 1 ]-%tky
        netamount = lt_item[ 1 ]-requested * lt_item[ 1 ]-rate
        %control-netamount = if_abap_behv=>mk-on
         ) )
        MAPPED DATA(lt_mapped)
        FAILED DATA(lt_faields)
        REPORTED DATA(lt_reportd).

    ENDIF.


  ENDMETHOD.

  METHOD gt_data1.
**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_i_apps08_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr)
     BY \_Item
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_item).
**********************************************************************

    zbp_mm_i_apps08_rv=>gt_item =
      VALUE #( FOR ls IN lt_item
               ( CORRESPONDING #( ls ) ) ).

**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_c_apps08_iv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item1).

    LOOP AT lt_item1 INTO  DATA(ls_item) WHERE supplierqt IS NOT INITIAL.

      MODIFY ENTITIES OF I_SupplierQuotationTP PRIVILEGED
      ENTITY SupplierQuotationItem
      UPDATE FROM VALUE #(  ( SupplierQuotation = ls_item-supplierqt
      SupplierQuotationItem = ls_item-supplierqtim
*      NetPriceAmount = ls_item-rate
      ScheduleLineOrderQuantity = ls_item-requested
*      NetAmount = ls_item-netamount
*      %control-NetPriceAmount = if_abap_behv=>mk-on
      %control-ScheduleLineOrderQuantity = if_abap_behv=>mk-on
*      %control-NetAmount = if_abap_behv=>mk-on

       )   )
        MAPPED DATA(lt_mapped)
      FAILED DATA(lt_faields)
      REPORTED DATA(lt_reportd).

*      READ ENTITIES OF i_supplierquotationtp PRIVILEGED
*      ENTITY SupplierQtanItemPricingElement
*      FIELDS ( ConditionType ConditionRateValue ConditionCurrency PricingDocument PricingDocumentItem PricingProcedureStep PricingProcedureCounter )
*      WITH VALUE #( (
*        SupplierQuotation = ls_item-supplierqt
*        SupplierQuotationItem = ls_item-supplierqtim
*
*      ) )
*      RESULT DATA(lt_pricing).
      SELECT SINGLE * FROM I_SupplierQuotationPrcElmntTP

      WHERE SupplierQuotation = @ls_item-supplierqt
      AND SupplierQuotationItem = @ls_item-supplierqtim
      INTO @DATA(ls_pricing) PRIVILEGED ACCESS.

*      DATA(ls_pricing) = lt_pricing[ 1 ].

      MODIFY ENTITIES OF I_SupplierQuotationTP PRIVILEGED
      ENTITY SupplierQtanItemPricingElement
      UPDATE FROM VALUE #( (  SupplierQuotation = ls_pricing-SupplierQuotation
      SupplierQuotationItem = ls_pricing-SupplierQuotationItem
      PricingDocument = ls_pricing-PricingDocument
      PricingDocumentItem = ls_pricing-PricingDocumentItem
       PricingProcedureStep = ls_pricing-PricingProcedureStep
       PricingProcedureCounter = ls_pricing-PricingProcedureCounter
        ConditionRateValue = ls_item-rate
        ConditionBaseValue = ls_item-requested
        %control-ConditionRateValue = if_abap_behv=>mk-on
        %control-ConditionBaseValue = if_abap_behv=>mk-on )
      )
       MAPPED DATA(lt_mapped1)
      FAILED DATA(lt_faields1)
      REPORTED DATA(lt_reportd1).







    ENDLOOP.






  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZMM_I_APPS08_RV DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zmm_i_apps08_rv RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zmm_i_apps08_rv RESULT result.
    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION zmm_i_apps08_rv~submit RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zmm_i_apps08_rv RESULT result.
    METHODS finalsubmit FOR MODIFY
       keys FOR ACTION zmm_i_apps08_rv~finalsubmit RESULT result.
    METHODS gt_hdr1 FOR DETERMINE ON SAVE
       keys FOR zmm_i_apps08_rv~gt_hdr1.

ENDCLASS.

CLASS lhc_ZMM_I_APPS08_RV IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD submit.
    DATA: lv_json        TYPE STANDARD TABLE OF string,
          lv_url         TYPE string,
          lv_auth        TYPE string,
          lv_message_err TYPE string,
          lv_invoice     TYPE belnr_d,
           lv_etag        TYPE string,
          lv_fiscalyear  TYPE gjahr.
***********************************************************************
*    DATA: ls_data          TYPE I_SupplierQuotationTP,
*
*          lt_header_create TYPE TABLE FOR CREATE I_SupplierQuotationTP\\SupplierQuotation,
*
*          ls_data_item     TYPE I_SupplierQuotationItemTP,
*
*          lt_item_create   TYPE TABLE FOR CREATE I_SupplierQuotationTP\\SupplierQuotation\_SupplierQuotationItem,
*
*          ls_item          TYPE STRUCTURE FOR CREATE I_SupplierQuotationTP\\SupplierQuotation\_SupplierQuotationItem.
*    DATA ls_target_item LIKE LINE OF ls_item-%target.
***********************************************************************
*    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
*    ENTITY zmm_i_apps08_rv
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_header).
*    DATA(ls_header) = lt_header[ 1 ].
*
*    SELECT SINGLE * FROM I_RequestForQuotationTP WITH PRIVILEGED ACCESS
*    WHERE RequestForQuotation = @ls_header-RequestForQuotation
*    INTO @DATA(ls_req).
*    ls_data = VALUE #(
*
*      companycode                   = ls_header-CompanyCode
*      purchasingdocumentcategory    = 'O'
*      purchasingdocumenttype        = 'ERQ'
*
*      supplier                      = ls_header-Supplier
*      language                      = 'E'
*      documentcurrency              = ls_header-DocumentCurrency
*
*
*      paymentterms                  = ls_header-PaymentTerms
*      cashdiscount1days             = ls_header-CashDiscount1Days
*      cashdiscount2days             = ls_header-cashdiscount2days
*      cashdiscount1percent          = ls_header-CashDiscount1Percent
*      cashdiscount2percent          = ls_header-CashDiscount2Percent
*      CreatedByUser                 = cl_abap_context_info=>get_user_technical_name(  )
**      netpaymentdays                =
*      CreationDate                  = cl_abap_context_info=>get_system_date(  )
*
**      pricingprocedure              =
*      purchasingorganization =      ls_header-PurchasingOrganization
*      purchasinggroup = ls_header-PurchasingGroup
*
*      requestforquotation = ls_header-RequestForQuotation
*
*      quotationsubmissiondate = ls_header-QuotationLatestSubmissionDate
*
*      quotationlatestsubmissiondate = ls_header-QuotationLatestSubmissionDate
*
*      bindingperiodvalidityenddate =  ls_req-BindingPeriodValidityEndDate
*
*      followondocumentcategory =  ls_req-FollowOnDocumentCategory
*
*      purgdocfollowondocumenttype = ls_req-PurgDocFollowOnDocumentType
*    ).
*
*    APPEND INITIAL LINE TO lt_header_create
*  ASSIGNING FIELD-SYMBOL(<ls_header>).
*
*    <ls_header> = CORRESPONDING #(
*      ls_data
*      CHANGING CONTROL
*      EXCEPT
*        supplierquotation
*        purchasingdocumentcategory
*        purchasingdocumenttype
*        lastchangedatetime
*        createdbyuser
*        creationdate
*    ).
*
*    <ls_header>-%cid = 'HEADER_1'.
***********************************************************************
*    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
*    ENTITY zmm_i_apps08_rv
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_hdr)
*    BY \_Item
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_rfq_item).
*
*    SELECT FROM @lt_rfq_item AS itm
*    INNER JOIN I_RequestForQuotationItemTP WITH PRIVILEGED ACCESS AS rfqtim ON rfqtim~RequestForQuotation = itm~RequestForQuotation
*    AND rfqtim~RequestForQuotationItem = itm~RequestForQuotationItem
*    FIELDS
*    itm~requested,
*    itm~rate,
*    rfqtim~PurchasingDocumentItemText,
*    rfqtim~Material,
*    rfqtim~ProductTypeCode,
*    rfqtim~ManufacturerMaterial,
*    rfqtim~MaterialGroup,
*    rfqtim~Plant,
*    rfqtim~ManualDeliveryAddressID,
*    rfqtim~ScheduleLineOrderQuantity,
*    rfqtim~ScheduleLineDeliveryDate,
*    rfqtim~PerformancePeriodStartDate,
*    rfqtim~PerformancePeriodEndDate,
*    rfqtim~OrderQuantityUnit,
*    rfqtim~OrderItemQtyToBaseQtyDnmntr,
*    rfqtim~OrderItemQtyToBaseQtyNmrtr,
*    rfqtim~BaseUnit,
*    itm~netamount,
*    rfqtim~PurchaseRequisition,
*    rfqtim~PurchaseRequisitionItem,
*    rfqtim~RequestForQuotation,
*    rfqtim~RequestForQuotationItem,
*    rfqtim~PurchasingDocumentItemCategory
*
*    WHERE itm~RequestForQuotation = @ls_data-RequestForQuotation
*    INTO TABLE @DATA(lt_rfq_itm).
*
*
*
*
*    ls_item-%cid_ref = 'HEADER_1'.
*
*
*    "---------------------------------------------------------
*    " Loop Multiple Items
*    "---------------------------------------------------------
*
*    LOOP AT lt_rfq_itm INTO DATA(rfq_item).
*
*      CLEAR:
*        ls_data_item,
*        ls_target_item.
*
*      ls_data_item = VALUE #(
*                            purchasingdocumentitemtext      = rfq_item-PurchasingDocumentItemText
*                            material                        = rfq_item-material
*                            producttypecode                 = rfq_item-ProductTypeCode
*                            manufacturermaterial            = rfq_item-manufacturermaterial
*                            materialgroup                   = rfq_item-materialgroup
*                            plant                           = rfq_item-plant
*                            manualdeliveryaddressid         = rfq_item-manualdeliveryaddressid
*                            schedulelineorderquantity       = rfq_item-requested
*                            schedulelinedeliverydate        = rfq_item-schedulelinedeliverydate
*                            performanceperiodstartdate      = '00000000'
*                            performanceperiodenddate        = '00000000'
*                            orderquantityunit               = rfq_item-OrderQuantityUnit
*                            orderitemqtytobaseqtynmrtr      = rfq_item-OrderItemQtyToBaseQtyNmrtr
*                            orderitemqtytobaseqtydnmntr     = rfq_item-OrderItemQtyToBaseQtyNmrtr
**                        purgdocpricedate                = '20210331'
*                            baseunit                        = rfq_item-BaseUnit
*                            netpriceamount                  = rfq_item-rate
*                            netpricequantity                = '1'
*                            NetAmount                       = rfq_item-netamount
*                            documentcurrency                = ls_header-DocumentCurrency
*                            purchaserequisition             = rfq_item-purchaserequisition
*                            purchaserequisitionitem         = rfq_item-purchaserequisitionitem
*                            requestforquotation             = rfq_item-RequestForQuotation
*                            requestforquotationitem         = rfq_item-requestforquotationitem
*                            purchasingdocumentitemcategory  = rfq_item-purchasingdocumentitemcategory
*
*
*      ).
*
*
*      "-------------------------------------------------------
*      " Add each item to SAME HEADER %TARGET
*      "-------------------------------------------------------
*
*
*
*      ls_target_item = CORRESPONDING #(
*        ls_data_item
*        CHANGING CONTROL
*        EXCEPT
*          SupplierQuotation
*          SupplierQuotationItem
*          PurchasingDocumentItemCategory
*          LastChangeDateTime
*      ).
*
*      ls_target_item-%cid =
*        |ITEM_{ rfq_item-requestforquotationitem }|.
*
*      APPEND ls_target_item TO ls_item-%target.
*
*    ENDLOOP.
*
*    APPEND ls_item TO lt_item_create.
*    MODIFY ENTITIES OF I_SupplierQuotationTP FORWARDING PRIVILEGED
*             ENTITY SupplierQuotation CREATE FROM  lt_header_create"<-- Calls CREATE method on Header
*             CREATE BY \_SupplierQuotationItem FROM lt_item_create "<-- Call Create By Association method on Header
*
*
*
*             FAILED   DATA(ls_failed)
*             REPORTED DATA(ls_reported)
*             MAPPED   DATA(ls_mapped).
*    IF ls_failed IS INITIAL.
*      result = VALUE #( FOR ls IN lt_hdr ( %tky = ls-%tky
*      %param = ls ) ).
*      READ ENTITIES OF I_SupplierQuotationTP PRIVILEGED
*  ENTITY SupplierQuotation
*  ALL FIELDS WITH CORRESPONDING #( ls_mapped-supplierquotation )
*  RESULT DATA(lt_created).
*      zbp_mm_i_apps08_rv=>ct_suppliertp = ls_mapped.
*    ELSE.
*
*    ENDIF.
******************************************************************************************

**********************************************************************
**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_i_apps08_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).
    DATA(ls_header) = lt_header[ 1 ].

    SELECT SINGLE * FROM I_RequestForQuotationTP WITH PRIVILEGED ACCESS
    WHERE RequestForQuotation = @ls_header-RequestForQuotation
    INTO @DATA(ls_req).

**********************************************************************
**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_i_apps08_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr)
    BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_rfq_item).

    SELECT FROM @lt_rfq_item AS itm
    INNER JOIN I_RequestForQuotationItemTP WITH PRIVILEGED ACCESS AS rfqtim ON rfqtim~RequestForQuotation = itm~RequestForQuotation
    AND rfqtim~RequestForQuotationItem = itm~RequestForQuotationItem
    FIELDS
    itm~requested,
    itm~rate,
    rfqtim~PurchasingDocumentItemText,
    rfqtim~Material,
    rfqtim~ProductTypeCode,
    rfqtim~ManufacturerMaterial,
    rfqtim~MaterialGroup,
    rfqtim~Plant,
    rfqtim~ManualDeliveryAddressID,
    rfqtim~ScheduleLineOrderQuantity,
    rfqtim~ScheduleLineDeliveryDate,
    rfqtim~PerformancePeriodStartDate,
    rfqtim~PerformancePeriodEndDate,
    rfqtim~OrderQuantityUnit,
    rfqtim~OrderItemQtyToBaseQtyDnmntr,
    rfqtim~OrderItemQtyToBaseQtyNmrtr,
    rfqtim~BaseUnit,
    itm~netamount,
    rfqtim~PurchaseRequisition,
    rfqtim~PurchaseRequisitionItem,
    rfqtim~RequestForQuotation,
    rfqtim~RequestForQuotationItem,
    rfqtim~PurchasingDocumentItemCategory
    WHERE itm~RequestForQuotation = @ls_header-RequestForQuotation
    INTO TABLE @DATA(lt_rfq_itm).

**********************************************************************
**********************************************************************
*
*    TRY.
*
*
*
**--------------------------------------------------------------------*
** Get system URL
**--------------------------------------------------------------------*
*        TRY.
*            DATA(system_url) =
*            cl_abap_context_info=>get_system_url( ).
*          CATCH cx_abap_context_info_error  INTO DATA(lx_erro1).
*            DATA(lv_err1) = lx_erro1->get_text( ).
*        ENDTRY.
**--------------------------------------------------------------------*
** Determine host
**--------------------------------------------------------------------*
*        DATA(lv_host) = COND string(
*          WHEN system_url CS 'my437525'
*            THEN 'https://my437525-api.s4hana.cloud.sap'
*
*          WHEN system_url CS 'my425571'
*            THEN 'https://my425571-api.s4hana.cloud.sap'
*
*          WHEN system_url CS 'my437194'
*            THEN 'https://my437194-api.s4hana.cloud.sap'
*
*          ELSE ''
*            ).
*
**--------------------------------------------------------------------*
** Authentication
**--------------------------------------------------------------------*
*        lv_auth = 'INTEGRATION_2:Vendor123456789098765#'.
*
*        DATA(lv_auth_base64) =
*            cl_web_http_utility=>encode_base64( lv_auth ).
*
**--------------------------------------------------------------------*
** Create ONE HTTP destination
**--------------------------------------------------------------------*
*        DATA(lo_destination) =
*          cl_http_destination_provider=>create_by_url( lv_host ).
*
**--------------------------------------------------------------------*
** Create ONE HTTP client
**--------------------------------------------------------------------*
*        DATA(lo_client) =
*          cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
*
*        DATA(lo_request) =
*          lo_client->get_http_request( ).
*
**--------------------------------------------------------------------*
** GET Delivery - Fetch CSRF Token + ETag
**--------------------------------------------------------------------*
*        lo_request->set_uri_path(
*          |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation|
**          |supplierquotation/0001/SupplierQuotation|
*            ).
*
*        lo_request->set_header_fields(
*          VALUE #(
*                ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
*
*                ( name  = 'Accept' value = 'application/json' )
*
*                ( name  = 'X-CSRF-Token' value = 'fetch' )
*                  )
*                ).
*
**--------------------------------------------------------------------*
** Execute GET
**--------------------------------------------------------------------*
*        DATA(lo_get_response) =
*          lo_client->execute( if_web_http_client=>get ).
*
*        DATA(lv_status1) =
*           lo_get_response->get_status( ).
*
**--------------------------------------------------------------------*
** Get CSRF Token
**--------------------------------------------------------------------*
*        DATA(lv_xcsrf) =
*          lo_get_response->get_header_field( 'x-csrf-token' ).
*
*
*
*
**--------------------------------------------------------------------*
** Validate CSRF
**--------------------------------------------------------------------*
*        IF lv_xcsrf IS INITIAL.
*
*          APPEND VALUE #(
*            %tky = ls_header-%tky
*            %msg = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = |CSRF token not received for delivery { ls_header-Supplier }|
*            )
*          ) TO reported-zmm_i_apps08_rv.
*
*          RETURN.
*
*        ENDIF.
*
**--------------------------------------------------------------------*
** POST - Post Supplier Quotation
**--------------------------------------------------------------------*
*        DATA(lv_iso_date) = |{ ls_header-QuotationLatestSubmissionDate DATE = (cl_abap_format=>d_iso) }|.
*        DATA(lv_payload) =
*          |\{"RequestForQuotation":"{ ls_header-RequestForQuotation }","Supplier":"{ ls_header-Supplier }","QuotationSubmissionDate":"{ lv_iso_date }"\}|.
*        lo_request->set_uri_path(
*          |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/SAP__self.CreateSuplrQtnFromRFQAllItems|
**          |supplierquotation/0001/SupplierQuotation/SAP__self.CreateSuplrQtnFromRFQAllItems|
*            ).
*
**--------------------------------------------------------------------*
** Set POST headers
**--------------------------------------------------------------------*
*        lo_request->set_header_fields(
*          VALUE #(
*                ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
*
*                ( name  = 'Accept' value = 'application/json' )
*
*                ( name  = 'Content-Type' value = 'application/json' )
*
*                ( name  = 'X-CSRF-Token' value = lv_xcsrf )
*
*
*                  )
*                ).
*        lo_request->set_text( lv_payload ).
**--------------------------------------------------------------------*
** Execute POST
**--------------------------------------------------------------------*
*        DATA(lo_post_response) =
*          lo_client->execute(
*            if_web_http_client=>post ).
*
**--------------------------------------------------------------------*
** Get status
**--------------------------------------------------------------------*
*        DATA(lv_status) =
*              lo_post_response->get_status( ).
*
*        DATA(lv_response_text) =
*              lo_post_response->get_text( ).
*
*       FIND REGEX '"SupplierQuotation":"([^"]+)"'
*     IN lv_response_text
*     SUBMATCHES data(lv_supplierquotation).
*
*        data(lv_ser) = lv_response_text.
***********************************************************************
***********************************************************************
*
*        IF lv_status-code = 201.
*
***********************************************************************
**--------------------------------------------------------------------*
** GET Delivery - Fetch CSRF Token + ETag
**--------------------------------------------------------------------*
*        lo_request->set_uri_path(
*          |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/{ lv_supplierquotation }|
**          |supplierquotation/0001/SupplierQuotation|
*            ).
*
*        lo_request->set_header_fields(
*          VALUE #(
*                ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
*
*                ( name  = 'Accept' value = 'application/json' )
*
*                ( name  = 'X-CSRF-Token' value = 'fetch' )
*                  )
*                ).
*
**--------------------------------------------------------------------*
** Execute GET
**--------------------------------------------------------------------*
*        DATA(lo_get_response1) =
*          lo_client->execute( if_web_http_client=>get ).
*
*        DATA(lv_status5) =
*           lo_get_response->get_status( ).
*
**--------------------------------------------------------------------*
** Get CSRF Token
**--------------------------------------------------------------------*
*        DATA(lv_xcsrf1) =
*          lo_get_response->get_header_field( 'x-csrf-token' ).
*
*        data(lv_etag1) = lo_get_response->get_header_field( 'etag' ).
*
*
*
*
**--------------------------------------------------------------------*
** Validate CSRF
**--------------------------------------------------------------------*
*        IF lv_xcsrf1 IS INITIAL.
*
*          APPEND VALUE #(
*            %tky = ls_header-%tky
*            %msg = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = |CSRF token not received for delivery { ls_header-Supplier }|
*            )
*          ) TO reported-zmm_i_apps08_rv.
*
*          RETURN.
*
*        ENDIF.
**--------------------------------------------------------------------*
** Validate ETag
**--------------------------------------------------------------------*
*        IF lv_etag1 IS INITIAL.
*
*          APPEND VALUE #(
*              %tky = ls_header-%tky
*              %msg = new_message_with_text(
*              severity = if_abap_behv_message=>severity-error
*              text     = |ETag Not avilable For this Sup|
*              )
*            ) TO reported-zmm_i_apps08_rv.
*
*          RETURN.
*
*        ENDIF.
*
*
*
*
*
*
*
***********************************************************************
**--------------------------------------------------------------------*
** PATCH - UPDATE Supplier Quotation Payment terms & Incoterms
**--------------------------------------------------------------------*
*          DATA(lv_payload3) =
*                 |\{"PaymentTerms":"{ ls_header-PaymentTerms }",|
*              && |"IncotermsClassification":"{ ls_header-IncotermsClassification }",|
*              && |"IncotermsLocation1":"{ ls_header-IncotermsLocation1 }"\}|.
*
*   lo_request->set_uri_path(
*              |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation(SupplierQuotation='{ lv_supplierquotation }')|
**          |supplierquotation/0001/SupplierQuotation/SAP__self.CreateSuplrQtnFromRFQAllItems|
*                ).
*
**--------------------------------------------------------------------*
** Set POST headers
**--------------------------------------------------------------------*
*            lo_request->set_header_fields(
*              VALUE #(
*                    ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
*
*                    ( name  = 'Accept' value = 'application/json' )
*
*                    ( name  = 'Content-Type' value = 'application/json' )
*
*                    ( name  = 'X-CSRF-Token' value = lv_xcsrf1 )
*
*                      ( name = 'If-Match' value = lv_etag1  )
*
*
*                      )
*                    ).
*            lo_request->set_text( lv_payload3 ).
*
**--------------------------------------------------------------------*
** Execute Patch
**--------------------------------------------------------------------*
*            DATA(lo_patch_response1) =
*              lo_client->execute(
*                if_web_http_client=>patch ).
*
**--------------------------------------------------------------------*
** Get status
**--------------------------------------------------------------------*
*            DATA(lv_status3) =
*                  lo_patch_response1->get_status( ).
*
*            DATA(lv_response_text3) =
*                  lo_patch_response1->get_text( ).
*
***********************************************************************
***********************************************************************
*
*
*
*
*
*
*
*
***********************************************************************
***********************************************************************
*          SELECT FROM @lt_rfq_item AS rfq
*          INNER JOIN zmm_apps08_sup AS sup ON sup~RequestForQuotation = rfq~RequestForQuotation AND
*          sup~RequestForQuotationItem = rfq~RequestForQuotationItem AND sup~Supplier = rfq~Supplier
*          FIELDS
*          rfq~curr,
*          rfq~rate,
*          rfq~OrderQuantityUnit,
*          rfq~requested,
*          rfq~ScheduleLineOrderQuantity,
*          sup~SupplierQuotation,
*          sup~SupplierQuotationItem
*          WHERE rfq~RequestForQuotation = @ls_header-RequestForQuotation
*          INTO TABLE @DATA(lt_rfq_item1).
*
*          LOOP AT lt_rfq_item1 INTO DATA(ls_rfq_item).
*
*            TRY.
*                cl_uom_maintenance=>get_instance( )->read(
*                  EXPORTING
*                    unit           = ls_rfq_item-OrderQuantityUnit
*                    language = 'E'             " Your internal DB unit
*                  IMPORTING
*                    unit_st = DATA(ls_item_uom)      " Will get populated with 'PC'
*                ).
*
*                " Processing continues here if the unit exists...
*
*              CATCH cx_uom_error INTO DATA(lx_error1).
*                " Triggers if 'ST' does not exist in the SAP UoM customizing tables (T006)
*                DATA(lv_error_text) = lx_error1->get_text( ).
*
*            ENDTRY.
*
*
*
**--------------------------------------------------------------------*
** PATCH - UPDATE Supplier Quotation ITEM
**--------------------------------------------------------------------*
*            DATA(lv_payload2) =
*        |\{"DocumentCurrency":"{ ls_header-DocumentCurrency }",|
*     && |"NetPriceAmount":{ ls_rfq_item-rate },|
*     && |"OrderQuantityUnit":"{ ls_item_uom-technical }",|
*     && |"ScheduleLineOrderQuantity":{ ls_rfq_item-requested }\}|.
*
*            lo_request->set_uri_path(
*              |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotationItem(SupplierQuotation='{ ls_rfq_item-SupplierQuotation }',SupplierQuotationItem='{ ls_rfq_item-SupplierQuotationItem }')|
**          |supplierquotation/0001/SupplierQuotation/SAP__self.CreateSuplrQtnFromRFQAllItems|
*                ).
*
**--------------------------------------------------------------------*
** Set POST headers
**--------------------------------------------------------------------*
*            lo_request->set_header_fields(
*              VALUE #(
*                    ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
*
*                    ( name  = 'Accept' value = 'application/json' )
*
*                    ( name  = 'Content-Type' value = 'application/json' )
*
*                    ( name  = 'X-CSRF-Token' value = lv_xcsrf )
*
*
*
*
*                      )
*                    ).
*            lo_request->set_text( lv_payload2 ).
*
**--------------------------------------------------------------------*
** Execute Patch
**--------------------------------------------------------------------*
*            DATA(lo_patch_response) =
*              lo_client->execute(
*                if_web_http_client=>patch ).
*
**--------------------------------------------------------------------*
** Get status
**--------------------------------------------------------------------*
*            DATA(lv_status2) =
*                  lo_patch_response->get_status( ).
*
*            DATA(lv_response_text2) =
*                  lo_patch_response->get_text( ).
*
***********************************************************************
***********************************************************************
*
*
*
*
*
*
*
*
*
*          ENDLOOP.
*
*        ENDIF.
*
**--------------------------------------------------------------------*
** Check result
**--------------------------------------------------------------------*
*
*      CATCH cx_http_dest_provider_error
*            cx_web_http_client_error
*            cx_web_message_error
*            INTO DATA(lx_error).
*
*        APPEND VALUE #(
*        %tky = ls_header-%tky
*        %msg = new_message_with_text(
*        severity = if_abap_behv_message=>severity-error
*        text     = lx_error->get_text( )
*          )
*        ) TO reported-zmm_i_apps08_rv.
*
*    ENDTRY.
TRY.

    "--------------------------------------------------------------------*
    "* Get system URL
    "--------------------------------------------------------------------*
    DATA(system_url) = ``.

    TRY.

        system_url = cl_abap_context_info=>get_system_url( ).

      CATCH cx_abap_context_info_error INTO DATA(lx_erro1).

        DATA(lv_err1) = lx_erro1->get_text( ).

    ENDTRY.


    "--------------------------------------------------------------------*
    "* Determine host
    "--------------------------------------------------------------------*
    DATA(lv_host) = COND string(
      WHEN system_url CS 'my437525'
        THEN 'https://my437525-api.s4hana.cloud.sap'

      WHEN system_url CS 'my425571'
        THEN 'https://my425571-api.s4hana.cloud.sap'

      WHEN system_url CS 'my437194'
        THEN 'https://my437194-api.s4hana.cloud.sap'

      ELSE ''
    ).


    "--------------------------------------------------------------------*
    "* Authentication
    "--------------------------------------------------------------------*
    lv_auth = 'INTEGRATION_2:Vendor123456789098765#'.

    DATA(lv_auth_base64) =
      cl_web_http_utility=>encode_base64( lv_auth ).


    "--------------------------------------------------------------------*
    "* Create HTTP destination
    "--------------------------------------------------------------------*
    DATA(lo_destination) =
      cl_http_destination_provider=>create_by_url( lv_host ).


    "--------------------------------------------------------------------*
    "* Create HTTP client
    "--------------------------------------------------------------------*
    DATA(lo_client) =
      cl_web_http_client_manager=>create_by_http_destination(
        lo_destination
      ).


    "====================================================================*
    "* 1. GET SupplierQuotation collection
    "*    Fetch CSRF Token
    "====================================================================*

    DATA(lo_get_request) =
      lo_client->get_http_request( ).

    lo_get_request->set_uri_path(
      |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation|
    ).

    lo_get_request->set_header_fields(
      VALUE #(
        ( name  = 'Authorization'
          value = |Basic { lv_auth_base64 }| )

        ( name  = 'Accept'
          value = 'application/json' )

        ( name  = 'X-CSRF-Token'
          value = 'fetch' )
      )
    ).

    DATA(lo_get_response) =
      lo_client->execute(
        if_web_http_client=>get
      ).

    DATA(lv_status1) =
      lo_get_response->get_status( ).


    "--------------------------------------------------------------------*
    "* Get CSRF token
    "--------------------------------------------------------------------*
    DATA(lv_xcsrf) =
      lo_get_response->get_header_field(
        'x-csrf-token'
      ).


    "--------------------------------------------------------------------*
    "* Validate CSRF
    "--------------------------------------------------------------------*
    IF lv_xcsrf IS INITIAL.

      APPEND VALUE #(
        %tky = ls_header-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text =
            |CSRF token not received for supplier { ls_header-Supplier }|
        )
      ) TO reported-zmm_i_apps08_rv.

      RETURN.

    ENDIF.


    "====================================================================*
    "* 2. POST - Create Supplier Quotation
    "====================================================================*

    DATA(lv_iso_date) =
      |{ ls_header-QuotationLatestSubmissionDate
         DATE = (cl_abap_format=>d_iso) }|.


    DATA(lv_payload) =
      |\{"RequestForQuotation":"{ ls_header-RequestForQuotation }",|
      && |"Supplier":"{ ls_header-Supplier }",|
      && |"QuotationSubmissionDate":"{ lv_iso_date }"\}|.


    "--------------------------------------------------------------------*
    "* IMPORTANT:
    "* Create NEW request object
    "--------------------------------------------------------------------"
    DATA(lo_post_request) =
      lo_client->get_http_request( ).


    lo_post_request->set_uri_path(
      |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/SAP__self.CreateSuplrQtnFromRFQAllItems|
    ).


    lo_post_request->set_header_fields(
      VALUE #(
        ( name  = 'Authorization'
          value = |Basic { lv_auth_base64 }| )

        ( name  = 'Accept'
          value = 'application/json' )

        ( name  = 'Content-Type'
          value = 'application/json' )

        ( name  = 'X-CSRF-Token'
          value = lv_xcsrf )
      )
    ).


    lo_post_request->set_text( lv_payload ).


    DATA(lo_post_response) =
      lo_client->execute(
        if_web_http_client=>post
      ).


    DATA(lv_status) =
      lo_post_response->get_status( ).


    DATA(lv_response_text) =
      lo_post_response->get_text( ).


    "====================================================================*
    "* Extract SupplierQuotation
    "====================================================================*

    DATA(lv_supplierquotation) = ``.

    FIND REGEX '"SupplierQuotation"\s*:\s*"([^"]+)"'
         IN lv_response_text
         SUBMATCHES lv_supplierquotation.


    IF lv_supplierquotation IS INITIAL.

      APPEND VALUE #(
        %tky = ls_header-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text =
            |SupplierQuotation not found in API response|
        )
      ) TO reported-zmm_i_apps08_rv.

      RETURN.

    ENDIF.


    "====================================================================*
    "* Continue only if POST successful
    "====================================================================*

    IF lv_status-code = 201.


      "==================================================================*
      "* 3. GET CREATED SupplierQuotation
      "*    Fetch latest CSRF + ETag
      "==================================================================*

      " IMPORTANT:
      " New request object
*      DATA(lo_get_request1) =
*        lo_client->get_http_request( ).
*
*
*      lo_get_request1->set_uri_path(
*        |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/{ lv_supplierquotation }|
*      ).
*
*
*      lo_get_request1->set_header_fields(
*        VALUE #(
*          ( name  = 'Authorization'
*            value = |Basic { lv_auth_base64 }| )
*
*          ( name  = 'Accept'
*            value = 'application/json' )
*
*          ( name  = 'X-CSRF-Token'
*            value = 'fetch' )
*        )
*      ).
*
*
*      DATA(lo_get_response1) =
*        lo_client->execute(
*          if_web_http_client=>get
*        ).
*
*
*      " IMPORTANT:
*      " Read from lo_get_response1, NOT lo_get_response
*      DATA(lv_status5) =
*        lo_get_response1->get_status( ).
*
*
*      DATA(lv_xcsrf1) =
*        lo_get_response1->get_header_field(
*          'x-csrf-token'
*        ).
*
*
*      DATA(lv_etag1) =
*        lo_get_response1->get_header_field(
*          'etag'
*        ).
*
*
*      "------------------------------------------------------------------*
*      "* Validate CSRF
*      "------------------------------------------------------------------*
*      IF lv_xcsrf1 IS INITIAL.
*
*        APPEND VALUE #(
*          %tky = ls_header-%tky
*          %msg = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text =
*              |CSRF token not received for supplier { ls_header-Supplier }|
*          )
*        ) TO reported-zmm_i_apps08_rv.
*
*        RETURN.
*
*      ENDIF.
*
*
*      "------------------------------------------------------------------*
*      "* Validate ETag
*      "------------------------------------------------------------------*
*      IF lv_etag1 IS INITIAL.
*
*        APPEND VALUE #(
*          %tky = ls_header-%tky
*          %msg = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text = |ETag not available for SupplierQuotation|
*          )
*        ) TO reported-zmm_i_apps08_rv.
*
*        RETURN.
*
*      ENDIF.
*
*
*      "==================================================================*
*      "* 4. PATCH SupplierQuotation HEADER
*      "*
*      "* If-Match IS USED here
*      "==================================================================*
*
*      DATA(lv_payload3) =
*        |\{"PaymentTerms":"{ ls_header-PaymentTerms }",|
*        && |"IncotermsClassification":"{ ls_header-IncotermsClassification }",|
*        && |"IncotermsLocation1":"{ ls_header-IncotermsLocation1 }"\}|.
*
*
*      " IMPORTANT:
*      " New request object
*      DATA(lo_header_patch_request) =
*        lo_client->get_http_request( ).
*
*
*      lo_header_patch_request->set_uri_path(
*        |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation(SupplierQuotation='{ lv_supplierquotation }')|
*      ).
*
*
*      lo_header_patch_request->set_header_fields(
*        VALUE #(
*          ( name  = 'Authorization'
*            value = |Basic { lv_auth_base64 }| )
*
*          ( name  = 'Accept'
*            value = 'application/json' )
*
*          ( name  = 'Content-Type'
*            value = 'application/json' )
*
*          ( name  = 'X-CSRF-Token'
*            value = lv_xcsrf1 )
*
*          " ETag required for HEADER
*          ( name  = 'If-Match'
*            value = lv_etag1 )
*        )
*      ).
*
*
*      lo_header_patch_request->set_text(
*        lv_payload3
*      ).
*
*
*      DATA(lo_patch_response1) =
*        lo_client->execute(
*          if_web_http_client=>patch
*        ).
*
*
*      DATA(lv_status3) =
*        lo_patch_response1->get_status( ).
*
*
*      DATA(lv_response_text3) =
*        lo_patch_response1->get_text( ).


      "==================================================================*
      "* 5. Read RFQ Items
      "==================================================================*

      SELECT FROM @lt_rfq_item AS rfq

        INNER JOIN zmm_apps08_sup AS sup

          ON sup~RequestForQuotation =
             rfq~RequestForQuotation

         AND sup~RequestForQuotationItem =
             rfq~RequestForQuotationItem

         AND sup~Supplier =
             rfq~Supplier

        FIELDS

          rfq~curr,
          rfq~rate,
          rfq~OrderQuantityUnit,
          rfq~requested,
          rfq~ScheduleLineOrderQuantity,

          sup~SupplierQuotation,
          sup~SupplierQuotationItem

        WHERE rfq~RequestForQuotation =
              @ls_header-RequestForQuotation

        INTO TABLE @DATA(lt_rfq_item1).


      "==================================================================*
      "* 6. LOOP RFQ ITEMS
      "==================================================================*

      LOOP AT lt_rfq_item1 INTO DATA(ls_rfq_item).


        "================================================================*
        "* Get UOM
        "================================================================*

        TRY.

            cl_uom_maintenance=>get_instance( )->read(

              EXPORTING

                unit = ls_rfq_item-OrderQuantityUnit

                language = 'E'

              IMPORTING

                unit_st = DATA(ls_item_uom)
            ).


          CATCH cx_uom_error INTO DATA(lx_error1).

            DATA(lv_error_text) =
              lx_error1->get_text( ).

            APPEND VALUE #(
              %tky = ls_header-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text = lv_error_text
              )
            ) TO reported-zmm_i_apps08_rv.

            RETURN.

        ENDTRY.


        "================================================================*
        "* 7. PATCH SupplierQuotationItem
        "*
        "* IMPORTANT:
        "* DO NOT SEND If-Match
        "*
        "* SupplierQuotationItem does NOT support ETag according
        "* to your Gateway error.
        "================================================================*


        DATA(lv_payload2) =
          |\{"DocumentCurrency":"{ ls_header-DocumentCurrency }",|
          && |"NetPriceAmount":{ ls_rfq_item-rate },|
          && |"OrderQuantityUnit":"{ ls_item_uom-technical }",|
          && |"ScheduleLineOrderQuantity":{ ls_rfq_item-requested }\}|.


        "*****************************************************************
        "* IMPORTANT FIX
        "* Create a completely NEW request object
        "*****************************************************************

        DATA(lo_item_patch_request) =
          lo_client->get_http_request( ).


        lo_item_patch_request->set_uri_path(
          |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotationItem(SupplierQuotation='{ ls_rfq_item-SupplierQuotation }',SupplierQuotationItem='{ ls_rfq_item-SupplierQuotationItem }')|
        ).


        "*****************************************************************
        "* IMPORTANT
        "* NO If-Match HERE
        "*****************************************************************

        lo_item_patch_request->set_header_fields(
          VALUE #(

            ( name = 'Authorization'
              value = |Basic { lv_auth_base64 }| )

            ( name = 'Accept'
              value = 'application/json' )

            ( name = 'Content-Type'
              value = 'application/json' )

            ( name = 'X-CSRF-Token'
              value = lv_xcsrf )

          )
        ).


        lo_item_patch_request->set_text(
          lv_payload2
        ).


        "*****************************************************************
        "* Execute Item PATCH
        "*****************************************************************

        DATA(lo_patch_response) =
          lo_client->execute(
            if_web_http_client=>patch
          ).


        DATA(lv_status2) =
          lo_patch_response->get_status( ).


        DATA(lv_response_text2) =
          lo_patch_response->get_text( ).


        "================================================================*
        "* Check Item PATCH result
        "================================================================*

        IF lv_status2-code < 200
           OR lv_status2-code >= 300.

          APPEND VALUE #(
            %tky = ls_header-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error

              text =
                |SupplierQuotationItem PATCH failed. HTTP { lv_status2-code }: { lv_response_text2 }|
            )
          ) TO reported-zmm_i_apps08_rv.

          RETURN.

        ENDIF.


      ENDLOOP.

      "==================================================================*
      "* 3. GET CREATED SupplierQuotation
      "*    Fetch latest CSRF + ETag
      "==================================================================*

      " IMPORTANT:
    " New request object
      DATA(lo_get_request1) =
        lo_client->get_http_request( ).


      lo_get_request1->set_uri_path(
        |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/{ lv_supplierquotation }|
      ).


      lo_get_request1->set_header_fields(
        VALUE #(
          ( name  = 'Authorization'
            value = |Basic { lv_auth_base64 }| )

          ( name  = 'Accept'
            value = 'application/json' )

          ( name  = 'X-CSRF-Token'
            value = 'fetch' )
        )
      ).


      DATA(lo_get_response1) =
        lo_client->execute(
          if_web_http_client=>get
        ).


      " IMPORTANT:
      " Read from lo_get_response1, NOT lo_get_response
      DATA(lv_status5) =
        lo_get_response1->get_status( ).


      DATA(lv_xcsrf1) =
        lo_get_response1->get_header_field(
          'x-csrf-token'
        ).


      DATA(lv_etag1) =
        lo_get_response1->get_header_field(
          'etag'
        ).


      "------------------------------------------------------------------*
      "* Validate CSRF
      "------------------------------------------------------------------*
      IF lv_xcsrf1 IS INITIAL.

        APPEND VALUE #(
          %tky = ls_header-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text =
              |CSRF token not received for supplier { ls_header-Supplier }|
          )
        ) TO reported-zmm_i_apps08_rv.

        RETURN.

      ENDIF.


      "------------------------------------------------------------------*
      "* Validate ETag
      "------------------------------------------------------------------*
      IF lv_etag1 IS INITIAL.

        APPEND VALUE #(
          %tky = ls_header-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |ETag not available for SupplierQuotation|
          )
        ) TO reported-zmm_i_apps08_rv.

        RETURN.

      ENDIF.


      "==================================================================*
      "* 4. PATCH SupplierQuotation HEADER
      "*
      "* If-Match IS USED here
      "==================================================================*

      DATA(lv_payload3) =
        |\{"YY1_Remarks_PDH":"{ ls_header-Remarks }"\}|.


      " IMPORTANT:
      " New request object
      DATA(lo_header_patch_request) =
        lo_client->get_http_request( ).


      lo_header_patch_request->set_uri_path(
        |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation(SupplierQuotation='{ lv_supplierquotation }')|
      ).


      lo_header_patch_request->set_header_fields(
        VALUE #(
          ( name  = 'Authorization'
            value = |Basic { lv_auth_base64 }| )

          ( name  = 'Accept'
            value = 'application/json' )

          ( name  = 'Content-Type'
            value = 'application/json' )

          ( name  = 'X-CSRF-Token'
            value = lv_xcsrf1 )

          " ETag required for HEADER
          ( name  = 'If-Match'
            value = lv_etag1 )
        )
      ).


      lo_header_patch_request->set_text(
        lv_payload3
      ).


      DATA(lo_patch_response1) =
        lo_client->execute(
          if_web_http_client=>patch
        ).


      DATA(lv_status3) =
        lo_patch_response1->get_status( ).


      DATA(lv_response_text3) =
        lo_patch_response1->get_text( ).

    ELSE.

      APPEND VALUE #(
        %tky = ls_header-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error

          text =
            |Supplier Quotation creation failed. HTTP { lv_status-code }: { lv_response_text }|
        )
      ) TO reported-zmm_i_apps08_rv.

      RETURN.

    ENDIF.


  CATCH cx_http_dest_provider_error
        cx_web_http_client_error
        cx_web_message_error
        INTO DATA(lx_error).

    APPEND VALUE #(
      %tky = ls_header-%tky
      %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-error
        text = lx_error->get_text( )
      )
    ) TO reported-zmm_i_apps08_rv.

ENDTRY.



  ENDMETHOD.

  METHOD get_instance_features.
**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_i_apps08_rv ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).

    DATA(ls_hdr) = lt_hdr[ 1 ].
**********************************************************************
    SELECT SINGLE FROM I_SupplierQuotation_Api01 FIELDS RequestForQuotation
    WHERE RequestForQuotation = @ls_hdr-RequestForQuotation
    AND Supplier =  @ls_hdr-Supplier
    INTO @DATA(lt_qta).
**********************************************************************
    result              = VALUE #( FOR ls_H IN lt_hdr
                                ( %tky = ls_H-%tky

   %action-submit      = COND #( WHEN lt_qta IS INITIAL
                                 THEN
                                 if_abap_behv=>fc-o-enabled
                                 ELSE
                                 if_abap_behv=>fc-o-disabled )


                                                            ) ).

  ENDMETHOD.

  METHOD finalsubmit.
**********************************************************************
    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_i_apps08_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).
    DATA(ls_header) = lt_header[ 1 ].
**********************************************************************
    DATA:
      lv_etag        TYPE string,
      lv_url         TYPE string,
      lv_auth        TYPE string,
      lv_message_err TYPE string.

*--------------------------------------------------------------------*
* Get system URL
*--------------------------------------------------------------------*
    TRY.
        TRY.
            DATA(system_url) =
            cl_abap_context_info=>get_system_url( ).
          CATCH cx_abap_context_info_error  INTO DATA(lx_erro1).
            DATA(lv_err1) = lx_erro1->get_text( ).
        ENDTRY.
*--------------------------------------------------------------------*
* Determine host
*--------------------------------------------------------------------*
        DATA(lv_host) = COND string(
          WHEN system_url CS 'my437525'
            THEN 'https://my437525-api.s4hana.cloud.sap'

          WHEN system_url CS 'my425571'
            THEN 'https://my425571-api.s4hana.cloud.sap'

          WHEN system_url CS 'my437194'
            THEN 'https://my437194-api.s4hana.cloud.sap'

          ELSE ''
            ).

*--------------------------------------------------------------------*
* Authentication
*--------------------------------------------------------------------*
        lv_auth = 'INTEGRATION_2:Vendor123456789098765#'.

        DATA(lv_auth_base64) =
            cl_web_http_utility=>encode_base64( lv_auth ).

*--------------------------------------------------------------------*
* Create ONE HTTP destination
*--------------------------------------------------------------------*
        DATA(lo_destination) =
          cl_http_destination_provider=>create_by_url( lv_host ).

*--------------------------------------------------------------------*
* Create ONE HTTP client
*--------------------------------------------------------------------*
        DATA(lo_client) =
          cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        DATA(lo_request) =
          lo_client->get_http_request( ).

*--------------------------------------------------------------------*
* GET Delivery - Fetch CSRF Token + ETag
*--------------------------------------------------------------------*
        lo_request->set_uri_path(
          |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/{ ls_header-SupplierQuotation }|
*          |supplierquotation/0001/SupplierQuotation|
            ).

        lo_request->set_header_fields(
          VALUE #(
                ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )

                ( name  = 'Accept' value = 'application/json' )

                ( name  = 'X-CSRF-Token' value = 'fetch' )
                  )
                ).

*--------------------------------------------------------------------*
* Execute GET
*--------------------------------------------------------------------*
        DATA(lo_get_response) =
          lo_client->execute( if_web_http_client=>get ).

        DATA(lv_status1) =
           lo_get_response->get_status( ).

*--------------------------------------------------------------------*
* Get CSRF Token
*--------------------------------------------------------------------*
        DATA(lv_xcsrf) =
          lo_get_response->get_header_field( 'x-csrf-token' ).

        lv_etag = lo_get_response->get_header_field( 'etag' ).


*--------------------------------------------------------------------*
* Validate CSRF
*--------------------------------------------------------------------*
        IF lv_xcsrf IS INITIAL.

          APPEND VALUE #(
            %tky = ls_header-%tky
            %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |CSRF token not received for delivery { ls_header-Supplier }|
            )
          ) TO reported-zmm_i_apps08_rv.

          RETURN.

        ENDIF.
*--------------------------------------------------------------------*
* Validate ETag
*--------------------------------------------------------------------*
        IF lv_etag IS INITIAL.

          APPEND VALUE #(
              %tky = ls_header-%tky
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |ETag Not avilable For this Sup|
              )
            ) TO reported-zmm_i_apps08_rv.

          RETURN.

        ENDIF.
*--------------------------------------------------------------------*
* Submit For Quotations
*--------------------------------------------------------------------*

        lo_request->set_uri_path(
                  |/sap/opu/odata4/sap/api_supplierquotation_2/srvd_a2x/sap/supplierquotation/0001/SupplierQuotation/{ ls_header-SupplierQuotation }/SAP__self.Submit|
*          |supplierquotation/0001/SupplierQuotation/SAP__self.CreateSuplrQtnFromRFQAllItems|
                    ).

*--------------------------------------------------------------------*
* Set POST headers
*--------------------------------------------------------------------*
        lo_request->set_header_fields(
          VALUE #(
                ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )

                ( name  = 'Accept' value = 'application/json' )

                ( name  = 'Content-Type' value = 'application/json' )

                ( name  = 'X-CSRF-Token' value = lv_xcsrf )

                ( name = 'If-Match' value = lv_etag  )


                  )
                ).
*--------------------------------------------------------------------*
* Execute POST
*--------------------------------------------------------------------*
        DATA(lo_post_response) =
          lo_client->execute(
            if_web_http_client=>post ).

*--------------------------------------------------------------------*
* Get status
*--------------------------------------------------------------------*
        DATA(lv_status) =
              lo_post_response->get_status( ).

        DATA(lv_response_text) =
              lo_post_response->get_text( ).

**********************************************************************
**********************************************************************

        IF lv_status-code = 204.

        ELSE.

        ENDIF.
*--------------------------------------------------------------------*
* Check result
*--------------------------------------------------------------------*

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            cx_web_message_error
            INTO DATA(lx_error).

        APPEND VALUE #(
        %tky = ls_header-%tky
        %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-error
        text     = lx_error->get_text( )
          )
        ) TO reported-zmm_i_apps08_rv.

    ENDTRY.





**********************************************************************
  ENDMETHOD.

  METHOD gt_hdr1.
**********************************************************************
**********************************************************************

    DATA : lt_gthdr TYPE TABLE OF zmm_a_apps08_htb,
           ls_gthdr TYPE zmm_a_apps08_htb.

    READ ENTITIES OF zmm_i_apps08_rv IN LOCAL MODE
    ENTITY zmm_i_apps08_rv ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).

    DATA(ls_hdr) = lt_hdr[ 1 ].

    MOVE-CORRESPONDING ls_hdr TO ls_gthdr.

    APPEND ls_gthdr TO zbp_mm_i_apps08_rv=>gt_hdr.


    IF ls_hdr-SupplierQuotation IS NOT INITIAL.

      MODIFY ENTITIES OF I_SupplierQuotationTP PRIVILEGED ENTITY SupplierQuotation
     UPDATE FROM VALUE #(  ( SupplierQuotation = ls_hdr-SupplierQuotation
      YY1_Remarks_PDH = ls_hdr-Remarks



      %control-YY1_Remarks_PDH = if_abap_behv=>mk-on
         )   )
          MAPPED DATA(lt_mapped)
        FAILED DATA(lt_faields)
        REPORTED DATA(lt_reportd).



    ENDIF.


**********************************************************************
**********************************************************************




**********************************************************************
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_I_APPS08_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMM_I_APPS08_RV IMPLEMENTATION.

  METHOD save_modified.

    IF zbp_mm_i_apps08_rv=>gt_hdr IS NOT INITIAL.
      MODIFY zmm_a_apps08_htb FROM TABLE @zbp_mm_i_apps08_rv=>gt_hdr.
    ENDIF.


    IF zbp_mm_i_apps08_rv=>gt_item IS NOT INITIAL.
      MODIFY zmm_a_apps08_itm FROM TABLE @zbp_mm_i_apps08_rv=>gt_item.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
