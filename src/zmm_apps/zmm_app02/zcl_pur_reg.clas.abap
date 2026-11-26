CLASS zcl_pur_reg DEFINITION

  PUBLIC

  FINAL

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_pur_reg IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

**********************************************************************
* Output Data
**********************************************************************
      DATA: lt_outdata   TYPE TABLE OF zmm_pur_reg_ce,
            ls_outdata   LIKE LINE OF lt_outdata,
            lt_finaldata TYPE TABLE OF zmm_pur_reg_ce,
            ls_finaldata LIKE LINE OF lt_outdata.
**********************************************************************
* Paging
**********************************************************************
      DATA(lv_top) =
        io_request->get_paging( )->get_page_size( ).

      DATA(lv_skip) =
        io_request->get_paging( )->get_offset( ).

      DATA(lv_max_rows) =
        COND #(
          WHEN lv_top = if_rap_query_paging=>page_size_unlimited
          THEN 0
          ELSE lv_top ).
**********************************************************************
* Filter
**********************************************************************
      TRY.

          DATA(lt_clause) =
            io_request->get_filter( )->get_as_ranges( ).

        CATCH cx_rap_query_filter_no_range.

          DATA(lvere) = 1.

      ENDTRY.


      DATA(lt_parameter) =
        io_request->get_parameters( ).

      DATA(lt_fields) =
        io_request->get_requested_elements( ).

      DATA(lt_sort) =
        io_request->get_sort_elements( ).

**********************************************************************
* Get Filter Conditions
**********************************************************************
      TRY.

          DATA(lt_filter_cond) =
            io_request->get_filter( )->get_as_ranges( ).

        CATCH cx_rap_query_filter_no_range
              INTO DATA(lx_no_sel_option).

          DATA(lvere2) = 1.

      ENDTRY.

**********************************************************************
* Filter Ranges
**********************************************************************

      DATA:
        lt_purchaseorder
          TYPE RANGE OF zmm_pur_reg_pv_01-purchaseorder,

        lt_purchaseorderitem
          TYPE RANGE OF zmm_pur_reg_pv_01-purchaseorderitem,

        lt_companycode
          TYPE RANGE OF zmm_pur_reg_pv_01-companycode.

*        lt_purchaserequisition
*          TYPE RANGE OF zmm_pur_reg_pv_01-PurchaseRequisition.

**********************************************************************
* Prepare Filter Values
**********************************************************************

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

        IF ls_filter_cond-name = 'PURCHASEORDER'.

          LOOP AT ls_filter_cond-range
               INTO DATA(ls_range_po).

            APPEND VALUE #(
              sign   = ls_range_po-sign
              option = ls_range_po-option
              low    = CONV zmm_pur_reg_pv_01-purchaseorder(
                         ls_range_po-low )
              high   = CONV zmm_pur_reg_pv_01-purchaseorder(
                         ls_range_po-high )
            ) TO lt_purchaseorder.

          ENDLOOP.


        ELSEIF ls_filter_cond-name = 'PURCHASEORDERITEM'.

          LOOP AT ls_filter_cond-range
               INTO DATA(ls_range_item).

            APPEND VALUE #(
              sign   = ls_range_item-sign
              option = ls_range_item-option
              low    = CONV zmm_pur_reg_pv_01-purchaseorderitem(
                         ls_range_item-low )
              high   = CONV zmm_pur_reg_pv_01-purchaseorderitem(
                         ls_range_item-high )
            ) TO lt_purchaseorderitem.

          ENDLOOP.


        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.

          LOOP AT ls_filter_cond-range
               INTO DATA(ls_range_cc).

            APPEND VALUE #(
              sign   = ls_range_cc-sign
              option = ls_range_cc-option
              low    = CONV zmm_pur_reg_pv_01-companycode(
                         ls_range_cc-low )
              high   = CONV zmm_pur_reg_pv_01-companycode(
                         ls_range_cc-high )
            ) TO lt_companycode.

          ENDLOOP.

