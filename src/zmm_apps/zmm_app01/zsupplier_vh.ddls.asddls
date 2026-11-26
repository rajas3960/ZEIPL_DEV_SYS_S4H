@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Custom Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZSUPPLIER_VH
  as select from I_Supplier_VH
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key Supplier as Vendor,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      SupplierName
}
