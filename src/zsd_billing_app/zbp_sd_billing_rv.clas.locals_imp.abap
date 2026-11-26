    CLASS lhc_zsd_billing_irv DEFINITION INHERITING FROM cl_abap_behavior_handler.

      PRIVATE SECTION.

        METHODS fill_ldata FOR DETERMINE ON SAVE
           keys FOR item~fill_ldata.
        METHODS calculatetax FOR DETERMINE ON MODIFY
           keys FOR item~calculatetax.
        METHODS updategrossamount FOR DETERMINE ON MODIFY
           keys FOR item~updategrossamount.
        METHODS syncheaderinvoicingparty FOR DETERMINE ON MODIFY
           keys FOR item~syncheaderinvoicingparty.
        METHODS check_duplicate_item FOR VALIDATE ON SAVE
          IMPORTING keys FOR item~check_duplicate_item.
        METHODS get_instance_features FOR INSTANCE FEATURES
          keys REQUEST requested_features FOR item RESULT result.
        METHODS check_duplicate FOR DETERMINE ON MODIFY
           keys FOR item~check_duplicate.
        METHODS fill_from_billing FOR DETERMINE ON MODIFY
           keys FOR item~fill_from_billing.
        METHODS check_invoicing_party FOR VALIDATE ON SAVE
           keys FOR item~check_invoicing_party.
        METHODS synchdrin_delete FOR DETERMINE ON SAVE
           keys FOR item~synchdrin_delete.
    ENDCLASS.

    CLASS lhc_zsd_billing_irv IMPLEMENTATION.


      METHOD fill_ldata.

        DATA ls_linedata TYPE zsd_billing_itb.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_line).

        IF lt_line IS INITIAL.
          RETURN.
        ENDIF.



        LOOP AT lt_line INTO DATA(ls_line).

          CLEAR ls_linedata.

          "Unique Item UUID
          ls_linedata-item_uuid = ls_line-ItemUuid.

          "Parent Header UUID
          ls_linedata-bill_uuid = ls_line-BillUuid.

          IF ls_linedata-item_uuid IS INITIAL
             OR ls_linedata-bill_uuid IS INITIAL.
            CONTINUE.
          ENDIF.

          ls_linedata-gl_account = '48130000'.
          ls_linedata-cost_centre = ls_line-CostCentre.
          ls_linedata-item_text = ls_line-ItemText.
          ls_linedata-assignment = ls_line-Assignment.
          ls_linedata-payment_terms = ls_line-PaymentTerms.
          ls_linedata-tax_code = ls_line-TaxCode.
          ls_linedata-sales_billing_no = ls_line-SalesBillingNo.
          ls_linedata-sales_billing_item = ls_line-SalesBillingItem.

          ls_linedata-amount = ls_line-Amount.
          ls_linedata-currency_key = ls_line-CurrencyKey.
          ls_linedata-tax_amount = ls_line-TaxAmount.
          ls_linedata-plant = ls_line-Plant.
          ls_linedata-invoicingparty = ls_line-invoicingparty.
          ls_linedata-local_created_by = ls_line-LocalCreatedBy.
          ls_linedata-local_created_at = ls_line-LocalCreatedAt.
          ls_linedata-local_last_changed_by =
            ls_line-LocalLastChangedBy.
          ls_linedata-local_last_changed_at =
            ls_line-LocalLastChangedAt.
          ls_linedata-last_changed_at = ls_line-LastChangedAt.


          "Remove old buffer entry
          DELETE zbp_sd_billing_rv=>gt_lindata
            WHERE item_uuid = ls_linedata-item_uuid.

          "Append latest Item data
          APPEND ls_linedata
            TO zbp_sd_billing_rv=>gt_lindata.

        ENDLOOP.

      ENDMETHOD.




      METHOD CalculateTax.

        DATA: lv_rate TYPE decfloat34,
              lv_tax  TYPE decfloat34.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS ( Amount TaxCode )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).

          CLEAR: lv_rate, lv_tax.

          IF <ls_item>-Amount IS NOT INITIAL
             AND <ls_item>-TaxCode IS NOT INITIAL.

            TRY.
                SELECT SINGLE FROM zsd_taxxode_v4 FIELDS Percentage
                WHERE name = @<ls_item>-TaxCode
                INTO @DATA(ls_cond).
                "Tax Code entered by user is the percentage
                lv_rate = CONV decfloat34( ls_cond ).

                "Calculate tax amount
                lv_tax = CONV decfloat34( <ls_item>-Amount )
                         * lv_rate / 100.

              CATCH cx_sy_conversion_no_number.

                lv_tax = 0.

            ENDTRY.

          ENDIF.

          "Update Tax Amount in RAP entity
          MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY item
            UPDATE FIELDS ( TaxAmount )
            WITH VALUE #(
              (
                %tky      = <ls_item>-%tky
                TaxAmount = lv_tax
              )
            ).

        ENDLOOP.

      ENDMETHOD.

      METHOD UpdateGrossAmount.

        DATA: lv_gross    TYPE zsd_billing_tb-amount,
              lv_currency TYPE zsd_billing_tb-currency_key.

        "Step 1: Read changed Line Items
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS ( BillUuid Amount TaxAmount CurrencyKey )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_changed_items).

        IF lt_changed_items IS INITIAL.
          RETURN.
        ENDIF.

        "Step 2: Get Parent Headers
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item BY \hdr
          ALL FIELDS
          WITH CORRESPONDING #( lt_changed_items )
          RESULT DATA(lt_headers).

        IF lt_headers IS INITIAL.
          RETURN.
        ENDIF.

        "Step 3: Read All Line Items
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY hdr BY \Item
          FIELDS ( BillUuid Amount TaxAmount CurrencyKey )
          WITH CORRESPONDING #( lt_headers )
          RESULT DATA(lt_all_items).

        "Step 4: Calculate Gross Amount and Currency
        LOOP AT lt_headers INTO DATA(ls_header).

          CLEAR: lv_gross, lv_currency.

          LOOP AT lt_all_items INTO DATA(ls_item)
            WHERE BillUuid = ls_header-BillUuid.

            lv_gross = lv_gross
                     + ls_item-Amount
                     + ls_item-TaxAmount.

            IF lv_currency IS INITIAL.
              lv_currency = ls_item-CurrencyKey.
            ENDIF.

          ENDLOOP.

          "Step 5: Update Header Amount and Currency
          MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY hdr
            UPDATE FIELDS ( Amount CurrencyKey )
            WITH VALUE #(
              (
                %tky       = ls_header-%tky
                Amount     = lv_gross
                CurrencyKey = lv_currency
              )
            ).

        ENDLOOP.

      ENDMETHOD.

      METHOD SyncHeaderInvoicingParty.

        DATA: lt_header TYPE TABLE FOR READ RESULT zsd_billing_rv\\hdr.

        "Step 1: Read changed Line Items
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS ( InvoicingParty )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        IF lt_items IS INITIAL.
          RETURN.
        ENDIF.

        "Step 2: Read Parent Header through association
        LOOP AT lt_items INTO DATA(ls_item).

          READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY item BY \hdr
            ALL FIELDS
            WITH VALUE #(
              ( %tky = ls_item-%tky )
            )
            RESULT lt_header.

          IF lt_header IS INITIAL.
            CONTINUE.
          ENDIF.

          "Step 3: Update Header Invoicing Party
          MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY hdr
            UPDATE FIELDS ( InvoicingParty )
            WITH VALUE #(
              FOR ls_hdr IN lt_header
              (
                %tky = ls_hdr-%tky
                InvoicingParty = ls_item-InvoicingParty
              )
            ).

        ENDLOOP.

      ENDMETHOD.

