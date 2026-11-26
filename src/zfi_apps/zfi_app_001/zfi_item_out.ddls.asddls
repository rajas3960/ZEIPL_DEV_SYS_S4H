@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Form Output Item View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_ITEM_OUT 
as select from ZFI_ITEM_VIEW
{
  key SourceLedger,
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key LedgerGLLineItem,
  AccountingDocumentItem,
  AccountingDocumentType,
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
  Material,
  PurchaseOrderItemText,
  HSNCode,
   @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  POOrderQuantity,
  
  Rate,
  POAmount,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  OrderQuantity,
  BaseUnit,
  DocumentCurrency,
  Amount  
}