*        ELSEIF ls_filter_cond-name = 'PURCHASEREQUISITION'.
*
*          LOOP AT ls_filter_cond-range
*               INTO DATA(ls_range_pr).
*
*            APPEND VALUE #(
*              sign   = ls_range_pr-sign
*              option = ls_range_pr-option
*              low    = CONV zmm_pur_reg_pv_01-purchaserequisition(
*                         ls_range_pr-low )
*              high   = CONV zmm_pur_reg_pv_01-purchaserequisition(
*                         ls_range_pr-high )
*            ) TO lt_purchaserequisition.
*
*          ENDLOOP.

        ENDIF.

      ENDLOOP.

**********************************************************************
* Purchase Register Data
*
* IMPORTANT:
* DO NOT DELETE DUPLICATES HERE.
*
* If one PO item has 2 GRNs, both records must remain.
**********************************************************************
      SELECT *
        FROM zmm_pur_reg_pv_01
          WHERE PurchaseOrder     IN @lt_purchaseorder
          AND PurchaseOrderItem IN @lt_purchaseorderitem
          AND CompanyCode       IN @lt_companycode
*          AND PurchaseRequisition IN @lt_purchaserequisition
          INTO TABLE @DATA(lt_pur).
**********************************************************************
* Approval - Workflow Overview
**********************************************************************

      TYPES:

        BEGIN OF ty_workflow,
          purchaseorder TYPE I_WorkflowStatusOverview-SAPBusinessObjectNodeKey1,
        END OF ty_workflow.
      DATA lt_workflow TYPE TABLE OF ty_workflow.

**********************************************************************
* Prepare Purchase Order List
**********************************************************************

      LOOP AT lt_pur ASSIGNING FIELD-SYMBOL(<ls_pur>).

        IF <ls_pur>-PurchaseOrder IS NOT INITIAL.

          APPEND VALUE #(
            purchaseorder =
              <ls_pur>-PurchaseOrder
          ) TO lt_workflow.

        ENDIF.
      ENDLOOP.

**********************************************************************
* Remove Duplicate Purchase Orders
*
* This is ONLY for workflow selection.
* It does NOT affect lt_pur.
**********************************************************************
      SORT lt_workflow BY purchaseorder.
      DELETE ADJACENT DUPLICATES FROM lt_workflow COMPARING purchaseorder.
**********************************************************************
* Get Workflow Status Overview
**********************************************************************
      DATA lt_wfs TYPE TABLE OF I_WorkflowStatusOverview.
**********************************************************************
      "comment 26-10-26
*      IF lt_workflow IS NOT INITIAL.
*
*        SELECT *
*          FROM I_WorkflowStatusOverview
*          FOR ALL ENTRIES IN @lt_workflow
*          WHERE SAPBusinessObjectNodeKey1 = @lt_workflow-purchaseorder
*          INTO TABLE @lt_wfs.
*
*      ENDIF.

      IF lt_workflow IS NOT INITIAL.

        SELECT SAPBusinessObjectNodeKey1,
           WrkflwTskCompletionUTCDateTime,
           WorkflowInternalID
       FROM I_WorkflowStatusOverview
       FOR ALL ENTRIES IN @lt_workflow
       WHERE SAPBusinessObjectNodeKey1 = @lt_workflow-purchaseorder
       INTO CORRESPONDING FIELDS OF TABLE @lt_wfs.

      ENDIF.

**********************************************************************
* Get Workflow Status Details
**********************************************************************
      DATA lt_wfi TYPE TABLE OF I_WorkflowStatusDetails.
**********************************************************************
      "comment 26-10-26
*      IF lt_wfs IS NOT INITIAL.
*
*        SELECT *
*          FROM I_WorkflowStatusDetails
*          FOR ALL ENTRIES IN @lt_wfs
*          WHERE WorkflowInternalID = @lt_wfs-WorkflowInternalID
*          INTO TABLE @lt_wfi.
*
*      ENDIF.

*IF lt_wfs IS NOT INITIAL.
*
*  SELECT WorkflowInternalID,
*         WrkflwTskCompletionUTCDateTime,
*         WorkflowTaskProcessor
*    FROM I_WorkflowStatusDetails
*    FOR ALL ENTRIES IN @lt_wfs
*    WHERE WorkflowInternalID = @lt_wfs-WorkflowInternalID
*    INTO CORRESPONDING FIELDS OF TABLE @lt_wfi.
*
*ENDIF.



      " Workflow Details
