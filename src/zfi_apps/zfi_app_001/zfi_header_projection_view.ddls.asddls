@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Header Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZFI_HEADER_PROJECTION_VIEW 
provider contract transactional_query
as projection on ZFI_HEADER_ROOTVIEW
{
  key AccountingDocument,
  key FiscalYear,
  key CompanyCode,
  @ObjectModel.text.element: [ 'AccountingDocumentTypeName' ] 
  AccountingDocumentType,
  AccountingDocumentTypeName,
  DocumentDate,
  OriginalReferenceDocument,
  PostingDate,
  CompanyCodeCurrency,
  Supplier,
  Plant,
  @ObjectModel.text.element: [ 'SupplierName' ]
  SupplierName,
  GSTIN,
  PAN,
  EmailAddress,
  CityName,
  PostalCode,
  StreetName,
  Region,
  Country,
  StreetPrefixName1,
  StreetPrefixName2,
  AddressTimeZone,
  formtype,
  @Semantics.largeObject: {   mimeType: 'mimetype', 
                                fileName: 'filename', 
                                contentDispositionPreference: #INLINE }
  attachment,
  filename,
  mimetype,
  createdby,
  createdat,
  /* Associations */
  _Item : redirected to composition child ZFI_ITEM_PROJECTION_VIEW
}
