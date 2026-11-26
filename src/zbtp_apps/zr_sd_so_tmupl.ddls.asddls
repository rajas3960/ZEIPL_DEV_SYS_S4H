@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Carrier Allocation Upload'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SD_SO_TMUPL
  as select from zsd_so_tmupl
{
  key uploaduuid       as UploadUuid,
      @Semantics.largeObject: { mimeType: 'MimeType',
                                fileName: 'FileName',
                                acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                                contentDispositionPreference: #ATTACHMENT }
      attachment       as Attachment,
      @Semantics.mimeType: true
      mimetype         as MimeType,
      filename         as FileName,
      status           as Status,
      case status
        when 'S' then 'Uploaded'
        else 'Not uploaded'
      end              as StatusText,
      case status
        when 'S' then 3
        else 2
      end              as StatusCriticality,
      rowsread         as RowsRead,
      carcreated       as CarCreated,
      carupdated       as CarUpdated,
      focreated        as FoCreated,
      foupdated        as FoUpdated,
      message          as Message,
      @Semantics.user.createdBy: true
      createdby        as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      createdat        as CreatedAt,
      @Semantics.user.lastChangedBy: true
      lastchangedby    as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat    as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchanged as LocalLastChanged
}
