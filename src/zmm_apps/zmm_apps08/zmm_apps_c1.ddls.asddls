@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Counting Of Open RFQ'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS_C1 as select from ZMM_I_APPS08_RV as h
{
 key h.Supplier,
 h.EmailAddress,
 
 count(*)  as OpenSupplierQuo
 
    
} where h.mark is null and h.QuotationLatestSubmissionDate >= $session.system_date
group by
h.Supplier,
h.EmailAddress
