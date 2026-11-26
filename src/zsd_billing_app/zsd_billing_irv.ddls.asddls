@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Custom App Item'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZSD_BILLING_iRV
  as select from zsd_billing_itb

  association to parent ZSD_BILLING_RV as hdr on hdr.BillUuid = $projection.BillUuid

{
  key item_uuid             as ItemUuid,

      bill_uuid             as BillUuid,

      gl_account            as GlAccount,
      cost_centre           as CostCentre,
      item_text             as ItemText,
      assignment            as Assignment,
      payment_terms         as PaymentTerms,
      tax_code              as TaxCode,
      sales_billing_no      as SalesBillingNo,
      sales_billing_item    as SalesBillingItem,
      @Semantics.amount.currencyCode: 'CurrencyKey'   
      amount                as Amount,
      currency_key          as CurrencyKey,
      @Semantics.amount.currencyCode: 'CurrencyKey'
      tax_amount            as TaxAmount,
      plant                 as Plant,
      invoicingparty,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      hdr
}
