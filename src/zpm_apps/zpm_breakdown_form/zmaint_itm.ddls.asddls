@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Breakdown Maintenance Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_ITM 
as select from zmaint_itm_db as MID
{
    key MID.maintenancenotificationcause,
    key MID.maintenancenotification,
    key MID.maintenancenotificationitem,
        MID.maintnotificationcausecode,
        MID.maintenanceplanningplant,
        MID.maintnotifcausetext
//        MID.OperationDescription
        
}
