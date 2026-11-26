@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Contract Report - Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_SC_REPORT_PV
provider contract transactional_query
  as projection on ZSD_SC_REPORT_RV
{
  key SalesContract                  as SalesContract,
  key SalesContractItem                as SalesContractItem,
  key SalesOrder                         as SalesOrder,
  key SalesOrderItem                     as SalesOrderItem,
      MaterialCode,
      MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      @DefaultAggregation: #SUM
      ContractQuantity,
      Unit,
      @Semantics.amount.currencyCode: 'Currency'
//      @DefaultAggregation: #SUM
      ContractRateValue,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      @DefaultAggregation: #SUM
      ContractNetValue,
      @Semantics.amount.currencyCode: 'Currency'
      @DefaultAggregation: #SUM
      ContractTaxValue,
      SoldToParty,
      SoldToPartyDescription,      
      ShipToParty,
      ShipToPartyDescription,
      ContractValidFrom,
      ContractValidTo,
      @Semantics.quantity.unitOfMeasure: 'Requnit'
      @DefaultAggregation: #SUM
      TotalSalesOrderQty,
      Requnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      @DefaultAggregation: #SUM
      InvoicedQty,
      BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      @DefaultAggregation: #SUM
      BalanceQty,
      BalanceUnit,
      SalesOrderDate,
      CustomerReference,
      CustomerReferenceDate,
      Division,
      HSNCode,
      SOShipTo,
      BrokerCode,
      BrokerName,
      SOCurrency,
       @Semantics.amount.currencyCode: 'SOCurrency'
      SONetAmount,
       @Semantics.amount.currencyCode: 'SOCurrency'
      SGST,
       @Semantics.amount.currencyCode: 'SOCurrency'
      CGST,
       @Semantics.amount.currencyCode: 'SOCurrency'
      IGST,
       @Semantics.amount.currencyCode: 'SOCurrency'
      Roundoff,
      SOUnit,
      @Semantics.quantity.unitOfMeasure: 'SOUnit'
      SOQty,
      @Semantics.quantity.unitOfMeasure: 'SOUnit'
      SOInvoicedQty,
      @Semantics.quantity.unitOfMeasure: 'SOUnit'
      @DefaultAggregation: #SUM
      SOBalanceQty
      
      
      
}
