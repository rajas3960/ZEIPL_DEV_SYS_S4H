@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item for Carrier Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: { serviceQuality: #C, sizeCategory: #L, dataClass: #TRANSACTIONAL }
@Search.searchable: true
define view entity ZMM_PO_TMPOITEM
  as select from    I_PurchaseOrderItemAPI01 as a
    left outer join I_PurchaseOrderAPI01     as d on a.PurchaseOrder = d.PurchaseOrder
    left outer join I_ProductText            as c on  a.Material = c.Product
                                                  and c.Language = $session.system_language
    left outer join I_Supplier               as e on d.Supplier = e.Supplier
{
      @Search.defaultSearchElement: true
  key a.PurchaseOrder,
  key a.PurchaseOrderItem,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      a.OrderQuantity,
      a.PurchaseOrderQuantityUnit,
      a.Material,
      @Search.defaultSearchElement: true
      c.ProductName,
      a.Plant,
      @Search.defaultSearchElement: true
      d.Supplier,
      e.SupplierName,
      d.PurchaseOrderDate
}
where
  a.PurchasingDocumentDeletionCode = ''
