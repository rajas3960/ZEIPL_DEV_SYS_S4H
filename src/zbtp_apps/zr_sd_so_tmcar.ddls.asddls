@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Allocation per SO Item'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SD_SO_TMCAR
  as select from zsd_so_tmcar
  composition [0..*] of ZR_SD_SO_TMFO    as _FreightOrder
  association [0..1] to ZSD_SO_TMSOITEM  as _SOItem on  $projection.SalesOrder     = _SOItem.SalesOrder
                                                    and $projection.SalesOrderItem = _SOItem.SalesOrderItem
{
  key salesorder        as SalesOrder,
  key salesorderitem    as SalesOrderItem,
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
      _SOItem
}
