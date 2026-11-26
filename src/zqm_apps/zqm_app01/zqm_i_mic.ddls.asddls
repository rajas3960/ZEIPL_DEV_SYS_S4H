@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Manage PO MIC Master'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_I_MIC
  as select from zqm_mic_db as a
  association to parent ZQM_I_HEAD as _Header on $projection.Uuid = _Header.Uuid
  composition [0..*] of ZQM_I_SLAB as _ItemSlab
{
  key a.uuid               as Uuid,
  key a.plangroup          as Plangroup,
  key a.boocharacteristic  as Boocharacteristic,
      a.boocharacteristicversion as Boocharacteristicversion,
      a.inspectionlot      as Inspectionlot,
      a.booperationid      as Booperationid,
      a.inspunit           as Inspunit,
      a.inspectionspecid   as Inspectionspecid,
      a.inspectionspeplant as Inspectionspeplant,
      a.masteric           as Masteric,
      a.specification      as Specification,
      a.insptargetvalue    as Insptargetvalue,
      a.insplowerlimit     as Insplowerlimit,
      a.inspupperlimit     as Inspupperlimit,
      inspresultmeanvalue  as Inspresultmeanvalue,
      @Semantics.user.createdBy: true
      a.createdby          as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat          as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby      as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat      as Lastchangedat,
      _Header,
      _ItemSlab
}
