@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance ITM Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMAINTE_ITM_C
  as projection on ZMAINTE_ITM_I
{
    key maintenancenotification,
    key maintenancenotificationitem,
        why1,
        why2,
        why3,
        why4,
        why5,        
        url1,
        @UI.hidden: true
        url2,
        @UI.hidden: true
        url3,
      _header : redirected to parent ZMAINTE_HDR_C
}
