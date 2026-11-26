@EndUserText.label: 'Weighment Input Parameter'
define abstract entity ZSD_WEIGHT_INP
//  with parameters parameter_name : parameter_type
{
  @EndUserText.label: 'Weighment Machine'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_WEIGHT_VH',
   element: 'value_low' } }]  
  Weighmentmcno : abap.char(10);

  @EndUserText.label: 'Weight Reading'
  Weight : menge_d;
  @Semantics.unitOfMeasure: true
  @Consumption.valueHelpDefault.display: true
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasureStdVH',
  element: 'UnitOfMeasure' } }]
  Unit   : abap.unit(3);    

    
}
