@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Grouping For Supplier Quotation'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZMM_APPS08_GRP
  as select from I_RfqBidder_Api01 as bid

    left outer join ZMM_APPS08_SUP as sup
      on  sup.RequestForQuotation = bid.RequestForQuotation
      and sup.Supplier            = bid.Supplier

{
  key bid.RequestForQuotation,
  key bid.Supplier,

      max( sup.SupplierQuotation ) as SupplierQuotation
}

group by
  bid.RequestForQuotation,
  bid.Supplier
