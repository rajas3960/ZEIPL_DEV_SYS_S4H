@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance ITM Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINTE_ITM_I
  as select from ZMAINTE_ITM
  association to parent ZMAINTE_HDR_I as _header on $projection.maintenancenotification = _header.MaintenanceNotification
{
    key maintenancenotification,
    key maintenancenotificationitem,
        why1,
        why2,
        why3,
        why4,
        why5,        
        url1,
        url2,
        url3,
      _header

}