*      METHOD check_duplicate_item.
*        DATA lv_existing_item_uuid TYPE sysuuid_x16.
*
*        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
*          ENTITY item
*          FIELDS (
*            ItemUuid
*            SalesBillingNo
*            SalesBillingItem
*          )
*          WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_items).
*
*        LOOP AT lt_items INTO DATA(ls_item).
*
*          CLEAR lv_existing_item_uuid.
*
*          IF ls_item-SalesBillingNo IS INITIAL
*             OR ls_item-SalesBillingItem IS INITIAL.
*            CONTINUE.
*          ENDIF.
*
*    **********************************************************************
*    * CHECK WHETHER BILLING DOCUMENT + ITEM ALREADY EXISTS
*    **********************************************************************
*
*          SELECT SINGLE FROM zsd_billing_itb
*            FIELDS item_uuid
*            WHERE sales_billing_no =
*                    @ls_item-SalesBillingNo
*              AND sales_billing_item =
*                    @ls_item-SalesBillingItem
*              AND item_uuid <> @ls_item-ItemUuid
*            INTO @lv_existing_item_uuid.
*
*          IF sy-subrc = 0.
*
*            APPEND VALUE #(
*              %tky = ls_item-%tky
*              %msg = new_message_with_text(
*                severity = if_abap_behv_message=>severity-error
*                text =
*                  |Billing Document { ls_item-SalesBillingNo } | &&
*                  | { ls_item-SalesBillingItem } already exists.|
*              )
*            ) TO reported-item.
*
*          ENDIF.
*
*        ENDLOOP.
*      ENDMETHOD.


      METHOD check_duplicate_item.

        DATA lv_existing_item_uuid TYPE sysuuid_x16.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS (
            ItemUuid
            SalesBillingNo
            SalesBillingItem
          )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        IF lt_items IS INITIAL.
          RETURN.
        ENDIF.

        LOOP AT lt_items INTO DATA(ls_item).

          CLEAR lv_existing_item_uuid.

          IF ls_item-SalesBillingNo IS INITIAL
             OR ls_item-SalesBillingItem IS INITIAL.
            CONTINUE.
          ENDIF.

          DATA(lv_duplicate) = abap_false.

          "========================================
          " STEP 1: CHECK DUPLICATES IN SAME RAP
          " TRANSACTION
          "========================================

          LOOP AT lt_items INTO DATA(ls_compare).

            IF ls_compare-ItemUuid = ls_item-ItemUuid.
              CONTINUE.
            ENDIF.

            IF ls_compare-SalesBillingNo =
                 ls_item-SalesBillingNo
               AND ls_compare-SalesBillingItem =
                 ls_item-SalesBillingItem.

              lv_duplicate = abap_true.
              EXIT.

            ENDIF.

          ENDLOOP.

          "========================================
          " STEP 2: CHECK EXISTING DATABASE RECORDS
          "========================================

          IF lv_duplicate = abap_false.

            SELECT SINGLE FROM zsd_billing_itb
              FIELDS item_uuid
              WHERE sales_billing_no =
                      @ls_item-SalesBillingNo
                AND sales_billing_item =
                      @ls_item-SalesBillingItem
                AND item_uuid <> @ls_item-ItemUuid
              INTO @lv_existing_item_uuid.

            IF sy-subrc = 0.
              lv_duplicate = abap_true.
            ENDIF.

          ENDIF.

          "========================================
          " STEP 3: REPORT ERROR AND PREVENT SAVE
          "========================================

          IF lv_duplicate = abap_true.

            APPEND VALUE #(
              %tky = ls_item-%tky

              %element-SalesBillingNo =
                if_abap_behv=>mk-on

              %element-SalesBillingItem =
                if_abap_behv=>mk-on

              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text =
                  |Same Billing no{ ls_item-SalesBillingNo } | &&
                  |Item{ ls_item-SalesBillingItem } is not allowed.|
              )
            ) TO reported-item.

            APPEND VALUE #(
              %tky = ls_item-%tky
            ) TO failed-item.

          ENDIF.

        ENDLOOP.

      ENDMETHOD.




      METHOD get_instance_features.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS ( BillUuid )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        DATA lt_headers TYPE TABLE FOR READ RESULT zsd_billing_Irv\hdr.

        LOOP AT lt_items INTO DATA(ls_item).

          READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY item BY \hdr
            FIELDS ( Supplierinvoice )
            WITH VALUE #(
              ( %tky = ls_item-%tky )
            )
            RESULT lt_headers.

          DATA(ls_header) = VALUE #( lt_headers[ 1 ] OPTIONAL ).

          APPEND VALUE #(
            %tky = ls_item-%tky

            %features-%update =
              COND #(
                WHEN ls_header-Supplierinvoice IS NOT INITIAL
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled
              )

            %features-%delete =
              COND #(
                WHEN ls_header-Supplierinvoice IS NOT INITIAL
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled
              )
          ) TO result.

        ENDLOOP.

      ENDMETHOD.


      METHOD check_duplicate.
        DATA lv_existing_item_uuid TYPE sysuuid_x16.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS (
            ItemUuid
            SalesBillingNo
            SalesBillingItem
          )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        LOOP AT lt_items INTO DATA(ls_item).

          CLEAR lv_existing_item_uuid.

          IF ls_item-SalesBillingNo IS INITIAL
             OR ls_item-SalesBillingItem IS INITIAL.
            CONTINUE.
          ENDIF.

