@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Dispatch Planning Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_II_DISPLAN
  as select from zsd_app09_idb as a
  association to parent ZSD_IH_DISPLAN as _Head on $projection.Uuid = _Head.Uuid  
{
  key a.uuid           as Uuid,
  key a.salesorder     as Salesorder,
  key a.salesorderitem as Salesorderitem,
  key a.subuuid        as Subuuid,
      a.slno           as Slno,
      a.numseq         as Numseq,
      a.dispatchdate   as Dispatchdate,
      a.customer       as Customer,
      a.plant          as Plant,
      a.transmode     as Transmode,
      a.material       as Material,
      a.baseunit       as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.totalorderqty  as Totalorderqty,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.dispplantqty   as Dispplantqty,
      a.vehicleno	  as Vehicleno,
      a.createdby      as Createdby,
      a.createdat      as Createdat,
      a.lastchangedby  as Lastchangedby,
      a.lastchangedat  as Lastchangedat,
      _Head
}
