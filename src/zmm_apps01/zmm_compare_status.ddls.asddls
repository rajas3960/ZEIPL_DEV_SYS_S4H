@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Compare Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity zmm_compare_status as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZMM_COMPARE' )
{

      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @EndUserText.label: 'Status'
      @ObjectModel.text.element: [ 'text' ]
      value_low as name,
      @Semantics.text: true
      text 
}
