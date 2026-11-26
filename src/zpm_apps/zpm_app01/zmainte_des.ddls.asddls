@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Description'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINTE_DES
  as select from  zmaint_item_db as MN
//  left outer join ZMAINTE_TXT               as MITM on MITM.MaintenanceNotification = MN.maintenancenotification  //old one
  left outer join ZMAINT_TXT               as MITM on MITM.Maintenancenotification = MN.maintenancenotification  //new one
  composition [0..*] of ZMAINTE_ITXT_RE     as _item
{
  key MN.maintenancenotification,
      MITM.Maintenancenotificationitem,
      MITM.des1,
      MITM.des2,
      MITM.des3,
      MITM.des4,
      MITM.des5,
//      MITM.des6,
//      MITM.url1,
//      MITM.url2,
//      MITM.url3,     
      _item
}

group by
  MN.maintenancenotification,
  MITM.des1,
  MITM.des2,
  MITM.des3,
  MITM.des4,
  MITM.des5,
//  MITM.des6,
  MITM.Maintenancenotificationitem
 