*    *********************************************************************
*     CHECK WHETHER BILLING DOCUMENT + ITEM ALREADY EXISTS
*    *********************************************************************

          SELECT SINGLE FROM zsd_billing_itb
            FIELDS item_uuid
            WHERE sales_billing_no =
                    @ls_item-SalesBillingNo
              AND sales_billing_item =
                    @ls_item-SalesBillingItem
              AND item_uuid <> @ls_item-ItemUuid
            INTO @lv_existing_item_uuid.

          IF sy-subrc = 0.

            APPEND VALUE #(
              %tky = ls_item-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text =
                  |Billing No { ls_item-SalesBillingNo } | &&
                  |Item { ls_item-SalesBillingItem } already exists.|
              )
            ) TO reported-item.

          ENDIF.

        ENDLOOP.
      ENDMETHOD.




      METHOD fill_from_billing.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item
          FIELDS (
            ItemUuid
            SalesBillingNo
            SalesBillingItem
          )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        IF lt_items IS INITIAL.
          RETURN.
        ENDIF.

        LOOP AT lt_items INTO DATA(ls_item).

          IF ls_item-SalesBillingNo IS INITIAL
             OR ls_item-SalesBillingItem IS INITIAL.
            CONTINUE.
          ENDIF.

          "Fetch Billing Document and Item from CDS
          SELECT SINGLE FROM zsd_billing_v4
            FIELDS
              Gla,
              Costcenter,
              NetValue,
              TransactionCurrency,
              Plant,
              Broker_Code
            WHERE BillingDocument =
                    @ls_item-SalesBillingNo
              AND Item =
                    @ls_item-SalesBillingItem
            INTO @DATA(ls_billing).

          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          "Update RAP Line Item
          MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY item
            UPDATE FIELDS (
              GlAccount
              CostCentre
              Amount
              CurrencyKey
              Plant
              InvoicingParty
            )
            WITH VALUE #(
              (
                %tky = ls_item-%tky

                GlAccount      = ls_billing-Gla
                CostCentre     = ls_billing-Costcenter
                Amount         = ls_billing-NetValue
                CurrencyKey    = ls_billing-TransactionCurrency
                Plant          = ls_billing-Plant
                InvoicingParty = ls_billing-Broker_Code

                %control-GlAccount      = if_abap_behv=>mk-on
                %control-CostCentre     = if_abap_behv=>mk-on
                %control-Amount         = if_abap_behv=>mk-on
                %control-CurrencyKey    = if_abap_behv=>mk-on
                %control-Plant          = if_abap_behv=>mk-on
                %control-InvoicingParty = if_abap_behv=>mk-on
              )
            ).

          CLEAR ls_billing.

        ENDLOOP.

      ENDMETHOD.


      METHOD check_invoicing_party.

        DATA lv_ref_party TYPE zsd_billing_itb-invoicingparty.

        "Parent headers of the changed items
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY item BY \hdr
          FIELDS ( BillUuid )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_hdr).

        IF lt_hdr IS INITIAL.
          RETURN.
        ENDIF.

        "All items that currently exist under those headers
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY hdr BY \item
          FIELDS ( BillUuid InvoicingParty )
          WITH CORRESPONDING #( lt_hdr )
          RESULT DATA(lt_all_items).

        LOOP AT lt_hdr INTO DATA(ls_hdr).

          CLEAR lv_ref_party.

          "Reference party = first non-empty party among remaining items
          LOOP AT lt_all_items INTO DATA(ls_ref)
               WHERE BillUuid = ls_hdr-BillUuid
                 AND InvoicingParty IS NOT INITIAL.
            lv_ref_party = ls_ref-InvoicingParty.
            EXIT.
          ENDLOOP.

          IF lv_ref_party IS INITIAL.
            CONTINUE.
          ENDIF.

          LOOP AT lt_all_items INTO DATA(ls_item)
               WHERE BillUuid = ls_hdr-BillUuid
                 AND InvoicingParty IS NOT INITIAL
                 AND InvoicingParty <> lv_ref_party.

            APPEND VALUE #(
              %tky = ls_item-%tky
              %element-InvoicingParty = if_abap_behv=>mk-on
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = 'Select the same Invoicing Party in Line item.' )
            ) TO reported-item.

            APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.

          ENDLOOP.

        ENDLOOP.

      ENDMETHOD.


      METHOD synchdrin_delete.
