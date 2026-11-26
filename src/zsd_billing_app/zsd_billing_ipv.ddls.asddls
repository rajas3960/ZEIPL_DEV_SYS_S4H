@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Custom App Item Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_BILLING_IPV
  as projection on ZSD_BILLING_iRV
{
  key ItemUuid,
      BillUuid,
      GlAccount,
      CostCentre,
      ItemText,
      Assignment,
      PaymentTerms,
      TaxCode,
      SalesBillingNo,
      SalesBillingItem,
      @Semantics.amount.currencyCode: 'CurrencyKey'
      Amount,
      CurrencyKey,
      @Semantics.amount.currencyCode: 'CurrencyKey'
      TaxAmount,
      Plant,
      invoicingparty,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      hdr : redirected to parent ZSD_BILLING_PV
}
