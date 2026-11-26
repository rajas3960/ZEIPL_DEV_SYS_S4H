@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection of MSME Report'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_MSME_REPORT_PV
  //provider contract transactional_query
  with parameters
    P_companycode : bukrs,
    p_currdate    : datum

  //as projection on ZI_MSME_REPORT_RV(P_companycode : $parameters.P_companycode, p_currdate : $parameters.p_currdate)
  as select from ZI_MSME_REPORT_RV( P_companycode:$parameters.P_companycode , p_currdate: $parameters.p_currdate )
{

  key Vendor,
  key CompanyCode,
  key AD,
      VendorName,
      GlobalCurrency,
      @Semantics.amount.currencyCode: 'GlobalCurrency'
      TotalDueAmount,
      PAN,
      MSMEno,
      @Semantics.amount.currencyCode: 'GlobalCurrency'
      AmountDueMoreThan45Days,
      InvDate,
      // RecordDate,
      ODDays,
      NetDueDate,
      MSMEdate,
      InvoiceNo,
      PostDate,
      MinorityIndicator 
    //  DocumentReferenceID
}
