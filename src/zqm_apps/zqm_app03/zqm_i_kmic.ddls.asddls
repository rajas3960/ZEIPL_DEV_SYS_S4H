@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection Specification'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_I_KMIC
  as select from zqm_kpi_db as a
  association to parent ZQM_I_INSP as _Insp on  $projection.Uuid              = _Insp.Uuid
                                              and $projection.Purchaseorder = _Insp.Purchaseorder
                                              and $projection.Purchaseorderitem = _Insp.Purchaseorderitem
                                              and $projection.Inspectionlot         = _Insp.Inspectionlot
  association to ZQM_I_PO       as _POHead  on  $projection.Uuid = _POHead.Uuid
                                              and $projection.Purchaseorder = _POHead.Purchaseorder
                                              and $projection.Purchaseorderitem = _POHead.Purchaseorderitem
  
{
  key a.uuid                     as Uuid,
  key a.purchaseorder            as Purchaseorder,
  key a.purchaseorderitem        as Purchaseorderitem,
  key a.inspectionlot            as Inspectionlot,
  key a.plangroup                as Plangroup,
  key a.boocharacteristic        as Boocharacteristic,
  key a.granduuid                as Granduuid,
      a.boocharacteristicversion as Boocharacteristicversion,
      a.booperationid            as Booperationid,
      a.inspunit                 as Inspunit,
      a.inspectionspecid         as Inspectionspecid,
      a.inspectionspeplant       as Inspectionspeplant,
      a.masteric                 as Masteric,
      a.specification            as Specification,
      a.insptargetvalue          as Insptargetvalue,
      a.insplowerlimit           as Insplowerlimit,
      a.inspupperlimit           as Inspupperlimit,
      a.inspresultmeanvalue      as Inspresultmeanvalue,
      a.inspresultoriginalvalue  as Inspresultoriginalvalue,
      a.amtvalue                 as Amtvalue,
      @Semantics.user.createdBy: true
      a.createdby                as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat                as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby            as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat            as Lastchangedat,
      _Insp,
      _POHead
}
