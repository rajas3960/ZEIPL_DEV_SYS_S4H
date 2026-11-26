@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Series Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: { dataCategory: #VALUE_HELP }
@Search.searchable: true
define view entity ZGATE_SERIES_VH 
as select from 
DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZGATE_SERIES')
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @EndUserText.label: 'Serier Type'
      @ObjectModel.text.element: [ 'text' ]
      @Search.defaultSearchElement: true      
      value_low,
      @Semantics.text: true
      text    
}
