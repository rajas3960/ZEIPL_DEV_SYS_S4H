@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fixed Asset AUC'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_AUC
  as select from I_JournalEntryItem as a
    inner join   I_JournalEntryItem as b on  b.CompanyCode          =  a.CompanyCode
                                         and b.FiscalYear           =  a.FiscalYear
                                         and b.AccountingDocument   =  a.AccountingDocument
                                         and b.Ledger               =  '0L'
                                         and b.WBSElementInternalID is not initial
                                         and b.WBSElementInternalID <> '00000000'
{
  key a.CompanyCode,
  key a.MasterFixedAsset,
  key a.FixedAsset,
  key b.WBSElementInternalID
}
where
      a.Ledger           = '0L'
  and a.MasterFixedAsset is not initial
  and a.FixedAsset       is not initial
  and a.IsReversal       is initial
  and a.IsReversed       is initial
group by
  a.CompanyCode,
  a.MasterFixedAsset,
  a.FixedAsset,
  b.WBSElementInternalID
