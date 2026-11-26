@EndUserText.label: 'Sales Order Parameter'
define abstract entity ZSALESORDER
//  with parameters parameter_name : parameter_type
{
    @EndUserText.label: 'Customer'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer_VH', element: 'Customer' } }]
    Customer : kunnr;

    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSALES_VH', element: 'SalesDocument' },
                                       additionalBinding: [
                                       { localElement: 'Customer', element: 'Customer' ,
                                       usage: #FILTER_AND_RESULT }]}]
    @EndUserText.label: 'Sales Order'
    Salesdocument : vbeln_vl;
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSALESITEM_VH', element: 'SalesDocumentItem' },
                                    additionalBinding: [
                                    { localElement: 'Customer', element: 'Customer',usage: #FILTER_AND_RESULT },
                                    { localElement: 'Salesdocument', element: 'SalesDocument', usage: #FILTER_AND_RESULT }
                                    ] }]
    @EndUserText.label: 'Sales Order Item'
    SalesDocumentItem : posnr_vl;

    
}
