@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Joural Entry Amount Calculation'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_JOURNAL_V2 
as select from ZFI_JOURNAL_V1
{
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    key LedgerGLLineItem,
    key Ledger,
    Supplier,
    FiscalPeriod,
    ReferenceDocument,
    TransactionCurrency,
    DocumentDate,
    PostingDate,
    BusinessArea,
    TaxCode,
    GLAccount,
    GLAccountName,
    CostCenter,
    ProfitCenter,
    ClearingDate,
    ClearingJournalEntry,
    ClearingStatus,
    AccountingDocumentCreationDate,
    CreationTime,
    DocumentReferenceID,
    SupplierFullName,
    Region,
    RegionName,
    TaxNumber3,
    WithholdingTaxCode,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    WithholdingTaxBaseAmount,
    @Semantics.amount.currencyCode: 'TransactionCurrency'    
    WithholdingTaxAmount,
    TaxItemGroup,
    TaxableValue,
    IGSTAmount,
    CGSTAmount,
    SGSTAmount,
    TotalConditionRateRatio,
    TaxCodeName,
    cast(
    coalesce( IGSTAmount, 0 ) +
    coalesce( CGSTAmount, 0 ) +
    coalesce( SGSTAmount, 0 )
    as abap.dec(15,2)
       ) as ConsolidatedGSTAmount,
       
    cast(
    coalesce( IGSTAmount, 0 ) +
    coalesce( CGSTAmount, 0 ) +
    coalesce( SGSTAmount, 0 ) +
    coalesce( TaxableValue, 0 )
    as abap.dec(15,2)
       ) as TotalInvoiceAmt
       

}
