@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Manage PO Slab Master'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_I_SLAB
  as select from zqm_slab_db as a
  association to parent ZQM_I_MIC as _ItemMIC on  $projection.Uuid              = _ItemMIC.Uuid
                                              and $projection.Plangroup         = _ItemMIC.Plangroup
                                              and $projection.Boocharacteristic = _ItemMIC.Boocharacteristic
  association to ZQM_I_HEAD       as _Header  on  $projection.Uuid = _Header.Uuid
{
  key a.uuid                 as Uuid,
  key a.plangroup            as Plangroup,
  key a.boocharacteristic    as Boocharacteristic,
  key a.granduuid            as Granduuid,
      a.slabno               as Slabno,
      a.minusplus            as Minusplus,
      a.fromslab             as Fromslab,
      a.fromuom              as Fromuom,
      a.toslab               as Toslab,
      a.touom                as Touom,
      a.debitcreditindicator as Debitcreditindicator,
      a.currency             as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      a.amount               as Amount,
      a.amountnew            as Amountnew,
      a.perrate              as Perrate,
      a.poqtyuom             as Poqtyuom,
      a.fromslabamt          as Fromslabamt,
      a.toslabamt            as Toslabamt,
      @Semantics.user.createdBy: true
      a.createdby            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat            as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby        as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat        as Lastchangedat,
      _ItemMIC,
      _Header
}
