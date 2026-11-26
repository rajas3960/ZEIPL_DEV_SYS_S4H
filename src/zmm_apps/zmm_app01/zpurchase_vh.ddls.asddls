@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZPURCHASE_VH
  as select from I_PurchaseOrderAPI01 as a
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.PurchaseOrder,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      a.Supplier as Vendor
}
