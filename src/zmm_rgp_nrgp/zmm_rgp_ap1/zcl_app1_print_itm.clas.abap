CLASS zcl_app1_print_itm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_APP1_PRINT_ITM IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF NOT io_request->is_data_requested(  ).
      RETURN.
    ENDIF.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        DATA(lver) = 1.
    ENDTRY.

    IF NOT line_exists( lt_range[ name = 'UUID' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.

    DATA rt_table TYPE TABLE OF zpp_apps05_citm.



    LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls_range>).

    select * from zmm_app1_itm where Uuid = @<ls_range>-low into table @data(lt_item).

*   select * from zmm_app1_itm1 where Uuid = @<ls_range>-low into table @data(lt_item).

  SORT lt_item BY uuid sno ASCENDING.

CLEAR rt_table.

LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).

  DATA(ls_result) =
    CORRESPONDING zpp_apps05_citm( <ls_item> ).

  CONCATENATE <ls_item>-plant
              <ls_item>-plantname
    INTO ls_result-plant_combined
    SEPARATED BY ' - '.

  APPEND ls_result TO rt_table.

ENDLOOP.

      io_response->set_data( rt_table ).
      io_response->set_total_number_of_records( lines( rt_table ) ).


    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
