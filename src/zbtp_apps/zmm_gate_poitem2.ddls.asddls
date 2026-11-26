@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Data for BTP Gate Entry'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_GATE_POITEM2
  as select from    I_PurchaseOrderItemAPI01     as a
    left outer join I_PurchaseOrderAPI01         as d on a.PurchaseOrder = d.PurchaseOrder
    left outer join I_Plant                      as b on a.Plant = b.Plant
    left outer join I_ProductText                as c on  a.Material = c.Product
                                                      and c.Language = 'E'
    left outer join I_Supplier                   as e on d.Supplier = e.Supplier
    left outer join I_PurchasingDocumentTypeText as f on  d.PurchaseOrderType          = f.PurchasingDocumentType
                                                      and f.PurchasingDocumentCategory = 'F'
                                                      and f.Language                   = 'E'
{
  key a.PurchaseOrder,
  key a.PurchaseOrderItem,
      a.Material,
      a.Plant,
      a.OrderPriceUnit                             as BaseUnit,
      cast( a.OrderQuantity as abap.dec( 13, 3 ) ) as OrderQuantity,
      a.MaterialGroup,
      b.PlantName,
      c.ProductName,
      d.Supplier,
      d.PurchaseOrderDate,
      d.PurchaseOrderType,
      e.SupplierName,
      f.PurchasingDocumentTypeName,
      // item incoterms, header incoterms when the item has none
      case when a.IncotermsClassification <> ''
           then a.IncotermsClassification
           else d.IncotermsClassification end      as IncotermsClassification
}