*
*        "Read deleted item keys
*        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
*          ENTITY item
*          FIELDS ( BillUuid )
*          WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_deleted_items).
*
*        IF lt_deleted_items IS INITIAL.
*          RETURN.
*        ENDIF.
*
*        "Read parent header for deleted items
*        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
*          ENTITY item BY \hdr
*          ALL FIELDS
*          WITH CORRESPONDING #( lt_deleted_items )
*          RESULT DATA(lt_headers).
*
*        IF lt_headers IS INITIAL.
*          RETURN.
*        ENDIF.
*
*        LOOP AT lt_headers INTO DATA(ls_header).
*
*          "Read remaining items belonging to this header
*          READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
*            ENTITY hdr BY \item
*            FIELDS ( ItemUuid InvoicingParty )
*            WITH VALUE #( ( %tky = ls_header-%tky ) )
*            RESULT DATA(lt_remaining_items).
*
*          "Use the correct type from the InvoicingParty field
*          DATA lv_invoicing_party LIKE ls_header-InvoicingParty.
*          CLEAR lv_invoicing_party.
*
*          "Get InvoicingParty from remaining items
*          LOOP AT lt_remaining_items INTO DATA(ls_remaining_item)
*            WHERE InvoicingParty IS NOT INITIAL.
*
*            lv_invoicing_party = ls_remaining_item-InvoicingParty.
*            EXIT.
*
*          ENDLOOP.
*
*          "Update header with remaining item's InvoicingParty
*          IF lv_invoicing_party IS NOT INITIAL.
*
*            MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
*              ENTITY hdr
*              UPDATE FIELDS ( InvoicingParty )
*              WITH VALUE #(
*                (
*                  %tky = ls_header-%tky
*                  InvoicingParty = lv_invoicing_party
*                  %control-InvoicingParty = if_abap_behv=>mk-on
*                )
*              ).
*
*          ENDIF.
*
*        ENDLOOP.

      ENDMETHOD.


    ENDCLASS.

    CLASS lhc_hdr DEFINITION INHERITING FROM cl_abap_behavior_handler.

      PRIVATE SECTION.

        METHODS get_instance_authorizations
          FOR INSTANCE AUTHORIZATION
          keys REQUEST requested_authorizations FOR hdr
          RESULT result.

        METHODS get_global_authorizations
          FOR GLOBAL AUTHORIZATION
          REQUEST requested_authorizations FOR hdr
          RESULT result.

        METHODS get_instance_features
          FOR INSTANCE FEATURES
          IMPORTING keys REQUEST requested_features
          FOR hdr RESULT result.

        METHODS fill_hdata FOR DETERMINE ON SAVE
           keys FOR hdr~fill_hdata.

        METHODS postinvoice FOR MODIFY
           keys FOR ACTION hdr~postinvoice RESULT result.

        METHODS setdefaultdocumenttype FOR DETERMINE ON MODIFY
           keys FOR hdr~setdefaultdocumenttype.
        METHODS validaterequiredfields FOR VALIDATE ON SAVE
           keys FOR hdr~validaterequiredfields.

    ENDCLASS.
    CLASS lhc_hdr IMPLEMENTATION.

      METHOD get_instance_authorizations.
      ENDMETHOD.

      METHOD get_global_authorizations.
      ENDMETHOD.




      METHOD fill_hdata.

        DATA ls_hdrdata TYPE zsd_billing_tb.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY hdr
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_hdr).

        IF lt_hdr IS INITIAL.
          RETURN.
        ENDIF.

        LOOP AT lt_hdr INTO DATA(ls_hdr).

          CLEAR ls_hdrdata.

          ls_hdrdata-bill_uuid = ls_hdr-BillUuid.
          ls_hdrdata-sno = ls_hdr-Sno.

          ls_hdrdata-invoicing_party = ls_hdr-InvoicingParty.
          ls_hdrdata-document_date = ls_hdr-DocumentDate.
          ls_hdrdata-posting_date = ls_hdr-PostingDate.
          ls_hdrdata-reference = ls_hdr-Reference.
          ls_hdrdata-amount = ls_hdr-Amount.
          ls_hdrdata-currency_key = ls_hdr-CurrencyKey.
          ls_hdrdata-business_place = ls_hdr-BusinessPlace.
          ls_hdrdata-calculate_tax = ls_hdr-CalculateTax.
          ls_hdrdata-document_type = ls_hdr-DocumentType.
          ls_hdrdata-withholding_tax = ls_hdr-WithholdingTax.
          ls_hdrdata-supplierinvoice = ls_hdr-Supplierinvoice.
          ls_hdrdata-fiscalyear      = ls_hdr-Fiscalyear.
          ls_hdrdata-postinvoiceflag = ls_hdr-Postinvoiceflag.
          ls_hdrdata-local_created_by = ls_hdr-LocalCreatedBy.
          ls_hdrdata-local_created_at = ls_hdr-LocalCreatedAt.
          ls_hdrdata-local_last_changed_by =
            ls_hdr-LocalLastChangedBy.
          ls_hdrdata-local_last_changed_at =
            ls_hdr-LocalLastChangedAt.
          ls_hdrdata-last_changed_at = ls_hdr-LastChangedAt.

          "Remove old buffer entry
          DELETE zbp_sd_billing_rv=>gt_hdrdata
            WHERE bill_uuid = ls_hdrdata-bill_uuid.

          "Append latest Header data
          APPEND ls_hdrdata
            TO zbp_sd_billing_rv=>gt_hdrdata.

        ENDLOOP.

      ENDMETHOD.


      METHOD PostInvoice.

