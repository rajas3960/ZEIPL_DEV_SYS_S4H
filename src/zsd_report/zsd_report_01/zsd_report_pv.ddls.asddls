@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Report Against Broker Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_REPORT_PV
  provider contract transactional_query
  as projection on ZSD_REPORT_RV02
{
  key  Billing_No,
  key  billitem,
       SalesOredr,
       salesOrderitem,
       Salescontract,
       Salescontractitem,
       PlantSupplier,
       Billing_Date,
       Material_Code,
       Material_Desc,
       @Semantics.quantity.unitOfMeasure: 'uom'
       Qty,
       uom,
       Customer_code,
       Customer_Name,
       Consignee_Code,
       Consignee_Name,
       Broker_Code,
       Broker_Name,
       @Semantics.amount.currencyCode: 'TransactionCurrency'
       Net_Value,
       TransactionCurrency,
       @Semantics.amount.currencyCode: 'TransactionCurrency'
       Tax_Value,
       curr,
       @Semantics.amount.currencyCode: 'curr'
       Rate_value,
       Broker_rate,
       @Semantics.amount.currencyCode: 'curr'
       //       @Semantics.amount.currencyCode: 'TransactionCurrency'
       Broker_value,
       Open_value,
       Cleared_value
}
