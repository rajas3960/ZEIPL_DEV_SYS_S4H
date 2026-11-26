@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCV_HISTORYCARD
  //  provider contract transactional_query
  //  as projection on ZRV_HISTORYCARD
  with parameters
    @Environment.systemField: #SYSTEM_DATE
    P_Start_date : sydate,
    P_End_date   : sydate
  as select from ZRV_HISTORYCARD(P_Start_date :$parameters.P_Start_date,P_End_date:$parameters.P_End_date)
{
  key order_no,
  key MaintenanceOrderOperation,
      MaintOrderRoutingNumber,
      Equipment_Number,
      Plant,
      MainWorkCenter,
      Notification,
      Order_Description,
      FunctionalLocation,
      MaintObjectDowntimeDuration,
      MaintObjDowntimeDurationUnit,
      Order_Type,
      Priority,
      Start_date,
      MaintOrdBasicStartTime,
      End_date,
      MaintOrdBasicEndTime,
      final_duedate,
      created_by,
      process_phase,
      Costcenter,
      Main_order_Operation,
      Task_performed,
      @Semantics.quantity.unitOfMeasure: 'unit_work'
      actual_work,
      unit_work,
      EnteredByUser,
      ConfirmationText,
      coding,
      Material,
   //   @Semantics.amount.currencyCode: 'MaintOrdOpComponentCurrency'
      component_price,
      qty_withdrawn,
      MaintOrdOpComponentCurrency
}
