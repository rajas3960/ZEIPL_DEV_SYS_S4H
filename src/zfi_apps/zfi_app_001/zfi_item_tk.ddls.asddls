@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transaction Key For RK doc'
@Metadata.ignorePropagatedAnnotations: true


define view entity ZFI_ITEM_TK
  as select from ZFI_ITEM_JE as BASE

    inner join I_OperationalAcctgDocItem as OA
      on  OA.CompanyCode           = BASE.CompanyCode
      and OA.FiscalYear             = BASE.FiscalYear
      and OA.AccountingDocument     = BASE.AccountingDocument
      and OA.AccountingDocumentItem = BASE.MappedAccountingDocumentItem
{
  key BASE.SourceLedger,
  key BASE.CompanyCode,
  key BASE.FiscalYear,
  key BASE.AccountingDocument,
  key BASE.AccountingDocumentItem,
  key BASE.LedgerGLLineItem,
      BASE.MappedAccountingDocumentItem,
      BASE.TaxCode
     

}

