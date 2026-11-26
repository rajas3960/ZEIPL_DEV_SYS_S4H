@EndUserText.label: 'Freight Order Value Help'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MM_FO_VH_QUERY'
define custom entity ZMM_FO_VH
{
      @EndUserText.label:'Freight Order'
  key FreightOrder     : zmm_freight_order_id;
      @EndUserText.label:'Freight Order Type'
      FreightOrderType : abap.char(4);
      @EndUserText.label:'Carrier'
      Carrier          : zmm_carrier_id;
      @EndUserText.label:'Carrier Name'
      CarrierName      : abap.char(81);
      @EndUserText.label:'Life Cycle Status'
      LifeCycleStatus  : abap.char(2);
}
