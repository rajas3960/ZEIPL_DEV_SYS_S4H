@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Custom Broker Cds View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_BROKER_CDS 
as select from ZSD_APPS08_RV
{
    key Brokerid,
    Bkcurr,
    @Semantics.amount.currencyCode: 'Bkcurr'
    Open_bal
}
 