@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document Delivery Qty'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_MIGO_DELVQTY
  as select from I_MaterialDocumentItem_2 as a
{
  key a.PurchaseOrder,
  key a.PurchaseOrderItem,
      sum(cast( a.QuantityInEntryUnit as abap.dec( 13, 3 ))) as DelQty
}
where
  a.PurchaseOrder is not initial
group by
  a.PurchaseOrder,
  a.PurchaseOrderItem
