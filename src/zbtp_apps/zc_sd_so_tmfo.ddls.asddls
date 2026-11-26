@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Carrier Freight Order Validity'
@Metadata.allowExtensions: true
define view entity ZC_SD_SO_TMFO
  as projection on ZR_SD_SO_TMFO
{
  key FoUuid,
      SalesOrder,
      SalesOrderItem,
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

      _Carrier : redirected to parent ZC_SD_SO_TMCAR
}
