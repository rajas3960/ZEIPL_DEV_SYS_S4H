@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Weighment Recording - Head Apps'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_IH_WEIGHT
  as select from zsd_app05_hdb as a
  composition [0..*] of ZSD_II_WEIGHT as _Item
{
  key a.uuid                 as Uuid,
      a.gateno               as Gateno,
      a.gatenodes            as Gatenodes,
      a.plant                as Plant,
      a.plantname            as Plantname,
      a.gateentryid          as Gateentryid,
      a.gateentryiddate      as Gateentryiddate,
      a.gateentryidtime      as Gateentryidtime,
      a.gateentrytype        as Gateentrytype,
      a.gateentrytypetext    as Gateentrytypetext,
      a.gateentryno          as Gateentryno,
      a.gateentrysequence    as Gateentrysequence,
      a.gateentrydate        as Gateentrydate,
      a.gateentrytime        as Gateentrytime,
      a.transportid          as Transportid,
      a.transportname        as Transportname,
      a.vehicleno            as Vehicleno,
      a.packingdetails       as Packingdetails,
      a.dispinstrdetails     as Dispinstrdetails,
      a.contactdetails       as Contactdetails,
      a.drivername           as Drivername,
      a.driveraddress        as Driveraddress,
      a.driverlicensenumber  as Driverlicensenumber,
      a.drivermobile         as Drivermobile,
      a.remarks              as Remarks,
      a.customer             as Customer,
      a.customername         as Customername,
      a.fromplace            as Fromplace,
      a.billingfrom          as Billingfrom,
      a.consignee            as Consignee,
      a.billto               as Billto,
      a.broker               as Broker,
      a.doremark             as Doremark,

      a.division             as Division,
      a.attachment           as Attachment,
      a.mimetype             as Mimetype,
      a.filename             as Filename,
      a.weigmentindicator    as Weigmentindicator,
      a.weighmentindicator   as Weighmentindicator,
      a.weighmentmcno        as Weighmentmcno,
      a.weighmentmcndes      as Weighmentmcndes,
      a.weighmentdate        as Weighmentdate,
      a.weighmenttime        as Weighmenttime,
      a.weighuom             as Weighuom,
      @Semantics.quantity.unitOfMeasure: 'WEIGHUOM'
      a.tarewt               as Tarewt,
      a.transferexit         as Transferexit,
      a.deliveryno           as Deliveryno,
      a.materialdocument     as Materialdocument,
      a.materialdocumentyear as Materialdocumentyear,
      a.deliyindicator       as Deliyindicator,
      a.gateexittime         as Gateexittime,
      a.imagevalid           as Imagevalid,
      a.exitindic            as Exitindic,
      a.gateexitdate         as Gateexitdate,
      a.pickqtyindicator     as Pickqtyindicator,
      a.giindicator          as Giindicator,
      a.billingdocument      as Billingdocument,
      a.billingdocumentdate  as billingdocumentdate,
      a.einvoiceno           as Einvoiceno,
      a.einvoicedate         as Einvoicedate,
      a.ewaybillno           as Ewaybillno,
      a.ewaybilldate         as Ewaybilldate,
      a.picqtindicator 	as Picqtindicator,
      a.loadendindi as Loadendindi,
      a.attachmentwt        as Attachmentwt,
      a.filenamewt          as Filenamewt,
      a.mimetypewt          as Mimetypewt,
      a.imagecount		  as Imagecount,
      a.cancelgateentry as Cancelgateentry,
      a.actualgidate    as Actualgidate,
      @Semantics.user.createdBy: true
      a.createdby            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat            as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby        as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat        as Lastchangedat,
      case
            when a.cancelgateentry = 'X' then 'Gate Entry Cancelled'
            else 'Gate Entry Active'
            end as Gateentrystatus,
            
      case  when a.cancelgateentry = 'X' then 1
            else 3 end  as Criticality,
      
      _Item
}
where
  a.vehicleno is not initial and a.gateentryno is not initial
