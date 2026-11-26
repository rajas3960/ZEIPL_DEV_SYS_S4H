@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Entry - Apps'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_I_GENTRY 
as select from zmm_app04_hdb as a
left outer join ZMM_VEHICLE_VH as b on b.value_low = a.vehicletype
{
key a.uuid                  as Uuid,
a.gateno                    as Gateno,
a.gatenodes                 as Gatenodes,
a.gateentryno               as Gateentryno,
a.gateentryseqno            as Gateentryseqno,
a.gateentrydate             as Gateentrydate,
a.gateentrytime             as Gateentrytime,
a.gateentryid               as Gateentryid,
a.gateentryiddate           as Gateentryiddate,
a.plant                     as Plant,
a.plantname                 as Plantname,
a.gateentryseries           as Gateentryseries,
a.gateentryseriesdes        as Gateentryseriesdes,
a.permitno                  as Permitno,
a.tokenentryno              as Tokenentryno,
a.erpreferenceno            as Erpreferenceno,
a.trasporterid              as Trasporterid,
a.trasportername            as Trasportername,
a.vehicleno                 as Vehicleno,
a.vehicletype               as Vehicletype,
a.drivername                as Drivername,
a.mobile                    as Mobile,
a.licenseno                 as Licenseno,
a.experiredt                as Experiredt,
a.chaseno                   as Chaseno,
a.address                   as Address,
a.challanno                 as Challanno,
a.challandate               as Challandate,
a.lrno                      as Lrno,
a.lrdate                    as Lrdate,
a.securityremarks           as Securityremarks,
a.referno                   as Referno,
a.referdate                 as Referdate,
a.fromplace                 as Fromplace,
a.toplace                   as Toplace,
a.freightorderno            as Freightorderno,
a.helpername                as Helpername,
a.minepassno                as Minepassno,
a.forestpassno              as Forestpassno,
a.rakecontno                as Rakecontno,
a.createdname               as Createdname,
a.engineno                  as Engineno,
@Semantics.user.createdBy: true
a.createdby                 as Createdby,
@Semantics.systemDateTime.createdAt: true
a.createdat                 as Createdat,
@Semantics.user.lastChangedBy: true
a.lastchangedby             as Lastchangedby,
@Semantics.systemDateTime.lastChangedAt: true
a.lastchangedat             as Lastchangedat,
b.text as vehicletypedes,
case
    when a.gateentryid is not initial then 'Gate ID Created'
    else 'Gate ID Not Created'
    end as GateIDStatus,
case
    when a.gateentryid is not initial then 'Gate ID'
    else 'Gate ID'
    end as GateIDName    
}
