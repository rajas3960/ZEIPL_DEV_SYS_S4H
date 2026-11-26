@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSUPPLIER_DLTS 
as select from I_JournalEntryItem 
{
    key SourceLedger,
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    key LedgerGLLineItem,
    key Ledger,
        Supplier
 
}
where Ledger = '0L' 
//and GLAccountType = 'X' 
and  TransactionTypeDetermination = 'KBS'     
//Supplier is not initial

