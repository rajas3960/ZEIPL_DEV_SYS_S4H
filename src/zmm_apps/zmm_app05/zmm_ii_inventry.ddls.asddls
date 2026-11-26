@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Team Gate Entry Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_II_INVENTRY
  as select from zmm_app04_idb as a
  left outer join ZMM_PO_PENQTY as b on b.PurchaseOrder = a.purchaseorder
                                and b.PurchaseOrderItem = a.purchaseorderitem  
  association to parent ZMM_IH_INVENTRY as _Head on $projection.Uuid = _Head.Uuid
{
  key a.uuid              as Uuid,
  key a.purchaseorder     as Purchaseorder,
  key a.purchaseorderitem as Purchaseorderitem,
  key a.subuuid           as Subuuid,
      a.vendor            as Vendor,
      a.suppliername      as Suppliername,
      a.gateentryno       as Gateentryno,
      a.subgateentryno    as Subgateentryno,
      a.material          as Material,
      a.materialtext      as Materialtext,
      a.plant             as Plant,
      a.plantname         as Plantname,
      a.baseunit          as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.quantity          as Quantity,
      a.remark            as Remark,
      a.weiuom            as Weiuom,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'      
      b.Pendqty           as Pendqty,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      a.tareweight        as Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      a.grossweight       as Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      a.netweight         as Netweight,
      a.storagelocation   as Storagelocation,
      a.chbaseunit as Chbaseunit,
      a.challanno		as Challanno,
      a.challandate		as Challandate,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
      a.challangrossweight as Challangrossweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
      a.challantareweight as Challantareweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
      a.challannetweight as Challannetweight,
      a.chqtyunit        as Chqtyunit,
      @Semantics.quantity.unitOfMeasure: 'Chqtyunit'      
      a.challanqty       as Challanqty,
      a.materialgroup		as Materialgroup,
      a.poordertype     as Poordertype,
      a.poordertypetext as Poordertypetext,
      a.ewaybillno      as Ewaybillno,
      a.ewaybilldate    as Ewaybilldate,
      a.orderdate       as Orderdate,
      a.podocumt        as Podocumt,
      a.chdocumt        as Chdocumt,
      a.sidocumt        as Sidocumt,
      a.qadocumt        as Qadocumt,
      a.tpdocumt        as Tpdocumt,
      a.gateentryseries as Gateentryseries,
      a.weightindicator as Weightindicator,
      a.grnqty          as Grnqty,
      a.inbounddelivery as Inbounddelivery,
      a.invoiceno       as Invoiceno,
      a.trasporterid   as Trasporterid,
      a.trasportername as Trasportername,
      a.lrno			as Lrno,
      a.lrdate		as Lrdate,
      a.poperunitprice as Poperunitprice,
      @Semantics.user.createdBy: true
      a.createdby         as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat         as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby     as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat     as Lastchangedat,
      _Head
}
