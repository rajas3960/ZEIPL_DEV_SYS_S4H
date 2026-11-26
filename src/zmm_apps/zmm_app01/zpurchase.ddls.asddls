@EndUserText.label: 'Purchase Order Parameter'
define abstract entity ZPURCHASE
//  with parameters parameter_name : parameter_type
{
    @EndUserText.label: 'Vendor'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSUPPLIER_VH', element: 'Vendor' } }]    
    Vendor : abap.char(10);
    @EndUserText.label: 'Purchase Order'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPURCHASE_VH', element: 'PurchaseOrder' },
                                       additionalBinding: [
                                       { localElement: 'Vendor', element: 'Vendor' ,
                                       usage: #FILTER_AND_RESULT }]}]  
    PurchaseOrder : abap.char(10);
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPOITEM_VH', element: 'PurchaseOrderItem' },
                                    additionalBinding: [
                                    { localElement: 'Vendor', element: 'Vendor',usage: #FILTER_AND_RESULT },
                                    { localElement: 'PurchaseOrder', element: 'PurchaseOrder', usage: #FILTER_AND_RESULT }
                                    ] }]
    @EndUserText.label: 'Order Item'    
    PurchaseOrderItem : abap.numc(5);

    
}
