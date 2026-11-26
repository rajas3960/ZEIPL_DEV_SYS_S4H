@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Header Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_GATE_I
  as select from zsd_ghd_db
  composition [0..*] of ZSD_GATE_ITEM_I as _GateItem
{
  key gateentryuuid as Gateentryuuid,
  key gateentrytype as Gateentrytype,
  key gateentrydate as Gateentrydate,
  key gateentrytime as Gateentrytime,
  key trucknumber   as Trucknumber,
      drivername    as Drivername,
      drivernumber  as Drivernumber,
      driverlicense as Driverlicense,
      baseunit      as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      tareweight    as Tareweight,
      weighedat     as Weighedat,
      weighedby     as Weighedby,
      _GateItem
}
