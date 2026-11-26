CLASS zfi_form_imp_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES:
   if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFI_FORM_IMP_CL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
********************************************************************************************************
  if not io_request->is_data_requested(  ).
        RETURN.
    endif.
******************************************************************************************************************

   DATA(lo_filter) = io_request->get_filter(  ).

    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lv_err).
      DATA(lv_error_text) = lv_err->get_text( ).
    ENDTRY.
*******************************************************************************************************************
        IF NOT line_exists( lt_range[  name = 'ACCOUNTINGDOCUMENT' ] ) and
        not line_exists( lt_range[ name = 'FISCALYEAR' ] ) and
        NOT line_exists( lt_range[ name = 'COMPANYCODE' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
*****************************************************************************************************************
    DATA rt_table TYPE TABLE OF ZFI_FORM_OUTPUT.
    DATA: lv_accdoc TYPE ZFI_FORM_OUTPUT-AccountingDocument.

    data lvgateno type c length 10 .
    DATA: lv_accodoc TYPE ZFI_FORM_OUTPUT-AccountingDocument.
*****************************************************************************************************
     LOOP AT lt_range[ name = 'ACCOUNTINGDOCUMENT' ]-range ASSIGNING FIELD-SYMBOL(<ls_Acc>).
    LOOP AT lt_range[ name = 'FISCALYEAR' ]-range ASSIGNING FIELD-SYMBOL(<ls_fis>).
    LOOP AT lt_range[ name = 'COMPANYCODE' ]-range ASSIGNING FIELD-SYMBOL(<ls_com>).
        data(lv_acc) = <ls_acc>-low.
        data(lv_fis) = <ls_fis>-low.
        data(lv_com) = <ls_com>-low.

************************************************************************************************************
        select SINGLE * from ZFI_HEADER_VIEW wiTH PRIVILEGED ACCESS
        whERE AccountingDocument = @lv_acc
        and FiscalYear = @lv_fis
        and CompanyCode = @lv_com
        into @data(ls_acchd).


*******************************************************************************************************
******************************New addition******************************************************************
       select single AccountingDocument,CompanyCode,FiscalYear,InvoiceReference
                    from I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS
                     where AccountingDocument = @lv_acc
                      and FiscalYear = @lv_fis
                      and CompanyCode = @lv_com
                      and DebitCreditCode = 'S'
        into @data(ls_invref).


        select single AccountingDocument,CompanyCode,FiscalYear,DocumentReferenceID
                    from  I_JournalEntry WITH PRIVILEGED ACCESS
                    where  AccountingDocument = @ls_invref-InvoiceReference
                    into @data(ls_docrefid).

        select single BusinessPartner,PersonFullName from  I_BusinessUserBasic
                    WITH PRIVILEGED ACCESS
                    WHERE BusinessPartner = @ls_acchd-AccountingDocCreatedByUser+2
                   into  @data(ls_createdby).

******************************************************************
      select single CompanyCode,FiscalYear,InvoiceReference,NetDueDate,
                      AccountingDocument,LedgerGLLineItem,DocumentItemText
                      from I_JournalEntryItem with PRIVILEGED ACCESS
                      where AccountingDocument = @lv_acc
                      and FiscalYear = @lv_fis
                      and CompanyCode = @lv_com
                      and Ledger = '0L'
                      and LedgerGLLineItem = '000001'


        into @data(ls_formtype).

        data(ls_desform) = ls_formtype-DocumentItemText+0(3).
******************************************************************************************************
        INSERT VALUE ZFI_FORM_OUTPUT(
                        AccountingDocument = ls_acchd-AccountingDocument
                        FiscalYear = ls_acchd-FiscalYear
                        CompanyCode = ls_acchd-CompanyCode
                        AccountingDocumentType = ls_acchd-AccountingDocumentType
                        AccountingDocumentTypeName = ls_acchd-AccountingDocumentTypeName
                        DocumentDate = ls_acchd-DocumentDate
                        OriginalReferenceDocument = ls_formtype-InvoiceReference
                        PostingDate = ls_acchd-PostingDate
                        CompanyCodeCurrency = ls_acchd-CompanyCodeCurrency
                        Supplier = ls_acchd-Supplier
                        Plant = ls_acchd-Plant
                        SupplierName = ls_acchd-SupplierName
                        gstin = ls_acchd-gstin
                        pan = ls_acchd-pan
                        EmailAddress = ls_acchd-EmailAddress
                        CityName = ls_acchd-CityName
                        PostalCode = ls_acchd-PostalCode
                        Phonenumber = ls_acchd-phone
                        StreetName = ls_acchd-StreetName
                        Region = ls_acchd-Region
                        Country = ls_acchd-Country
                        StreetPrefixName1 = ls_acchd-StreetPrefixName1
                        StreetPrefixName2 = ls_acchd-StreetPrefixName2
                        AddressTimeZone = ls_acchd-AddressTimeZone
                        FormType = ls_desform
                        Dateofinvoice = ls_formtype-NetDueDate
                        CDNReson = ls_formtype-DocumentItemText
*                       Invoicereference = ls_acchd-InvoiceReference
                         DocumentReferenceIDHeader = ls_acchd-DocumentReferenceID
*                        Commonnarration = ls_acchd-DocumentItemText
                         Invoicereference = ls_invref-InvoiceReference
                         Documentreferenceid = ls_docrefid-DocumentReferenceID
                         PreparedBy = ls_acchd-ParkedByUser
                         CheckedandVerifiedby = ls_createdby-PersonFullName

                        )
                        into table rt_table.
*******************************************************************************************************
      io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
    ENDLOOP.
    ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
