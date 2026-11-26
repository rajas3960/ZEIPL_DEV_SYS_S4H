@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Production Stock Qty'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_PRD_STK 
as select from I_ReservationDocumentItem
{
key Plant,
key StorageLocation,
key Product,
EntryUnit,
@Semantics.quantity.unitOfMeasure: 'EntryUnit'
sum( ResvnItmRequiredQtyInBaseUnit ) as PrdQty,
@Semantics.quantity.unitOfMeasure: 'EntryUnit'
sum( ResvnItmWithdrawnQtyInBaseUnit ) as WitdraQty


}
where ReservationItemIsFinallyIssued is initial
group by Plant,
         StorageLocation,
         Product,
         EntryUnit
