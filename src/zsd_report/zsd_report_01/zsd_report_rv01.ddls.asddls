@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Report Against Broker Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_REPORT_RV01 as select from ZSD_REPORT_Rv
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
    @Semantics.amount.currencyCode: 'curr'
    Net_Value,
    TransactionCurrency,
    @Semantics.amount.currencyCode: 'curr'
    Tax_Value,
    Rate_value,
    curr,
    @Semantics.amount.currencyCode: 'curr'
    Broker_rate,
    @Semantics.amount.currencyCode: 'curr'
    case when Broker_value < 0
    then
    Broker_value * -1
    else Broker_value 
    end as Broker_value,
    Open_value,
    Cleared_value,
    @Semantics.amount.currencyCode: 'currency_key'
    amount,
    currency_key,
    tax_code
}where
    Broker_value is not initial
