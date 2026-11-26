@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: { dataCategory: #VALUE_HELP   }
@Search.searchable: true
define view entity ZGATE_DEPT_VH 
as select from 
DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZDEPT')
{
          @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @EndUserText.label: 'Department ID'
      @ObjectModel.text.element: [ 'text' ]
      @Search.defaultSearchElement: true      
      value_low,
      @Semantics.text: true
      @EndUserText.label: 'Description'
      text    
}
