@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Item Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZPOITEM_VH
  as select from I_PurchaseOrderItemAPI01 as a
    inner join   I_PurchaseOrderAPI01     as b on a.PurchaseOrder = b.PurchaseOrder
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.PurchaseOrder,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.PurchaseOrderItem,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH  
      a.Material,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @EndUserText.label: 'Material Description'      
      a.PurchaseOrderItemText,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      b.Supplier as Vendor
      
}
where a.IsCompletelyDelivered is initial
