@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Item Apps - Dispatch'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_CI_GATE 
as projection on ZSD_II_GATE
{
    key Uuid,
    key Salesdocument,
    key Salesitem,
    Customer,
    Customername,
    Gateentryno,
    @ObjectModel.text.element: [ 'Plantname' ]
    Plant,
    Plantname,
    Material,
    Materialdesc,
    Baseunit,
    Batch,
    @Semantics.quantity.unitOfMeasure: 'baseunit'
    Quantity,
    Remark,
    @Semantics.quantity.unitOfMeasure: 'baseunit'    
    Tareweight,
    @Semantics.quantity.unitOfMeasure: 'baseunit'    
    Grossweight,
    @Semantics.quantity.unitOfMeasure: 'baseunit'    
    Netweight,
    Ordertype,
    Distributionchannel,
    Shippingpoint,
    @ObjectModel.text.element: [ 'Weighmentmcndes' ]
    Weighmentmcno,
    Weighmentmcndes,
    Independentrequirementtype,
    OpenQty,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Header : redirected to parent ZSD_CH_GATE
}
