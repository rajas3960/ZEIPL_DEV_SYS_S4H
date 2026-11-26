@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Broker Bill Report'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZFI_BILL_REPORT_PV 
as projection on ZFI_BILL_REPORT_RV
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
    ConsolidatedGSTAmount,
    TotalInvoiceAmt
}
