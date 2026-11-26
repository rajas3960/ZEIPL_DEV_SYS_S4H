@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Breakdown Maintenance Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMAINT_ITM_C 
as projection on ZMAINT_ITM_I
{
    key maintenancenotificationcause,
    key maintenancenotification,
    key maintenancenotificationitem,
    maintnotificationcausecode,
    maintenanceplanningplant,
    MaintNotifCauseText,
//    OperationDescription,
    _header :redirected to parent ZMAINT_HDR_C 
}
