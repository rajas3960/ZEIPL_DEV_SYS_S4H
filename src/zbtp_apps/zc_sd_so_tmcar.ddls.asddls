@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Allocation per SO Item'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_SD_SO_TMCAR
  provider contract transactional_query
  as projection on ZR_SD_SO_TMCAR
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_SO_TMSOITEM', element: 'SalesOrder' } }]
  key SalesOrder,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_SO_TMSOITEM', element: 'SalesOrderItem' },
                                           additionalBinding: [{ localElement: 'SalesOrder',
                                                                 element: 'SalesOrder',
                                                                 usage: #FILTER_AND_RESULT }] }]
  key SalesOrderItem,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier_VH', element: 'Supplier' } }]
  key Carrier,
      @Search.defaultSearchElement: true
      CarrierName,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      AllocatedQty,
      OrderUnit,
      @EndUserText.label: 'SO Item Quantity'
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      _SOItem.OrderQuantity as SOItemQuantity,
      @EndUserText.label: 'Material'
      _SOItem.Material      as Material,
      @EndUserText.label: 'Material Description'
      _SOItem.ProductName   as MaterialName,
      @EndUserText.label: 'Customer'
      _SOItem.SoldToParty   as Customer,
      @EndUserText.label: 'Customer Name'
      _SOItem.CustomerName  as CustomerName,
      @EndUserText.label: 'Plant'
      _SOItem.Plant         as Plant,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChanged,

      _FreightOrder : redirected to composition child ZC_SD_SO_TMFO,
      _SOItem
}
