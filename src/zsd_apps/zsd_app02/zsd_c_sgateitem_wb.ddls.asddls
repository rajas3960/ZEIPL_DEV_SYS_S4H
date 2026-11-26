@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Item-Weigh Bridge Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_C_SGATEITEM_WB 
as projection on ZSD_I_SGATEITEM_WB
{
    key Uuid,
    key Salesdocument,
    key Salesitem,
    Gateentryno,
    Plant,
    Plantname,
    Material,
    Materialdesc,
    Baseunit,
    Batch,
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
    _Head : redirected to parent ZSD_C_GATEHEAD_WB
}
