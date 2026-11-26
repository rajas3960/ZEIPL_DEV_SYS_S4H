@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SD Gate Entry Apps Header Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_I_GATEHEAD
  as select from zsd_gate_htb as a
  left outer join I_PlantStdVH as b on a.plant = b.Plant
  left outer join I_CompanyCodeStdVH as c on a.companycode = c.CompanyCode
  composition [0..*] of ZSD_I_SGATEHEAD as _SalesHead
  composition [0..*] of ZSD_I_SGATEITEM   as _SalesItem  
{
  key a.uuid                as Uuid,
      a.plant               as Plant,
      a.companycode         as Companycode,
      a.gateentryid         as Gateentryid,
      a.gateentryiddate   as Gateentryiddate,
      a.gateentrytype       as Gateentrytype,
      a.gateentrytypetext   as Gateentrytypetext,
      a.gateentryno         as Gateentryno,
      a.gateentrysequence   as Gateentrysequence,
      a.gateentrydate       as Gateentrydate,
      a.gateentrytime       as Gateentrytime,
      a.transportid         as Transportid,
      a.transportname       as Transportname,
      a.vehicleno           as Vehicleno,
      a.packingdetails      as Packingdetails,
      a.dispinstrdetails    as Dispinstrdetails,
      a.contactdetails      as Contactdetails,
      a.drivername          as Drivername,
      a.driveraddress       as Driveraddress,
      a.driverlicensenumber as Driverlicensenumber,
      a.drivermobile        as Drivermobile,
      a.remarks             as Remarks,
      @Semantics.user.createdBy: true
      a.createdby           as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat           as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby       as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat       as Lastchangedat,
      b.PlantName           as Plantname,
      c.CompanyCodeName as Companycodename,
      a.attachment   as Attachment,
      a.filename     as Filename,
      a.mimetype     as Mimetype,
      _SalesHead,
      _SalesItem
}
