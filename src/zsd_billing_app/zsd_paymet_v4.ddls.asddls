@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help For Payment'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsd_paymet_v4 as select from I_PaymentTermsText
{
    @EndUserText.label: 'Payment Terms'
    key PaymentTerms,
    @EndUserText.label: 'Payment Terms Name'
    PaymentTermsName,
    @EndUserText.label: 'Payment Terms Desc'
    PaymentTermsDescription
    
}
