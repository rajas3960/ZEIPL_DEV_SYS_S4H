@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Gate Entry PO - Apps Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_C_PGATEHEAD 
as projection on ZMM_I_PGATEHEAD
{
    key Uuid,
    key Purchaseorder,
    Vendor,
    Gateentryno,
    Suppliername,
    Orderdate,
    Referno,
    Referdate,
    Fromplace,
    Toplace,
    Baseunit,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Challantareweight,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Challangrossweight,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Challannetweight,
    Freightorderno,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Head : redirected to parent ZMM_C_GATEHEAD
}
