@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RKA Document Item Mapping'

define view entity ZFI_TEST
  as select distinct from I_JournalEntry            as JOH
    inner join            I_JournalEntryItem        as JOI    on  JOI.AccountingDocument = JOH.AccountingDocument
                                                              and JOI.FiscalYear         = JOH.FiscalYear
                                                              and JOI.CompanyCode        = JOH.CompanyCode
                                                              and JOI.Ledger             = '0L'

    inner join            I_OperationalAcctgDocItem as JEI    on  JEI.AccountingDocument     = JOI.AccountingDocument
                                                              and JEI.AccountingDocumentItem = JOI.AccountingDocumentItem
                                                              and JEI.CompanyCode            = JOI.CompanyCode
                                                              and JEI.FiscalYear             = JOI.FiscalYear
                                                              and JEI.TransactionTypeDetermination = 'RKA' 
//                                                              or JEI.TransactionTypeDetermination = 'KBS' ) // base line only

    left outer join       I_OperationalAcctgDocItem as RKSGST on  RKSGST.AccountingDocument           = JEI.AccountingDocument
                                                              and RKSGST.CompanyCode                  = JEI.CompanyCode
                                                              and RKSGST.FiscalYear                   = JEI.FiscalYear
                                                              and RKSGST.TaxItemGroup                 = JEI.TaxItemGroup   // link by tax group, not item
                                                              and RKSGST.TransactionTypeDetermination = 'JIS'

    left outer join       I_OperationalAcctgDocItem as RKCGST on  RKCGST.AccountingDocument           = JEI.AccountingDocument
                                                              and RKCGST.CompanyCode                  = JEI.CompanyCode
                                                              and RKCGST.FiscalYear                   = JEI.FiscalYear
                                                              and RKCGST.TaxItemGroup                 = JEI.TaxItemGroup
                                                              and RKCGST.TransactionTypeDetermination = 'JIC'
{
  key JOI.SourceLedger,
  key JOI.CompanyCode,
  key JOI.FiscalYear,
  key JOI.AccountingDocument,
  key JOI.LedgerGLLineItem,
//  key JEI.AccountingDocumentItem,
      JEI.TaxItemGroup,
      JEI.TransactionTypeDetermination,
//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//      RKSGST.AbsltAmtInAdditionalCurrency1,
//      RKSGST.CompanyCodeCurrency

      case when JOI.TaxCode = '3E' or JOI.TaxCode = '3A'
             or JOI.TaxCode = '3B' or JOI.TaxCode = '3F'
           then cast( 0 as abap.dec(15,2) )
           else cast( RKSGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end as RKSgstAmt,

      case when JOI.TaxCode = '3E' or JOI.TaxCode = '3A'
             or JOI.TaxCode = '3B' or JOI.TaxCode = '3F'
           then cast( 0 as abap.dec(15,2) )
           else cast( RKCGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end as RKCgstAmt
}



































//define view entity ZFI_TEST
//  as select from I_JournalEntryItem as JEI
//{
//  key JEI.SourceLedger,
//  key JEI.CompanyCode,
//  key JEI.FiscalYear,
//  key JEI.AccountingDocument,
//  key JEI.AccountingDocumentItem,
//  key JEI.LedgerGLLineItem,
//      JEI.Ledger,
//      JEI.TransactionTypeDetermination,
//      JEI.TaxCode,
//
//      case
//        when JEI.LedgerGLLineItem = '000003'
//          then '001'
//        when JEI.LedgerGLLineItem = '000004'
//          then '002'
//        else '000'
//      end as MappedAccountingDocumentItem
//}
//where
//      JEI.Ledger = '0L'
//  and JEI.TransactionTypeDetermination = 'RKA'
//  and ( JEI.LedgerGLLineItem = '000003'
//     or JEI.LedgerGLLineItem = '000004' )
