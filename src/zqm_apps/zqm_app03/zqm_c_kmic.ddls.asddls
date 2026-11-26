@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection KPI Specification'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZQM_C_KMIC 
as projection on ZQM_I_KMIC
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
    key Inspectionlot,
    key Plangroup,
    key Boocharacteristic,
    key Granduuid,
    Boocharacteristicversion,
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
    Inspresultoriginalvalue,
    Amtvalue,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Insp : redirected to parent ZQM_C_INSP,
    _POHead : redirected to ZQM_C_PO
}
