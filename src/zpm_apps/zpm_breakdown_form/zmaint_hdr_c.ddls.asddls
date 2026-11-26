@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Breakdown Maintenance Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMAINT_HDR_C 
provider contract transactional_query 
as projection on ZMAINT_HDR_I

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
    @Semantics.largeObject: {   mimeType: 'mimetype', 
                                fileName: 'filename', 
                                contentDispositionPreference: #INLINE } 
    attachment,
    filename,
    mimetype,
    _item :redirected to composition child ZMAINT_ITM_C
}
