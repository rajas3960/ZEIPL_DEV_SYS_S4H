@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Max Po Date'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_MAXPO
  as select from    I_PurchaseOrderItemAPI01 as poi
    inner join I_PurchaseOrderAPI01 as po
      on po.PurchaseOrder = poi.PurchaseOrder

{
    key poi.Material,
    key po.Supplier,

    max( po.CreationDate  ) as MaxPOCreationDate
}

where
     (  po.PurchaseOrderType = 'ZRAW'
    or po.PurchaseOrderType = 'ZDOM'
    or po.PurchaseOrderType = 'ZSER'
    or po.PurchaseOrderType = 'ZCAP'
    or po.PurchaseOrderType = 'ZIMP')

group by
    poi.Material,
    po.Supplier
