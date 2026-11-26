@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Carrier Freight Orders for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SO_TMFO_API
  as select from zsd_so_tmfo  as f
    inner join   zsd_so_tmcar as c on  f.salesorder     = c.salesorder
                                   and f.salesorderitem = c.salesorderitem
                                   and f.carrier        = c.carrier
{
  key f.fouuid          as FoUuid,
      f.salesorder      as SalesOrder,
      f.salesorderitem  as SalesOrderItem,
      f.carrier         as Carrier,
      c.carriername     as CarrierName,
      f.freightorder    as FreightOrder
}
