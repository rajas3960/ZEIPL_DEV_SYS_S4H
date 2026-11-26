@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Breakdown Maintenance Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_ITM_I 
as select from ZMAINT_ITM
association to parent ZMAINT_HDR_I as _header on $projection.maintenancenotification = _header.MaintenanceNotification 
{
    key maintenancenotificationcause,
    key maintenancenotification,
    key maintenancenotificationitem,
    maintnotificationcausecode,
    maintenanceplanningplant,
    MaintNotifCauseText,
//    OperationDescription,
    _header
}
