@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_ORDER_VH1
  as select from    I_SalesDocument     as a
    inner join      I_SalesDocumentItem as c on c.SalesDocument = a.SalesDocument
    left outer join I_Customer_VH       as b on b.Customer = a.SoldToParty
{
  key a.SalesDocument as SalesDocument,
      a.SoldToParty   as Customer,
      b.CustomerName
}
where
  c.SDProcessStatus <> 'C' and (  a.SalesDocumentType = 'ZDOM' or
  a.SalesDocumentType = 'ZEXP' or
  a.SalesDocumentType = 'ZJOB' or
  a.SalesDocumentType = 'CBRE' )
group by
  a.SalesDocument,
  a.SoldToParty,
  b.CustomerName
