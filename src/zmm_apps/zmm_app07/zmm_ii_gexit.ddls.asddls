@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Security Exit Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_II_GEXIT
  as select from zmm_app04_idb
  association to parent ZMM_IH_GEXIT as _Head on $projection.Uuid = _Head.Uuid
{
  key uuid              as Uuid,
  key purchaseorder     as Purchaseorder,
  key purchaseorderitem as Purchaseorderitem,
  key subuuid           as Subuuid,
      vendor            as Vendor,
      suppliername      as Suppliername,
      gateentryno       as Gateentryno,
      subgateentryno    as Subgateentryno,
      material          as Material,
      materialtext      as Materialtext,
      plant             as Plant,
      plantname         as Plantname,
      baseunit          as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      quantity          as Quantity,
      remark            as Remark,
      weiuom            as Weiuom,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      tareweight        as Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      grossweight       as Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      netweight         as Netweight,
      challanno        as Challanno,
      challandate   as Challandate,
      chbaseunit      as Chbaseunit,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'      
      challangrossweight as Challangrossweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'      
      challantareweight as Challantareweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'      
      challannetweight as Challannetweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'            
      challanqty       as Challanqty,
      poordertype      as Poordertype,
      poordertypetext  as Poordertypetext,
      ewaybillno       as Ewaybillno,
      ewaybilldate     as Ewaybilldate,
      orderdate        as Orderdate,
      podocumt         as Podocumt,
      chdocumt         as Chdocumt,
      sidocumt         as Sidocumt,
      qadocumt         as Qadocumt,
      shortageqty      as Shortageqty,
      createdby         as Createdby,
      createdat         as Createdat,
      lastchangedby     as Lastchangedby,
      lastchangedat     as Lastchangedat,
      _Head
}
