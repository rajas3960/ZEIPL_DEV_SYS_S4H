CLASS zcl_mm_fo_vh_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    METHODS search_condition
      IMPORTING iv_search       TYPE string
      RETURNING VALUE(rv_where) TYPE string.
ENDCLASS.



CLASS ZCL_MM_FO_VH_QUERY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA lt_data TYPE STANDARD TABLE OF zmm_fo_vh WITH EMPTY KEY.

    " filter from the UI ($filter); element names = CTE column names
    DATA lv_where TYPE string.
    TRY.
        lv_where = io_request->get_filter( )->get_as_sql_string( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR lv_where.
    ENDTRY.

    " free-text search in the value help dialog
    DATA(lv_search) = search_condition( io_request->get_search_expression( ) ).
    IF lv_search IS NOT INITIAL.
      lv_where = COND #( WHEN lv_where IS INITIAL THEN lv_search
                         ELSE |( { lv_where } ) AND { lv_search }| ).
    ENDIF.
    IF lv_where IS INITIAL.
      lv_where = `1 = 1`.
    ENDIF.

    " sorting
    DATA lv_order TYPE string.
    LOOP AT io_request->get_sort_elements( ) INTO DATA(ls_sort).
      lv_order = lv_order && COND #( WHEN lv_order IS NOT INITIAL THEN `, ` )
                 && ls_sort-element_name
                 && COND #( WHEN ls_sort-descending = abap_true THEN ` DESCENDING` ELSE ` ASCENDING` ).
    ENDLOOP.
    IF lv_order IS INITIAL.
      lv_order = `FREIGHTORDER DESCENDING`.
    ENDIF.

    " paging
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).
    DATA(lv_top)  = io_request->get_paging( )->get_page_size( ).
    IF lv_top = if_rap_query_paging=>page_size_unlimited.
      lv_top = 0.            " UP TO 0 ROWS = no limit
    ENDIF.

    IF io_request->is_data_requested( ).
      WITH
        +fo AS ( SELECT FROM i_freightordertp AS f
                   LEFT OUTER JOIN i_businesspartner AS b
                     ON f~carrier = b~businesspartner
                 FIELDS f~transportationorder      AS freightorder,
                        f~transportationordertype  AS freightordertype,
                        f~carrier                  AS carrier,
                        b~businesspartnerfullname  AS carriername,
                        f~transpordlifecyclestatus AS lifecyclestatus )
        SELECT FROM +fo
          FIELDS *
          WHERE (lv_where)
          ORDER BY (lv_order)
          INTO CORRESPONDING FIELDS OF TABLE @lt_data
          UP TO @lv_top ROWS
          OFFSET @lv_skip.
      io_response->set_data( lt_data ).
    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      WITH
        +fo AS ( SELECT FROM i_freightordertp AS f
                   LEFT OUTER JOIN i_businesspartner AS b
                     ON f~carrier = b~businesspartner
                 FIELDS f~transportationorder      AS freightorder,
                        f~transportationordertype  AS freightordertype,
                        f~carrier                  AS carrier,
                        b~businesspartnerfullname  AS carriername,
                        f~transpordlifecyclestatus AS lifecyclestatus )
        SELECT FROM +fo
          FIELDS COUNT( * )
          WHERE (lv_where)
          INTO @DATA(lv_count).
      io_response->set_total_number_of_records( lv_count ).
    ENDIF.
  ENDMETHOD.


  METHOD search_condition.
    " search text -> LIKE on freight order, carrier and carrier name
    CHECK iv_search IS NOT INITIAL.
    DATA(lv_term) = to_upper( condense( iv_search ) ).
    REPLACE ALL OCCURRENCES OF `*` IN lv_term WITH `%`.
    lv_term = cl_abap_dyn_prg=>escape_quotes( lv_term ).
    IF lv_term NA `%`.
      lv_term = |%{ lv_term }%|.
    ENDIF.
    rv_where = |( FREIGHTORDER LIKE '{ lv_term }' OR CARRIER LIKE '{ lv_term }'|
            && | OR UPPER( CARRIERNAME ) LIKE '{ lv_term }' )|.
  ENDMETHOD.
ENDCLASS.
