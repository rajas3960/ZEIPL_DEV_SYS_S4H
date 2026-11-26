@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Freight Order Form'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_FREIGHT_ORDER as select from zmm_po_tmfo
{
    key fouuid as Fouuid,
    purchaseorder as Purchaseorder,
    purchaseorderitem as Purchaseorderitem,
    carrier as Carrier,
    freightorder as Freightorder,
    validfrom as Validfrom,
    validto as Validto,
     @Semantics.quantity.unitOfMeasure : 'founit'
    foqty as Foqty,
    founit as Founit,
    locallastchanged as Locallastchanged
}
