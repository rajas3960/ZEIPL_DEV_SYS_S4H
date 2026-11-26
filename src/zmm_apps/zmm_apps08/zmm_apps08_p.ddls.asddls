@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Terms V4'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS08_P as select from I_PaymentTermsText
{
    key Language,
    key PaymentTerms,
    PaymentTermsName,
    PaymentTermsDescription,
    /* Associations */
    _CustomerPaymentTermsText,
    _Language,
    _PaymentTerms
}
