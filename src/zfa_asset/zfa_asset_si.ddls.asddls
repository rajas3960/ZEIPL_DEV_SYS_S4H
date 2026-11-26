@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fixed Asset Supplier Invoice'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_ASSET_SI
  as select from I_JournalEntryItem            as JEI
    inner join   I_SuplrInvcItemPurOrdRefAPI01 as SI  on  SI.ReferenceDocument           = JEI.ReferenceDocument
                                                      and SI.ReferenceDocumentFiscalYear = JEI.ReferenceDocumentContext
                                                      and SI.ReferenceDocumentItem       = substring(
      JEI.ReferenceDocumentItem, 3, 4
    )
                                                      and SI.PurchaseOrder               = JEI.PurchasingDocument
                                                      and SI.PurchaseOrderItem           = JEI.PurchasingDocumentItem
    inner join   I_SupplierInvoiceAPI01        as SIH on  SIH.SupplierInvoice        = SI.SupplierInvoice
                                                      and SIH.FiscalYear             = SI.FiscalYear
                                                      and SIH.AccountingDocumentType = 'RE'
                                                      and SIH.IsInvoice              = 'X'

{
  key JEI.WBSElementInternalID,
      JEI.Supplier,
      SI.SupplierInvoice,
      SI.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum( SI.SupplierInvoiceItemAmount ) as ItemAmount
}
where
      JEI.Ledger                 =  '0L'
  and JEI.AccountingDocumentType =  'WE'
  and JEI.WBSElementInternalID   is not initial
  and JEI.WBSElementInternalID   <> '00000000'
  and JEI.PurchasingDocument     is not initial
  and JEI.PurchasingDocumentItem is not initial
  and JEI.Supplier               is not initial
  and JEI.IsReversal             is initial
  and JEI.IsReversed             is initial
group by
  JEI.WBSElementInternalID,
  JEI.Supplier,
  SI.SupplierInvoice,
  SI.DocumentCurrency
