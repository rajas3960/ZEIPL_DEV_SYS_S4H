@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery SUM Qty'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_DLV_SUMQTY 
as select from I_DeliveryDocumentItem as a
{
       key a.ReferenceSDDocument,
       key a.ReferenceSDDocumentItem,  
        sum( cast( a.ActualDeliveryQuantity as abap.dec(13,3)) ) as DeliveryQTY
}
where a.ReferenceSDDocument is not initial
group by a.ReferenceSDDocument, 
         a.ReferenceSDDocumentItem
