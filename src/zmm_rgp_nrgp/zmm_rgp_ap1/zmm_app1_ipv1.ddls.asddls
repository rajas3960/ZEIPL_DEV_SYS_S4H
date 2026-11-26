@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RGP/NRGP Outword Entry - CPE1'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMM_APP1_IPV1  
as projection on ZMM_APP1_IV1
{
  key Uuid,
  key Itemno,
//      @Search.defaultSearchElement: true
      Matnr,
      Maktx,
      Uom, 
      plant,
      plantname,
      @EndUserText.label: 'Storage location'  
//      @ObjectModel.text.element: [ 'Storagelocation' ] 
      Storagelocation,
      Hsncode,
      @Semantics.quantity.unitOfMeasure: 'Uom' 
      Quantity,
      Curky,
      @Semantics.amount.currencyCode: 'Curky'
      Netprice,
      @Semantics.amount.currencyCode: 'Curky'
      Totvalue,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Totrcvqty,
      @Semantics.quantity.unitOfMeasure: 'Uom' 
      Totopnqty,
      Remarks,
      Mark,
      Rgpnrpactualno,
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      Createdat,
      @Semantics.user.lastChangedBy: true
      Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      Lastchangedat,
      /* Associations */
      _Header : redirected to parent ZMM_APP1_RPV
}
