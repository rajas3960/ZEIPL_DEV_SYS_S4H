@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vehicle Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZMM_APP2_VEHICLE
 as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZMM_V_TYPE')
{
    @UI.hidden: true
    key domain_name,

    @UI.hidden: true
    key value_position,

    @Semantics.language: true
    @UI.hidden: true
    key language,

    @EndUserText.label: 'Vehicle Type'
//    @ObjectModel.text.element: [ 'text' ]
    value_low,
    
    @Semantics.text: true
      @EndUserText.label: 'Vehicle Type'
//      @ObjectModel.text.element: [ 'text' ]
//      Vehicletype,
    text
    
}


//define view entity ZMM_APP2_VEHICLE 
//as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZMM_V_TYPE')
//{
//      @UI.hidden: true
//  key domain_name,
//      @UI.hidden: true
//  key value_position,
//      @Semantics.language: true
//      @UI.hidden: true
//  key language,
//      @EndUserText.label: 'Gate Pass Type'
//      @ObjectModel.text.element: [ 'text' ]
//      value_low,
//      @Semantics.text: true
//      text
//      }
