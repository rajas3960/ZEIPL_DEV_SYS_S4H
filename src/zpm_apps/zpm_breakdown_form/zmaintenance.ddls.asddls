@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Description'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINTENANCE 
as select from I_MaintenanceNotification as MN
left outer join ZMAINT_DES as MITM on MITM.MaintenanceNotification = MN.MaintenanceNotification
composition[0..*] of ZMAINT_TABLE_ir as _item
//composition[0..*] of ZMAINT_CONT_DES as _itm


{
    key MN.MaintenanceNotification,
        MITM.maintenancenotificationitem,
        MITM.des1,
        MITM.des2,
        MITM.des3,
        MITM.des4,
        MITM.des5,
        MITM.des6,
    //key MITM.maintenancenotificationcause,
//    key MITM.maintenancenotificationitem,
//        MITM.maintnotificationcausecode as des1


//max(
//    case
//      when MITM.maintenancenotificationcause = '0005'
//      then MITM.maintnotifcausetext
//      else ''
//    end
//) as des1,
//
//max(
//    case
//      when MITM.maintenancenotificationcause = '0004'
//      then MITM.maintnotifcausetext
//      else ''
//    end
//) as des2,
//
//max(
//    case
//      when MITM.maintenancenotificationcause = '0003'
//      then MITM.maintnotifcausetext
//      else ''
//    end
//) as des3,
//
//max(
//    case
//      when MITM.maintenancenotificationcause = '0002'
//      then MITM.maintnotifcausetext
//      else ''
//    end
//) as des4,
//
//max(
//    case
//      when MITM.maintenancenotificationcause = '0001'
//      then MITM.maintnotifcausetext
//      else ''
//    end
//) as des5,
_item
//_itm
}
group by MN.MaintenanceNotification,
    MITM.des1,
    MITM.des2,
    MITM.des3,
    MITM.des4,
    MITM.des5,
    MITM.des6,
    MITM.maintenancenotificationitem

