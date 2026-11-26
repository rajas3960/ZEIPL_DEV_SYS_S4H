@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Data For Debit Note'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_ITEM_VIEW
  as select distinct from I_JournalEntry                as JOH
    inner join            I_JournalEntryItem            as JOI    on  JOI.AccountingDocument                     = JOH.AccountingDocument
                                                                  and JOI.FiscalYear                             = JOH.FiscalYear
                                                                  and JOI.CompanyCode                            = JOH.CompanyCode
                                                                  and JOI.Ledger                                 = '0L'
                                                                //  and
                                                                      //  //JOI.AccountingDocumentType = 'RE'
                                                                  //    (
                                                                   //     (
                                                                   //       JOI.AccountingDocumentType             = 'RE'
                                                                    //      and(
                                                                    //        JOI.GLAccountType                    = 'X'
                                                                      //      and JOI.TransactionTypeDetermination = 'BSX'
                                                                      //    )
                                                                      //  )
                                                                     // )



  //add logic for RK type//
   //  and   ( ( JOI.AccountingDocumentType = 'RK'
   //    and (JOI.TransactionTypeDetermination = 'RKA'
    //    and (JOI.Ledger = '0L'
    //     and JOI.LedgerGLLineItem = '000002'    )) ))


  //add logic for RK type//

    and (
      ( JOI.AccountingDocumentType = 'RE'
       and JOI.TransactionTypeDetermination = 'BSX'
  //  // and JOI.TransactionTypeDetermination = 'RKA'
  //  //  and JOI.LedgerGLLineItem = '000001'
      and JOI.GLAccountType = 'X' ))
    or
     ( JOI.AccountingDocumentType = 'RK'
      and JOI.TransactionTypeDetermination = 'RKA'
      and JOI.Ledger = '0L' )
     // Remove lineitem hardcode by Manoj 14-10-26 
//     and JOI.LedgerGLLineItem = '000002' )

  //add logic for RK type//

    left outer join       I_GLAccountText               as GLText on  GLText.ChartOfAccounts = JOI.ChartOfAccounts
                                                                  and GLText.GLAccount       = JOI.GLAccount
                                                                  and GLText.Language        = $session.system_language
    left outer join       I_OperationalAcctgDocItem     as JEI    on  JEI.AccountingDocument     = JOI.AccountingDocument
                                                                  and JEI.AccountingDocumentItem = JOI.AccountingDocumentItem
                                                                  and JEI.CompanyCode            = JOI.CompanyCode
                                                                  and JEI.FiscalYear             = JOI.FiscalYear
  //IGST Cal
    left outer join       I_OperationalAcctgDocItem     as IGST   on  IGST.AccountingDocument             = JEI.AccountingDocument
                                                                  and IGST.FiscalYear                     = JEI.FiscalYear
                                                                  and IGST.CompanyCode                    = JEI.CompanyCode
                                                                  and IGST.TaxItemGroup                   = JEI.TaxItemGroup
                                                                  and (
                                                                     IGST.TransactionTypeDetermination    = 'JII'
                                                                     or IGST.TransactionTypeDetermination = 'JIN'
                                                                     or IGST.TransactionTypeDetermination = 'JIM'
                                                                   )
    left outer join       I_TaxCodeRate                 as IGSTR  on  IGSTR.TaxCode                = IGST.TaxCode
                                                                  and IGSTR.AccountKeyForGLAccount = IGST.TransactionTypeDetermination
  //CGST Cal
    left outer join       I_OperationalAcctgDocItem     as CGST   on  CGST.AccountingDocument             = JEI.AccountingDocument
                                                                  and CGST.FiscalYear                     = JEI.FiscalYear
                                                                  and CGST.CompanyCode                    = JEI.CompanyCode
                                                                  and CGST.TaxItemGroup                   = JEI.TaxItemGroup
                                                                  and (
                                                                     CGST.TransactionTypeDetermination    = 'JIC'
                                                                     or CGST.TransactionTypeDetermination = 'JCN'
                                                                   )
    left outer join       I_TaxCodeRate                 as CGSTR  on  CGSTR.TaxCode                = CGST.TaxCode
                                                                  and CGSTR.AccountKeyForGLAccount = CGST.TransactionTypeDetermination
  //SGST Cal
    left outer join       I_OperationalAcctgDocItem     as SGST   on  SGST.AccountingDocument             = JEI.AccountingDocument
                                                                  and SGST.FiscalYear                     = JEI.FiscalYear
                                                                  and SGST.CompanyCode                    = JEI.CompanyCode
                                                                  and SGST.TaxItemGroup                   = JEI.TaxItemGroup
                                                                  and (
                                                                     SGST.TransactionTypeDetermination    = 'JIS'
                                                                     or SGST.TransactionTypeDetermination = 'JSN'
                                                                   )
    left outer join       I_TaxCodeRate                 as SGSTR  on  SGSTR.TaxCode                = SGST.TaxCode
                                                                  and SGSTR.AccountKeyForGLAccount = SGST.TransactionTypeDetermination
  //"""With PO Details for Credit debit note
    left outer join       ZFI_PO_ITEM                   as POI    on  POI.PurchaseOrder     = JOI.PurchasingDocument
                                                                  and POI.PurchaseOrderItem = JOI.PurchasingDocumentItem

    left outer join       I_SuplrInvcItemPurOrdRefAPI01 as Supp   on  Supp.SupplierInvoice     = JOI.ReferenceDocument
                                                                  and Supp.SupplierInvoiceItem = JOI.ReferenceDocumentItem
                                                                  and Supp.FiscalYear          = JOI.FiscalYear
 // """ Added 13-10-26 for RK Doc Multiple lineitem
 
   left outer join      zfi_matdes_db                    as  MD   on MD.companycode = JOI.CompanyCode
                                                                  and MD.accountingdocument = JOI.AccountingDocument
																  and MD.fiscalyear = JOI.FiscalYear
																  and MD.ledgergllineitem = JOI.LedgerGLLineItem  
																  


