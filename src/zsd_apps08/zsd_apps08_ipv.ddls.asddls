@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BROKER CUSTOM APPLICATION ITEM ROOT'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_APPS08_IPV as projection on ZSD_APPS08_IRV
{
    key Srno,
    key Brokerid,
    Partnerid,
    @Semantics.amount.currencyCode: 'Bkcurr'
    Netamt,
    Bkcurr,
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdon,
    /* Associations */
    _hdr : redirected to parent ZSD_APPS08_PV
}
