CLASS zdemo_vh_cls DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDEMO_VH_CLS IMPLEMENTATION.


 METHOD if_rap_query_provider~select.

    DATA: lt_result        TYPE TABLE OF ZDEMO_VH,
          lv_total_records TYPE int8,
          lv_top           TYPE int8,
          lv_skip          TYPE int8,
          lv_filter        TYPE string.

    " Get paging details
    lv_top  = io_request->get_paging( )->get_page_size( ).
    lv_skip = io_request->get_paging( )->get_offset( ).

    " Get filter condition
    lv_filter = io_request->get_filter( )->get_as_sql_string( ).

    " Get total record count
    IF io_request->is_total_numb_of_rec_requested( ).

      SELECT COUNT( * )
        FROM zdemo
        WHERE (lv_filter)
          AND GLAccount IS NOT INITIAL
        INTO @lv_total_records.

      io_response->set_total_number_of_records(
        lv_total_records
      ).

    ENDIF.

    " Fetch data
    IF io_request->is_data_requested( ).

      IF lv_top > 0.

        SELECT GLAccount,
               GLAccountName
          FROM zdemo
          WHERE (lv_filter)
            AND GLAccount IS NOT INITIAL
          ORDER BY  GLAccount ASCENDING
          INTO CORRESPONDING FIELDS OF TABLE @lt_result
          OFFSET @lv_skip
          UP TO @lv_top ROWS.

      ELSE.

        SELECT GLAccount,
               GLAccountName
          FROM ZDEMO
          WHERE (lv_filter)
            AND GLAccount IS NOT INITIAL
          ORDER BY GLAccount ASCENDING
          INTO CORRESPONDING FIELDS OF TABLE @lt_result.

      ENDIF.

      io_response->set_data( lt_result ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
