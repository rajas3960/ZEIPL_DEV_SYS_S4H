@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Manage PO MIC Master Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZQM_C_MIC 
as projection on ZQM_I_MIC
{
    key Uuid,
    key Plangroup,
    key Boocharacteristic,
    Boocharacteristicversion,
    Inspectionlot,
    Booperationid,
    Inspunit,
    Inspectionspecid,
    Inspectionspeplant,
    Masteric,
    Specification,
    Insptargetvalue,
    Insplowerlimit,
    Inspupperlimit,
    Inspresultmeanvalue,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Header : redirected to parent ZQM_C_HEAD,
    _ItemSlab : redirected to composition child ZQM_C_SLAB
}
