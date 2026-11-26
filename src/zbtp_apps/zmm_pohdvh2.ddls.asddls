@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Value Help - BTP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZMM_POHDVH2
  as select from I_PurchaseOrderItemAPI01 as a
    inner join   I_PurchaseOrderAPI01     as b on b.PurchaseOrder = a.PurchaseOrder
    inner join   I_Supplier_VH            as c on c.Supplier = b.Supplier
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.5
      @Search.ranking: #HIGH
  key a.PurchaseOrder,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.5
      @Search.ranking: #HIGH
      b.Supplier as Vendor,
      c.SupplierName,
      b.YY1_SupplierRefNo_PDH as Supplierrefno   //New Field added on 15.10.2026
}
where
  a.IsCompletelyDelivered is initial
group by
  a.PurchaseOrder,
  b.Supplier,
  c.SupplierName,
  b.YY1_SupplierRefNo_PDH   //New Field added on 15.10.2026
