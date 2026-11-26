@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Allocation per PO Item'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_MM_PO_TMCAR
  as select from zmm_po_tmcar
  composition [0..*] of ZR_MM_PO_TMFO   as _FreightOrder
  association [0..1] to ZMM_PO_TMPOITEM as _POItem on  $projection.PurchaseOrder     = _POItem.PurchaseOrder
                                                   and $projection.PurchaseOrderItem = _POItem.PurchaseOrderItem
{
  key purchaseorder     as PurchaseOrder,
  key purchaseorderitem as PurchaseOrderItem,
  key carrier           as Carrier,
      carriername       as CarrierName,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      allocatedqty      as AllocatedQty,
      orderunit         as OrderUnit,
      @Semantics.user.createdBy: true
      createdby         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      createdat         as CreatedAt,
      @Semantics.user.lastChangedBy: true
      lastchangedby     as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat     as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchanged  as LocalLastChanged,

      _FreightOrder,
      _POItem
}
