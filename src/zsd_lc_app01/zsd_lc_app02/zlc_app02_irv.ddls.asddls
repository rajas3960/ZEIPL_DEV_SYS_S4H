@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales LC Utilization Item Root'
@Metadata.ignorePropagatedAnnotations: true
define  view entity ZLC_APP02_IRV as select from zlc_app02_idb
association to parent ZLC_APP02_RV as _hdr on $projection.Salesdocument = _hdr.SalesDocument
{
    key srno as Srno,
    key salesdocument as Salesdocument,
    lcnum as Lcnum,
    @Semantics.amount.currencyCode: 'Lcurr'
    lcamount as Lcamount,
    lcurr as Lcurr,
    mark as Mark,
    @Semantics.user.createdBy: true
    createdby as Createdby,
    @Semantics.systemDateTime.createdAt: true
    createdon as Createdon,
    @Semantics.user.lastChangedBy: true
    lastchangedbyuser as Lastchangedbyuser,
    @Semantics.systemDateTime.lastChangedAt: true
    lastchangedatetime as Lastchangedatetime,
    _hdr
}
