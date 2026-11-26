@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax Code Root Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZAPP1_TRUCK_PV provider contract transactional_query
as projection on ZAPP1_TRUCK_RV
{
//         @EndUserText.label: 'Vehicletype'  
//      @ObjectModel.text.element: [ 'Vehicletype' ] 
    key Vehicletype,
    Vehicledesc 
} 
