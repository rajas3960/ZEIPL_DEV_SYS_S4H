@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Pending Qty View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PO_PENQTY 
as select from I_PurchaseOrderItemAPI01 as a
left outer join ZMM_MIGO_DELQTY as b on b.PurchaseOrder = a.PurchaseOrder
                            and b.PurchaseOrderItem = a.PurchaseOrderItem
{
    key a.PurchaseOrder,
    key a.PurchaseOrderItem,
        cast( a.OrderQuantity as abap.dec(13,3) ) as PoQty,
        b.DelQty,
        cast(
    cast( a.OrderQuantity as abap.dec(13,3) )
    - coalesce( b.DelQty, cast( 0 as abap.dec(13,3) ) )
    as abap.dec(13,3)
) as Pendqty

}
group by a.PurchaseOrder,
         a.PurchaseOrderItem,
         a.OrderQuantity,
         b.DelQty
