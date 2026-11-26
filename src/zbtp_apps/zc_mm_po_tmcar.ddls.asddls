@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Allocation per PO Item'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_MM_PO_TMCAR
  provider contract transactional_query
  as projection on ZR_MM_PO_TMCAR
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_PO_TMPOITEM', element: 'PurchaseOrder' } }]
  key PurchaseOrder,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_PO_TMPOITEM', element: 'PurchaseOrderItem' },
                                           additionalBinding: [{ localElement: 'PurchaseOrder',
                                                                 element: 'PurchaseOrder',
                                                                 usage: #FILTER_AND_RESULT }] }]
  key PurchaseOrderItem,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier_VH', element: 'Supplier' } }]
  key Carrier,
      @Search.defaultSearchElement: true
      CarrierName,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      AllocatedQty,
      OrderUnit,
      @EndUserText.label: 'PO Item Quantity'
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      _POItem.OrderQuantity as POItemQuantity,
      @EndUserText.label: 'Material'
      _POItem.Material      as Material,
      @EndUserText.label: 'Material Description'
      _POItem.ProductName   as MaterialName,
      @EndUserText.label: 'Supplier'
      _POItem.Supplier      as Supplier,
      @EndUserText.label: 'Supplier Name'
      _POItem.SupplierName  as SupplierName,
      @EndUserText.label: 'Plant'
      _POItem.Plant         as Plant,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChanged,

      _FreightOrder : redirected to composition child ZC_MM_PO_TMFO,
      _POItem
}