*DATA lt_wfi TYPE TABLE OF I_WorkflowStatusDetails.

      IF lt_wfs IS NOT INITIAL.

        " CHANGED: INNER JOIN replaces FOR ALL ENTRIES
        SELECT DISTINCT
               wfi~WorkflowInternalID,
               wfi~WrkflwTskCompletionUTCDateTime,
               wfi~WorkflowTaskProcessor
          FROM @lt_wfs AS wfs
          INNER JOIN I_WorkflowStatusDetails AS wfi
            ON wfi~WorkflowInternalID = wfs~WorkflowInternalID
          INTO CORRESPONDING FIELDS OF TABLE @lt_wfi.

      ENDIF.

**********************************************************************
* Sort Workflow Overview
**********************************************************************
      SORT lt_wfs BY
        SAPBusinessObjectNodeKey1
        WrkflwTskCompletionUTCDateTime
        WorkflowInternalID.
**********************************************************************
* Sort Workflow Details
**********************************************************************
      SORT lt_wfi BY
        WorkflowInternalID
        WrkflwTskCompletionUTCDateTime.
**********************************************************************
* Business User
**********************************************************************

      TYPES: BEGIN OF ty_business_user,
               UserID         TYPE I_BusinessUserBasic-UserID,
               PersonFullName TYPE I_BusinessUserBasic-PersonFullName,
             END OF ty_business_user.

      DATA lt_business_user TYPE TABLE OF ty_business_user.

**********************************************************************
* Get Business User Names
**********************************************************************
      IF lt_wfi IS NOT INITIAL.

        SELECT
             UserID,
             PersonFullName
          FROM I_BusinessUserBasic
          FOR ALL ENTRIES IN @lt_wfi
          WHERE UserID = @lt_wfi-WorkflowTaskProcessor
          INTO TABLE @lt_business_user.

      ENDIF.

**********************************************************************
* Remove Duplicate Business Users
**********************************************************************
      SORT lt_business_user BY UserID.
      DELETE ADJACENT DUPLICATES FROM lt_business_user COMPARING UserID.

**********************************************************************
* Main Purchase Register Loop
*
* IMPORTANT:
* Every record in lt_pur is processed.
*
* Therefore:
*
* PO Item 10 - GRN 1 -> Line 1
* PO Item 10 - GRN 2 -> Line 2
* PO Item 20 - GRN 1 -> Line 3
* PO Item 20 - GRN 2 -> Line 4
* PO Item 30 - GRN 1 -> Line 5
* PO Item 30 - GRN 2 -> Line 6
**********************************************************************
      LOOP AT lt_pur INTO DATA(ls_pur).
**********************************************************************
* Clear Output Structure
**********************************************************************
        CLEAR ls_outdata.
