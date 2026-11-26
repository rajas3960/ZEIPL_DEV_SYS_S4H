@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection Result Recording'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZQM_C_INSP_RESULT 
as projection on ZQM_I_INSP_RESULT
{
    key Uuid,
    key Plangroup,
    key Boocharacteristic,
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
    Inspresultoriginalvalue,
    Amtvalue,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _InspHead : redirected to parent ZQM_C_INSP_HEAD
}