*    *********************************************************************
        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
           ENTITY hdr
           ALL FIELDS WITH CORRESPONDING #( keys )
           RESULT DATA(lt_sh)
           FAILED DATA(lt_failed).

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
            ENTITY hdr BY \Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_si)
            FAILED DATA(lt_item_failed).
*    *********************************************************************
        DATA lv_duplicate_bill_uuid TYPE sysuuid_x16.

        DATA ls_sh LIKE LINE OF lt_sh.

        READ TABLE lt_sh INDEX 1 INTO ls_sh.

        LOOP AT lt_si INTO DATA(ls_check_item).


          CLEAR lv_duplicate_bill_uuid.

          "Check whether the same combination exists
          "in another successfully parked Supplier Invoice

          SELECT SINGLE FROM zsd_billing_tb AS h
            INNER JOIN zsd_billing_itb AS i
              ON i~bill_uuid = h~bill_uuid
            FIELDS h~bill_uuid
            WHERE h~reference = @ls_sh-Reference
              AND i~sales_billing_no =
                  @ls_check_item-SalesBillingNo
              AND i~sales_billing_item =
                  @ls_check_item-SalesBillingItem
              AND h~bill_uuid <> @ls_sh-BillUuid
              AND h~postinvoiceflag = 'X'
            INTO @lv_duplicate_bill_uuid.

          IF sy-subrc = 0.

            APPEND VALUE #(
              %tky = ls_sh-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text =
                  |Duplicate Supplier Invoice! Reference { ls_sh-Reference }, | &&
                  |Billing No { ls_check_item-SalesBillingNo }, | &&
                  |Item { ls_check_item-SalesBillingItem } already exists.|
              )
            ) TO reported-hdr.

            APPEND VALUE #(
              %tky = ls_sh-%tky
            ) TO failed-hdr.

            "Stop processing. Do not call SAP API.
            RETURN.

          ENDIF.

        ENDLOOP.
*    *********************************************************************
*        DATA(ls_sh) = VALUE #( lt_sh[ 1 ] OPTIONAL ).
        DATA(ls_si) = VALUE #( lt_si[ 1 ] OPTIONAL ).
*        DATA(gt_keys) = keys.
*        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
        DATA(lv_reference) = ls_sh-Reference.

        DATA(lv_posting_date) = ls_sh-PostingDate.

        DATA(lv_post_isodate) =
            |{ lv_posting_date DATE = ISO }|.
*    *********************************************************************
        DATA: lv_json        TYPE STANDARD TABLE OF string,
              lv_url         TYPE string,
              lv_auth        TYPE string,
              lv_message_err TYPE string,
              lv_invoice     TYPE belnr_d,
              lv_fiscalyear  TYPE gjahr.
*    *********************************************************************
        DATA: lt_items      TYPE STANDARD TABLE OF string,
              lv_item_str   TYPE string,
              lv_items_json TYPE string.
*        DATA lv_post_isodate TYPE string.
        DATA lv_docu_isodate TYPE string.

*    *********************************************************************
        GET TIME STAMP FIELD DATA(ts).
        CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date1) TIME DATA(lv_time).

        lv_docu_isodate = |{ lv_date1 DATE = ISO }|.
*        lv_post_isodate = |{ gs_keys-PostingDate DATE = ISO }|.
        DATA(lv_suppitem) = '1'.
        DATA(lv_subDebitCredit) = 'X'.
        DATA(lv_busplace) = '2100'.
        DATA(tax) = 'true'.
        DATA(lv_sts) = 'A'.
        DATA(lv_bp) = '2100'.
        DATA(lv_gst) = 'OD'.
        DATA(lv_comp) = '1000'.
        DATA(ls_cd) = 'S'.
        DATA(ls_con) = 'A000'.
        DATA(ls_fun) = 'YB20'.
        DATA(ls_tax) = 'false'.

