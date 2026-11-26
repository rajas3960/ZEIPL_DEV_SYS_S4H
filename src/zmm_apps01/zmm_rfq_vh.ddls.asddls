@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F4 for RFQ'
@Metadata.ignorePropagatedAnnotations: true
define view entity zmm_rfq_vh as select from I_Requestforquotation_Api01
{
   key RequestForQuotation,
   RequestForQuotationName
}
