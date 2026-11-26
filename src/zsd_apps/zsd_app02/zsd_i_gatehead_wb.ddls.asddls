@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry - Weigh Bridge Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_I_GATEHEAD_WB 
  as select from zsd_gate_htb as a
  composition [0..*] of ZSD_I_SGATEHEAD_WB as _SalesHead
  composition [0..*] of ZSD_I_SGATEITEM_WB   as _SalesItem  
{
  key a.uuid                as Uuid,
      a.plant               as Plant,
      a.plantname           as Plantname,
//      a.gateentrytype       as Gateentrytype,
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
      _SalesHead,
      _SalesItem
}
