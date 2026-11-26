@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Security Exit - Apps'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_IH_GEXIT
  as select from zmm_app04_hdb
  composition[0..*] of ZMM_II_GEXIT as _Item 
{
  key uuid               as Uuid,
      gateno             as Gateno,
      gatenodes          as Gatenodes,
      gateentryno        as Gateentryno,
      gateentryseqno     as Gateentryseqno,
      gateentrydate      as Gateentrydate,
      gateentrytime      as Gateentrytime,
      gateentryid        as Gateentryid,
      gateentryiddate    as Gateentryiddate,
      plant              as Plant,
      plantname          as Plantname,
      gateentryseries    as Gateentryseries,
      gateentryseriesdes as Gateentryseriesdes,
      permitno           as Permitno,
      tokenentryno       as Tokenentryno,
      erpreferenceno     as Erpreferenceno,
      trasporterid       as Trasporterid,
      trasportername     as Trasportername,
      vehicleno          as Vehicleno,
      vehicletype        as Vehicletype,
      drivername         as Drivername,
      mobile             as Mobile,
      licenseno          as Licenseno,
      experiredt         as Experiredt,
      chaseno            as Chaseno,
      address            as Address,
      challanno          as Challanno,
      challandate        as Challandate,
      lrno               as Lrno,
      lrdate             as Lrdate,
      securityremarks    as Securityremarks,
      referno            as Referno,
      referdate          as Referdate,
      fromplace          as Fromplace,
      toplace            as Toplace,
      freightorderno     as Freightorderno,
      helpername         as Helpername,
      minepassno         as Minepassno,
      forestpassno       as Forestpassno,
      rakecontno         as Rakecontno,
      createdname        as Createdname,
      weighmentindicator as Weighmentindicator,
      weighmentmcno      as Weighmentmcno,
      weighmentmcndes    as Weighmentmcndes,
      weighuom           as Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      grosswt            as Grosswt,
      weighmentdate      as Weighmentdate,
      weighmenttime      as Weighmenttime,
      imagevaldindicator as Imagevaldindicator,
      gateexitdate       as Gateexitdate,
      gateexittime       as Gateexittime,
      gateexitindicator  as Gateexitindicator,
      exitindicator      as Exitindicator,
      createdby          as Createdby,
      createdat          as Createdat,
      lastchangedby      as Lastchangedby,
      lastchangedat      as Lastchangedat,
      case
            when gateentryno is not initial then 'Gate Entry No'
            else 'Gate Entry No'
            end as GateEntryStatus,
      case
            when gateexitindicator is not initial then 'Gate Exit Completed'
            else 'Gate Exit Not Completed'
            end as ExitStatus,
      case
            when exitindicator = 'X' then 'Image Validation Completed'
            else 'Image Validation Not Completed'
            end as ImageValStatus,                        
      _Item
}
where imagevaldindicator = 'X'
