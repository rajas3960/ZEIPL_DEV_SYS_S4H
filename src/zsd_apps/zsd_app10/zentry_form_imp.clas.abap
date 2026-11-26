CLASS zentry_form_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZENTRY_FORM_IMP IMPLEMENTATION.


 METHOD if_rap_query_provider~select.
**********************************************************************
if not io_request->is_data_requested(  ).
        RETURN.
    endif.
**********************************************************************
DATA(lo_filter) = io_request->get_filter(  ).

    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

**********************************************************************
     IF NOT line_exists( lt_range[  name = 'UUID' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
**********************************************************************
    DATA rt_table TYPE TABLE OF zsd_hce_gatesec.
    DATA: lv_uuid TYPE zsd_hce_gatesec-uuid.


**********************************************************************
  LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls>).
        lv_uuid = <ls>-low.

**********************************************************************
  select SINGLE * from zsd_app05_hdb wiTH PRIVILEGED ACCESS
        whERE uuid = @lv_uuid
        into @data(ls_gate).
**********************************************************************
      INSERT VALUE zsd_hce_gatesec(
                         uuid = ls_gate-uuid
                         gateentryid = ls_gate-gateentryid
                         vehicleno = ls_gate-vehicleno
                         gateentrydate = ls_gate-gateentryiddate
                         gateentrytime = ls_gate-gateentryidtime


                        )
                        into table rt_table.
**********************************************************************
   io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
