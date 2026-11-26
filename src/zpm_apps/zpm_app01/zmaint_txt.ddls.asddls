@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Description'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_TXT as select from zmaint_idb
{
    key maintenancenotification as Maintenancenotification,
    key maintenancenotificationitem as Maintenancenotificationitem,
    why1 as des1,
    why2 as des2,
    why3 as des3,
    why4 as des4,
    why5 as des5,
    url1 as Url1
}
