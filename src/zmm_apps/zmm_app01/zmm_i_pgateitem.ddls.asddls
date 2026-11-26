@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Gate Entry PO Item - Apps Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_I_PGATEITEM
  as select from zmm_gate_pitb as a
association to parent ZMM_I_GATEHEAD as _Head on $projection.Uuid = _Head.Uuid    
{
  key a.uuid              as Uuid,
  key a.purchaseorder     as Purchaseorder,
  key a.purchaseorderitem as Purchaseorderitem,
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
