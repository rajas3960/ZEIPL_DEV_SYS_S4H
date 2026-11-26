@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection Result Recording'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_I_INSP_RESULT
  as select from zqm_mic_db
  association to parent ZQM_I_INSP_HEAD as _InspHead on $projection.Uuid = _InspHead.Uuid
{
  key uuid                    as Uuid,
  key plangroup               as Plangroup,
  key boocharacteristic       as Boocharacteristic,
      inspectionlot           as Inspectionlot,
      booperationid           as Booperationid,
      inspunit                as Inspunit,
      inspectionspecid        as Inspectionspecid,
      inspectionspeplant      as Inspectionspeplant,
      masteric                as Masteric,
      specification           as Specification,
      insptargetvalue         as Insptargetvalue,
      insplowerlimit          as Insplowerlimit,
      inspupperlimit          as Inspupperlimit,
      inspresultmeanvalue     as Inspresultmeanvalue,
      inspresultoriginalvalue as Inspresultoriginalvalue,
      amtvalue                as Amtvalue,
      createdby               as Createdby,
      createdat               as Createdat,
      lastchangedby           as Lastchangedby,
      lastchangedat           as Lastchangedat,
      _InspHead
}
