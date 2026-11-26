@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Gate Entry PO - Apps Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_I_PGATEHEAD
  as select from zmm_gate_phtb as a
association to parent ZMM_I_GATEHEAD as _Head on $projection.Uuid = _Head.Uuid  
{
  key a.uuid               as Uuid,
  key a.purchaseorder      as Purchaseorder,
      a.vendor             as Vendor,
      a.gateentryno        as Gateentryno,
      a.suppliername       as Suppliername,
      a.orderdate          as Orderdate,
      a.referno            as Referno,
      a.referdate          as Referdate,
      a.fromplace          as Fromplace,
      a.toplace            as Toplace,
      a.baseunit           as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.challantareweight  as Challantareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.challangrossweight as Challangrossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.challannetweight   as Challannetweight,
      a.freightorderno     as Freightorderno,
      @Semantics.user.createdBy: true
      a.createdby           as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat           as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby       as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat       as Lastchangedat,
      _Head
}
