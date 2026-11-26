@EndUserText.label: 'Sales Order Parameter Input'
define abstract entity ZSD_ORDER
{
// Standard cds view value help

    @EndUserText.label: 'Customer'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer_VH', element: 'Customer' } }]
    Customer : kunnr;

    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_ORDER_VH', element: 'SalesDocument' },
                                       additionalBinding: [
                                       { localElement: 'Customer', element: 'Customer' ,
                                       usage: #FILTER_AND_RESULT }]}]
    @EndUserText.label: 'Sales Order'
    Salesdocument : vbeln_vl;
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_ORDERITEM_VH', element: 'SalesDocumentItem' },
                                    additionalBinding: [
                                    { localElement: 'Customer', element: 'Customer',usage: #FILTER_AND_RESULT },
                                    { localElement: 'Salesdocument', element: 'SalesDocument', usage: #FILTER_AND_RESULT }
                                    ] }]
    @EndUserText.label: 'Sales Order Item'
    SalesDocumentItem : posnr_vl;

//dispatch plan Value help
//    @EndUserText.label: 'Customer'
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_CUS_VH', element: 'Customer' } }]
//    Customer : abap.numc(10);
//
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_ORDER_VH', element: 'SalesDocument' },
//                                       additionalBinding: [
//                                       { localElement: 'Customer', element: 'Customer' ,
//                                       usage: #FILTER_AND_RESULT }]}]
//    @EndUserText.label: 'Sales Order'
//    Salesdocument : vbeln_vl;
//    
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_ORDERITEM_VH', element: 'SalesdocumentItem' },
//                                    additionalBinding: [
//                                    { localElement: 'Customer', element: 'Customer',usage: #FILTER_AND_RESULT },
//                                    { localElement: 'Salesdocument', element: 'Salesdocument', usage: #FILTER_AND_RESULT }
//                                    ] }]
//    @EndUserText.label: 'Sales Order Item'
//    SalesdocumentItem : posnr_vl;

    
}
