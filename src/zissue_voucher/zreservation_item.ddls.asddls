@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'reservation item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZRESERVATION_ITEM 
as select from I_ReservationDocumentItem as rdi
left outer join I_ProductDescription  as prd  on prd.Product = rdi.Product
                                              and prd.Language = $session.system_language

left outer join I_ProductValuationBasic as pv  on pv.Product = rdi.Product
                                          and pv.ValuationArea = rdi.Plant
left outer join I_MaterialDocumentItem_2 as mdi on mdi.Reservation = rdi.Reservation
                                               and mdi.ReservationItem = rdi.ReservationItem
                                               and mdi.DebitCreditCode = 'H'
                                               and mdi.ReversedMaterialDocument <> ' '
left outer join I_StorageLocation as sl on sl.Plant = rdi.Plant
                                        and sl.StorageLocation = rdi.StorageLocation
{
    key rdi.Reservation,
    key rdi.ReservationItem,
    key mdi.MaterialDocument,
    key mdi.MaterialDocumentItem,
        rdi.Product as productcode,
        prd.ProductDescription as itemdetails,
        rdi.BaseUnit    as um,
        @Semantics.quantity.unitOfMeasure: 'um'
        rdi.ResvnItmRequiredQtyInBaseUnit as reqqty,
        @Semantics.quantity.unitOfMeasure: 'um'
        rdi.ResvnItmWithdrawnQtyInBaseUnit as issueqty,
        pv.Currency,
        @Semantics.amount.currencyCode: 'Currency'
        pv.MovingAveragePrice   as rate,
        @Semantics.amount.currencyCode: 'Currency'
        rdi.ResvnItmWithdrawnAmtInCCCrcy as provamt,
         concat(
    concat(
        ltrim( rdi.Product, '0' ),
        ' - '
    ),
    prd.ProductDescription
) as ProductWithDescription,
mdi.StorageLocation,
concat( concat(ltrim( rdi.StorageLocation, '0' ),' - ' ),sl.StorageLocationName ) as Storagelocationname,

rdi.ReservationItemText as Remark     
}
