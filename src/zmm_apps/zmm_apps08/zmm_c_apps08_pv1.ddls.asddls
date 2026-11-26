@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request For Quotation Projection View Entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_C_APPS08_PV1
  provider contract transactional_query
  as projection on ZMM_I_APPS08_RV
{
  key Supplier,
  key RequestForQuotation,
      EmailAddress,
      Passcode,
      SupplierName,
      PurchasingGroup,
      PurchasingOrganization,
      BindingPeriodValidityEndDate,
      RequestForQuotationName,
      CompanyCode,
      DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      TargetAmount,
      QuotationLatestSubmissionDate,
      PaymentTerms,
      CashDiscount1Days,
      CashDiscount1Percent,
      CashDiscount2Days,
      CashDiscount2Percent,
      IncotermsVersion,
      IncotermsClassification,
      IncotermsLocation1,
      IncotermsLocation2,
      mark,
      status,
      SupplierQuotation,
      Remarks,
      /* Associations */
      _Item : redirected to composition child ZMM_C_APPS08_IPV
}
