@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Text RE'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINTE_ITXT_RE 
as select from zmaint_itxt_db
association to parent ZMAINTE_DES as _hdr on _hdr.MaintenanceNotification =  $projection.Maintenancenotification
{
    key maintenancenotification as Maintenancenotification,
    key maintenancenotificationitem as Maintenancenotificationitem,
    maintnotifitemtext as Maintnotifitemtext,
    _hdr
}
