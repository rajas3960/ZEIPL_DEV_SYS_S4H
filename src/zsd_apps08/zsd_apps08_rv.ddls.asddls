@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BROKER CUSTOM APPLICATION ROOT'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_APPS08_RV
  as select from zsd_apps08_db as _hdr
  left outer join ZPP_APPS08_BD   as n on n.Brokerid = _hdr.brokerid
  left outer join ZPP_APPS08_DS02 as i on i.Customer = _hdr.brokerid
  composition [0..*] of ZSD_APPS08_IRV  as _item
{
  key _hdr.brokerid                                                             as Brokerid,
      _hdr.brokername                                                           as brokername,
      _hdr.fromdt                                                               as Fromdt,
      _hdr.todate                                                               as Todate,
      @Semantics.amount.currencyCode: 'Bkcurr'
      n.totamt                                                                  as Netamt,
      _hdr.bkcurr                                                               as Bkcurr,
      @Semantics.amount.currencyCode: 'Bkcurr'
      i.Total_utlize                                                            as Total_utlize,
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(coalesce(cast( n.totamt as abap.dec(15,2) ),0)
      -
      coalesce(cast( i.Total_utlize as abap.dec(15,2) ),0)as abap.dec( 15, 2 )) as Open_bal,

      @Semantics.user.createdBy: true
      _hdr.createdby                                                            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      _hdr.createdon                                                            as Createdon,
      _item
}
