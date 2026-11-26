@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'History Card Root view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZRV_HISTORYCARD
  with parameters
    P_Start_date : datum,
    P_End_date   : datum

  as select from    I_MaintenanceOrderBasic    as Mo
    left outer join I_MaintOrderOperationBasic as mop  on  mop.MaintenanceOrder        = Mo.MaintenanceOrder
                                                       and mop.MaintOrderRoutingNumber = Mo.MaintOrderRoutingNumber
  //    left outer join I_Equipment                as eqp on eqp.Equipment = Mo.Equipment
    left outer join I_MaintOrdConfirmationCube as moc  on  moc.MaintenanceOrder          = mop.MaintenanceOrder
                                                       and moc.MaintOrderRoutingNumber   = mop.MaintOrderRoutingNumber
                                                       and moc.MaintenanceOrderOperation = mop.MaintenanceOrderOperation
    left outer join I_MaintenanceNotification  as mn   on  mn.MaintenanceOrder        = Mo.MaintenanceOrder
                                                       and mn.MaintenanceNotification = Mo.MaintenanceNotification
    left outer join I_MaintOrderComponentDEX   as mnd  on  mnd.MaintenanceOrder          = Mo.MaintenanceOrder
                                                       and mnd.MaintenanceOrderOperation = mop.MaintenanceOrderOperation
                                                       and mnd.MaintOrderRoutingNumber   = mop.MaintOrderRoutingNumber
    left outer join I_MaintenanceOrderDEX      as mnx  on  mnx.MaintenanceOrder        = Mo.MaintenanceOrder
                                                       and mnx.MaintOrderRoutingNumber = Mo.MaintOrderRoutingNumber
    left outer join I_PMNotifMaintenanceData   as pmd  on  pmd.Equipment               = Mo.Equipment
                                                       and pmd.MaintenanceNotification = Mo.MaintenanceNotification
    left outer join I_TechnicalObject          as tco  on Mo.Equipment = tco.Equipment
    left outer join I_ProductText              as pt   on  pt.Product  = mnd.Material
                                                       and pt.Language = 'E'
    left outer join I_BusinessUserBasic        as bub  on bub.UserID = Mo.CreatedByUser
    left outer join I_BusinessUserBasic        as bub1 on bub1.UserID = moc.EnteredByUser
    left outer join I_EquipmentText            as eqt  on eqt.Equipment = Mo.Equipment
  //  left outer join I_MAINTENANCENOTIFICATIONTP_2 as mtp on mtp.MaintenanceOrder = Mo.MaintenanceOrder

{

  key Mo.MaintenanceOrder                                                as order_no,
  key mop.MaintenanceOrderOperation,
      Mo.MaintOrderRoutingNumber,
      concat(
      concat(
         Mo.Equipment,'(' ),concat( eqt.EquipmentName, ')'  ))           as Equipment_Number,
      //  Mo.Equipment                                                       as Equipment_Number,
      Mo.MaintenancePlanningPlant                                        as Plant,
      Mo.MainWorkCenter,
      Mo.MaintenanceNotification                                         as Notification,
      mnx.MaintenanceOrderDesc                                           as Order_Description,
      tco.SuperiorTechnicalObject                                        as FunctionalLocation,
      cast( pmd.MaintObjectDowntimeDuration / 3600.0 as abap.dec(15,2) ) as MaintObjectDowntimeDuration,
      pmd.MaintObjDowntimeDurationUnit,
      Mo.MaintenanceOrderType                                            as Order_Type,
      case
        when Mo.MaintPriority = '1' then 'Very High'
        when Mo.MaintPriority = '2' then 'High'
        when Mo.MaintPriority = '3' then 'Medium'
        when Mo.MaintPriority = '4' then 'Low'
        else ''
        end                                                              as Priority,
      //  Mo.MaintPriority                                                   as Priority,
      Mo.MaintOrdBasicStartDate                                          as Start_date,
      Mo.MaintOrdBasicStartTime,
      Mo.MaintOrdBasicEndDate                                            as End_date,
      Mo.MaintOrdBasicEndTime,
      Mo.LatestAcceptableCompletionDate                                  as final_duedate,
      bub.PersonFullName                                                 as created_by,
      Mo.MaintOrdProcessPhaseCode                                        as process_phase,
      Mo.ResponsibleCostCenter                                           as Costcenter,
      mop.MaintenanceOrderOperation                                      as Main_order_Operation,
      mop.OperationDescription                                           as Task_performed,
      @Semantics.quantity.unitOfMeasure: 'unit_work'
      moc.ActualWorkQuantity                                             as actual_work,
      moc.ActualWorkQuantityUnit                                         as unit_work,
      bub1.PersonFullName                                                as EnteredByUser,
      moc.ConfirmationText                                               as ConfirmationText,
      //      mn.MaintNotificationCode                                           as coding,
      case
      when mn.MaintNotificationCode ='ERO' then 'Erratic Output'
      when mn.MaintNotificationCode ='VIB' then 'Vibration'
      when mn.MaintNotificationCode ='LOA' then 'Load Drop'
      when mn.MaintNotificationCode ='NOI' then 'Noise'
      when mn.MaintNotificationCode ='OHE' then 'Overheating'
      when mn.MaintNotificationCode ='OTH' then 'Other'
      when mn.MaintNotificationCode ='POW' then 'Insufficient Power'
      when mn.MaintNotificationCode ='UNK' then 'Unknown'
      else ''
      end                                                                as coding,
      case
      when mnd.QuantityWithdrawnInBaseUnit > 0
      then
      concat(
      concat(
         concat(
             pt.ProductName,  '('), ltrim( mnd.Material, '0' ) ), ')')
             else null end                                               as Material,
      //  mnd.Material,
      // pt.ProductName,
      //  @Semantics.amount.currencyCode: 'MaintOrdOpComponentCurrency'

      case
          when mnd.QuantityWithdrawnInBaseUnit > 0
          then cast(
                  mnd.MaintOrderOpComponentPrice
                  as abap.dec(15,2)
               )
          else cast(
                  0 as abap.dec(15,2))end                                as component_price,
      cast( mnd.QuantityWithdrawnInBaseUnit as abap.dec(15,3) )          as qty_withdrawn,
      mnd.MaintOrdOpComponentCurrency
      //      $parameters.P_Start_date as Start_datee,
      //      $parameters.P_End_date as End_datee

}
where
      Mo.MaintOrdBasicStartDate >= $parameters.P_Start_date
  and Mo.MaintOrdBasicStartDate <= $parameters.P_End_date
