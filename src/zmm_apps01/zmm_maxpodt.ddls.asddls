@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Max Date Of Po'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_MAXPODT
  as select from    ZMM_MAXPO as mx

    inner join I_PurchaseOrderAPI01 as po
      on  po.Supplier     = mx.Supplier
      and po.CreationDate = mx.MaxPOCreationDate

    inner join I_PurchaseOrderItemAPI01 as poi
      on  poi.PurchaseOrder = po.PurchaseOrder
      and poi.Material      = mx.Material

{
    key mx.Supplier,
    key mx.Material,

    key max(po.PurchaseOrder) as PurchaseOrder,
    po.CreationDate,

    
    @Semantics.amount.currencyCode: 'DocumentCurrency'
    sum(cast(poi.NetPriceAmount as abap.curr( 13, 2 ))) as NetAmount,
    poi.DocumentCurrency
}where
     (  po.PurchaseOrderType = 'ZRAW'
    or po.PurchaseOrderType = 'ZDOM'
    or po.PurchaseOrderType = 'ZSER'
    or po.PurchaseOrderType = 'ZCAP'
    or po.PurchaseOrderType = 'ZIMP')
group by
    mx.Supplier,
    mx.Material,
    po.CreationDate,
//    poi.PurchaseOrderItem,
    poi.DocumentCurrency

