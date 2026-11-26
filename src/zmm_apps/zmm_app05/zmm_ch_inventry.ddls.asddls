@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Team Gate Entry - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_CH_INVENTRY 
provider contract transactional_query
as projection on ZMM_IH_INVENTRY
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
    Weighmentindicator,
    Materialdocument,
    Materialdocumentyear,
    @Semantics.largeObject: {   mimeType: 'Entrymimetype', 
                                fileName: 'Entryfilename', 
                                contentDispositionPreference: #INLINE }    
    Entryslipattcmt,
    Entrymimetype,
    Entryfilename,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    CheckInStatus,
    GateEntryStatus,
    MigoStatus,
    vehicletypedes,
    /* Associations */
    _Item : redirected to composition child ZMM_CI_INVENTRY
}
