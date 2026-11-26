@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Breakdown maintenance Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_HDR 
as select from I_MaintenanceNotification as MN
left outer join zmaint_table as MT on MT.maintenancenotification = MN.MaintenanceNotification


{
    key MN.MaintenanceNotification,
        MN.MaintPriority,
        MN.Material,
        MN.NotificationType,
        MN.NotificationText,
        MN.MaintenanceOrder,
        MN.MaintNotificationCode,
        MN.MaintenanceWorkCenterPlant,
        MN.CreationDate,
        MN.LastChangeTime,
        MN.NotificationCompletionDate,
        MN.NotificationCompletionTime,
        MN.CreatedByUser,
        MT.attachment,
        MT.filename,
        MT.mimetype
    
}
