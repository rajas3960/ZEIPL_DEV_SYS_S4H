CLASS zfi_from_item_imp_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFI_FROM_ITEM_IMP_CL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF NOT io_request->is_data_requested( ).
      RETURN.
    ENDIF.

**********************************************************************
    "Get filters

    DATA(lo_filter) = io_request->get_filter( ).

    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.
**********************************************************************
    "All 3 keys are mandatory

    IF NOT line_exists( lt_range[ name = 'ACCOUNTINGDOCUMENT' ] ) AND
       NOT line_exists( lt_range[ name = 'FISCALYEAR' ] ) AND
       NOT line_exists( lt_range[ name = 'COMPANYCODE' ] ).

      RETURN.

    ENDIF.

**********************************************************************
    "Get key values

    DATA(lv_acc) =
      lt_range[ name = 'ACCOUNTINGDOCUMENT' ]-range[ 1 ]-low.

    DATA(lv_fis) =
      lt_range[ name = 'FISCALYEAR' ]-range[ 1 ]-low.

    DATA(lv_com) =
      lt_range[ name = 'COMPANYCODE' ]-range[ 1 ]-low.

**********************************************************************
    " Result table

    DATA lt_item TYPE TABLE OF zfi_item_ce.
    DATA: lv_potex TYPE I_PurchaseOrderItemAPI01-PurchaseOrderItemText.
    DATA: lv_hsn TYPE I_PurchaseOrderItemAPI01-br_ncm.
    DATA: lv_qty  TYPE I_PurchaseOrderItemAPI01-OrderQuantity,
          		  lv_unit TYPE I_PurchaseOrderItemAPI01-BaseUnit,
          		  lv_rate TYPE I_PurchaseOrderItemAPI01-NetPriceAmount.
"" added RK TaxCode 16.10.26
    DATA: lv_rkcgst TYPE zfi_item_projection_view-RKCgstAmt.   		  	
    DATA: lv_rksgst TYPE zfi_item_projection_view-RKSgstAmt.
    DATA: lv_rkigst TYPE zfi_item_projection_view-RKIgstAmt.

**********************************************************************
 "Get Accounting Document Type

    SELECT SINGLE
           FROM zfi_header_view
           FIELDS AccountingDocumentType
           WHERE AccountingDocument = @lv_acc
             AND FiscalYear         = @lv_fis
             AND CompanyCode        = @lv_com
           INTO @DATA(lv_type).

    IF lv_type IS INITIAL.
      RETURN.
    ENDIF.

**********************************************************************
*      SELECT SINGLE
*             AccountingDocument,
*             CompanyCode,
*             FiscalYear,
*             InvoiceReference
*        FROM I_JournalEntryItem
*        WITH PRIVILEGED ACCESS
*        WHERE AccountingDocument = @lv_acc
*          AND FiscalYear         = @lv_fis
*          AND CompanyCode        = @lv_com
*          AND Ledger             = '0L'
*          AND InvoiceReference   <> ''
*        INTO @DATA(ls_invref).
**********************************************************************

**********************************************************************
" Get all reference PO items

*      SELECT
*             AccountingDocument,
*             CompanyCode,
*             FiscalYear,
*             LedgerGLLineItem,
*             PurchasingDocument,
*             PurchasingDocumentItem,
*             GLAccount,
*             DocumentItemText,
*             DebitCreditCode,
*             TaxCode,
*             AmountInCompanyCodeCurrency,
*             CompanyCodeCurrency
*        FROM I_JournalEntryItem
*        WITH PRIVILEGED ACCESS
*        WHERE AccountingDocument     = @ls_invref-InvoiceReference
*          AND Ledger                 = '0L'
*          AND PurchasingDocument     <> ''
*          AND PurchasingDocumentItem <> ''
*        INTO TABLE @DATA(lt_reference_items).

**********************************************************************
      " Process each PO item

*      LOOP AT lt_reference_items INTO DATA(ls_reference_item).
*
*        SELECT SINGLE
*               PurchaseOrder,
*               PurchaseOrderItem,
*               CompanyCode,
*               Plant,
*               Material,
*               PurchaseOrderItemText,
*               PurchaseOrderQuantityUnit,
*               BaseUnit,
*               OrderQuantity,
*               NetPriceAmount,
*               NetPriceQuantity,
*               NetAmount,
*               DocumentCurrency,
*               TaxCode,
*               br_ncm
*          FROM I_PurchaseOrderItemAPI01
*          WITH PRIVILEGED ACCESS
*          WHERE PurchaseOrder     = @ls_reference_item-PurchasingDocument
*            AND PurchaseOrderItem = @ls_reference_item-PurchasingDocumentItem
*          INTO @DATA(ls_po_item).
*
*        IF ls_po_item-PurchaseOrder IS INITIAL.
*          CONTINUE.
*        ENDIF.
*
*      ENDLOOP.

