@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register - Projection View 1'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_PUR_REG_PV_01
  as select from ZMM_PUR_REG_PV
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key PurchasingHistoryDocument,
  key SupplierInvoice,
  key SupplierInvoiceItem,
  key FiscalYear,
      PurchaseRequisition,
      Plant,
      Material,
      PurchaseOrderItemText,
      BaseUnit,
      MaterialType,
      NetAmount,
      POCurrency,
      NetPriceAmount,
      TaxCode,
      OrderQuantity,
      CompanyCode,
      PurchaseOrderDate,
      Supplier,
      PurchasingGroup,
      ScheduleLineDeliveryDate,
      BalanceOrderQuantity,
      PostingDate,
      Quantity,
      IsCompletelyDelivered,
      CreationDate,
      IGST,
      CGST,
      SGST,
      TaxPercentage,
//      SupplierInvoice,
      PlantName ,
      MaterialTypeName,
      SupplierName,
      PurchasingGroupName,
      PurchaseOrderType,
//      WrkflwTskCreationUTCDateTime,
//      WorkflowTaskProcessor,
//      PersonFullName,
      IGSTAmount,
      CGSTAmount,
      SGSTAmount,
      TotalAmount,
      CancelQuantity,
      APP1,
      APP2,
      APP3,
      GrnAmount,
      InvoiceDate,
      InvoiceReferenceNumber,
      SupplierReferenceNumber,
      SupplierReferenceDate
      
      
      
      
}













