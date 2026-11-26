@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry - Weigh Bridge Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_C_GATEHEAD_WB 
provider contract transactional_query 
as projection on ZSD_I_GATEHEAD_WB
{
    key Uuid,
    Plant,
    Plantname,
//    Gateentrytype,
    Gateentryno,
    Gateentrysequence,
    Gateentrydate,
    Gateentrytime,
    Transportid,
    Transportname,
    Vehicleno,
    Packingdetails,
    Dispinstrdetails,
    Contactdetails,
    Drivername,
    Driveraddress,
    Driverlicensenumber,
    Drivermobile,
    Remarks,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _SalesHead : redirected to composition child ZSD_C_SGATEHEAD_WB,
    _SalesItem : redirected to composition child ZSD_C_SGATEITEM_WB
}
