CLASS zpm_form_imp_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
    if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPM_FORM_IMP_CL IMPLEMENTATION.


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

*****************************************************************************
IF NOT line_exists( lt_range[ name = 'MAINTENANCENOTIFICATION' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
*****************************************************************************

  DATA rt_table TYPE TABLE OF ZMAINT_CUSENTITY.

***********************************07-07-2026(added extra for concatenation)**********

 DATA: lt_head TYPE TABLE OF ZMAINT_HDR.

  DATA(lv_maint) = lt_range[
                    name = 'MAINTENANCENOTIFICATION'
                  ]-range[ 1 ]-low.

SELECT *
  FROM zmaint_hdr
  WHERE maintenancenotification = @lv_maint
  INTO TABLE @DATA(mt_head).
************************************07-07-2026*****************************************


*****************************************************************************
   LOOP AT lt_range[ name = 'MAINTENANCENOTIFICATION' ]-range ASSIGNING FIELD-SYMBOL(<ls_range>).

      DATA(LV_SALES) = <ls_range>-low.

*****************************************************************************
      SELECT SINGLE * FROM ZMAINT_HDR WITH PRIVILEGED ACCESS
      WHERE MaintenanceNotification = @lv_sales
      INTO @DATA(wa_maints).

*****************************07-07-2026(added extra for concatenation)******************

   DATA:  lv_namee TYPE c LENGTH 40,
          lv_equipno TYPE c LENGTH 18.
          lv_namee = |Doc No.EIPL/TPM/REVNo { mt_head[ 1 ]-MaintenanceNotification+4 }|.


********************************************************************************
  DATA:  lv_cdate TYPE c LENGTH 30,
         lv_time  TYPE c LENGTH 20,
         lv_date  TYPE c LENGTH 20.
*         lv_cdate = |{ mt_head[ 1 ]-CreationDate } { mt_head[ 1 ]-LastChangeTime }|.


         lv_date = |{ mt_head[ 1 ]-CreationDate DATE = ISO }|.
         lv_time = |{ mt_head[ 1 ]-LastChangeTime TIME = ISO }|.
         lv_cdate = |{ lv_date } / { lv_time }|.

********************************************************************************

  DATA:  lv_cmdate TYPE c LENGTH 20,
         lv_cmtime  TYPE c LENGTH 20,
         lv_cmdatee  TYPE c LENGTH 30.
*         lv_cmdate = |{ mt_head[ 1 ]-NotificationCompletionDate } { mt_head[ 1 ]-NotificationCompletionTime }|.

		 lv_cmdate = |{ mt_head[ 1 ]-NotificationCompletionDate DATE = ISO }|.
		 lv_cmtime = |{ mt_head[ 1 ]-NotificationCompletionTime TIME = ISO }|.
		 lv_cmdatee = |{ lv_cmdate } / { lv_cmtime }|.

******************************************************************************

******************************************************************************
      SELECT SINGLE * FROM I_Plant WITH PRIVILEGED ACCESS
	  WHERE Plant = @wa_maints-MaintenanceWorkCenterPlant
	  INTO @DATA(wa_plant).

      SELECT SINGLE * FROM I_PMNotifMaintenanceData WITH PRIVILEGED ACCESS
      WHERE MaintenanceNotification = @wa_maints-MaintenanceNotification
      INTO @DATA(wa_equipno).

	  SELECT SINGLE * FROM I_EquipmentText WITH PRIVILEGED ACCESS
	  WHERE Equipment = @wa_equipno-Equipment
	  INTO @DATA(wa_desc).

	  SELECT SINGLE * FROM I_BusinessUserBasic WITH PRIVILEGED ACCESS
	  WHERE UserID = @wa_maints-CreatedByUser
	  INTO @DATA(wa_user).

	  SELECT SINGLE * FROM I_TechnicalObject WITH PRIVILEGED ACCESS
	  WHERE TechnicalObject = @wa_maints-MaintenanceNotification
	  INTO @DATA(wa_techobj).

	  SELECT SINGLE * FROM I_InspectionCodeText WITH PRIVILEGED ACCESS
	  WHERE InspectionCode = @wa_maints-MaintNotificationCode
	  INTO @DATA(wa_inspcode).

*      SELECT SINGLE * FROM I_MaintNotificationItemTP_2 WITH PRIVILEGED ACCESS
*	  WHERE MaintenanceNotification = @wa_maints-MaintenanceNotification
**	  AND MaintenanceNotificationItem = @wa_maints-MaintenanceNotificationItem
*	  INTO @DATA(wa_item).


**************************added for hours***************************************************

      DATA: lv_downtime TYPE f,
      lv_char     TYPE c LENGTH 10.

      lv_downtime = wa_equipno-MaintObjectDowntimeDuration / 3600.

      lv_char = |{ CONV i( lv_downtime ) }|.

******************************************************************************

******************************************************************************

     IF wa_maints IS NOT INITIAL.

        INSERT VALUE ZMAINT_CUSENTITY(   MaintenanceNotification     = wa_maints-MaintenanceNotification
                                         MaintPriority               = wa_maints-MaintPriority
                                         Material                    = wa_maints-Material
                                         NotificationType            = wa_maints-NotificationType
                                         NotificationText            = wa_maints-NotificationText
                                         MaintenanceOrder            = wa_maints-MaintenanceOrder
                                         MaintenanceWorkCenterPlant  = wa_maints-MaintenanceWorkCenterPlant
                                         MaintNotificationCode       = wa_maints-MaintNotificationCode
                                         PlantDes                    = wa_plant-PlantName
                                         EquipmentDes				 = wa_desc-EquipmentName
                                         EquipmentNo                 = wa_equipno-Equipment
                                         CreationDate                = wa_maints-CreationDate
                                         LastChangeTime			     = wa_maints-LastChangeTime
                                         NotificationCompletionDate = wa_maints-NotificationCompletionDate
                                         NotificationCompletionTime = wa_maints-NotificationCompletionTime
                                         MaintenanceNotificationdocno = lv_namee
                                         CreationdateTime             = lv_cdate
                                         CompletionDateTime           = lv_cmdatee
                                         MaintObjectDowntimeDuration  = lv_char
*                                         AreaManager                  = wa_equipno-yy1_areamanager_ntf
*                                         RCATeam1                     = wa_equipno-yy1_rca_team_ntf
*                                         RCATeam2                     = wa_equipno-yy1_rca_team_2_ntf
                                         PersonFullName               = wa_user-PersonFullName
                                         SuperiorTechnicalObject      = wa_techobj-SuperiorTechnicalObject
                                         InspectionCodeText           = wa_inspcode-InspectionCodeText
*                                         MaintNotifItemText           = wa_item-MaintNotifItemText
*                                         DrawupOPL                    = wa_equipno-YY1_DrawupOPL_NTF
*                                         Standardize                  = wa_equipno-YY1_Standardize_NTF
*                                         Errorproof                   = wa_equipno-YY1_ErrorProof_NTF
*                                         Correctmaint                 = wa_equipno-YY1_Correctivemaintena_NTF
*                                         Issuempinf                   = wa_equipno-YY1_IssueMPinformation_NTF
*                                         Horreplication               = wa_equipno-YY1_Horizontalreplicat_NTF
*                                         Poorbascon                   = wa_equipno-yy1_poorbasiccondition_ntf
*                                         Pooropecon                   = wa_equipno-yy1_pooroperatingcondi_ntf
*                                         Deterioration                = wa_equipno-yy1_deterioration_ntf
*                                         Weakdesign                   = wa_equipno-yy1_weakdesign_ntf
*                                         Poorskill                    = wa_equipno-yy1_poorskill_ntf
*                                         Des1                         = wa_equipno-yy1_description_1_ntf
*                                         Des2                         = wa_equipno-yy1_description_2_ntf
*                                         Des3                         = wa_equipno-yy1_description_3_ntf
*                                         Des4                         = wa_equipno-yy1_description_4_ntf
*                                         Des5                         = wa_equipno-yy1_description_5_ntf
*                                         Des6                         = wa_equipno-yy1_description_6_ntf
*                                         Perres1                      = wa_equipno-yy1_personresponsible1_ntf
*                                         Perres2                      = wa_equipno-yy1_personresponsible2_ntf
*                                         Perres3                      = wa_equipno-yy1_personresponsible3_ntf
*                                         Perres4                      = wa_equipno-yy1_personresponsible4_ntf
*                                         Perres5                      = wa_equipno-yy1_personresponsible5_ntf
*                                         Perres6                      = wa_equipno-yy1_personresponsible6_ntf
*                                         Deadline1                    = wa_equipno-yy1_deadline1_ntf
*                                         Deadline2                    = wa_equipno-yy1_deadline2_ntf
*                                         Deadline3                    = wa_equipno-yy1_deadline3_ntf
*                                         Deadline4                    = wa_equipno-yy1_deadline4_ntf
*                                         Deadline5                    = wa_equipno-yy1_deadline5_ntf
*                                         Deadline6                    = wa_equipno-yy1_deadline6_ntf
*                                         Datecomp1                    = wa_equipno-yy1_datecompleted1_ntf
*                                         Datecomp2                    = wa_equipno-yy1_datecompleted2_ntf
*                                         Datecomp3                    = wa_equipno-yy1_datecompleted3_ntf
*                                         Datecomp4                    = wa_equipno-yy1_datecompleted4_ntf
*                                         Datecomp5                    = wa_equipno-yy1_datecompleted5_ntf
*                                         Datecomp6                    = wa_equipno-yy1_datecompleted6_ntf
*                                         Countermeasure1              = wa_equipno-YY1_CounterMeasure1_NTF
*                                         Countermeasure2              = wa_equipno-YY1_CounterMeasure2_NTF
*                                         Countermeasure3              = wa_equipno-YY1_CounterMeasure3_NTF
*                                         Countermeasure4              = wa_equipno-YY1_CounterMeasure4_NTF
*                                         Countermeasure5              = wa_equipno-YY1_CounterMeasure5_NTF
*                                         Perresponse1                 = wa_equipno-yy1_personresponsible1_ntf
*                                         Perresponse2                 = wa_equipno-yy1_personresponsible2_ntf
*                                         Perresponse3                 = wa_equipno-yy1_personresponsible3_ntf
*                                         Perresponse4                 = wa_equipno-yy1_personresponsible4_ntf
*                                         Perresponse5                 = wa_equipno-yy1_personresponsible5_ntf
*                                         Targetdate1                  = wa_equipno-yy1_targetdate1_ntf
*                                         Targetdate2                  = wa_equipno-yy1_targetdate2_ntf
*                                         Targetdate3 				  = wa_equipno-yy1_targetdate3_ntf
*                                         Targetdate4 				  = wa_equipno-yy1_targetdate4_ntf
*                                         Targetdate5 				  = wa_equipno-yy1_targetdate5_ntf
*                                         Datecom1   			      = wa_equipno-yy1_datecompleted1_ntf
*                                         Datecom2   			      = wa_equipno-yy1_datecompleted2_ntf
*                                         Datecom3   			      = wa_equipno-yy1_datecompleted3_ntf
*                                         Datecom4  			          = wa_equipno-yy1_datecompleted4_ntf
*                                         Datecom5                     = wa_equipno-yy1_datecompleted5_ntf
  )

  INTO TABLE rt_table.
        io_response->set_data( rt_table ).
        io_response->set_total_number_of_records( lines( rt_table ) ).

      ENDIF.

 ENDLOOP.
  ENDMETHOD.
ENDCLASS.
