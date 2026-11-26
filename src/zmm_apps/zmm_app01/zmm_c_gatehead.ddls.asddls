@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Gate Entry - Apps Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_C_GATEHEAD 
provider contract transactional_query
as projection on ZMM_I_GATEHEAD
{
    key Uuid,
    Gateentryno,
    Gateentryseqno,
    Gateentrydate,    
    Gateentrytime,
    Gateentryid,
    Gateentryiddate,
    @ObjectModel.text.element: ['Companyname']
    Companycode,
    Companyname,
    @ObjectModel.text.element: ['Gateentryseriesdes']    
    Gateentryseries,
    @ObjectModel.text.element: ['Gateentrytypedes']    
    Gateentrytype,
    Gateentryseriesdes,
    Gateentrytypedes,
    Permitno,
    Tokenentryno,
    Erpreferenceno,
    @ObjectModel.text.element: ['Trasportername']    
    Trasporterid,
    Trasportername,
    Vehicleno,
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
    Ewaybillno,
    Ewaybilldate,
    Securityremarks,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _POHEAD : redirected to composition child ZMM_C_PGATEHEAD ,
    _POITEM : redirected to composition child ZMM_C_PGATEITEM
}
