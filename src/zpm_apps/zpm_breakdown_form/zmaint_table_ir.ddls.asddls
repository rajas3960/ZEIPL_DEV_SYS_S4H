@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Description Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_TABLE_ir as select from zmaint_ides_db 
association to parent ZMAINTENANCE as _hdr on _hdr.MaintenanceNotification =  $projection.Maintenancenotification
//                                           and _hdr.maintenancenotificationitem = $projection.Maintenancenotificationitem
{
 key maintenancenotification as Maintenancenotification,
 key maintenancenotificationitem as Maintenancenotificationitem,
 maintnotifitemtext as Maintnotifitemtext,
 _hdr
}
