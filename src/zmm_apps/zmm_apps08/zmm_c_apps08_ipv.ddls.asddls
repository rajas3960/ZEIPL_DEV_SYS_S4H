@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request For Quotation Projection Item View Entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_C_APPS08_IPV
  as projection on ZMM_C_APPS08_IV
{
  key Supplier,
  key RequestForQuotation,
  key RequestForQuotationItem,
      Material,
      BaseUnit,
      OrderQuantityUnit,
      OrderItemQtyToBaseQtyNmrtr,
      OrderItemQtyToBaseQtyDnmntr,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      ScheduleLineOrderQuantity,
      ScheduleLineDeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      requested,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      arwared,
      curr,
      @Semantics.amount.currencyCode: 'curr'
      rate,
      @Semantics.amount.currencyCode: 'curr'
      netamount,
      PurchasingDocumentItemText,
      supplierqt,
      supplierqtim,

      /* Associations */
      _hdr : redirected to parent ZMM_C_APPS08_PV1
}
