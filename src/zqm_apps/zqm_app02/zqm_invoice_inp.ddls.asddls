@EndUserText.label: 'QM Invoice Posting Input Parameter'
define abstract entity ZQM_INVOICE_INP
//  with parameters parameter_name : parameter_type
{
    @EndUserText.label: 'Reference'
    Reference : abap.char(16);
    @EndUserText.label: 'Posting Date'
    PostingDate: abap.dats;
    
}
