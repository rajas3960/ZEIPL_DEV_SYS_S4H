@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_ORDERITEM_VH1
  as select from I_SalesDocumentItem as a
{
  key a.SalesDocument     as SalesDocument,
  key a.SalesDocumentItem as SalesDocumentItem,
      a.SoldToParty       as Customer,
      a.SalesDocumentItemText as ProductDescription
}
where SDProcessStatus <> 'C' and (  SalesDocumentType = 'ZDOM' or
  SalesDocumentType = 'ZEXP' or
  SalesDocumentType = 'ZJOB' or
  SalesDocumentType = 'CBRE' )
