@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Usage Decision Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: { dataCategory: #VALUE_HELP   }
@Search.searchable: true
define view entity ZQM_UD_VH 
as select from 
DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZQM_UD_DOMAIN')
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @Semantics.text: true
      @EndUserText.label: 'UD Description'
      text,    
      @EndUserText.label: 'UD Code'
      @ObjectModel.text.element: [ 'text' ]
      @Search.defaultSearchElement: true      
      value_low
    
}
