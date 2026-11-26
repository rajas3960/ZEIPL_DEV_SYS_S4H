@EndUserText.label: 'Item Custom Entity for Debit Note'
@ObjectModel.query.implementedBy: 'ABAP:ZFI_FROM_ITEM_IMP_CL'

define custom entity ZFI_ITEM_CE
{
  key SourceLedger           : fins_ledger;
  key CompanyCode            : bukrs;
  key FiscalYear             : fis_gjahr_no_conv;
  key AccountingDocument     : vbeln;
  key LedgerGLLineItem       : abap.char(6);
      AccountingDocumentItem : buzei;
      AccountingDocumentType : blart;
      Plant                  : werks_d;
      GLAccount              : saknr;
      GLAccountLongName      : abap.char(50);
      CompanyCodeCurrency    : waers;
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TaxableValue           : abap.curr(13,2);
      TaxCode                : mwskz;
      TaxItemGroup           : abap.numc(3);
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      CgstAmt                : abap.curr(13,2);
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      CgstRate               : abap.dec(15,2);
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      CgstRateRatio          : meins;
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      SgstAmt                : abap.curr(13,2);
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      SgstRate               : abap.dec(15,2);
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      SgstRateRatio          : meins;
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      IgstAmt                : abap.curr(13,2);
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      IgstRate               : abap.dec(15,2);
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      IgstRateRatio          : meins;
      InvoiceReference       : abap.char(10);
      PurchaseOrder          : ebeln;
      PurchaseOrderItem      : ebelp;
      Material               : matnr;
      PurchaseOrderItemText  : txz01;
      HSNCode                : abap.char(16);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      POOrderQuantity        : abap.quan(13,3);
      Rate                   : abap.dec(11,2);
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      POAmount               : abap.curr(13,2);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity          : abap.quan(13,3);
      BaseUnit               : meins;
      DocumentCurrency       : waers;
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Amount                 : abap.curr(13,2);
      Poitemtext             : abap.char(40);
      PoHsncode              : abap.char(10);
      @Semantics.quantity.unitOfMeasure: 'PoBaseunit'
      PoQty 			     : abap.quan(13,3);
      PoBaseunit		     : abap.unit(3);
      PoRate			     : abap.dec(15,2);
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      RKCgstAmt              : abap.curr(13,2);
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      RKSgstAmt              : abap.curr(13,2);
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      RKIgstAmt              : abap.curr(13,2);
      
}
