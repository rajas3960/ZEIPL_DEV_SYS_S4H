@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Quotation Vendor'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS08_SUP
  as select from I_SupplierQuotation_Api01     as hdr
    inner join   I_SupplierQuotationItem_Api01 as itm on itm.SupplierQuotation = hdr.SupplierQuotation

{
  key itm.SupplierQuotation,
  key itm.SupplierQuotationItem,
      itm.RequestForQuotation,
      itm.RequestForQuotationItem,
      hdr.Supplier
}
