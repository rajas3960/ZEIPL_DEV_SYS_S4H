@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales LC Utilization Header Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZLC_APP02_PV provider contract transactional_query as projection on  ZLC_APP02_RV
{
    key SalesDocument,
    SoldToParty,
    CustomerName,
    TotLCamt,
    Utilized_amt,
    Balance_amt,
    CreatedByUser,
    CreationDate,
    LastChangedByUser,
    LastChangeDateTime,
    /* Associations */
    _litem  : redirected to composition child ZLC_APP02_IPV
}
