@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Test'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_DES
  as select distinct from    I_MaintenanceNotification as MN
  //left outer join zmaint_itm_db as MITM on MITM.maintenancenotification = MN.MaintenanceNotification
    left outer join zmaint_itm_db             as WHY1 on  WHY1.maintenancenotification    = MN.MaintenanceNotification
                                                      and WHY1.maintnotificationcausecode = 'WHY1'

    left outer join zmaint_itm_db             as WHY2 on  WHY2.maintenancenotification    = MN.MaintenanceNotification
                                                      and WHY2.maintenancenotificationitem = WHY1.maintenancenotificationitem
                                                      and WHY2.maintnotificationcausecode = 'WHY2'

    left outer join zmaint_itm_db             as WHY3 on  WHY3.maintenancenotification    = MN.MaintenanceNotification
                                                      and WHY3.maintenancenotificationitem = WHY1.maintenancenotificationitem
                                                      and WHY3.maintnotificationcausecode = 'WHY3'

    left outer join zmaint_itm_db             as WHY4 on  WHY4.maintenancenotification    = MN.MaintenanceNotification
                                                      and WHY4.maintenancenotificationitem = WHY1.maintenancenotificationitem
                                                      and WHY4.maintnotificationcausecode = 'WHY4'

    left outer join zmaint_itm_db             as WHY5 on  WHY5.maintenancenotification    = MN.MaintenanceNotification
                                                      and WHY5.maintenancenotificationitem = WHY1.maintenancenotificationitem
                                                      and WHY5.maintnotificationcausecode = 'WHY5'
                                                      
   left outer join zmaint_itm_db             as WHYV on  WHYV.maintenancenotification    = MN.MaintenanceNotification
                                                      and WHYV.maintenancenotificationitem = WHY1.maintenancenotificationitem
                                                      and WHYV.maintnotificationcausecode = 'WHYV'
{

  key  MN.MaintenanceNotification,
  key  WHY1.maintenancenotificationitem,
  key  WHY1.maintenancenotificationcause,
       WHY1.maintnotifcausetext         as des1,
       WHY2.maintnotifcausetext         as des2,
       WHY3.maintnotifcausetext         as des3,
       WHY4.maintnotifcausetext         as des4,
       WHY5.maintnotifcausetext         as des5,
       WHYV.maintnotifcausetext         as des6

}
group by
     MN.MaintenanceNotification,
     WHY1.maintenancenotificationitem,
     WHY1.maintenancenotificationcause,
     WHY1.maintnotifcausetext,
     WHY2.maintnotifcausetext,
     WHY3.maintnotifcausetext,
     WHY4.maintnotifcausetext,
     WHY5.maintnotifcausetext,
     WHYV.maintnotifcausetext 
     
