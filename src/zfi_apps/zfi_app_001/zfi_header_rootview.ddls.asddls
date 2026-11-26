@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Header Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_HEADER_ROOTVIEW 
as select from ZFI_HEADER_VIEW
composition [0..*] of ZFI_ITEM_ROOTVIEW as _Item
{
    
 key AccountingDocument,
 key FiscalYear,
 key CompanyCode,
 AccountingDocumentType,
 AccountingDocumentTypeName,
 DocumentDate,
 OriginalReferenceDocument,
 PostingDate,
 CompanyCodeCurrency,
 Supplier,
 Plant,
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
 attachment,
 filename,
 mimetype,
 createdby,
 createdat ,
 _Item
}
