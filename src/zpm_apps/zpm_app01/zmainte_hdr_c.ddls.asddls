@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance HDR Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMAINTE_HDR_C
  provider contract transactional_query
  as projection on ZMAINTE_HDR_I

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
      webaddress,
      webaddress1,
      webaddress2,
      webaddress3,
      webaddress4,
      @Semantics.largeObject: {   mimeType: 'mimetype',
                                  fileName: 'filename',
                                  contentDispositionPreference: #INLINE }
      attachment,
      filename,
      mimetype,
      @EndUserText.label: 'ExcelAttachments'
      @Semantics.largeObject: {   mimeType: 'excelmimetype',
                                  fileName: 'excelfilename',
                                  contentDispositionPreference: #INLINE }
      excelattachment,
      excelfilename,
      excelmimetype,
//      status,
//      createdby,
//      createdat,
//      lastchangedby,
//      lastchangedat,
//      UploadStatus,
      _item : redirected to composition child ZMAINTE_ITM_C

}
