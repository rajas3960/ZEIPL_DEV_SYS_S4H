@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total Due Amount in MSME'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_AMT
  with parameters
    P_CompanyCode : abap.char(4),
    P_CurrDate    : abap.dats
  as select from    I_BusinessPartner  as BP
    inner join      I_JournalEntryItem as JEI on JEI.Supplier = BP.BusinessPartner
    left outer join I_JournalEntry     as JE  on JE.AccountingDocument = JEI.AccountingDocument
    left outer join I_SupplierCompany  as SC  on  SC.Supplier    = JEI.Supplier
                                              and SC.CompanyCode = $parameters.P_CompanyCode
{
  key BP.BusinessPartner         as Vendor,
      BP.BusinessPartnerFullName as VendorName,
      JEI.GlobalCurrency, 
      @Semantics.amount.currencyCode: 'GlobalCurrency'
      sum(
      case
       when dats_days_between(JEI.NetDueDate, $parameters.P_CurrDate) > 45
       then JEI.AmountInCompanyCodeCurrency
       else cast(0 as abap.curr(23,2))
      end
      )                          as TotalDueAmount
      //@Semantics.amount.currencyCode: 'GlobalCurrency'
      //cast(JEI.AmountInCompanyCodeCurrency as abap.curr( 23, 2 )) as amountdue

}
where
       JEI.Ledger                                                   =  '0L'
  and  JEI.Supplier                                                 is not null
  and  JEI.CompanyCode                                              = $parameters.P_CompanyCode
  and  dats_days_between( JEI. NetDueDate, $parameters.P_CurrDate ) >  45
  and  JEI.TransactionTypeDetermination                             <> 'WRX'
  and  JEI.ClearingDate                                             is initial
  and  JEI.ClearingJournalEntry                                     is initial
  and  SC.MinorityGroup                                             is not initial
  and  JEI.NetDueDate                                               is not initial
//  and(
//       JE.AccountingDocumentType                                    =  'KR'
//    or JE.AccountingDocumentType                                    =  'RE'
//    or JE.AccountingDocumentType                                    =  'KZ'
//    or JE.AccountingDocumentType                                    =  'KG'
//  )


group by
  BP.BusinessPartner,
  BP.BusinessPartnerFullName,
  JEI.GlobalCurrency
//  JEI.AmountInCompanyCodeCurrency