**********************************************************************
* Purchase Register Fields
**********************************************************************
        ls_outdata-PurchaseOrder = ls_pur-PurchaseOrder.
        ls_outdata-PurchaseOrderItem = ls_pur-PurchaseOrderItem.
        ls_outdata-PurchasingHistoryDocument = ls_pur-PurchasingHistoryDocument.
        ls_outdata-SupplierInvoice = ls_pur-SupplierInvoice.
        ls_outdata-SupplierInvoiceItem = ls_pur-SupplierInvoiceItem.
        ls_outdata-FiscalYear = ls_pur-FiscalYear.
        ls_outdata-PurchaseRequisition = ls_pur-PurchaseRequisition.
        ls_outdata-Material = ls_pur-Material.
        ls_outdata-PurchaseOrderItemText = ls_pur-PurchaseOrderItemText.
        ls_outdata-BaseUnit = ls_pur-BaseUnit.
        ls_outdata-NetAmount =  ls_pur-NetAmount.
        ls_outdata-DocumentCurrency = ls_pur-POCurrency.
        ls_outdata-TaxCode = ls_pur-TaxCode.
        ls_outdata-OrderQuantity = ls_pur-OrderQuantity.
        ls_outdata-NetPriceAmount =  ls_pur-NetPriceAmount.
        ls_outdata-CompanyCode =  ls_pur-CompanyCode.
        ls_outdata-PurchaseOrderDate = ls_pur-PurchaseOrderDate.
        ls_outdata-ScheduleLineDeliveryDate = ls_pur-ScheduleLineDeliveryDate.
        ls_outdata-PurchaseOrderQuantityUnit = ls_pur-BaseUnit.
        ls_outdata-BalanceOrderQuantity = ls_pur-BalanceOrderQuantity.
        ls_outdata-PostingDate = ls_pur-PostingDate.
        ls_outdata-Quantity =  ls_pur-Quantity.
        ls_outdata-IsCompletelyDelivered =  ls_pur-IsCompletelyDelivered.
        ls_outdata-CreationDate =  ls_pur-CreationDate.
        ls_outdata-IGSTAmount =  ls_pur-IGSTAmount.
        ls_outdata-CGSTAmount =  ls_pur-CGSTAmount.
        ls_outdata-SGSTAmount =  ls_pur-SGSTAmount.
        ls_outdata-igst = ls_pur-igst.
        ls_outdata-cgst =  ls_pur-cgst.
        ls_outdata-sgst = ls_pur-sgst.
        ls_outdata-TaxPercentage = ls_pur-TaxPercentage.
        ls_outdata-PlantName = ls_pur-PlantName.
        ls_outdata-MaterialTypeName = ls_pur-MaterialTypeName.
        ls_outdata-SupplierName = ls_pur-SupplierName.
        ls_outdata-PurchasingGroupName =  ls_pur-PurchasingGroupName.
        ls_outdata-PurchaseOrderType = ls_pur-PurchaseOrderType.
        ls_outdata-GrnAmount = ls_pur-GrnAmount.
        ls_outdata-InvoiceDate = ls_pur-InvoiceDate.
        ls_outdata-SupplierInvoiceIDByInvcgParty = ls_pur-InvoiceReferenceNumber.
        ls_outdata-SupplierReferenceNumber = ls_pur-SupplierReferenceNumber.
        ls_outdata-SupplierReferenceDate = ls_pur-SupplierReferenceDate.


**********************************************************************
* Clear Approval Fields
**********************************************************************

        CLEAR:
          ls_outdata-WorkflowProcessor1,
          ls_outdata-WorkflowProcessor2,
          ls_outdata-WorkflowProcessor3,
          ls_outdata-WorkflowProcessor,
          ls_outdata-WorkflowCompletionTime1,
          ls_outdata-WorkflowCompletionTime2,
          ls_outdata-WorkflowCompletionTime3.

**********************************************************************
* Approval Counter
**********************************************************************
        DATA(lv_approval_count) = 0.
**********************************************************************
* Approval Level Processing
**********************************************************************
        LOOP AT lt_wfs INTO DATA(ls_wfs)
          WHERE SAPBusinessObjectNodeKey1 = ls_pur-PurchaseOrder.
**********************************************************************
* Workflow Details
**********************************************************************
          LOOP AT lt_wfi INTO DATA(ls_wfi)
            WHERE WorkflowInternalID = ls_wfs-WorkflowInternalID.
**********************************************************************
* Ignore Empty Processor
**********************************************************************
            IF ls_wfi-WorkflowTaskProcessor IS INITIAL.
              CONTINUE.
            ENDIF.

**********************************************************************
* Increase Approval Counter
**********************************************************************
            lv_approval_count = lv_approval_count + 1.
**********************************************************************
* First Approval
**********************************************************************
            IF lv_approval_count = 1.

              LOOP AT lt_business_user
                INTO DATA(ls_business_user1)
                WHERE UserID = ls_wfi-WorkflowTaskProcessor.
                ls_outdata-WorkflowProcessor1 = ls_business_user1-PersonFullName.

                EXIT.
              ENDLOOP.
**********************************************************************
* First Approval Completion Time
**********************************************************************

