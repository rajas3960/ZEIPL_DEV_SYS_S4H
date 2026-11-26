@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Open Stock Qty'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_OPEN_STK1 
as select from I_StockQuantityCurrentValue_2(
    P_DisplayCurrency: 'INR'
  )
{
    key Product,
    key Plant,
    key StorageLocation,
    key InventoryStockType,
    key MaterialBaseUnit,
    key Currency,
    DisplayCurrency,
    ValuationAreaType,
    @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
    MatlWrhsStkQtyInMatlBaseUnit,
    SDDocument,
    SDDocumentItem
}
where ValuationAreaType = '1' and InventoryStockType = '01'
