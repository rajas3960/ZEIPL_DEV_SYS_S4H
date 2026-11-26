@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZSALES_VH
  as select from I_SalesDocument as a
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key a.SalesDocument     as SalesDocument,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      a.SoldToParty       as Customer
}

