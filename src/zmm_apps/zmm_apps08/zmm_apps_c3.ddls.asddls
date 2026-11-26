@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Counting Of Closed RFQ'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS_C3 as select from ZMM_I_APPS08_RV as h
{
 key h.Supplier,
 h.EmailAddress,
 
 count(*)  as ClosedQuotatRFQ
 
    
} where  h.QuotationLatestSubmissionDate < $session.system_date
group by
h.Supplier,
h.EmailAddress
