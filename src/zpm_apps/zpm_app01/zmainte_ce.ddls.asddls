@EndUserText.label: 'Maintenance Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZMAINTE_FORM_IMP_CL'
define custom entity ZMAINTE_CE
{
  key MaintenanceNotification      : abap.char( 12 );
      MaintPriority                : abap.char( 1 );
      Material                     : abap.char( 40 );
      NotificationType             : abap.char( 2 );
      NotificationText             : abap.char( 40 );
      MaintenanceOrder             : abap.char( 12 );
      MaintNotificationCode        : abap.char( 4 );
      MaintenanceWorkCenterPlant   : abap.char( 4 );
      CreationDate                 : erdat;
      LastChangeTime               : abap.tims( 6 );
      NotificationCompletionDate   : abap.dats( 8 );
      NotificationCompletionTime   : abap.tims( 6 );
      CreatedByUser                : abap.char( 12 );
      Maintnotifitemtext           : abap.char( 40 );
      MaintenancePlanningPlant     : abap.char( 4 );
      Equipmentid                  : abap.char( 18 );
      MalfunctionStartDate         : abap.dats( 8 );
      MalfunctionStartTime         : abap.tims( 6 );
      MaintObjectDowntimeDuration  : abap.char( 10);
      PlantName                    : abap.char( 30 );
      EquipmentName                : abap.char( 40 );
      TechnicalObjectDescription   : abap.char( 40 );
      WorkCenterText               : abap.char( 40 );
      LanguageKey                  : abap.char( 2 );
      BreakdownCount               : abap.char( 10 );
      AreaManager                  : abap.char( 30 );
      Broadanalysis1               : abap.char( 30 );
      Broadanalysis2               : abap.char( 30 );
      Broadanalysis3               : abap.char( 30 );
      Broadanalysis4               : abap.char( 30 );
      Broadanalysis5               : abap.char( 30 );
      Broadanalysis6               : abap.char( 30 );
      CAPA1                        : abap.char( 30 );
      CAPA2                        : abap.char( 30 );
      CAPA3                        : abap.char( 30 );
      CAPA4                        : abap.char( 30 );
      CAPA5                        : abap.char( 30 );
      CAPA6                        : abap.char( 30 );
      PersonResponsible1           : abap.char( 30 );
      PersonResponsible2           : abap.char( 30 );
      PersonResponsible3           : abap.char( 30 );
      PersonResponsible4           : abap.char( 30 );
      PersonResponsible5           : abap.char( 30 );
      PersonResponsible6           : abap.char( 30 );
      Targetdate1                  : abap.dats( 8 );
      Targetdate2                  : abap.dats( 8 );
      Targetdate3                  : abap.dats( 8 );
      Targetdate4                  : abap.dats( 8 );
      Targetdate5                  : abap.dats( 8 );
      Targetdate6                  : abap.dats( 8 );
      Completiondate1              : abap.dats( 8 );
      Completiondate2              : abap.dats( 8 );
      Completiondate3              : abap.dats( 8 );
      Completiondate4              : abap.dats( 8 );
      Completiondate5              : abap.dats( 8 );
      Completiondate6              : abap.dats( 8 );
      Teammembers1                 : abap.char( 30 );
      Teammembers2                 : abap.char( 30 );
      Teammembers3                 : abap.char( 30 );
      Teammembers4                 : abap.char( 30 );
      Teammembers5                 : abap.char( 30 );
      Teammembers6                 : abap.char( 30 );
      Actiontaken                  : abap.char( 60 );
      FinancialimpactRS            : abap.char( 30 );
      Productionloss               : abap.char( 30 );
      RootCause                    : abap.char( 60 );
      MalfunctionEffectDescription : abap.char(40);
      PersonFullName               : abap.char( 30 );
      webaddress                   : zwebadrs;
      webaddress1                  : zwebadrs;
      webaddress2                  : zwebadrs;
      webaddress3                  : zwebadrs;
      webaddress4                  : zwebadrs;
     




      @ObjectModel.filter.enabled  : false
      _item                        : association [0..*] to ZMAINTE_DES on $projection.MaintenanceNotification = _item.MaintenanceNotification;
}
