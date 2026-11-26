@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'All Details'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_ALL
  as select from    I_JournalEntryItem as a
    inner join      I_JournalEntryItem as b on  b.CompanyCode          =  a.CompanyCode
                                            and b.FiscalYear           =  a.FiscalYear
                                            and b.AccountingDocument   =  a.AccountingDocument
                                            and b.Ledger               =  '0L'
                                            and b.WBSElementInternalID is not initial
                                            and b.WBSElementInternalID <> '00000000'
    left outer join I_JournalEntryItem as c on  c.PartnerFixedAsset           = a.FixedAsset
                                            and c.CompanyCode                 = a.CompanyCode
                                            and c.PartnerMasterFixedAsset     = a.MasterFixedAsset
                                            and c.Ledger                      = '0L'
                                            and c.AmountInCompanyCodeCurrency = a.AmountInCompanyCodeCurrency
{
  key a.CompanyCode,
  key a.MasterFixedAsset,
  key a.FixedAsset,
  key b.WBSElementInternalID,
      a.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      a.AmountInCompanyCodeCurrency as AUCAmt,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      c.AmountInCompanyCodeCurrency as FAAmt
}
where
      a.Ledger           = '0L'
  and a.MasterFixedAsset is not initial
  and a.FixedAsset       is not initial
  and a.IsReversal       is initial
  and a.IsReversed       is initial
