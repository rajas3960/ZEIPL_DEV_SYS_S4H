@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINTE_HDR
  as select from    I_MaintenanceNotification as MN
    left outer join zmaint_db                 as MT  on MT.maintenancenotification = MN.MaintenanceNotification
    left outer join zmaint_hd                 as MHT on MHT.maintenancenotification = MN.MaintenanceNotification
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
      MN.WorkCenterInternalID,
      MN.CreatedByUser,
      MT.attachment,
      MT.filename,
      MT.mimetype,
      MHT.webaddress,
      MHT.webaddress1,
      MHT.webaddress2,
      MHT.webaddress3,
      MHT.webaddress4,
      @EndUserText.label: 'ExcelAttachments'
      @Semantics.largeObject:{fileName: 'excelfilename' ,
                                mimeType: 'excelmimetype',
                                contentDispositionPreference: #INLINE  }
      MHT.excelattachment as excelattachment,
      MHT.excelfilename   as excelfilename,
      @Semantics.mimeType: true
      MHT.excelmimetype   as excelmimetype
      //      MT.status          as status,
      //      @Semantics.user.createdBy: true
      //      MT.createdby       as createdby,
      //      @Semantics.systemDateTime.createdAt: true
      //      MT.createdat       as createdat,
      //      @Semantics.user.lastChangedBy: true
      //      MT.lastchangedby   as lastchangedby,
      //      @Semantics.systemDateTime.lastChangedAt: true
      //      MT.lastchangedat   as lastchangedat,
      //      case
      //            when MT.status = 'X' then 'Active'
      //            else 'Inactive'
      //            end          as UploadStatus

}