*        DATA(ls_json) = '{ "CompanyCode": "' && lv_comp &&
*                           '","InvoicingParty": "' && ls_sh-InvoicingParty &&
*                           '","DocumentDate": "' && lv_docu_isodate &&
*                           'T00:00","PostingDate": "' && lv_post_isodate &&
*                           'T00:00' &&
*                           '","DocumentCurrency": "' && ls_sh-CurrencyKey &&
*                           '","InvoiceGrossAmount": "' && ls_sh-Amount &&
*                           '","PaymentTerms": "' && ls_si-PaymentTerms &&
*                           '","AccountingDocumentType": "' && ls_sh-DocumentType &&
*                           '","SupplierInvoiceIDByInvcgParty": "' && lv_reference &&
*                           '","BusinessPlace": "' && lv_bp &&
*                           '","IN_GSTPlaceOfSupply": "' && lv_gst &&
*                           '","SupplierInvoiceStatus": "' && lv_sts &&
*                           '","TaxDeterminationDate": "' && lv_post_isodate &&
*                           'T00:00' &&
*                           '","DueCalculationBaseDate": "' && lv_post_isodate &&
*                           'T00:00' &&
*                           '","TaxIsCalculatedAutomatically": ' && tax &&
*                           ',"to_SupplierInvoiceItemGLAcct":[ ' &&
*                               ' { ' &&
*                                   ' "CompanyCode": "' && lv_comp &&
*                                   '", "SupplierInvoiceItem": "' && lv_suppitem &&
*                                   '","DocumentCurrency": "' && ls_si-CurrencyKey &&
*                                   '","GLAccount": "' && ls_si-GlAccount &&
*                                   '","DebitCreditCode": "' && ls_cd &&
*                                   '","SupplierInvoiceItemAmount": "' && ls_si-Amount &&
*                                   '","TaxCode": "' && ls_si-TaxCode &&
*                                   '","CostCenter": "' && ls_si-CostCentre &&
*                                   '","ControllingArea": "' && ls_con &&
*                                   '","ProfitCenter": "' && 10102000 &&
*                                   '","FunctionalArea": "' && ls_fun &&
*                                   '","SupplierInvoiceItemText": "' && ls_si-ItemText &&
*                                   '","AssignmentReference": "' && tax &&
*                                   '","IsNotCashDiscountLiable": ' && ls_tax &&
*                                    ' }' &&
*                                   ']' &&
*                               '}' .
*    *********************************************************************
        DATA: ls_json    TYPE string,
*          lv_items_json TYPE string,
              lv_item_no TYPE i.
        CLEAR lv_items_json.
        lv_item_no = 0.



        LOOP AT lt_si INTO ls_si.

          lv_item_no = lv_item_no + 1.

          IF lv_items_json IS NOT INITIAL.
            lv_items_json = lv_items_json && ','.
          ENDIF.

          lv_items_json = lv_items_json &&
            '{' &&
            '"CompanyCode":"' && lv_comp && '",' &&
            '"SupplierInvoiceItem":"' && lv_item_no && '",' &&
            '"DocumentCurrency":"' && ls_si-CurrencyKey && '",' &&
            '"GLAccount":"' && ls_si-GlAccount && '",' &&
            '"DebitCreditCode":"' && ls_cd && '",' &&
            '"SupplierInvoiceItemAmount":"' && ls_si-Amount && '",' &&
            '"TaxCode":"' && ls_si-TaxCode && '",' &&
            '"CostCenter":"' && ls_si-CostCentre && '",' &&
            '"ControllingArea":"' && ls_con && '",' &&
            '"ProfitCenter":"10102000",' &&
            '"FunctionalArea":"' && ls_fun && '",' &&
            '"SupplierInvoiceItemText":"' && ls_si-ItemText && '",' &&
            '"AssignmentReference":"' && ls_si-Assignment && '",' &&
            '"IsNotCashDiscountLiable":' && ls_tax &&
            '}'.

        ENDLOOP.

        ls_json =
      '{' &&
      '"CompanyCode":"' && lv_comp && '",' &&
      '"InvoicingParty":"' && ls_sh-InvoicingParty && '",' &&
      '"DocumentDate":"' && lv_docu_isodate && 'T00:00",' &&
      '"PostingDate":"' && lv_post_isodate && 'T00:00",' &&
      '"DocumentCurrency":"' && ls_sh-CurrencyKey && '",' &&
      '"InvoiceGrossAmount":"' && ls_sh-Amount && '",' &&
      '"PaymentTerms":"' && ls_si-PaymentTerms && '",' &&
      '"AccountingDocumentType":"' && ls_sh-DocumentType && '",' &&
      '"SupplierInvoiceIDByInvcgParty":"' && lv_reference && '",' &&
      '"BusinessPlace":"' && lv_bp && '",' &&
      '"IN_GSTPlaceOfSupply":"' && lv_gst && '",' &&
      '"SupplierInvoiceStatus":"' && lv_sts && '",' &&
      '"TaxDeterminationDate":"' && lv_post_isodate && 'T00:00",' &&
      '"DueCalculationBaseDate":"' && lv_post_isodate && 'T00:00",' &&
      '"TaxIsCalculatedAutomatically":' && tax && ',' &&
      '"to_SupplierInvoiceItemGLAcct":[' &&
      lv_items_json &&
      ']' &&
      '}'.
*    *********************************************************************


        TRY.
            CONSTANTS lc_dev TYPE string VALUE 'https://my437525-api.s4hana.cloud.sap/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice'.
            CONSTANTS lc_qas TYPE string VALUE 'https://my437734-api.s4hana.cloud.sap/sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader'.
            CONSTANTS lc_prd TYPE string VALUE 'https://my443992-api.s4hana.cloud.sap/sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader'.
*    **************************************************************************
            TRY.
                DATA(system_url) = cl_abap_context_info=>get_system_url( ).
              CATCH cx_abap_context_info_error  INTO DATA(lx_erro1).
                DATA(lv_err1) = lx_erro1->get_text( ).
            ENDTRY.
*    **************************************************************************
            IF system_url CS 'my437525'.
              lv_url = lc_dev.
            ELSEIF system_url CS 'my437734'.
              lv_url = lc_qas.
            ELSEIF system_url CS 'my443992'.
              lv_url = lc_prd.
            ENDIF.
*    **************************************************************************
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

*    **********************************************************************
            DATA(lo_regex) = cl_abap_regex=>create_pcre( pattern = '<message[^>]*>([^<]*)</message>' ).

            FIND REGEX lo_regex
             IN lv_response
             SUBMATCHES lv_message_err.


            IF lv_message_err IS NOT INITIAL.

              APPEND VALUE #( %tky = ls_sh-%tky )
                  TO failed-hdr.

              APPEND VALUE #(
                %tky = ls_sh-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                          text     = lv_message_err
                       )
              ) TO reported-hdr .

            ENDIF.
