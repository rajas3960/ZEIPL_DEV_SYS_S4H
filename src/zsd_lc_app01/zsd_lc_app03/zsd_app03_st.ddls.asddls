@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LC Approval Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsd_app03_st as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZSD_APPROVE' )
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
