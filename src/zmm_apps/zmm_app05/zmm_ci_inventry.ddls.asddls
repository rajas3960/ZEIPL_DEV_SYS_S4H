@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Team Gate Entry Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_CI_INVENTRY 
as projection on ZMM_II_INVENTRY
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
    key Subuuid,
    @ObjectModel.text.element: [ 'Suppliername' ]
    Vendor,
    Suppliername,
    Gateentryno,
    Subgateentryno,
    @ObjectModel.text.element: [ 'Materialtext' ]
    Material,
    Materialtext,
    @ObjectModel.text.element: [ 'Plantname' ]
    Plant,
    Plantname,
    Baseunit,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Quantity,
    Remark,
    Weiuom,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'    
    Pendqty,
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
    Challangrossweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'        
    Challantareweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'        
    Challannetweight,
    Chqtyunit,
    @Semantics.quantity.unitOfMeasure: 'Chqtyunit'            
    Challanqty,
    Materialgroup,
    @ObjectModel.text.element: [ 'Poordertypetext' ]
    Poordertype,
    Poordertypetext,
    Ewaybillno,
    Ewaybilldate,
    Orderdate,
    Podocumt,
    Chdocumt,
    Sidocumt,
    Qadocumt,
    Tpdocumt,
    Grnqty,
    Inbounddelivery,
    Invoiceno,
    @ObjectModel.text.element: [ 'Trasportername' ]
    Trasporterid,
    Trasportername,
    Lrno,
    Lrdate,
    Poperunitprice,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Head : redirected to parent ZMM_CH_INVENTRY
}
