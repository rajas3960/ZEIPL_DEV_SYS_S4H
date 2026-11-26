@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fixed Asset Value'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_ASSET_VALUE
  as select from I_JournalEntryItem as JEI

{
  key  JEI.CompanyCode,
  key  JEI.MasterFixedAsset,
  key  JEI.FixedAsset,
       JEI.CompanyCodeCurrency                as Currency,
       @Semantics.amount.currencyCode: 'Currency'
       sum( JEI.AmountInCompanyCodeCurrency ) as TotalAmount
}
where
               JEI.Ledger                   = '0L'
  and          JEI.AssetDepreciationArea    = '01'
  and          JEI.IsReversal               is initial
  and          JEI.IsReversed               is initial
  and(
    (
               JEI.AccountingDocumentType   = 'AA'
      and(
        (
               JEI.PostingKey               = '70'
          and(
               JEI.FinancialTransactionType = '920'
            or JEI.FinancialTransactionType = '900'
            or JEI.FinancialTransactionType = '925'
          )
        )
        or(
               JEI.PostingKey               = '75'
          and  JEI.OffsettingAccountType    = 'S'
          and(
               JEI.FinancialTransactionType = '920'
            or JEI.FinancialTransactionType = '930'
          )
        )
      )
    )
    or(
               JEI.AccountingDocumentType   = 'SA'
      and(
               JEI.FinancialTransactionType = '920'
        or     JEI.FinancialTransactionType = '950'
      )
    )
  )
group by
  JEI.CompanyCode,
  JEI.MasterFixedAsset,
  JEI.FixedAsset,
  JEI.CompanyCodeCurrency
