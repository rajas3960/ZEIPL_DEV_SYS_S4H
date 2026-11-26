@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Freight Order Validity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_MM_PO_TMFO
  as select from zmm_po_tmfo
  association to parent ZR_MM_PO_TMCAR as _Carrier on  $projection.PurchaseOrder     = _Carrier.PurchaseOrder
                                                   and $projection.PurchaseOrderItem = _Carrier.PurchaseOrderItem
                                                   and $projection.Carrier           = _Carrier.Carrier
{
  key fouuid            as FoUuid,
      purchaseorder     as PurchaseOrder,
      purchaseorderitem as PurchaseOrderItem,
      carrier           as Carrier,
      freightorder      as FreightOrder,
      validfrom         as ValidFrom,
      validto           as ValidTo,
      @Semantics.quantity.unitOfMeasure: 'FoUnit'
      foqty             as FoQty,
      founit            as FoUnit,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchanged  as LocalLastChanged,

      _Carrier
}
