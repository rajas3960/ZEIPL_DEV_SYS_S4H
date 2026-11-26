@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Counting Of Inpreparation RFQ'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS_C2 as select from ZMM_I_APPS08_RV as h
{
 key h.Supplier,
 h.EmailAddress,
 
 count(* )  as InprepSupplierQuo
 
    
} where h.mark is not initial and h.QuotationLatestSubmissionDate >= $session.system_date
group by
h.Supplier,
h.EmailAddress

