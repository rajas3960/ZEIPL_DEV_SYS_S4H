@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Unloading Yard - Apps'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_II_UNLOAD 
  as select from zmm_app04_idb as a
  association to parent ZMM_IH_UNLOAD as _Head on $projection.Uuid = _Head.Uuid
{
  key a.uuid              as Uuid,
  key a.purchaseorder     as Purchaseorder,
  key a.purchaseorderitem as Purchaseorderitem,
  key a.subuuid           as Subuuid,
      a.vendor            as Vendor,
      a.suppliername      as Suppliername,
      a.gateentryno       as Gateentryno,
      a.material          as Material,
      a.materialtext      as Materialtext,
      a.plant             as Plant,
      a.plantname         as Plantname,
      a.baseunit          as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.quantity          as Quantity,
      a.remark            as Remark,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.tareweight        as Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.grossweight       as Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.netweight         as Netweight,
      a.unloadind         as Unloadind,
      a.lineimagecount	as Lineimagecount,
      a.createdby         as Createdby,
      a.createdat         as Createdat,
      a.lastchangedby     as Lastchangedby,
      a.lastchangedat     as Lastchangedat,
      _Head    
}
