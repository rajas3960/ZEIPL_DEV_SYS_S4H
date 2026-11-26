@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Gate Exit Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_II_GEXIT 
  as select from zsd_app05_idb as a
  association to parent ZSD_IH_GEXIT as _Head on $projection.Uuid = _Head.Uuid
{
  key a.uuid          as Uuid,
  key a.salesdocument as Salesdocument,
  key a.salesitem     as Salesitem,
      a.customer      as Customer,
      a.customername  as Customername,
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
      a.createdby     as Createdby,
      a.createdat     as Createdat,
      a.lastchangedby as Lastchangedby,
      a.lastchangedat as Lastchangedat,
      _Head
}
