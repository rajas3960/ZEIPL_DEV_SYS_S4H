@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RGP/NRGP Outward Processing Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}  
@Metadata.allowExtensions: true
define root view entity ZMM_APP2_RPV 
provider contract transactional_query as projection on ZMM_APP2_RV
{
  key Uuid,
      @EndUserText.label: 'Plant'
      @ObjectModel.text.element: [ 'Plantname' ]
      Plant,
      Plantname,
      Gpnum,
      @ObjectModel.text.element: [ 'Rgptypedesc' ]
      Gptype,
      @EndUserText.label: 'Vendor'
      @ObjectModel.text.element: [ 'Vendname' ]
      Vendnum,
      Vendname,
      Plnrtndate,
      Vehicleno,
      @EndUserText.label: 'Vehicle Type'
      @ObjectModel.text.element: [ 'VehTypeText' ]
      Vehicletype,
      Dispby,
      Issuedate,
      Issuedby,
      @EndUserText.label: 'Transporter'
      @ObjectModel.text.element: [ 'TransporterName' ]
      Transporterid,
      Transporter,
      Remarks,
      @Semantics.amount.currencyCode: 'Curky'
      Gpvalue,
      Curky,
      Rsngp,
      Frghtscope,
      Pcklist,
      Delmark,
      Mark,
      Mark2,
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      Createdat,
      @Semantics.user.lastChangedBy: true
      Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      Lastchangedat,
      @Semantics.largeObject:{fileName: 'Filename' ,
                                mimeType: 'Minetype',
                                contentDispositionPreference: #INLINE  }
      Zattachment,
      @Semantics.mimeType: true
      Minetype,
      Filename,
      Ebeln,
      Insurno,
      Ewabillno,
      @Semantics.quantity.unitOfMeasure : 'Uom'
      Netwgt,
      @Semantics.quantity.unitOfMeasure : 'Uom'
      Grosswgt,
      @Semantics.quantity.unitOfMeasure : 'Uom'
      Tarewgt,
      LRnumber,
      LRdate,
      Fromplace,
      Toplace,
      Uom,
      //      gateentryseqno,
      Gateno,
      Gitdat,
      Gittim,
      Gotdat,
      Gottim,
      Statustext,
      Contpr,
      Reqby,
      Reqdpt,
      Seqnum,
      Rgpnrpactualno,
      Rgptypedesc,
      VehTypeText,
      TransporterName,
    /* Associations */
    _item
}
