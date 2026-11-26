@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Gate Entry - Apps Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_I_GATEHEAD
  as select from zmm_gate_htb as a
  left outer join I_CompanyCodeVH as b on a.companycode = b.CompanyCode
  composition[0..*] of ZMM_I_PGATEHEAD as _POHEAD
  composition[0..*] of ZMM_I_PGATEITEM as _POITEM
{
  key a.uuid            as Uuid,
      a.gateentryno     as Gateentryno,
      a.gateentryseqno  as Gateentryseqno,
      a.gateentrydate   as Gateentrydate,
      a.gateentrytime   as Gateentrytime,
      a.gateentryid    as Gateentryid,
      a.gateentryiddate as Gateentryiddate,
      a.companycode     as Companycode,
      b.CompanyCodeName     as Companyname,
      a.gateentryseries as Gateentryseries,
      a.gateentrytype   as Gateentrytype,
      a.gateentryseriesdes as Gateentryseriesdes,
      a.gateentrytypedes as Gateentrytypedes,
      a.permitno        as Permitno,
      a.tokenentryno    as Tokenentryno,
      a.erpreferenceno  as Erpreferenceno,
      a.trasporterid    as Trasporterid,
      a.trasportername  as Trasportername,
      a.vehicleno       as Vehicleno,
      a.vehicletype     as Vehicletype,
      a.drivername      as Drivername,
      a.mobile          as Mobile,
      a.licenseno       as Licenseno,
      a.experiredt      as Experiredt,
      a.chaseno         as Chaseno,
      a.address         as Address,
      a.challanno       as Challanno,
      a.challandate     as Challandate,
      a.lrno            as Lrno,
      a.lrdate          as Lrdate,
      a.ewaybillno      as Ewaybillno,
      a.ewaybilldate    as Ewaybilldate,
      a.securityremarks as Securityremarks,
      @Semantics.user.createdBy: true
      a.createdby           as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat           as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby       as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat       as Lastchangedat,
      _POHEAD,
      _POITEM
}
