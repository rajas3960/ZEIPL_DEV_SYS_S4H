@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RFQ Supplier Count'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZMM_APPS_C4
  as select from ZMM_APPS_C1 as c1

    left outer join ZMM_APPS_C2 as c2
      on c2.Supplier = c1.Supplier

    left outer join ZMM_APPS_C3 as c3
      on c3.Supplier = c1.Supplier

{
  key c1.Supplier,
  c1.EmailAddress,

  coalesce( c1.OpenSupplierQuo, 0 ) as OpenRFQCount,

  coalesce( c2.InprepSupplierQuo, 0 ) as InPreparationCount,

  coalesce( c3.ClosedQuotatRFQ, 0 ) as ClosedRFQCount
}
