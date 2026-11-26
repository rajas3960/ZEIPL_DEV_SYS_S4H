@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Value Help - BTP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZMM_SUP_VH2
  as select from I_Supplier_VH
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.5
      @Search.ranking: #HIGH
  key Supplier as Vendor,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.5
      @Search.ranking: #HIGH
      SupplierName
}
