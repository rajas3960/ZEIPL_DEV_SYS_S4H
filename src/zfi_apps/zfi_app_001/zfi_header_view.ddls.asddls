@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Debit Note Header View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_HEADER_VIEW 
as select from I_JournalEntry as JOH 
left outer join I_JournalEntryItem as JOI on JOI.AccountingDocument = JOH.AccountingDocument
                                           and JOI.FiscalYear = JOH.FiscalYear
                                           and JOI.CompanyCode = JOH.CompanyCode
                                           and JOI.Ledger = '0L'
                                           and JOI.LedgerGLLineItem = '000001'
left outer join ZFI_SUPPLIER_ADDRESS as SupAdd on SupAdd.Supplier = JOI.Supplier
left outer join I_AccountingDocumentTypeText as Acctext on Acctext.AccountingDocumentType = JOH.AccountingDocumentType
                                            and Acctext.Language = $session.system_language
left outer join zfi_debitnote_db as Form on Form.accountingdocument = JOH.AccountingDocument
                                     and Form.companycode = JOH.CompanyCode
                                     and Form.fiscalyear = JOH.FiscalYear
left outer join I_SupplierInvoiceAPI01 as SupInv on SupInv.SupplierInvoice = JOI.ReferenceDocument
                                                      and SupInv.FiscalYear = JOI.FiscalYear
                                                      and SupInv.CompanyCode = JOI.CompanyCode                                     
                                   
//  NEW ADD


 ////left outer join I_OperationalAcctgDocItem as OAI   on OAI.AccountingDocument = JOH.AccountingDocument   
 // left  outer join I_OperationalAcctgDocItem as OAI   on OAI.AccountingDocument = JOI.AccountingDocument  
                                                     //   and OAI.CompanyCode = JOI.CompanyCode
                                                     //    and OAI.FiscalYear = JOI.FiscalYear
                                                     //  //  and OAI.DocumentItemText <> 'null'
                                                     //  and OAI.DebitCreditCode = 'S'
  
//  left  outer join  I_JournalEntry as    DRID    on DRID.AccountingDocument = OAI.InvoiceReference 
                                       //           and DRID.CompanyCode = OAI.CompanyCode
                                         //          and DRID.FiscalYear = OAI.FiscalYear                                           
{
    key JOH.AccountingDocument,
    key JOH.FiscalYear,
    key JOH.CompanyCode,
        JOH.AccountingDocumentType,
        Acctext.AccountingDocumentTypeName,
        JOH.DocumentDate,
        JOH.OriginalReferenceDocument,
        JOH.PostingDate,
        JOH.CompanyCodeCurrency,
        JOH.DocumentReferenceID,
        JOI.Supplier,
        JOI.Plant,
        JOI.ReferenceDocument,
        JOI.ReferenceDocumentItem,
        SupAdd.SupplierName,
        SupAdd.GSTIN,
        SupAdd.PAN,
        SupAdd.EmailAddress,
        SupAdd.CityName,
        SupAdd.PostalCode,
        SupAdd.StreetName,
        SupAdd.Region,
        SupAdd.Country,
        SupAdd.phone,
        SupAdd.StreetPrefixName1,
        SupAdd.StreetPrefixName2,
        SupAdd.AddressTimeZone,
        Form.formtype,
        Form.attachment,
        Form.filename,
        Form.mimetype,
        Form.createdby,
        Form.createdat,
        JOH.ParkedByUser,
        JOH.AccountingDocCreatedByUser
 //      OAI.DocumentItemText,
  //     DRID.DocumentReferenceID,
  //    OAI.InvoiceReference
       
        
}
//where JOH.AccountingDocumentType = 'RE'  and SupInv.IsInvoice = '' and SupInv.ReverseDocument = '' and  SupInv.SupplierInvoiceIDByInvcgParty not like '% SC'

 //where JOH.AccountingDocumentType = 'RE'  
 //and  SupInv.IsInvoice = '' and SupInv.ReverseDocument = ''

//where ( (JOH.AccountingDocumentType = 'RE' or JOH.AccountingDocumentType = 'RK' ) 
 //and SupInv.IsInvoice = 'X' and SupInv.ReverseDocument = '' )
 
 where 
(
   JOH.AccountingDocumentType = 'RE'  
   and SupInv.IsInvoice = '' 
   and SupInv.ReverseDocument = ''
)
or
(
   JOH.AccountingDocumentType = 'RK' 
// //  //and JOI.TransactionTypeDetermination = 'RKA' 
   and SupInv.IsInvoice = 'X' 
   and SupInv.ReverseDocument = ''
 )
