@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Allocation Upload'
@Metadata.allowExtensions: true
define root view entity ZC_MM_PO_TMUPL
  provider contract transactional_query
  as projection on ZR_MM_PO_TMUPL
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
