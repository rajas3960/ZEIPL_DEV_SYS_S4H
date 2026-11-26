@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Broker Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPP_APPS08_BD as select from ZSD_APPS08_IRV as s

{
    key s.Brokerid as Brokerid,
    @Semantics.amount.currencyCode: 'bkcurr'
    sum( cast( s.Netamt as abap.curr( 15, 2 ) ) )as totamt,
    s.Bkcurr 
}
group by
s.Brokerid,
s.Bkcurr
