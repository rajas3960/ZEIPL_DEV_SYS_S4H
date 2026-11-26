@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Item Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZPO_ITEM_VH 
  as select from I_PurchaseOrderItemAPI01 as a
  inner join I_PurchaseOrderAPI01 as b on b.PurchaseOrder = a.PurchaseOrder
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.PurchaseOrder,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.PurchaseOrderItem,
      b.PurchaseOrderDate,
      b.PurchaseOrderType,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      a.Material as Product,
      a.PurchaseOrderItemText as ProductDes
}
