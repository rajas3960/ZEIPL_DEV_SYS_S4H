@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINTE_ITM 
as select from zmaint_idb as MID
{

    key MID.maintenancenotification,
    key MID.maintenancenotificationitem,
        MID.why1,
        MID.why2,
        MID.why3,
        MID.why4,
        MID.why5,        
        MID.url1,
        MID.url2,
        MID.url3
    
}


