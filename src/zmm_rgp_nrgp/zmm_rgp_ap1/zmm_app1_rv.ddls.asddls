@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RGP/NRGP Outword Entry - RE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZMM_APP1_RV 
  as select from zmm_app1_tb1 as a

//   left outer join zmm_app1_chtb as c on c.uuid = a.uuid

    left outer join zmm_app1_chtb1 as c on c.uuid = a.uuid
  association [1..1] to ZAPP2_TRANSPORT     as Trans on a.transporterid = Trans.Supplier    
  association [0..*] to ZI_GPTYPE     as _gptyp on $projection.Gptype = _gptyp.value_low
  association [0..*] to ZMM_APP2_VEHICLE     as Vehtyp on $projection.Vehicletype = Vehtyp.value_low  

  composition [0..*] of ZMM_APP1_IV1 as _Item1 
  


{
  key a.uuid          as Uuid,
      a.plant         as Plant,
      a.plantname     as Plantname,
      a.gpnum         as Gpnum,
      a.gptype        as Gptype,
      a.vendnum       as Vendnum, 
      a.vendname      as Vendname,
      a.plnrtndate    as Plnrtndate,
      a.vehicleno     as Vehicleno,
      a.vehicletype   as Vehicletype,
      a.dispby        as Dispby,
      a.issuedate     as Issuedate,
      a.issuedby      as Issuedby,
      a.transporter   as Transporter,
      a.transporterid as Transporterid,
      a.remarks       as Remarks,
      @Semantics.amount.currencyCode: 'Curky'
      a.gpvalue       as Gpvalue,
      a.curky         as Curky,
      a.rsngp         as Rsngp, 
      a.particular    as particular,
      a.frghtscope    as Frghtscope,
      a.pcklist       as Pcklist,
      a.delmark       as Delmark,
      a.mark          as Mark,
      a.mark2        as Mark2,
      @Semantics.user.createdBy: true
      a.createdby     as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat     as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat as Lastchangedat,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{fileName: 'Filename' ,
                                mimeType: 'Minetype',
                                contentDispositionPreference: #INLINE
                                 }
      a.zattachment   as Zattachment,
      @Semantics.mimeType: true
      a.minetype      as Minetype,
      a.filename      as Filename,
      a.ebeln         as Ebeln,
      a.insurno       as Insurno,
      a.ewabillno     as Ewabillno,
      @Semantics.quantity.unitOfMeasure : 'Uom'
      a.netwgt        as Netwgt,
      @Semantics.quantity.unitOfMeasure : 'Uom'
      a.grosswgt      as Grosswgt,
      @Semantics.quantity.unitOfMeasure : 'Uom'
      a.tarewgt       as Tarewgt,
       a.lrnumber    as LRnumber,
       a.lrdate      as LRdate,
       a.fromplace   as Fromplace,
       a.toplace     as Toplace,
      a.uom           as Uom,
//      a.gateentryseqno as gateentryseqno,
      a.gateno        as Gateno,
      a.gitdat        as Gitdat,
      a.gittim        as Gittim,
      a.gotdat        as Gotdat,
      a.gottim        as Gottim,
      a.statustext    as Statustext,
      a.contpr        as Contpr,
      a.reqby         as Reqby,
      a.reqdpt        as Reqdpt,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{fileName: 'Cfilename' ,
                                mimeType: 'Cminetype',
                                contentDispositionPreference: #INLINE
                                 }
      c.zattachment   as Pdfattchement,
      c.filename      as Cfilename,
      c.minetype      as Cminetype,
      a.seqnum as Seqnum,
      a.rgpnrpactualno as Rgpnrpactualno,
      _Item1,
      _gptyp.text as Rgptypedesc,
      Vehtyp.text as VehTypeText,
      Trans.SupplierName as TransporterName
}
//////where
//////  a.mark = 'C'
