@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Weighment Flag Master Projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_CH_WMT_FLAG 
provider contract transactional_query
as projection on ZMM_IH_WMT_FLAG
{
    @ObjectModel.text.element: [ 'Gateentryseriesdes' ]
    key Gateentryseries,
    @ObjectModel.text.element: [ 'Materialgroupdes' ]
    key Materialgroup,
    Gateentryseriesdes,
    Materialgroupdes,
    Weighmentflag,
    Challanqtyflag,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat
}
