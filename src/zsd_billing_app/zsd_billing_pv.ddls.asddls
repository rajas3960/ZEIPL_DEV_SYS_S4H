@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Custom App HDR Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_BILLING_PV
  provider contract transactional_query
  as projection on ZSD_BILLING_RV
{
  key BillUuid,
      Sno,
      InvoicingParty,
      DocumentDate,
      PostingDate,
      Reference,
      @Semantics.amount.currencyCode: 'CurrencyKey'
      Amount,
      CurrencyKey,
      BusinessPlace,
//      @Semantics.booleanIndicator: true
      CalculateTax,
      @Semantics.booleanIndicator: true
      caltax,
      DocumentType,
      WithholdingTax,
      supplierinvoice,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      Item : redirected to composition child ZSD_BILLING_IPV
}