*    ***********************************************************************

            FIND FIRST OCCURRENCE OF PCRE
                `SupplierInvoice='([^']+)',FiscalYear='([^']+)'`
            IN lv_response
            SUBMATCHES lv_invoice lv_fiscalyear.
*    ***********************************************************************

*            IF lv_invoice IS NOT INITIAL AND lv_fiscalyear IS NOT INITIAL.
*
*              MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
*              ENTITY hdr
*              UPDATE
*              FIELDS ( supplierinvoice fiscalyear postinvoiceflag
*                        Reference Postingdate )
*              WITH VALUE #( FOR key IN keys
*                           ( %tky = ls_sh-%tky
*                           Supplierinvoice = lv_invoice
*                           Fiscalyear = lv_fiscalyear
*                           Reference = ls_sh-Reference
*                           Postingdate = ls_sh-PostingDate
*                           Postinvoiceflag = 'X'
*                           %control-Supplierinvoice = if_abap_behv=>mk-on
*                           %control-Fiscalyear = if_abap_behv=>mk-on
*                           %control-Postinvoiceflag = if_abap_behv=>mk-on
*                           %control-Reference = if_abap_behv=>mk-on
*                           %control-Postingdate = if_abap_behv=>mk-on
*                           ) ).
*
*              DATA(lv_success_msg) = |Park Invoice-{ lv_invoice } created successfully.|.
*              APPEND VALUE #(
*                %tky = ls_sh-%tky
*                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
*                          text     = lv_success_msg
*                       )
*              ) TO reported-hdr .
*
*            ENDIF.
*
*          CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(lv_check).
*
*            DATA(lv_error) = lv_check.
*        ENDTRY.
            IF lv_invoice IS NOT INITIAL
               AND lv_fiscalyear IS NOT INITIAL.

              MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
                ENTITY hdr
                UPDATE FIELDS (
                  Supplierinvoice
                  Fiscalyear
                  Postinvoiceflag
                )
                WITH VALUE #(
                  FOR ls_key IN keys
                  (
                    %tky = ls_key-%tky

                    Supplierinvoice = lv_invoice
                    Fiscalyear = lv_fiscalyear
                    Postinvoiceflag = abap_true

                    %control-Supplierinvoice = if_abap_behv=>mk-on
                    %control-Fiscalyear = if_abap_behv=>mk-on
                    %control-Postinvoiceflag = if_abap_behv=>mk-on
                  )
                ).

              APPEND VALUE #(
                %tky = ls_sh-%tky
                %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-success
                  text = |Supplier Invoice { lv_invoice } created successfully. Fiscal Year { lv_fiscalyear }.|
                )
              ) TO reported-hdr.

            ELSE.

              APPEND VALUE #(
                %tky = ls_sh-%tky
                %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text = |Supplier Invoice number or Fiscal Year not found in API response: { lv_response }|
                )
              ) TO reported-hdr.

              APPEND VALUE #(
                %tky = ls_sh-%tky
              ) TO failed-hdr.

            ENDIF.
        ENDTRY.
*    ************************************************************************
        result = VALUE #( FOR ls_ord IN lt_sh
                             ( %tky   = ls_ord-%tky
                               %param = ls_ord ) ).
*    **********************************************************************


      ENDMETHOD.

