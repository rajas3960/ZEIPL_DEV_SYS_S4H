@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Item Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_GATE_ITEM_I
  as select from zsd_git_db
  association to parent ZSD_GATE_I as _GateHead on $projection.Gateentryuuid = _GateHead.Gateentryuuid
                                                and $projection.Gateentrytype = _GateHead.Gateentrytype
                                                and $projection.Gateentrydate = _GateHead.Gateentrydate
                                                and $projection.Gateentrytime = _GateHead.Gateentrytime
                                                and $projection.Trucknumber = _GateHead.Trucknumber
{
  key gateentryuuid  as Gateentryuuid,
  key gateentrytype  as Gateentrytype,
  key gateentrydate  as Gateentrydate,
  key gateentrytime  as Gateentrytime,
  key trucknumber    as Trucknumber,
  key loadingid      as Loadingid,
      customer       as Customer,
      salesorder     as Salesorder,
      salesorderitem as Salesorderitem,
      material       as Material,
      baseunit       as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      loadingweight  as Loadingweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      tareweight     as Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      grossweight    as Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      netweight      as Netweight,
      weighedat      as Weighedat,
      weighedby      as Weighedby,
      _GateHead
}
