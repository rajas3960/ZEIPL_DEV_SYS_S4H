@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Quantity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SO_INVQTY
  as select from I_SDDocumentMultiLevelProcFlow as F
    inner join   I_BillingDocumentItem          as BI on  BI.BillingDocument     = F.SubsequentDocument
                                                      and BI.BillingDocumentItem = F.SubsequentDocumentItem
    inner join   I_BillingDocument              as BH on BH.BillingDocument = BI.BillingDocument
{
  key F.PrecedingDocument     as SalesOrder,
  key F.PrecedingDocumentItem as SalesOrderItem,
      BI.BaseUnit             as BaseUnit,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      sum( BI.BillingQuantityInBaseUnit ) as InvoicedQty
}
where F.PrecedingDocumentCategory  = 'C'   
  and F.SubsequentDocumentCategory = 'M'   
  and BH.BillingDocumentIsCancelled = ''
group by
  F.PrecedingDocument,
  F.PrecedingDocumentItem,
  BI.BaseUnit 
