@EndUserText.label: 'Inventory Auto Fetch Weighment'
define abstract entity ZMM_AUTOWT_INP
//  with parameters parameter_name : parameter_type
{
  @EndUserText.label: 'Weighment Machine'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_WEIGHMENT_VH',
   element: 'value_low' } }]  
  Weighmentmcno : abap.char(10);
    
}
