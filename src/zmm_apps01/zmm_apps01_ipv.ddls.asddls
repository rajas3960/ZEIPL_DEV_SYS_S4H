@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Compare Supplier Quotation Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_APPS01_IPV
  as projection on ZMM_APPS01_IRV
{
  key SupplierQuotation,
  key RequestForQuotation,
  key Supplier,
  key PurchaseOrder,
  key RequestForQuotationItem,
  key SupplierQuotationItem,
  Material,
      SupplierName,
      Supname,
      PurgDocPriceDate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      NetAmount,
      DocumentCurrency,
      Address,
      CreationDate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      PoNetAmount,
      MaterialDocument,
      PostingDate,
      text,
      stuscrt,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      Totamtgrn,
      Compare,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      rfqty,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      rate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sqty,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      NetPriceAmount,
      OrderQuantityUnit,
      lastpo_supplier,
      PaymentTerms,
      /* Associations */
      hdr : redirected to parent ZMM_APPS01_PV
}
