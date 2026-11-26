@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Contract Invoice Quantity'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZSD_SC_INVOICE_QTY
  as select from I_SalesOrderItem      as SO
    inner join   I_BillingDocumentItem as BI on  BI.SalesDocument     = SO.SalesOrder
                                             and BI.SalesDocumentItem = SO.SalesOrderItem
{
  key SO.ReferenceSDDocument     as SalesContract,
  key SO.ReferenceSDDocumentItem as SalesContractItem,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      sum( BI.BillingQuantity )  as InvoicedQty,
      BI.BaseUnit as BaseUnit
}
where
  SO.ReferenceSDDocument <> ''
group by
  SO.ReferenceSDDocument,
  SO.ReferenceSDDocumentItem,
  BI.BaseUnit

  
