@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BROKER CUSTOM APPLICATION ROOT'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_APPS08_PV provider contract transactional_query as projection on ZSD_APPS08_RV
{
    key Brokerid,
    brokername,
    Fromdt,
    Todate,
    @Semantics.amount.currencyCode: 'Bkcurr'
    Netamt,
    Total_utlize,
    Bkcurr,
    Open_bal,
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdon,
    /* Associations */
    _item : redirected to composition child ZSD_APPS08_IPV
}
