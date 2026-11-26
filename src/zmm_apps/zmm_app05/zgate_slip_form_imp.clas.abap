CLASS zgate_slip_form_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZGATE_SLIP_FORM_IMP IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
********************************************************************************************************
  if not io_request->is_data_requested(  ).
        RETURN.
    endif.
******************************************************************************************************************

   DATA(lo_filter) = io_request->get_filter(  ).

    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
*******************************************************************************************************************
        IF NOT line_exists( lt_range[  name = 'UUID' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
*****************************************************************************************************************
    DATA rt_table TYPE TABLE OF ZMM_ENTRY_SLIP_CE.
    DATA: lv_uuid TYPE ZMM_ENTRY_SLIP_CE-uuid.

    data lvgateno type c length 10 .
    DATA: lv_accodoc TYPE ZFI_FORM_OUTPUT-AccountingDocument.
*****************************************************************************************************
     LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls_Acc>).
        lv_uuid = <ls_acc>-low.

************************************************************************************************************
        select SINGLE uuid,gateentryno,gateentrydate,gateentrytime,
                    vehicleno from ZMM_APP04_HDB wiTH PRIVILEGED ACCESS
        whERE uuid = @lv_uuid
        into @data(ls_gate).
*******************************************************************************************************
        INSERT VALUE ZMM_ENTRY_SLIP_CE(
                         uuid = ls_gate-uuid
                         vehicleno = ls_gate-vehicleno
                         gateentryno = ls_gate-gateentryno
                         gateentrydate = ls_gate-gateentrydate
                         gateentrytime = ls_gate-gateentrytime

                        )
                        into table rt_table.
*******************************************************************************************************
      io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
