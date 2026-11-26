@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Item Root View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_ITEM_ROOTVIEW as select from ZFI_ITEM_VIEW
//composition of target_data_source_name as _association_name
association to parent ZFI_HEADER_ROOTVIEW as _Head on $projection.AccountingDocument = _Head.AccountingDocument
                                        and $projection.CompanyCode = _Head.CompanyCode
                                        and $projection.FiscalYear = _Head.FiscalYear
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
   @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  OrderQuantity,
  BaseUnit,
  Rate,
  POAmount,
  
  DocumentCurrency,
  Amount,
  Poitemtext,
  PoHsncode,
  @Semantics.quantity.unitOfMeasure: 'PoBaseunit'
  PoQty,
  PoBaseunit,
  PoRate,
  RKCgstAmt,
  RKSgstAmt,
  RKIgstAmt,
  _Head  
   
}
