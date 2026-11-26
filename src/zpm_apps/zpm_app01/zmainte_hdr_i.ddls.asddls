@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance HDR Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMAINTE_HDR_I
  as select from ZMAINTE_HDR
  composition [0..*] of ZMAINTE_ITM_I as _item
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
      WorkCenterInternalID,
      CreatedByUser,      
      attachment,
      filename,
      mimetype,
      webaddress,
      webaddress1,
      webaddress2,
      webaddress3,
      webaddress4,
      @EndUserText.label: 'ExcelAttachments'
      @Semantics.largeObject: {   mimeType: 'excelmimetype',
                                    fileName: 'excelfilename',
                                    contentDispositionPreference: #INLINE }
      excelattachment,
      excelfilename,
      @Semantics.mimeType: true
      excelmimetype,
      //      status,
      //      createdby,
      //      createdat,
      //      lastchangedby,
      //      lastchangedat,
      //      UploadStatus,
      _item
}
