@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'First Sales Order per Contract Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SC_FIRST_SO
  as select from ZSD_SC_ORDER_TRAKING
{
  key ReferenceSDDocument     as SalesContract,
  key ReferenceSDDocumentItem as SalesContractItem,
      min( concat( SalesOrder, SalesOrderItem ) ) as FirstKey
}
where ReferenceSDDocumentCategory = 'G'
group by
  ReferenceSDDocument,
  ReferenceSDDocumentItem
