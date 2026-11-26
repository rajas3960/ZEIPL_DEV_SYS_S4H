@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Goods Receipt - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_CI_GRN 
as projection on ZMM_II_GRN
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
    key Subuuid,
    Vendor,
    Suppliername,
    Gateentryno,
    Subgateentryno,
    Material,
    Materialtext,
    Plant,
    Plantname,
    Baseunit,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Quantity,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'    
    Pendqty,
    Remark,
    Weiuom,
    @Semantics.quantity.unitOfMeasure: 'Weiuom'    
    Tareweight,
    @Semantics.quantity.unitOfMeasure: 'Weiuom'        
    Grossweight,
    @Semantics.quantity.unitOfMeasure: 'Weiuom'        
    Netweight,
    Storagelocation,
    Chbaseunit,
    Challanno,
    Challandate,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'        
    Challantareweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'            
    Challangrossweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'            
    Challannetweight,
    Chqtyunit,
    @Semantics.quantity.unitOfMeasure: 'Chqtyunit'            
    Challanqty,
    Grnqty,
    Materialgroup,
    Poordertype,
    Poordertypetext,
    Ewaybillno,
    Ewaybilldate,
    Orderdate,
    Podocumt,
    Chdocumt,
    Sidocumt,
    Qadocumt,
    Gateentryseries,
    Weightindicator,
    Unloadind,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Head : redirected to parent ZMM_CH_GRN
}
