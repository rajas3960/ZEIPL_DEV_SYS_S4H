@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Freight Orders for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PO_TMFO_API
  as select from zmm_po_tmfo  as f
    inner join   zmm_po_tmcar as c on  f.purchaseorder     = c.purchaseorder
                                   and f.purchaseorderitem = c.purchaseorderitem
                                   and f.carrier           = c.carrier
{
  key f.fouuid            as FoUuid,
      f.purchaseorder     as PurchaseOrder,
      f.purchaseorderitem as PurchaseOrderItem,
      f.carrier           as Carrier,
      c.carriername       as CarrierName,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      c.allocatedqty      as AllocatedQty,
      c.orderunit         as OrderUnit,
      f.freightorder      as FreightOrder,
      f.validfrom         as ValidFrom,
      f.validto           as ValidTo
}
