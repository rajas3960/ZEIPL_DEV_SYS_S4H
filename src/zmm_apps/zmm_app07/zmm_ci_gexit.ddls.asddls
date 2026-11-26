@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Security Exit Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_CI_GEXIT 
as projection on ZMM_II_GEXIT
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
    key Subuuid,
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
    @Semantics.quantity.unitOfMeasure: 'Baseunit'    
    Tareweight,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Grossweight,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Netweight,
    Chbaseunit,
    Challanno,
    Challandate,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'        
    Challantareweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'        
    Challangrossweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'        
    Challannetweight,
    @Semantics.quantity.unitOfMeasure: 'Chbaseunit'    
    Challanqty,
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
    Shortageqty,  
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Head : redirected to parent ZMM_CH_GEXIT
}
