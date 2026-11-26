@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZMM_PUR_VH
  as select from I_PurchaseOrderAPI01 as a
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.PurchaseOrder
     
}
