@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Contract Order Quantity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SC_ORDER_QTY
  as select from I_SalesOrderItem as SO
{
  key SO.ReferenceSDDocument      as SalesContract,
  key SO.ReferenceSDDocumentItem  as SalesContractItem,
      @Semantics.quantity.unitOfMeasure: 'RequestedQuantityUnit'
      sum( SO.RequestedQuantity ) as TotalSalesOrderQty,
      SO.RequestedQuantityUnit
}
where
  SO.ReferenceSDDocument <> ''
group by
  SO.ReferenceSDDocument,
  SO.ReferenceSDDocumentItem,
  SO.RequestedQuantityUnit
