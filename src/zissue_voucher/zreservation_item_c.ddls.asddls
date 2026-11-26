@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESERVATION ITEM I CONSUMPTION'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZRESERVATION_ITEM_C
  as projection on ZRESERVATION_ITEM_I
{
  key Reservation,
  key ReservationItem,
    key MaterialDocument,
    key MaterialDocumentItem,  
      productcode,
      itemdetails,
      um,
      @Semantics.quantity.unitOfMeasure: 'um'
      reqqty,
      @Semantics.quantity.unitOfMeasure: 'um'
      issueqty,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      rate,
      @Semantics.amount.currencyCode: 'Currency'
      provamt,
      StorageLocation,
      Storagelocationname,
      Remark,
      /* Associations */
      _header : redirected to parent ZRESERVATION_HDR_C
}
