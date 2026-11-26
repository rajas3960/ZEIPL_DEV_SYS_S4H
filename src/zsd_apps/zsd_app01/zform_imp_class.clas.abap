CLASS zform_imp_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFORM_IMP_CLASS IMPLEMENTATION.


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
    DATA rt_table TYPE TABLE OF ZHEAD_FORM_CE.

**********************************************************************
    LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls_Acc>).
        data(lv_acc) = <ls_acc>-low.
**********************************************************************
        select SINGLE * from ZSD_GATE_HTB wiTH PRIVILEGED ACCESS
        whERE uuid = @lv_acc
        into @data(ls_acchd).

        INSERT VALUE ZHEAD_FORM_CE(
                        uuid = ls_acchd-uuid
                        plant = ls_acchd-plant
                        gateentrytype = ls_acchd-gateentrytype
                        )
                        into table rt_table.

**********************************************************************
    io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
