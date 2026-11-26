@EndUserText.label: 'Inventory Gate Entry Slip'
@ObjectModel.query.implementedBy: 'ABAP:ZGATE_SLIP_FORM_IMP'
define custom entity ZMM_ENTRY_SLIP_CE
  // with parameters parameter_name : parameter_type
{
  key uuid          : sysuuid_x16;
      vehicleno     : abap.char(15);
      gateentryno   : abap.char(20);
      gateentrydate : abap.dats;
      gateentrytime : abap.tims;

}
