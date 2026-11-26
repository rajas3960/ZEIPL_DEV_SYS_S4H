@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport ZTRP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAPP2_TRANSPORT as select from I_Supplier
{
    
    key Supplier,

    @Search.defaultSearchElement: true
    SupplierName,

    SupplierAccountGroup
}
where SupplierAccountGroup = 'ZTRP';