//""" Added 16-10-26 for RK Doc Tax Amount (CGST / SGST)

    left outer join       ZFI_ITEM_TAX                  as TAXV   on  TAXV.SourceLedger       = JOI.SourceLedger
                                                                  and TAXV.CompanyCode        = JOI.CompanyCode
                                                                  and TAXV.FiscalYear         = JOI.FiscalYear
                                                                  and TAXV.AccountingDocument = JOI.AccountingDocument
                                                                  and TAXV.LedgerGLLineItem   = JOI.LedgerGLLineItem
    
                                                                     
                                                                   
{
  key JOI.SourceLedger,
  key JOI.CompanyCode,
  key JOI.FiscalYear,
  key JOI.AccountingDocument,
  key JOI.LedgerGLLineItem,
      JOI.AccountingDocumentItem,
      JOI.AccountingDocumentType,
      JOI.Plant,
      JOI.GLAccount,
      GLText.GLAccountLongName,
      JOI.CompanyCodeCurrency,
      case
          when JOI.AccountingDocumentType = 'KG' then
          cast(JOI.CreditAmountInCoCodeCrcy as abap.dec( 15, 2 ) ) * -1
          when JOI.AccountingDocumentType = 'KR' then
          cast(JOI.DebitAmountInCoCodeCrcy as abap.dec( 15, 2 ) ) * +1
          when ( JOI.AccountingDocumentType = 'RE' and JOI.DebitAmountInCoCodeCrcy is initial ) then
          cast(JOI.CreditAmountInCoCodeCrcy as abap.dec( 15, 2 ) ) * -1

          when ( JOI.AccountingDocumentType = 'RE' and JOI.CreditAmountInCoCodeCrcy is initial ) then
          cast(JOI.DebitAmountInCoCodeCrcy as abap.dec( 15, 2 ) ) * +1

          when ( JOI.AccountingDocumentType = 'RK' and JOI.TransactionTypeDetermination = 'RKA' ) then
          cast(JOI.CreditAmountInCoCodeCrcy as abap.dec(15,2)) * -1
          else null end                                       as TaxableValue,

      //        cast(JOI.CreditAmountInCoCodeCrcy as abap.dec( 15, 2 ) ) * -1 as TaxableValue,
      JOI.TaxCode,
      JEI.TaxItemGroup,
      //********************************************HIMANSU NEW CODE*****************
      case
       when JOI.TaxCode = '3E'
         or JOI.TaxCode = '3A'
         or JOI.TaxCode = '3B'
         or JOI.TaxCode = '3F'
           then cast( 0 as abap.dec(15,2) )
       else
           cast( CGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
       end                                                    as CgstAmt,

      case
      when  JOI.TaxCode = '3E'
         or JOI.TaxCode = '3A'
         or JOI.TaxCode = '3B'
         or JOI.TaxCode = '3F'
          then cast( 0 as abap.dec(15,2) )
      else
          cast( CGSTR.ConditionRateRatio as abap.dec(15,2) )
      end                                                     as CgstRate,

      CGSTR.ConditionRateRatioUnit                            as CgstRateRatio,

      case
      when JOI.TaxCode = '3E'
       or  JOI.TaxCode = '3A'
       or  JOI.TaxCode = '3B'
       or  JOI.TaxCode = '3F'
      then cast( 0 as abap.dec(15,2) )
      else
      cast( CGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end                                                     as SgstAmt,

      case
      when  JOI.TaxCode = '3E'
        or  JOI.TaxCode = '3A'
        or  JOI.TaxCode = '3B'
        or  JOI.TaxCode = '3F'
          then cast( 0 as abap.dec(15,2) )
      else
          cast( CGSTR.ConditionRateRatio as abap.dec(15,2) )
      end                                                     as SgstRate,


      CGSTR.ConditionRateRatioUnit                            as SgstRateRatio,

      case
      when  JOI.TaxCode = '3E'
      or  JOI.TaxCode = '3A'
      or  JOI.TaxCode = '3B'
      or  JOI.TaxCode = '3F'
      then cast( 0 as abap.dec(15,2) )
      else
      cast( IGST.AbsltAmtInAdditionalCurrency1 as abap.dec(15,2) )
      end                                                     as IgstAmt,

      case
      when JOI.TaxCode = '3E'
          or  JOI.TaxCode = '3A'
          or  JOI.TaxCode = '3B'
          or  JOI.TaxCode = '3F'
         then cast( 0 as abap.dec(15,2) )
      else
         cast( IGSTR.ConditionRateRatio as abap.dec(15,2) )
      end                                                     as IgstRate,

      IGSTR.ConditionRateRatioUnit                            as IgstRateRatio,

      // OLD TAX
      //********************************************HIMANSU OLD CODE*****************
      //  cast(CGST.AbsltAmtInAdditionalCurrency1 as abap.dec( 15, 2 )) as CgstAmt,

      //   cast(CGSTR.ConditionRateRatio as abap.dec( 15, 2 )) as CgstRate,

      //    CGSTR.ConditionRateRatioUnit as CgstRateRatio,

      //    cast(SGST.AbsltAmtInAdditionalCurrency1 as abap.dec( 15, 2 )) as SgstAmt,
      //    cast(SGSTR.ConditionRateRatio as abap.dec( 15, 2 )) as SgstRate,
      //    SGSTR.ConditionRateRatioUnit as SgstRateRatio,
      //    cast(IGST.AbsltAmtInAdditionalCurrency1 as abap.dec( 15, 2 )) as IgstAmt,
      //    cast(IGSTR.ConditionRateRatio as abap.dec( 15, 2 )) as IgstRate,
      //    IGSTR.ConditionRateRatioUnit as IgstRateRatio,
      //********************************************HIMANSU OLD CODE*****************
      JOI.InvoiceReference,
      //"""This one With PO Process
      POI.PurchaseOrder,
      POI.PurchaseOrderItem,
      POI.Material,
      POI.PurchaseOrderItemText,
      //POI.HSNCode,
      JEI.IN_HSNOrSACCode as HSNCode,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      POI.OrderQuantity                                       as POOrderQuantity,
      POI.BaseUnit,
      POI.Rate,
      POI.Amount                                              as POAmount,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Supp.QuantityInPurchaseOrderUnit                        as OrderQuantity,
      Supp.DocumentCurrency,

      cast(Supp.SupplierInvoiceItemAmount as abap.dec(15,2) ) as Amount,
      MD.purchaseorderitemtext as Poitemtext,
      MD.hsncode as PoHsncode,
      @Semantics.quantity.unitOfMeasure: 'PoBaseunit'
      MD.quantity as PoQty,
      MD.baseunit as PoBaseunit,
      MD.rate as PoRate,
      TAXV.CgstAmt                     as RKCgstAmt,
      TAXV.SgstAmt                     as RKSgstAmt,
      TAXV.IgstAmt                     as RKIgstAmt
      

}
