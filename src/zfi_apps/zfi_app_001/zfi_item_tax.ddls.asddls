@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax Code'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_ITEM_TAX
  as select from ZFI_ITEM_TK as TT

    left outer join I_OperationalAcctgDocItem as CGST
      on  CGST.CompanyCode                   = TT.CompanyCode
      and CGST.FiscalYear                    = TT.FiscalYear
      and CGST.AccountingDocument            = TT.AccountingDocument
      and CGST.TaxItemGroup                  = TT.MappedAccountingDocumentItem
      and CGST.TransactionTypeDetermination  = 'JIC'

    left outer join I_OperationalAcctgDocItem as SGST
      on  SGST.CompanyCode                   = TT.CompanyCode
      and SGST.FiscalYear                    = TT.FiscalYear
      and SGST.AccountingDocument            = TT.AccountingDocument
      and SGST.TaxItemGroup                  = TT.MappedAccountingDocumentItem
      and SGST.TransactionTypeDetermination  = 'JIS'
      
    left outer join I_OperationalAcctgDocItem as IGST
      on  IGST.CompanyCode                   = TT.CompanyCode
      and IGST.FiscalYear                    = TT.FiscalYear
      and IGST.AccountingDocument            = TT.AccountingDocument
      and IGST.TaxItemGroup                  = TT.MappedAccountingDocumentItem
      and (    IGST.TransactionTypeDetermination = 'JII'
            or IGST.TransactionTypeDetermination = 'JIN'
            or IGST.TransactionTypeDetermination = 'JIM' )
      
{
  key TT.SourceLedger,
  key TT.CompanyCode,
  key TT.FiscalYear,
  key TT.AccountingDocument,
  key TT.AccountingDocumentItem,
  key TT.LedgerGLLineItem,

      TT.MappedAccountingDocumentItem                         as TaxItemGroup,
      TT.TaxCode,

      case
        when TT.TaxCode = '3E'
          or TT.TaxCode = '3A'
          or TT.TaxCode = '3B'
          or TT.TaxCode = '3F'
          then cast( 0 as abap.dec(15,2) )
        when CGST.AbsltAmtInAdditionalCurrency1 is null
          then cast( 0 as abap.dec(15,2) )
        else cast( CGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end                                                     as CgstAmt,

      case
        when TT.TaxCode = '3E'
          or TT.TaxCode = '3A'
          or TT.TaxCode = '3B'
          or TT.TaxCode = '3F'
          then cast( 0 as abap.dec(15,2) )
        when SGST.AbsltAmtInAdditionalCurrency1 is null
          then cast( 0 as abap.dec(15,2) )
        else cast( SGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end                                                     as SgstAmt,
      
      case
        when TT.TaxCode = '3E'
          or TT.TaxCode = '3A'
          or TT.TaxCode = '3B'
          or TT.TaxCode = '3F'
          then cast( 0 as abap.dec(15,2) )
        when IGST.AbsltAmtInAdditionalCurrency1 is null
          then cast( 0 as abap.dec(15,2) )
        else cast( IGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end                                                     as IgstAmt
      

}
