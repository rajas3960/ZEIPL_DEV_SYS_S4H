@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Custom App Root'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZSD_BILLING_RV
  as select from zsd_billing_tb

  composition [0..*] of ZSD_BILLING_iRV as Item

{
  key bill_uuid             as BillUuid,

      sno                   as Sno,
      invoicing_party       as InvoicingParty,
      document_date         as DocumentDate,
      posting_date          as PostingDate,
      reference             as Reference,

      @Semantics.amount.currencyCode: 'CurrencyKey'
      amount                as Amount,

      currency_key          as CurrencyKey,
      business_place        as BusinessPlace,
      //      @Semantics.booleanIndicator: true
      calculate_tax         as CalculateTax,
      @Semantics.booleanIndicator: true
      caltax                as caltax,
      document_type         as DocumentType,
      withholding_tax       as WithholdingTax,
      supplierinvoice,

      fiscalyear,
      postinvoiceflag,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,

      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      last_changed_at       as LastChangedAt,

      Item
}
