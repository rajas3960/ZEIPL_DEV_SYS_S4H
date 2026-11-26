@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Head - Weigh Bridge Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_I_SGATEHEAD_WB 
  as select from zsd_gate_shtb as a
association to parent ZSD_I_GATEHEAD_WB as _Head on $projection.Uuid = _Head.Uuid  
{
  key a.uuid          as Uuid,
  key a.salesdocument as Salesdocument,
      a.gateentryno   as Gateentryno,
      a.companycode   as Companycode,
      a.companyname   as Companyname,
      a.customer      as Customer,
      a.customername  as Customername,
      a.fromplace     as Fromplace,
      a.toplace       as Toplace,
      a.billingfrom   as Billingfrom,
      a.consignee     as Consignee,
      a.billto        as Billto,
      a.shipto        as Shipto,
      a.broker        as Broker,
      a.doremark      as Doremark,
      a.stocktype     as Stocktype,
      a.division      as Division,
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
