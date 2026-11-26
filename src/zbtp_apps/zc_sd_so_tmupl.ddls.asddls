@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Carrier Allocation Upload'
@Metadata.allowExtensions: true
define root view entity ZC_SD_SO_TMUPL
  provider contract transactional_query
  as projection on ZR_SD_SO_TMUPL
{
  key UploadUuid,
      Attachment,
      MimeType,
      FileName,
      Status,
      StatusText,
      StatusCriticality,
      RowsRead,
      CarCreated,
      CarUpdated,
      FoCreated,
      FoUpdated,
      Message,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChanged
}
