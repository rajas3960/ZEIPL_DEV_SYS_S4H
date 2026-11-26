@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Item - Weigh Bridge Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_I_SGATEITEM_WB 
  as select from zsd_gate_sitb as a
association to parent ZSD_I_GATEHEAD_WB as _Head on $projection.Uuid = _Head.Uuid  
{
  key a.uuid          as Uuid,
  key a.salesdocument as Salesdocument,
  key a.salesitem     as Salesitem,
      a.gateentryno   as Gateentryno,
      a.plant         as Plant,
      a.plantname     as Plantname,
      a.material      as Material,
      a.materialdesc  as Materialdesc,
      a.baseunit      as Baseunit,
      a.batch         as Batch,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.quantity      as Quantity,
      a.remark        as Remark,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.tareweight    as Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.grossweight   as Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.netweight     as Netweight,
      @Semantics.user.createdBy: true
      a.createdby     as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat     as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat as Lastchangedat,
      _Head
}
