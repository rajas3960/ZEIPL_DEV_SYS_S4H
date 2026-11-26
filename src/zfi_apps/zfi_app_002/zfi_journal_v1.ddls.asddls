@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_JOURNAL_V1
  as select from    I_JournalEntry            as a
    inner join      I_JournalEntryItem        as b    on  b.AccountingDocument = a.AccountingDocument
                                                      and b.CompanyCode        = a.CompanyCode
                                                      and b.FiscalYear         = a.FiscalYear
                                                      and b.Ledger             = '0L'
    left outer join I_OperationalAcctgDocItem as d    on  d.CompanyCode            = b.CompanyCode
                                                      and d.FiscalYear             = b.FiscalYear
                                                      and d.AccountingDocument     = b.AccountingDocument
                                                      and d.AccountingDocumentItem = b.AccountingDocumentItem

    left outer join I_Supplier                as c    on c.Supplier = b.Supplier
    left outer join I_RegionText              as e    on  e.Country  = c.Country
                                                      and e.Region   = c.Region
                                                      and e.Language = $session.system_language
    left outer join I_GLAccountTextRawData    as f    on  f.ChartOfAccounts = b.ChartOfAccounts
                                                      and f.GLAccount       = b.GLAccount
                                                      and f.Language        = $session.system_language

    left outer join I_OperationalAcctgDocItem as IGST on  IGST.AccountingDocument             = d.AccountingDocument
                                                      and IGST.FiscalYear                     = d.FiscalYear
                                                      and IGST.CompanyCode                    = d.CompanyCode
                                                      and IGST.TaxItemGroup                   = d.TaxItemGroup
                                                      and (
                                                         IGST.TransactionTypeDetermination    = 'JII'
                                                         or IGST.TransactionTypeDetermination = 'JIN'
                                                         or IGST.TransactionTypeDetermination = 'JIM'
                                                       )

    left outer join I_OperationalAcctgDocItem as CGST on  CGST.AccountingDocument             = d.AccountingDocument
                                                      and CGST.FiscalYear                     = d.FiscalYear
                                                      and CGST.CompanyCode                    = d.CompanyCode
                                                      and CGST.TaxItemGroup                   = d.TaxItemGroup
                                                      and (
                                                         CGST.TransactionTypeDetermination    = 'JIC'
                                                         or CGST.TransactionTypeDetermination = 'JCN'
                                                       )
    left outer join I_OperationalAcctgDocItem as SGST on  SGST.AccountingDocument             = d.AccountingDocument
                                                      and SGST.FiscalYear                     = d.FiscalYear
                                                      and SGST.CompanyCode                    = d.CompanyCode
                                                      and SGST.TaxItemGroup                   = d.TaxItemGroup
                                                      and (
                                                         SGST.TransactionTypeDetermination    = 'JIS'
                                                         or SGST.TransactionTypeDetermination = 'JSN'
                                                       )

    left outer join ZTAXRATE                  as g    on g.TaxCode = b.TaxCode

    left outer join ZSUPPLIER_DLTS            as s    on  s.AccountingDocument = b.AccountingDocument
                                                      and s.CompanyCode        = b.CompanyCode
                                                      and s.FiscalYear         = b.FiscalYear

{
  key b.CompanyCode,
  key b.FiscalYear,
  key b.AccountingDocument,
  key b.LedgerGLLineItem,
  key b.Ledger,
      b.Supplier,
      b.FiscalPeriod,
      b.ReferenceDocument,
      b.TransactionCurrency,
      //        a.AccountingDocumentCreationDate,
      a.DocumentDate,
      a.PostingDate,
      b.BusinessArea,
      b.TaxCode,
      b.GLAccount,
      f.GLAccountName,
      b.CostCenter,
      b.ProfitCenter,
      b.ClearingDate,
      b.ClearingJournalEntry,
      case
      when b.ClearingJournalEntry is not null
       and b.ClearingJournalEntry <> ''
      then 'Cleared'
      else 'Not Cleared'
      end                                                         as ClearingStatus,
      a.AccountingDocumentCreationDate,
      a.CreationTime,
      a.DocumentReferenceID,

      //Supplier Details
      c.SupplierFullName,
      c.Region,
      e.RegionName,
      c.TaxNumber3,

      //WithHolding Tax
      d.WithholdingTaxCode,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      d.WithholdingTaxBaseAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      d.WithholdingTaxAmount,
      d.TaxItemGroup,

      //GST
      cast( d.AmountInTransactionCurrency as abap.dec(15,2))      as TaxableValue,
      cast(IGST.AmountInCompanyCodeCurrency as abap.dec( 15, 2 )) as IGSTAmount,
      cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 15, 2 )) as CGSTAmount,
      cast(SGST.AmountInCompanyCodeCurrency as abap.dec( 15, 2 )) as SGSTAmount,
      g.TotalConditionRateRatio,
      g.TaxCodeName,
      s.Supplier as SupplierCode
}
where
  b.GLAccountType = 'P'
