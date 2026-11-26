@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Weighment Flag Master'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_IH_WMT_FLAG
  as select from zmm_app10_db as a
{
  key a.gateentryseries    as Gateentryseries,
  key a.materialgroup      as Materialgroup,
      a.gateentryseriesdes as Gateentryseriesdes,
      a.materialgroupdes   as Materialgroupdes,
      a.weighmentflag      as Weighmentflag,
      a.challanqtyflag     as Challanqtyflag,
      @Semantics.user.createdBy: true
      a.createdby          as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat          as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby      as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat      as Lastchangedat
}
