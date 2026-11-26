@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Ageing For Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_AGEING_RV
  as select from I_MaterialDocumentItem_2
{
  key MaterialDocumentYear,
  key MaterialDocument,
  key MaterialDocumentItem,
      Material,
      Plant,
      StorageLocation,
      SalesOrder,
      SalesOrderItem,
      InventorySpecialStockType,
      InventoryStockType,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      QuantityInBaseUnit,
      MaterialBaseUnit,
      PostingDate,
      DocumentDate,
      CompanyCode,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalGoodsMvtAmtInCCCrcy,
      CompanyCodeCurrency

}
