@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Report Against Broker Root2'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_REPORT_RV02 as select from ZSD_REPORT_RV01
{
    key Billing_No,
    key billitem,
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
    @Semantics.amount.currencyCode: 'curr'
    Tax_Value,
    Rate_value,
    curr,
    @Semantics.amount.currencyCode: 'curr'
    Broker_rate,
    @Semantics.amount.currencyCode: 'curr'
    Broker_value,
    Open_value,
    Cleared_value,
    @Semantics.amount.currencyCode: 'currency_key'
    amount,
    currency_key,
    tax_code
}where amount is null or amount is initial
