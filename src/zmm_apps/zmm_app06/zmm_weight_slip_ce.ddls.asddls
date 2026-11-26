@EndUserText.label: 'Inventory Weighment Slip form'
@ObjectModel.query.implementedBy: 'ABAP:ZWEIGHMENT_FORM_IMP'
define custom entity ZMM_WEIGHT_SLIP_CE
  // with parameters parameter_name : parameter_type
{
  key uuid          : sysuuid_x16;
      vehicleno     : abap.char(15);
      gateentrydate : abap.dats;
      grosswt       : abap.dec( 13, 3 );
      tareweight    : abap.dec( 13, 3 );
      netweight     : abap.dec( 13, 3 );

}
