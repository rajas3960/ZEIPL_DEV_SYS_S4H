@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Carrier Freight Order Validity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_SD_SO_TMFO
  as select from zsd_so_tmfo
  association to parent ZR_SD_SO_TMCAR as _Carrier on  $projection.SalesOrder     = _Carrier.SalesOrder
                                                   and $projection.SalesOrderItem = _Carrier.SalesOrderItem
                                                   and $projection.Carrier        = _Carrier.Carrier
{
  key fouuid            as FoUuid,
      salesorder        as SalesOrder,
      salesorderitem    as SalesOrderItem,
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