*    *********************************************************************

      METHOD SetDefaultDocumentType.
        MODIFY ENTITIES OF zsd_billing_rv IN LOCAL MODE
       ENTITY hdr
       UPDATE FIELDS ( DocumentType  PostingDate BusinessPlace )
       WITH VALUE #(
           FOR key IN keys
           (
               %tky = key-%tky
               DocumentType = 'KR'
               BusinessPlace = '2100'
               PostingDate = cl_abap_context_info=>get_system_date( )
           )
       ).

      ENDMETHOD.





      METHOD get_instance_features.


        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY hdr
          FIELDS ( Supplierinvoice )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_hdr).

        result = VALUE #(
          FOR ls_hdr IN lt_hdr
          (
            %tky = ls_hdr-%tky

            "Disable header update
            %features-%update =
              COND #(
                WHEN ls_hdr-Supplierinvoice IS NOT INITIAL
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled
              )

            "Disable header delete
            %features-%delete =
              COND #(
                WHEN ls_hdr-Supplierinvoice IS NOT INITIAL
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled
              )

            "Disable line-item Create
            %assoc-Item =
              COND #(
                WHEN ls_hdr-Supplierinvoice IS NOT INITIAL
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled
              )
              %action-PostInvoice =
              COND #(
                WHEN ls_hdr-Supplierinvoice IS NOT INITIAL
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled
              )
          )
        ).


      ENDMETHOD.




      METHOD validateRequiredFields.

        READ ENTITIES OF zsd_billing_rv IN LOCAL MODE
          ENTITY hdr
          FIELDS ( DocumentDate Reference )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_headers).

        LOOP AT lt_headers INTO DATA(ls_header).

          DATA(lv_invalid) = abap_false.

          IF ls_header-DocumentDate IS INITIAL.

            lv_invalid = abap_true.

            APPEND VALUE #(
              %tky = ls_header-%tky
              %element-DocumentDate = if_abap_behv=>mk-on
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text = 'Invoice/Document Date is mandatory.'
              )
            ) TO reported-hdr.

          ENDIF.

          IF ls_header-Reference IS INITIAL.

            lv_invalid = abap_true.

            APPEND VALUE #(
              %tky = ls_header-%tky
              %element-Reference = if_abap_behv=>mk-on
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text = 'Reference is mandatory.'
              )
            ) TO reported-hdr.

          ENDIF.

          IF lv_invalid = abap_true.

            APPEND VALUE #(
              %tky = ls_header-%tky
            ) TO failed-hdr.

          ENDIF.

        ENDLOOP.
      ENDMETHOD.

    ENDCLASS.

    CLASS lsc_ZSD_BILLING_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
      PROTECTED SECTION.

        METHODS save_modified REDEFINITION.

        METHODS cleanup_finalize REDEFINITION.

    ENDCLASS.

    CLASS lsc_ZSD_BILLING_RV IMPLEMENTATION.




      METHOD save_modified.

        DATA:
          lv_count   TYPE i,
          lv_current TYPE int8.

        FIELD-SYMBOLS:
          <ls_hdr> TYPE zsd_billing_tb.

        "================================================
        " STEP 1: GENERATE SERIAL NUMBER FOR NEW HEADERS
        "================================================

        IF create-hdr IS NOT INITIAL.

          CLEAR lv_count.

          LOOP AT create-hdr INTO DATA(ls_created_hdr).

            READ TABLE zbp_sd_billing_rv=>gt_hdrdata
              ASSIGNING <ls_hdr>
              WITH KEY bill_uuid = ls_created_hdr-BillUuid.

            IF sy-subrc = 0 AND <ls_hdr>-sno IS INITIAL.
              lv_count += 1.
            ENDIF.

          ENDLOOP.

          IF lv_count > 0.

            TRY.

                cl_numberrange_runtime=>number_get(
                  EXPORTING
                    nr_range_nr = '01'
                    object      = 'ZNR_BBSNO'
                    quantity    = CONV #( lv_count )
                  IMPORTING
                    number      = DATA(lv_last)
                    returncode  = DATA(lv_returncode)
                ).

                "Calculate first number in allocated block
                lv_current = CONV int8( lv_last ) - lv_count.

                LOOP AT create-hdr INTO ls_created_hdr.

                  READ TABLE zbp_sd_billing_rv=>gt_hdrdata
                    ASSIGNING <ls_hdr>
                    WITH KEY bill_uuid = ls_created_hdr-BillUuid.

                  IF sy-subrc = 0 AND <ls_hdr>-sno IS INITIAL.

                    lv_current += 1.

                    <ls_hdr>-sno = lv_current.

                  ENDIF.

                ENDLOOP.

              CATCH cx_number_ranges INTO DATA(lx_nr).

                "Stop saving if number allocation fails
                RAISE SHORTDUMP lx_nr.

            ENDTRY.

          ENDIF.

        ENDIF.


        "================================================
        " STEP 2: SAVE HEADER
        "================================================

        IF zbp_sd_billing_rv=>gt_hdrdata IS NOT INITIAL.

          MODIFY zsd_billing_tb
            FROM TABLE @zbp_sd_billing_rv=>gt_hdrdata.

        ENDIF.


        "================================================
        " STEP 3: SAVE ITEM
        "================================================

        IF zbp_sd_billing_rv=>gt_lindata IS NOT INITIAL.

          MODIFY zsd_billing_itb
            FROM TABLE @zbp_sd_billing_rv=>gt_lindata.

        ENDIF.


        "================================================
        " STEP 4: DELETE HEADER AND CHILD ITEMS
        "================================================

        IF delete-hdr IS NOT INITIAL.

          LOOP AT delete-hdr INTO DATA(ls_header).

            DELETE FROM zsd_billing_itb
              WHERE bill_uuid = @ls_header-BillUuid.

            DELETE FROM zsd_billing_tb
              WHERE bill_uuid = @ls_header-BillUuid.

          ENDLOOP.

        ENDIF.


        "================================================
        " STEP 5: DELETE ITEMS
        "================================================

        IF delete-item IS NOT INITIAL.

          LOOP AT delete-item INTO DATA(ls_item).

            DELETE FROM zsd_billing_itb
              WHERE item_uuid = @ls_item-ItemUuid.

          ENDLOOP.

        ENDIF.
        DATA: lv_party TYPE zsd_billing_tb-invoicing_party,
              lv_total TYPE zsd_billing_tb-amount,
              lv_curr  TYPE zsd_billing_tb-currency_key.

        LOOP AT zbp_sd_billing_rv=>gt_hdrdata INTO DATA(ls_hdr_buf).

          SELECT invoicingparty, amount, tax_amount, currency_key
            FROM zsd_billing_itb
            WHERE bill_uuid = @ls_hdr_buf-bill_uuid
            INTO TABLE @DATA(lt_db_items).

          IF lt_db_items IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR: lv_party, lv_total, lv_curr.

          LOOP AT lt_db_items INTO DATA(ls_db_item).
            IF lv_party IS INITIAL AND ls_db_item-invoicingparty IS NOT INITIAL.
              lv_party = ls_db_item-invoicingparty.
            ENDIF.
            IF lv_curr IS INITIAL.
              lv_curr = ls_db_item-currency_key.
            ENDIF.
            lv_total = lv_total + ls_db_item-amount + ls_db_item-tax_amount.
          ENDLOOP.

          UPDATE zsd_billing_tb
            SET invoicing_party = @lv_party,
                amount          = @lv_total,
                currency_key    = @lv_curr
            WHERE bill_uuid = @ls_hdr_buf-bill_uuid.

        ENDLOOP.

      ENDMETHOD.


      METHOD cleanup_finalize.
        CLEAR:
        zbp_sd_billing_rv=>gt_hdrdata,
        zbp_sd_billing_rv=>gt_lindata.

      ENDMETHOD.

    ENDCLASS.
