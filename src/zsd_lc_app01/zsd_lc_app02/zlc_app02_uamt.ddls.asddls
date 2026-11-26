@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Used LC Amount by Sales Order'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP02_UAMT
  as select from zlc_app02_idb
{
  key lcnum                                         as Lnum,
      @Semantics.amount.currencyCode: 'Lcurr'
      sum( cast( lcamount as abap.curr( 15, 2 ) ) ) as UsedAmount,

      lcurr                                         as Lcurr
}
group by
  lcnum,
  lcurr
