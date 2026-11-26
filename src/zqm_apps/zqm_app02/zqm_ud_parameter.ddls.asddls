@EndUserText.label: 'Inspection Result Usage Decision'
define abstract entity ZQM_UD_PARAMETER
//  with parameters parameter_name : parameter_type
{
    @EndUserText.label: 'UD Code'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZQM_UD_VH', element: 'value_low' } ,
                                        distinctValues: true }]   
    Usagedecisioncode : abap.char( 4 ) ;
    
}
