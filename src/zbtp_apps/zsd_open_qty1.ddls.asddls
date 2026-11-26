@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Open Quantity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_OPEN_QTY1
  as select from    I_SalesDocumentItem as a
    left outer join ZSD_DLV_SUMQTY      as b on  b.ReferenceSDDocument     = a.SalesDocument
                                             and b.ReferenceSDDocumentItem = a.SalesDocumentItem
{
  key a.SalesDocument,
  key a.SalesDocumentItem,
      cast( a.OrderQuantity as abap.dec(15,3) ) as SalesQty,
      b.DeliveryQTY,
      cast(
          cast( a.OrderQuantity as abap.dec(15,3) )
          -
          cast( coalesce( b.DeliveryQTY, 0 ) as abap.dec(15,3) )
          as abap.dec(15,3)
      )                                         as OpenQty

}
