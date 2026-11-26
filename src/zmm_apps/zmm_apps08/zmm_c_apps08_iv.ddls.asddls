@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request For Quotation Item View Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_C_APPS08_IV
  as select from    I_RfqBidder_Api01       as bid
    inner join      I_RfqItem_Api01         as rfqi on rfqi.RequestForQuotation = bid.RequestForQuotation

    inner join      I_RfqScheduleLine_Api01 as rfsl on  rfsl.RequestForQuotation     = rfqi.RequestForQuotation
                                                    and rfsl.RequestForQuotationItem = rfqi.RequestForQuotationItem
    left outer join zmm_a_apps08_itm        as itm  on  itm.supplier                = bid.Supplier
                                                    and itm.requestforquotation     = rfqi.RequestForQuotation
                                                    and itm.requestforquotationitem = rfqi.RequestForQuotationItem
    left outer join ZMM_APPS08_SUP          as sup  on  sup.Supplier                = bid.Supplier
                                                    and sup.RequestForQuotation     = rfqi.RequestForQuotation
                                                    and sup.RequestForQuotationItem = rfqi.RequestForQuotationItem

  association to parent ZMM_I_APPS08_RV as _hdr on  _hdr.Supplier            = $projection.Supplier
                                                and _hdr.RequestForQuotation = $projection.RequestForQuotation

{
  key bid.Supplier,
  key rfqi.RequestForQuotation,
  key rfqi.RequestForQuotationItem,
      rfqi.Material,
      rfqi.BaseUnit,
      rfqi.OrderQuantityUnit,
      rfqi.OrderItemQtyToBaseQtyNmrtr,
      rfqi.OrderItemQtyToBaseQtyDnmntr,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      rfsl.ScheduleLineOrderQuantity,
      rfsl.ScheduleLineDeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      itm.requested,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      itm.arwared,
      itm.curr,
      @Semantics.amount.currencyCode: 'curr'
      itm.rate,
      @Semantics.amount.currencyCode: 'curr'
      itm.netamount,
      rfqi.PurchasingDocumentItemText,
      //      itm.supplierqt,
      //      itm.supplierqtim,
      sup.SupplierQuotation     as supplierqt,
      sup.SupplierQuotationItem as supplierqtim,




      _hdr


}