*              ls_outdata-WorkflowCompletionTime =
*                ls_wfi-WrkflwTskCompletionUTCDateTime.

              " " added 06-10-2026 for First Approval Completion Time

              DATA(lv_timestamp) = CONV string( ls_wfi-WrkflwTskCompletionUTCDateTime ).

              DATA(lv_date) = lv_timestamp(8).

              ls_outdata-WorkflowCompletionTime1 = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date+0(4) }|.

**********************************************************************
* Second Approval
**********************************************************************

            ELSEIF lv_approval_count = 2.

              LOOP AT lt_business_user
                INTO DATA(ls_business_user2)
                WHERE UserID = ls_wfi-WorkflowTaskProcessor.
                ls_outdata-WorkflowProcessor2 = ls_business_user2-PersonFullName.

                EXIT.

              ENDLOOP.
*********************************************************************
              " added 06-10-2026 for Second Approval Completion Time

              DATA(lv_timestamp2) = CONV string( ls_wfi-WrkflwTskCompletionUTCDateTime ).

              DATA(lv_date2) = lv_timestamp2(8).

              ls_outdata-WorkflowCompletionTime2 = |{ lv_date2+6(2) }/{ lv_date2+4(2) }/{ lv_date2+0(4) }|.

*********************************************************************
**********************************************************************
* Third Approval
**********************************************************************

            ELSEIF lv_approval_count = 3.

              LOOP AT lt_business_user
                INTO DATA(ls_business_user3)
                WHERE UserID = ls_wfi-WorkflowTaskProcessor.
                ls_outdata-WorkflowProcessor3 = ls_business_user3-PersonFullName.

                EXIT.

              ENDLOOP.


*********************************************************************
              " added 06-10-2026 for Third Approval Completion Time

              DATA(lv_timestamp3) = CONV string( ls_wfi-WrkflwTskCompletionUTCDateTime ).

              DATA(lv_date3) = lv_timestamp3(8).

              ls_outdata-WorkflowCompletionTime3 = |{ lv_date3+6(2) }/{ lv_date3+4(2) }/{ lv_date3+0(4) }|.

**********************************************************************
* Stop After Third Approval
**********************************************************************

              EXIT.

            ENDIF.

          ENDLOOP.

**********************************************************************
* Stop Outer Workflow Loop After 3 Approvals
**********************************************************************

          IF lv_approval_count >= 3.

            EXIT.

          ENDIF.

        ENDLOOP.


**********************************************************************
* Append Every GRN Record
**********************************************************************
        APPEND ls_outdata TO lt_outdata.
**********************************************************************
* Clear Output
**********************************************************************
        CLEAR ls_outdata.

      ENDLOOP.
**********************************************************************
* Sort Output
*
* GRN/Purchasing History Document is included so that
* separate GRN records remain separate.
**********************************************************************
      SORT lt_outdata BY
        PurchaseOrder
        PurchaseOrderItem
        CompanyCode
        PurchasingHistoryDocument
        SupplierInvoice
        SupplierInvoiceItem.

**********************************************************************
* DO NOT DELETE DUPLICATES HERE
* Multiple GRNs for the same PO Item are valid records.
**********************************************************************
* Paging
**********************************************************************

      lv_max_rows =
        lv_skip + lv_top.

      IF lv_skip > 0.

        lv_skip =
          lv_skip + 1.

      ENDIF.

**********************************************************************
* Clear Final Data
**********************************************************************
      CLEAR lt_finaldata.
**********************************************************************
* Fill Final Data
**********************************************************************

      IF lv_top = if_rap_query_paging=>page_size_unlimited.

        lt_finaldata = lt_outdata.

      ELSE.

        LOOP AT lt_outdata

          ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>)

          FROM lv_skip

          TO lv_max_rows.

          ls_finaldata =
            <lfs_out_line_item>.

          APPEND ls_finaldata
            TO lt_finaldata.

        ENDLOOP.

      ENDIF.


**********************************************************************
* Response
**********************************************************************

      io_response->set_total_number_of_records(
        lines( lt_outdata ) ).

      io_response->set_data(
        lt_finaldata ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
