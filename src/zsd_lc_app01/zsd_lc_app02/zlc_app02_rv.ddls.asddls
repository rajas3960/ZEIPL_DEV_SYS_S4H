@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales LC Utilization Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZLC_APP02_RV
  as select from    I_SalesDocument as s
    left outer join ZLC_APP02_HDE03 as i on i.SalesDocument = s.SalesDocument
    left outer join I_Customer as c on c.Customer = s.SoldToParty
  composition [0..*] of ZLC_APP02_IRV as _litem
{
  key s.SalesDocument as SalesDocument,
      s.SoldToParty,
      c.CustomerName,
      i.TotLCamt,
      i.Utilized_amt,
      i.Balance_amt,
      s.CreatedByUser,
      s.CreationDate,
      s.LastChangedByUser,
      s.LastChangeDateTime,
      _litem
}
where
    ( s.SalesDocumentType = 'ZEXP'
      or s.SalesDocumentType = 'ZDOM' )
    and s.DistributionChannel = '50'
