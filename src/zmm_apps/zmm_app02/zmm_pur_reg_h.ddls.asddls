@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register History'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PUR_REG_H 
 as select from I_PurchaseOrderHistoryAPI01
{
    key PurchaseOrder,
    key PurchaseOrderItem,   
    key PurchasingHistoryDocument,

    PostingDate,

    @Semantics.amount.currencyCode: 'DocumentCurrency'
    PurchaseOrderAmount,

     DocumentCurrency,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    QtyInPurchaseOrderPriceUnit,

     BaseUnit,
    @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
    Quantity,

    PurchaseOrderQuantityUnit,
    ReferenceDocument,
    ReferenceDocumentItem,
    IsCompletelyDelivered


}
where //PurchaseOrderAmount <> cast( 0 as abap.curr(13,2) )
  PurchasingHistoryCategory = 'E'
group by
    PurchaseOrder,
    PurchaseOrderItem,
    DocumentCurrency,
    BaseUnit,
    PurchaseOrderQuantityUnit,
    PostingDate,
    PurchaseOrderAmount,
    QtyInPurchaseOrderPriceUnit,
    Quantity,
    PurchasingHistoryDocument,
    ReferenceDocument,
    ReferenceDocumentItem,
    IsCompletelyDelivered
