@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Breakdown Maintenance Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMAINT_HDR_I 
as select from ZMAINT_HDR
composition [0..*] of ZMAINT_ITM_I as _item

{
    key MaintenanceNotification,
    MaintPriority,
    Material,
    NotificationType,
    NotificationText,
    MaintenanceOrder,
    MaintNotificationCode,
    MaintenanceWorkCenterPlant,
    CreationDate,
    LastChangeTime,
    NotificationCompletionDate,
    NotificationCompletionTime,
    CreatedByUser,
    attachment,
    filename,
    mimetype,
    _item
}
