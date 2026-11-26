@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Of Compare Supplier Quotation'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_APPS01_PV
  provider contract transactional_query
  as projection on ZMM_APPS01_RV
{
  key RequestForQuotation,
      RequestForQuotationName,
      CreatedByUser,
      CreationDate,
      CreatedByUserName,
      RFQPublishingDate,
      RFQLifecycleStatus,
      Status,
      /* Associations */
      ITEM : redirected to composition child ZMM_APPS01_IPV
}
