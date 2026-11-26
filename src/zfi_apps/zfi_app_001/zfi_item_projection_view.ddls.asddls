@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Item Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZFI_ITEM_PROJECTION_VIEW 
as projection on ZFI_ITEM_ROOTVIEW
{
 key SourceLedger,
 key CompanyCode,
 key FiscalYear,
 key AccountingDocument,
 key LedgerGLLineItem,
 AccountingDocumentItem,
 AccountingDocumentType,
 Plant,
  @ObjectModel.text.element: [ 'GLAccountLongName' ]
 GLAccount,
 GLAccountLongName,
 CompanyCodeCurrency,
 TaxableValue,
 TaxCode,
 TaxItemGroup,
 CgstAmt,
 @ObjectModel.text.element: [ 'CgstRate' ]
 CgstRate,
 CgstRateRatio,
 SgstAmt,
 @ObjectModel.text.element: [ 'SgstRate' ]
 SgstRate,
 SgstRateRatio,
 IgstAmt,
 @ObjectModel.text.element: [ 'IgstRate' ]
 IgstRate,
 IgstRateRatio,
 InvoiceReference,
 PurchaseOrder,
 PurchaseOrderItem,

 PurchaseOrderItemText,
 HSNCode,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit' 
 OrderQuantity,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
 POOrderQuantity,
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
 /* Associations */
 _Head : redirected to parent ZFI_HEADER_PROJECTION_VIEW 
}