**********************************************************************
    " RE
    SELECT
           AccountingDocument,
           FiscalYear,
           CompanyCode,
           SourceLedger,
           LedgerGLLineItem,
           Plant,
           GLAccount,
           GLAccountLongName,
           CompanyCodeCurrency,
           TaxableValue,
           TaxCode,
           TaxItemGroup,
           CgstAmt,
           CgstRate,
           CgstRateRatio,
           SgstAmt,
           SgstRate,
           SgstRateRatio,
           IgstAmt,
           IgstRate,
           IgstRateRatio,
           InvoiceReference,
           PurchaseOrder,
           PurchaseOrderItem,
           PurchaseOrderItemText,
           HSNCode,
           OrderQuantity,
           POOrderQuantity,
           BaseUnit,
           Rate,
           POAmount,
           DocumentCurrency,
           Amount,
           Poitemtext,
           PoHsncode,
           PoQty,
           PoBaseunit,
           PoRate,
           RKCgstAmt,
           RKSgstAmt,
           RKIgstAmt

      FROM zfi_item_projection_view
      WITH PRIVILEGED ACCESS

      WHERE AccountingDocument = @lv_acc
        AND FiscalYear         = @lv_fis
        AND CompanyCode        = @lv_com
        AND SourceLedger       = '0L'

      INTO TABLE @DATA(lt_items).

**********************************************************************
    " Map RE items
    CONDENSE lv_type.

 " added Sort only for RK doc by 16.10.26
    IF lv_type = 'RK'.
      SORT lt_items BY LedgerGLLineItem ASCENDING.
    ENDIF.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
      IF <ls_item> IS ASSIGNED.

        IF lv_type = 'RK'.
          lv_potex = <ls_item>-Poitemtext.
          lv_hsn   = <ls_item>-PoHsncode.
          lv_qty   = <ls_item>-PoQty.
          lv_unit  = <ls_item>-PoBaseunit.
          lv_rate  = <ls_item>-PoRate.
          lv_rkcgst = <ls_item>-RKCgstAmt.
          lv_rksgst = <ls_item>-RKSgstAmt.
          lv_rkigst = <ls_item>-RKIgstAmt.

*        lv_potex = ls_po_item-PurchaseOrderItemText.
*        lv_hsn   = ls_po_item-br_ncm.
*        lv_qty   = ls_po_item-OrderQuantity.
*        lv_unit  = ls_po_item-BaseUnit.
*        lv_rate  = ls_po_item-NetPriceAmount.

        ELSE.
          CLEAR:lv_potex.
          lv_potex = <ls_item>-PurchaseOrderItemText.
          lv_hsn   = <ls_item>-HSNCode.
          lv_qty   = <ls_item>-OrderQuantity.
          lv_unit  = <ls_item>-BaseUnit.
          lv_rate  = <ls_item>-Rate.
          lv_rkcgst = <ls_item>-CgstAmt.
          lv_rksgst = <ls_item>-SgstAmt.
          lv_rkigst = <ls_item>-IgstAmt.


        ENDIF.

        APPEND VALUE zfi_item_ce(

          SourceLedger           = '0L'
          CompanyCode            = lv_com
          FiscalYear             = lv_fis
          AccountingDocument     = lv_acc
          LedgerGLLineItem       = <ls_item>-LedgerGLLineItem
*          AccountingDocumentItem = ls_item-LedgerGLLineItem
          AccountingDocumentType = lv_type
          Plant                  = <ls_item>-Plant
          GLAccount              = <ls_item>-GLAccount
          GLAccountLongName      = <ls_item>-GLAccountLongName
          CompanyCodeCurrency    = <ls_item>-CompanyCodeCurrency
          TaxableValue           = <ls_item>-TaxableValue
          TaxCode                = <ls_item>-TaxCode
          TaxItemGroup           = <ls_item>-TaxItemGroup
*          CgstAmt                = <ls_item>-CgstAmt
          CgstAmt                = lv_rkcgst
          CgstRate               = <ls_item>-CgstRate
          CgstRateRatio          = <ls_item>-CgstRateRatio
*          SgstAmt                = <ls_item>-SgstAmt
          SgstAmt                = lv_rksgst
          SgstRate               = <ls_item>-SgstRate
          SgstRateRatio          = <ls_item>-SgstRateRatio
*          IgstAmt                = <ls_item>-IgstAmt
          IgstAmt                = lv_rkigst
          IgstRate               = <ls_item>-IgstRate
          IgstRateRatio          = <ls_item>-IgstRateRatio
          InvoiceReference       = <ls_item>-InvoiceReference
          PurchaseOrder          = <ls_item>-PurchaseOrder
          PurchaseOrderItem      = <ls_item>-PurchaseOrderItem
          PurchaseOrderItemText  = lv_potex
          HSNCode                = lv_hsn
          OrderQuantity          = lv_qty
          POOrderQuantity        = <ls_item>-POOrderQuantity
          BaseUnit               = lv_unit
          Rate                   = lv_rate
          POAmount               = <ls_item>-POAmount
          DocumentCurrency       = <ls_item>-DocumentCurrency
          Amount                 = <ls_item>-Amount

        ) TO lt_item.

      ENDIF.
    ENDLOOP.

**********************************************************************
    " Return response

    io_response->set_data( lt_item ).

    io_response->set_total_number_of_records(
      lines( lt_item )
    ).

  ENDMETHOD.
ENDCLASS.
