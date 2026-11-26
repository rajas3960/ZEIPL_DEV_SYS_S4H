CLASS zloading_form_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZLOADING_FORM_IMP IMPLEMENTATION.


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
    DATA rt_table TYPE TABLE OF ZSD_CE_GATE.
    DATA: lv_uuid TYPE ZSD_CE_GATE-uuid.


**********************************************************************
  LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls>).
        lv_uuid = <ls>-low.

**********************************************************************
  select SINGLE * from zsd_app05_hdb wiTH PRIVILEGED ACCESS
        whERE uuid = @lv_uuid
        into @data(ls_gate).

**********************************************************************
   SELECT SINGLE * FROM zsd_app05_idb WITH PRIVILEGED ACCESS
          WHERE uuid = @lv_uuid
          INTO @DATA(lv_materialdes).

**********************************************************************
      INSERT VALUE ZSD_CE_GATE(
                         uuid = ls_gate-uuid
                         gateentryno = ls_gate-gateentryno
                         gateentrydate = ls_gate-gateentrydate
                         Truckno = ls_gate-vehicleno
                         Vehiclecapqty = ls_gate-vehiclecapqty
                         quality = ls_gate-quality
                         remarks = ls_gate-remarks
                         materialdesc = lv_materialdes-materialdesc


                        )
                        into table rt_table.
**********************************************************************
   io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
