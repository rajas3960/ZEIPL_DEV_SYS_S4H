@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BROKER CUSTOM APPLICATION ITEM ROOT'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_APPS08_IRV
  as select from zsd_apps08_idb as _item
  association to parent ZSD_APPS08_RV as _hdr on $projection.Brokerid = _hdr.Brokerid
{
  key srno      as Srno,
  key brokerid  as Brokerid,
      partnerid as Partnerid,
      @Semantics.amount.currencyCode: 'Bkcurr'
      netamt    as Netamt,
      bkcurr    as Bkcurr,
      @Semantics.user.createdBy: true
      createdby as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdon as Createdon,
      _hdr
}
