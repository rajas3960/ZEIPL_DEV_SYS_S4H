@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View of MSME Report'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MSME_REPORT_RV
  with parameters
    P_companycode : bukrs,
    p_currdate    : datum
  as select from    I_JournalEntryItem                                  as JEI
    inner join      I_BusinessPartner                                   as BP  on BP.BusinessPartner = JEI.Supplier
    inner join      ZI_AMT( P_CurrDate    : $parameters.p_currdate,
                            P_CompanyCode : $parameters.P_companycode ) as AMT on AMT.Vendor = JEI.Supplier
    left outer join I_Supplier                                          as SUP on  SUP.Supplier         = JEI.Supplier
                                                                               and SUP.SupplierLanguage = 'E'
    left outer join I_BuPaIdentification                                as BPA on  BPA.BusinessPartner      = JEI.Supplier
                                                                               and BPA.BPIdentificationType = 'MSME'
    left outer join I_SupplierCompany                                   as SC  on  SC.Supplier    = JEI.Supplier
                                                                               and SC.CompanyCode = $parameters.P_companycode
    left outer join I_JournalEntry                                      as JE  on JE.AccountingDocument = JEI.AccountingDocument

{
  key BP.BusinessPartner                                                              as Vendor,
  key JEI.CompanyCode                                                                 as CompanyCode,
  key JEI.AccountingDocument                                                          as AD,

      BP.BusinessPartnerFullName                                                      as VendorName,

      AMT.GlobalCurrency,
      @Semantics.amount.currencyCode: 'GlobalCurrency'
      AMT.TotalDueAmount                                                              as TotalDueAmount,

      SUP.BusinessPartnerPanNumber                                                    as PAN,
      case
          when BPA.BPIdentificationType = 'MSME'
          then BPA.BPIdentificationNumber
          else null
      end                                                                             as MSMEno,
         BPA.BPIdentificationEntryDate                                                   as MSMEdate,
//      cast(
//      concat(
//       concat(
//           substring( cast( BPA.BPIdentificationEntryDate as abap.char(8) ), 7, 2 ),
//           '.'
//       ),
//       concat(
//           concat(
//               substring( cast( BPA.BPIdentificationEntryDate as abap.char(8) ), 5, 2 ),
//               '.'
//           ),
//           substring( cast( BPA.BPIdentificationEntryDate as abap.char(8) ), 1, 4 )
//       )
//      )
//      as abap.char(10)
//      )                                                                               as MSMEdate, // Date Format

      @Semantics.amount.currencyCode: 'GlobalCurrency'
      case
          when dats_days_between( JEI.NetDueDate, $parameters.p_currdate ) > 45
          then JEI.AmountInCompanyCodeCurrency
          else cast( 0 as abap.curr(23,2) )
      end                                                                             as AmountDueMoreThan45Days,

        JEI.DocumentDate                                                                as InvDate,
//      cast(
//       concat(
//          concat(
//              substring( cast( JEI.DocumentDate as abap.char(8) ), 7, 2 ),
//              '.'
//          ),
//          concat(
//              concat(
//                  substring( cast( JEI.DocumentDate as abap.char(8) ), 5, 2 ),
//                  '.'
//              ),
//              substring( cast( JEI.DocumentDate as abap.char(8) ), 1, 4 )
//          )
//       )
//       as abap.char(10)
//       )                                                                              as InvDate,
      //     $parameters.p_currdate                                                          as RecordDate,
      //  cast( dats_days_between( JEI.DocumentDate, $parameters.p_currdate ) as abap.int4) as ODDays,
      cast( dats_days_between( JEI.NetDueDate, $parameters.p_currdate ) as abap.int4) as ODDays,
       JEI.NetDueDate                                                                  as NetDueDate,
//      cast(
//      concat(
//         concat(
//             substring( cast( JEI.NetDueDate as abap.char(8) ), 7, 2 ),
//             '.'
//         ),
//         concat(
//             concat(
//                 substring( cast( JEI.NetDueDate as abap.char(8) ), 5, 2 ),
//                 '.'
//             ),
//             substring( cast( JEI.NetDueDate as abap.char(8) ), 1, 4 )
//         )
//      )
//      as abap.char(10)
//      )                                                                               as NetDueDate,
         JEI.PostingDate                                                                 as PostDate,
//      cast(
//      concat(
//         concat(
//             substring( cast( JEI.PostingDate as abap.char( 8 )), 7, 2 ),
//             '.'
//      ),
//      concat(
//         concat(
//             substring( cast( JEI.PostingDate as abap.char( 8 )), 5, 2 ),
//             '.'
//         ),
//         substring( cast( JEI.NetDueDate as abap.char(8) ), 1, 4 )
//         )
//      )
//      as abap.char(10)
//      )                                                                               as PostDate,

      //    JEI.ReferenceDocument                                                           as InvoiceNo,
      JE.DocumentReferenceID                                                          as InvoiceNo,
      SC.MinorityGroup                                                                as MinorityIndicator
}
where
       JEI.Ledger                                                  =  '0L'
  // and  JEI.DocumentDate                                              <= $parameters.p_currdate
  and  JEI.CompanyCode                                             = $parameters.P_companycode
  and  JEI.Supplier                                                is not null
  and  dats_days_between( JEI.NetDueDate, $parameters.p_currdate ) >  45
  and  SC.MinorityGroup                                            is not initial
//  and(
//       JE.AccountingDocumentType                                   =  'KR'
//    or JE.AccountingDocumentType                                   =  'RE'
//    or JE.AccountingDocumentType                                    =  'KZ'
//    or JE.AccountingDocumentType                                   =  'KG'
//  )
  and  JEI.TransactionTypeDetermination                            <> 'WRX'
  and  JEI.ClearingDate                                            is initial
  and  JEI.ClearingJournalEntry                                    is initial
  and  JEI.NetDueDate                                              is not initial
// and BPA.BPIdentificationNumber                                    is initial
group by
  BP.BusinessPartner,
  BP.BusinessPartnerFullName,
  AMT.GlobalCurrency,
  JEI.AmountInCompanyCodeCurrency,
  AMT.TotalDueAmount,
  JEI.DocumentDate,
  SUP.BusinessPartnerPanNumber,
  BPA.BPIdentificationType,
  BPA.BPIdentificationNumber,
  JEI.CompanyCode,
  JEI.AccountingDocument,
  JEI.NetDueDate,
  BPA.BPIdentificationEntryDate,
  //JEI.ReferenceDocument,
  JEI.PostingDate,
  JE.DocumentReferenceID,
  SC.MinorityGroup
