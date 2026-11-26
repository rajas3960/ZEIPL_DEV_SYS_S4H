@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Compare Supplier Quotations Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS01_IRV
  as select from    I_Requestforquotation_Api01   as rq
    left outer join I_RfqScheduleLine_Api01       as rqs   on rqs.RequestForQuotation = rq.RequestForQuotation

    left outer join I_SupplierQuotation_Api01     as sq    on sq.RequestForQuotation = rq.RequestForQuotation
    left outer join I_Supplier                    as s     on s.Supplier = sq.Supplier
    left outer join I_SupplierQuotationItem_Api01 as sqi   on  sqi.SupplierQuotation       = sq.SupplierQuotation
                                                           and sqi.RequestForQuotation     = rq.RequestForQuotation
                                                           and sqi.RequestForQuotationItem = rqs.RequestForQuotationItem
    inner join      I_SuplrQtnScheduleLine_Api01  as sqs   on  sqs.SupplierQuotation     = sqi.SupplierQuotation
                                                           and sqs.SupplierQuotationItem = sqi.SupplierQuotationItem
    left outer join I_CountryText                 as CT    on CT.Country = s.Country
    left outer join ZMM_MAXGR                     as maxgr on  maxgr.Supplier = sq.Supplier
                                                           and maxgr.Material = sqi.Material
    left outer join zmm_apps01_itb                as cmp   on  cmp.supplierquotation   = sq.SupplierQuotation
                                                           and cmp.requestforquotation = rq.RequestForQuotation
                                                           and cmp.supplier            = sq.Supplier
    left outer join zmm_a_apps08_itm              as rqi   on  rqi.requestforquotation     = rqs.RequestForQuotation
                                                           and rqi.requestforquotationitem = rqs.RequestForQuotationItem
                                                           and rqi.supplier                = sq.Supplier
    inner join      I_ProductText                 as pt    on  pt.Product  = sqi.Material
                                                           and pt.Language = $session.system_language
    left outer join I_PurchaseOrderAPI01          as po    on po.PurchaseOrder = maxgr.PurchaseOrder
    inner join      I_Supplier                    as lsup  on lsup.Supplier = po.Supplier
    inner join      I_PaymentTermsText            as Pts   on Pts.PaymentTerms = sq.PaymentTerms
                                                           and Pts.Language = $session.system_language

  association [1..1] to zmm_compare_status   as stus on stus.name = $projection.Compare
  association        to parent ZMM_APPS01_RV as hdr  on hdr.RequestForQuotation = $projection.RequestForQuotation
{
  key sq.SupplierQuotation,
  key rq.RequestForQuotation,
  key sq.Supplier,
  key max(maxgr.PurchaseOrder)                         as PurchaseOrder,
  key rqs.RequestForQuotationItem,
  key sqi.SupplierQuotationItem,
      concat(
      concat(
        pt.ProductName,
        '('
      ),
      concat(
        ltrim( sqi.Material, '0' ),
        ')'
      )
      )                                                as Material,
      s.SupplierName,
      concat(
      concat(
        s.SupplierName,
        '('
      ),
      concat(
        ltrim( sq.Supplier, '0' ),
        ')'
      )
      )                                                as Supname,
      sqi.PurgDocPriceDate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum( cast(sqi.NetAmount as abap.curr( 15, 2 )))  as NetAmount,
      sqi.DocumentCurrency,
      concat_with_space(
      s.StreetName,
      concat_with_space(
          s.PostalCode,
          CT.CountryName,
          1
      ),
      1
      )                                                as Address,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      rqs.ScheduleLineOrderQuantity                    as rfqty,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      rqi.rate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sqs.ScheduleLineOrderQuantity                    as sqty,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sqi.NetPriceAmount,
      sqs.OrderQuantityUnit,
      max(maxgr.CreationDate)                          as CreationDate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(cast(maxgr.NetAmount as abap.curr( 13, 2 ))) as PoNetAmount,
      maxgr.MaterialDocument,
      max(maxgr.PostingDate)                           as PostingDate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(cast(maxgr.Totamtgrn as abap.curr( 13, 2 ))) as Totamtgrn,
      cmp.compare                                      as Compare,
      stus.text,
      case stus.name
      when '01'
      then 3
      else 0 end                                       as stuscrt,
      concat(
      concat(
        lsup.SupplierName,
        '('
      ),
      concat(
        ltrim( po.Supplier, '0' ),
        ')'
      )
      )                                                as lastpo_supplier,
      concat(
      concat(
        Pts.PaymentTermsName,
        '('
      ),
      concat( sq.PaymentTerms ,
        ')'
      )
      )                                                as PaymentTerms,
      hdr
}
group by
  sq.SupplierQuotation,
  rq.RequestForQuotation,
  sq.Supplier,
  s.SupplierName,
  sqi.PurgDocPriceDate,
  sqi.DocumentCurrency,
  s.StreetName,
  s.PostalCode,
  CT.CountryName,
  maxgr.MaterialDocument,
  maxgr.PurchaseOrder,
  cmp.compare,
  stus.text,
  stus.name,
  sqs.ScheduleLineOrderQuantity,
  sqi.NetPriceAmount,
  sqi.SupplierQuotationItem,
  sqs.OrderQuantityUnit,
  rqs.ScheduleLineOrderQuantity,
  rqs.RequestForQuotationItem,
  rqi.rate,
  sqi.Material,
  pt.ProductName,
  po.Supplier,
  lsup.SupplierName,
  Pts.PaymentTermsName,
  sq.PaymentTerms;
