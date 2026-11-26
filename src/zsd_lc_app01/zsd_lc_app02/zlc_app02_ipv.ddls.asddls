@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales LC Utilization Item Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZLC_APP02_IPV as projection on ZLC_APP02_IRV
{
    key Srno,
    key Salesdocument,
    Lcnum,
    @Semantics.amount.currencyCode: 'Lcurr'
    Lcamount,
    Lcurr,
    Mark,
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdon,
    @Semantics.user.lastChangedBy: true
    Lastchangedbyuser,
    @Semantics.systemDateTime.lastChangedAt: true
    Lastchangedatetime,
    /* Associations */
    _hdr :redirected to parent ZLC_APP02_PV
}
