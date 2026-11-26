@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JE FOR RKA '
@Metadata.ignorePropagatedAnnotations: true

define view entity ZFI_ITEM_JE
  as select from I_JournalEntryItem as JEI
{
  key JEI.SourceLedger,
  key JEI.CompanyCode,
  key JEI.FiscalYear,
  key JEI.AccountingDocument,
  key JEI.AccountingDocumentItem,
  key JEI.LedgerGLLineItem,
      JEI.Ledger,
      JEI.TransactionTypeDetermination,
      JEI.TaxCode,

      case
        when JEI.LedgerGLLineItem = '000002'
          then '001'
        when JEI.LedgerGLLineItem = '000003'
          then '002'
        when JEI.LedgerGLLineItem = '000004'  
          then '003'        
        when JEI.LedgerGLLineItem = '000005'  
          then '004'
        when JEI.LedgerGLLineItem = '000006' 
          then '005'
        when JEI.LedgerGLLineItem = '000007' 
          then '006'
        when JEI.LedgerGLLineItem = '000008'        
          then '007'
        when JEI.LedgerGLLineItem = '000009' 
          then '008'  
        when JEI.LedgerGLLineItem = '000010' 
          then '009'           
        else '000'
      end as MappedAccountingDocumentItem
}
where
      JEI.Ledger = '0L'
  and JEI.TransactionTypeDetermination = 'RKA'
//  and ( JEI.LedgerGLLineItem = '000003'
//     or JEI.LedgerGLLineItem = '000004' )
  and (
       JEI.LedgerGLLineItem = '000002'
    or JEI.LedgerGLLineItem = '000003'
    or JEI.LedgerGLLineItem = '000004'
    or JEI.LedgerGLLineItem = '000005'
    or JEI.LedgerGLLineItem = '000006'
    or JEI.LedgerGLLineItem = '000007'
    or JEI.LedgerGLLineItem = '000008'
    or JEI.LedgerGLLineItem = '000009'
    or JEI.LedgerGLLineItem = '000010'
)
