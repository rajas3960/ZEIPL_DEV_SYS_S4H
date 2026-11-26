CLASS zmainte_form_imp_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zmainte_form_imp_cl IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF NOT io_request->is_data_requested(  ).
      RETURN.
    ENDIF.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        DATA(lo_error) = 1.
    ENDTRY.
*********************************************************************
    IF NOT line_exists( lt_range[ name = 'MAINTENANCENOTIFICATION' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
*********************************************************************
    DATA rt_table TYPE TABLE OF zmainte_ce.
*********************************************************************
    LOOP AT lt_range[ name = 'MAINTENANCENOTIFICATION' ]-range ASSIGNING FIELD-SYMBOL(<ls_range>).

      DATA(lv_sales) = <ls_range>-low.
*********************************************************************
      SELECT SINGLE * FROM zmainte_hdr WITH PRIVILEGED ACCESS
      WHERE MaintenanceNotification = @lv_sales
      INTO @DATA(wa_maints).

      SELECT SINGLE MaintenancePlanningPlant,Equipment,
                    MalfunctionEffect,
                    MalfunctionStartDate,MalfunctionStartTime,
                    MaintObjectDowntimeDuration,MaintenanceObjectIsDown, yy1_hodareamanager_ntf,
                    yy1_capa1_ntf,yy1_capa2_ntf,yy1_capa3_ntf,yy1_capa4_ntf,yy1_capa5_ntf,yy1_capa6_ntf,
                    yy1_completiondate1_ntf,yy1_completiondate2_ntf,yy1_completiondate3_ntf,yy1_completiondate4_ntf,yy1_completiondate5_ntf,yy1_completiondate6_ntf,
                    yy1_targetdate_ntf,yy1_targetdate2_ntf,yy1_targetdate3_ntf,yy1_targetdate4_ntf,yy1_targetdate5_ntf,yy1_targetdate6_ntf,
                    yy1_teammember1_ntf,yy1_teammembers2_ntf,yy1_teammember3_ntf,yy1_teammember4_ntf,yy1_teammember5_ntf,
                    yy1_personresponsible1_ntf,yy1_personresponsible2_ntf,yy1_personresponsible3_ntf,yy1_personresponsible4_ntf,yy1_personresponsible5_ntf,yy1_personresponsible6_ntf,
                    yy1_poorbasiccondition_ntf,yy1_pooroperatingcondi_ntf,yy1_equipmentdeteriora_ntf,yy1_weakdesign_ntf,yy1_skillrelated_ntf,yy1_others_ntf,
                    yy1_actiontaken_ntf,yy1_financialimpactinr_ntf,yy1_productionloss_ntf,yy1_rootcause_ntf

      FROM I_PMNotifMaintenanceData
      WITH PRIVILEGED ACCESS
      WHERE MaintenanceNotification = @wa_maints-MaintenanceNotification
      INTO @DATA(wa_equipno).

*********************************************************************
      "Added for breakdown count
      IF wa_equipno-MaintenanceObjectIsDown IS INITIAL.
        CONTINUE.
      ENDIF.
*********************************************************************
      SELECT COUNT(*)
        FROM I_PMNotifMaintenanceData
        WITH PRIVILEGED ACCESS
        WHERE Equipment          = @wa_equipno-Equipment
          AND MaintenanceObjectIsDown = 'X'
        INTO @DATA(lv_breakdown_cnt).
*********************************************************************

      SELECT SINGLE Plant,PlantName FROM I_Plant
      WITH PRIVILEGED ACCESS
	  WHERE Plant = @wa_equipno-MaintenancePlanningPlant
	  INTO @DATA(wa_plant).
      	
      SELECT SINGLE Equipment,EquipmentName
      FROM I_EquipmentTP	
      WITH PRIVILEGED ACCESS
      WHERE Equipment = @wa_equipno-Equipment
      INTO @DATA(wa_equipment).
      	
      SELECT SINGLE WorkCenterInternalID, WorkCenterText FROM I_WorkCenterText
      WITH PRIVILEGED ACCESS
      WHERE WorkCenterInternalID = @wa_maints-WorkCenterInternalID
      INTO @DATA(wa_workcenter).

      SELECT SINGLE BusinessPartner,CreatedByUser,PersonFullName FROM I_BusinessUserBasic
      WITH PRIVILEGED ACCESS
      WHERE UserID = @wa_maints-CreatedByUser
      INTO @DATA(wa_user).
**********************************************************************
      " Malfunction text
      DATA: lv_malfunction_effect TYPE c LENGTH 40.
      CASE wa_equipno-MalfunctionEffect.

        WHEN '1'.
          lv_malfunction_effect = 'No effect'.
        WHEN '2'.
          lv_malfunction_effect = 'Production restricted'.
        WHEN '3'.
          lv_malfunction_effect = 'Production breakdown'.
        WHEN OTHERS.
          CLEAR lv_malfunction_effect.

      ENDCASE.

*********************************************************************
      " Added for Area
      TYPES: BEGIN OF ty_technical_object,
               FunctionalLocationLabelName TYPE i_equipmenttp-FunctionalLocationLabelName,
               TechnicalObjectDescription  TYPE i_technicalobjecttext-TechnicalObjectDescription,
             END OF ty_technical_object.

      DATA: lt_technical_object  TYPE TABLE OF ty_technical_object,
            wa_techobj1          TYPE ty_technical_object,
            lv_objectdescription TYPE i_technicalobjecttext-TechnicalObjectDescription.

      SELECT
         a~FunctionalLocationLabelName,
         b~TechnicalObjectDescription
       FROM i_equipmenttp AS a
       INNER JOIN i_technicalobjecttext AS b
         ON a~FunctionalLocationLabelName = b~TechnicalObject
       WHERE a~Equipment = @wa_equipno-Equipment
         AND b~Language = 'E'
       INTO TABLE @lt_technical_object.

      IF lt_technical_object IS NOT INITIAL.

        READ TABLE lt_technical_object
          INTO wa_techobj1
          INDEX 1.

        IF sy-subrc = 0.
          lv_objectdescription = wa_techobj1-TechnicalObjectDescription.
        ENDIF.
      ENDIF.
      	
*********************************************************************	
      " Added for Minutes
      DATA: lv_downtime TYPE p LENGTH 16 DECIMALS 2,
            lv_char     TYPE c LENGTH 10.

      lv_downtime = wa_equipno-MaintObjectDowntimeDuration / 60.
      lv_char = |{ CONV i( lv_downtime ) } mins|.
*********************************************************************
      IF wa_maints IS NOT INITIAL.

        INSERT VALUE zmainte_ce(   MaintenanceNotification     = wa_maints-MaintenanceNotification
                                   MaintPriority               = wa_maints-MaintPriority
                                   Material                    = wa_maints-Material
                                   NotificationType            = wa_maints-NotificationType
                                   NotificationText		       = wa_maints-NotificationText
                                   MaintenanceOrder  		   = wa_maints-MaintenanceOrder
                                   MaintNotificationCode	   = wa_maints-MaintNotificationCode
                                   MaintenanceWorkCenterPlant  = wa_maints-MaintenanceWorkCenterPlant
                                   CreationDate				   = wa_maints-CreationDate
                                   LastChangeTime			   = wa_maints-LastChangeTime
                                   NotificationCompletionDate  = wa_maints-NotificationCompletionDate
                                   NotificationCompletionTime  = wa_maints-NotificationCompletionTime
                                   MaintenancePlanningPlant    = wa_equipno-MaintenancePlanningPlant
                                   Equipmentid				   = wa_equipno-Equipment
                                   MalfunctionStartDate 	   = wa_equipno-MalfunctionStartDate
                                   MalfunctionStartTime		   = wa_equipno-MalfunctionStartTime
                                   MaintObjectDowntimeDuration = lv_char
                                   PlantName				   = wa_plant-PlantName
								   EquipmentName			   = wa_equipment-EquipmentName
                                   WorkCenterText              = wa_workcenter-WorkCenterText
                                   TechnicalObjectDescription  = lv_objectdescription
                                   BreakdownCount              = lv_breakdown_cnt
                                   AreaManager                 = wa_equipno-YY1_HODAreaManager_NTF
                                   Broadanalysis1              = wa_equipno-YY1_Poorbasiccondition_NTF
                                   Broadanalysis2              = wa_equipno-YY1_Pooroperatingcondi_NTF
                                   Broadanalysis3              = wa_equipno-YY1_Equipmentdeteriora_NTF
                                   Broadanalysis4              = wa_equipno-YY1_Weakdesign_NTF
                                   Broadanalysis5              = wa_equipno-YY1_Skillrelated_NTF
                                   Broadanalysis6              = wa_equipno-YY1_Others_NTF
                                   capa1                       = wa_equipno-yy1_capa1_ntf
                                   capa2                       = wa_equipno-yy1_capa2_ntf
                                   capa3                       = wa_equipno-yy1_capa3_ntf
                                   capa4                       = wa_equipno-yy1_capa4_ntf
                                   capa5                       = wa_equipno-yy1_capa5_ntf
                                   capa6                       = wa_equipno-yy1_capa6_ntf
                                   PersonResponsible1          = wa_equipno-yy1_personresponsible1_ntf
                                   PersonResponsible2          = wa_equipno-yy1_personresponsible2_ntf
                                   PersonResponsible3          = wa_equipno-yy1_personresponsible3_ntf
                                   PersonResponsible4          = wa_equipno-yy1_personresponsible4_ntf
                                   PersonResponsible5          = wa_equipno-yy1_personresponsible5_ntf
                                   PersonResponsible6          = wa_equipno-yy1_personresponsible6_ntf
                                   Targetdate1                 = wa_equipno-yy1_targetdate_ntf
                                   Targetdate2                 = wa_equipno-yy1_targetdate2_ntf
                                   Targetdate3                 = wa_equipno-yy1_targetdate3_ntf
                                   Targetdate4                 = wa_equipno-yy1_targetdate4_ntf
                                   Targetdate5                 = wa_equipno-yy1_targetdate5_ntf
                                   Targetdate6                 = wa_equipno-yy1_targetdate6_ntf
                                   Completiondate1             = wa_equipno-yy1_completiondate1_ntf
                                   Completiondate2             = wa_equipno-yy1_completiondate2_ntf
                                   Completiondate3             = wa_equipno-yy1_completiondate3_ntf
                                   Completiondate4             = wa_equipno-yy1_completiondate4_ntf
                                   Completiondate5             = wa_equipno-yy1_completiondate5_ntf
                                   Completiondate6             = wa_equipno-yy1_completiondate6_ntf
                                   Teammembers1                = wa_equipno-yy1_teammember1_ntf
                                   Teammembers2                = wa_equipno-yy1_teammembers2_ntf
                                   Teammembers3                = wa_equipno-yy1_teammember3_ntf
                                   Teammembers4                = wa_equipno-yy1_teammember4_ntf
                                   Teammembers5                = wa_equipno-yy1_teammember5_ntf
                                   Actiontaken				   = wa_equipno-yy1_actiontaken_ntf
                                   FinancialimpactRS           = wa_equipno-yy1_financialimpactinr_ntf
                                   Productionloss              = wa_equipno-YY1_Productionloss_NTF
                                   RootCause                   = wa_equipno-YY1_Rootcause_NTF
                                   PersonFullName               = wa_user-PersonFullName
                                   MalfunctionEffectDescription = lv_malfunction_effect
                                   webaddress                   = wa_maints-webaddress
                                   webaddress1                  = wa_maints-webaddress1
                                   webaddress2                  = wa_maints-webaddress2
                                   webaddress3                  = wa_maints-webaddress3
                                   webaddress4                  = wa_maints-webaddress4


                                    )



       INTO TABLE rt_table.
      ENDIF.

      CLEAR: lv_breakdown_cnt, lv_char, lv_objectdescription.

    ENDLOOP.

    io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
  ENDMETHOD.
ENDCLASS.
