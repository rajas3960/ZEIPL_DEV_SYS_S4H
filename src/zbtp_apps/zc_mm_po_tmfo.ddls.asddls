@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Freight Order Validity'
@Metadata.allowExtensions: true
define view entity ZC_MM_PO_TMFO
  as projection on ZR_MM_PO_TMFO
{
  key FoUuid,
      PurchaseOrder,
      PurchaseOrderItem,
      Carrier,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_FO_VH', element: 'FreightOrder' },
                                           additionalBinding: [{ localElement: 'Carrier',
                                                                 element: 'Carrier',
                                                                 usage: #FILTER }] }]
      FreightOrder,
      ValidFrom,
      ValidTo,
      @Semantics.quantity.unitOfMeasure: 'FoUnit'
      FoQty,
      FoUnit,
      LocalLastChanged,

      _Carrier : redirected to parent ZC_MM_PO_TMCAR
}
