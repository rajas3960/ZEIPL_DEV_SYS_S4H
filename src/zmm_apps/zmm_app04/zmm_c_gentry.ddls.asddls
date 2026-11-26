@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Entry - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_C_GENTRY 
provider contract transactional_query
as projection on ZMM_I_GENTRY
{
    key Uuid,
    @ObjectModel.text.element: [ 'Gatenodes' ]
    Gateno,
    Gatenodes,
    Gateentryno,
    Gateentryseqno,
    Gateentrydate,
    Gateentrytime,
    Gateentryid,
    Gateentryiddate,
    @ObjectModel.text.element: [ 'Plantname' ]    
    Plant,
    Plantname,
    @ObjectModel.text.element: [ 'Gateentryseriesdes' ]    
    Gateentryseries,
    Gateentryseriesdes,
    Permitno,
    Tokenentryno,
    Erpreferenceno,
    @ObjectModel.text.element: [ 'Trasportername' ]    
    Trasporterid,
    Trasportername,
    Vehicleno,
    @ObjectModel.text.element: [ 'vehicletypedes' ]        
    Vehicletype,
    Drivername,
    Mobile,
    Licenseno,
    Experiredt,
    Chaseno,
    Address,
    Challanno,
    Challandate,
    Lrno,
    Lrdate,
    Securityremarks,
    Referno,
    Referdate,
    Fromplace,
    Toplace,
    Freightorderno,
    Helpername,
    Minepassno,
    Forestpassno,
    Rakecontno,
    Createdname,
    Engineno,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    vehicletypedes,
    GateIDStatus,
    GateIDName
}
