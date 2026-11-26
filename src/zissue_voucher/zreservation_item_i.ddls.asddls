@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESERVATION ITEM INTERFACE'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZRESERVATION_ITEM_I 
as select from ZRESERVATION_ITEM
association to parent ZRESERVATION_HDR_I as _header on $projection.Reservation = _header.Requino

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
    ProductWithDescription,
    StorageLocation,
    Storagelocationname,
    Remark,
    _header
}
