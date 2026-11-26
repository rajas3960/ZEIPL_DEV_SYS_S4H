@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Final GR'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_MAXGR
  as select from ZMM_MAXPODT as mp
  left outer join I_MaterialDocumentItem_2 as md on md.PurchaseOrder = mp.PurchaseOrder
//                                                 and md.PurchaseOrderItem = mp.PurchaseOrderItem
                                                 and md.Supplier = mp.Supplier
                                                 and md.GoodsMovementType = '101'
                                                 
                                                 
  {
    
    key max(md.MaterialDocument) as MaterialDocument,
//    key md.MaterialDocumentItem,
    key mp.Supplier,
    key mp.Material,
    key max(mp.PurchaseOrder) as PurchaseOrder,
    @Semantics.amount.currencyCode: 'DocumentCurrency'
     mp.NetAmount,
     mp.DocumentCurrency,
     mp.CreationDate,
     @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
     sum(cast(md.TotalGoodsMvtAmtInCCCrcy as abap.curr( 13, 2 ))) as Totamtgrn,
     md.CompanyCodeCurrency,
     max(md.PostingDate) as PostingDate
     
    
   }
group by
//    md.MaterialDocumentItem,
    mp.Supplier,
    mp.Material,
//    mp.PurchaseOrder,
    mp.NetAmount,
    mp.CreationDate,
    mp.DocumentCurrency,
    md.CompanyCodeCurrency
                                               
  
