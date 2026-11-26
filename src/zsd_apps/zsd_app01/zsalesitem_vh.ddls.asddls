@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Item Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZSALESITEM_VH
  as select from I_SalesDocumentItem
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key SalesDocument     as SalesDocument,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key SalesDocumentItem as SalesDocumentItem,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      SoldToParty       as Customer,
      SalesDocumentItemText as ProductDescription
      
}
where SDProcessStatus <> 'C'
