@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Gate Entry Item - Apps Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_C_PGATEITEM 
as projection on ZMM_I_PGATEITEM
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
    Gateentryno,
    Material,
    Materialtext,
    Plant,
    Plantname,
    Baseunit,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Quantity,
    Remark,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Tareweight,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Grossweight,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Netweight,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Head : redirected to parent ZMM_C_GATEHEAD
}
