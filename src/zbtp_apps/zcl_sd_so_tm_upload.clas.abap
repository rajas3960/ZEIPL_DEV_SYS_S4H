CLASS zcl_sd_so_tm_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_car_c TYPE TABLE FOR CREATE zr_sd_so_tmcar\\Carrier.
    TYPES tt_fo_c  TYPE TABLE FOR CREATE zr_sd_so_tmcar\\Carrier\_FreightOrder.

    TYPES: BEGIN OF ty_result,
             errors      TYPE string_table,
             car_c       TYPE tt_car_c,
             fo_c        TYPE tt_fo_c,
             rows        TYPE i,
             focount     TYPE i,
             carextended TYPE i,   " saved carriers that got new freight orders
             skipped     TYPE i,   " freight orders already saved
           END OF ty_result.

    "! Read + check the file and build the changes (no data is changed)
    CLASS-METHODS prepare
      IMPORTING iv_file          TYPE xstring
      RETURNING VALUE(rs_result) TYPE ty_result.

    "! Text like "4 rows: 2 carriers, 4 FOs created"
    CLASS-METHODS summary
      IMPORTING is_result      TYPE ty_result
      RETURNING VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_excel,
             so      TYPE string,
             item    TYPE string,
             carrier TYPE string,
             fo      TYPE string,
           END OF ty_excel.

    TYPES: BEGIN OF ty_row,
             rowno   TYPE i,
             so      TYPE zsd_sales_order_id,
             item    TYPE n LENGTH 6,
             carrier TYPE c LENGTH 10,
             fo      TYPE c LENGTH 20,
           END OF ty_row.
    TYPES tt_row TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    TYPES: BEGIN OF ty_group,
             so      TYPE zsd_sales_order_id,
             item    TYPE n LENGTH 6,
             carrier TYPE c LENGTH 10,
             exists  TYPE abap_bool,
             cid     TYPE string,
           END OF ty_group.
ENDCLASS.



CLASS ZCL_SD_SO_TM_UPLOAD IMPLEMENTATION.


  METHOD prepare.
    DATA lt_excel  TYPE STANDARD TABLE OF ty_excel WITH EMPTY KEY.
    DATA lt_rows   TYPE tt_row.
    DATA lt_groups TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY so item carrier.
    DATA ls_cba    LIKE LINE OF rs_result-fo_c.

    "-------------------------------------------------------------
    " 1. read sheet 1 (all cells as text)
    "-------------------------------------------------------------
    IF iv_file IS INITIAL.
      APPEND `Select the Excel file first` TO rs_result-errors.
      RETURN.
    ENDIF.
    TRY.
        DATA(lo_sheet) = xco_cp_xlsx=>document->for_file_content( iv_file_content = iv_file
                           )->read_access( )->get_workbook( )->worksheet->at_position( 1 ).
        DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
        lo_sheet->select( lo_pattern )->row_stream( )->operation->write_to( REF #( lt_excel )
          )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
          )->if_xco_xlsx_ra_operation~execute( ).
      CATCH cx_root.
        APPEND `File not readable - upload an .xlsx file` TO rs_result-errors.
        RETURN.
    ENDTRY.
    IF lines( lt_excel ) > 0.
      DELETE lt_excel INDEX 1.                  " column titles
    ENDIF.

    "-------------------------------------------------------------
    " 2a. row by row: format + S/4 checks
    "-------------------------------------------------------------
    LOOP AT lt_excel INTO DATA(ls_x).
      DATA(lv_rowno) = sy-tabix + 1.          " row number as in Excel
      IF condense( ls_x-so ) = `` AND condense( ls_x-fo ) = `` AND condense( ls_x-carrier ) = ``.
        CONTINUE.                             " blank row
      ENDIF.

      DATA(ls_row) = VALUE ty_row( rowno = lv_rowno ).
      DATA(lv_rowerr) = lines( rs_result-errors ).

      IF condense( ls_x-so ) = ``.
        APPEND |Row { lv_rowno }: sales order empty| TO rs_result-errors.
      ELSE.
        ls_row-so = |{ condense( ls_x-so ) ALPHA = IN WIDTH = 10 }|.
      ENDIF.

      DATA(lv_item) = condense( ls_x-item ).
      IF matches( val = lv_item pcre = `\d{1,6}` ).
        ls_row-item = lv_item.
      ELSE.
        APPEND |Row { lv_rowno }: SO item '{ ls_x-item }' invalid| TO rs_result-errors.
      ENDIF.

      IF condense( ls_x-carrier ) = ``.
        APPEND |Row { lv_rowno }: carrier empty| TO rs_result-errors.
      ELSE.
        ls_row-carrier = |{ condense( ls_x-carrier ) ALPHA = IN WIDTH = 10 }|.
      ENDIF.

      IF condense( ls_x-fo ) = ``.
        APPEND |Row { lv_rowno }: freight order empty| TO rs_result-errors.
      ELSE.
        ls_row-fo = |{ condense( ls_x-fo ) ALPHA = IN WIDTH = 20 }|.
      ENDIF.

      IF lines( rs_result-errors ) > lv_rowerr.
        CONTINUE.                             " format errors: skip S/4 checks
      ENDIF.

      SELECT SINGLE @abap_true FROM zsd_so_tmsoitem
        WHERE SalesOrder = @ls_row-so AND SalesOrderItem = @ls_row-item
        INTO @DATA(lv_so_ok).
      IF lv_so_ok = abap_false.
        APPEND |Row { lv_rowno }: SO { ls_row-so ALPHA = OUT }/{ CONV i( ls_row-item ) } not found| TO rs_result-errors.
      ENDIF.
      CLEAR lv_so_ok.

      SELECT SINGLE @abap_true FROM i_businesspartner WITH PRIVILEGED ACCESS
        WHERE BusinessPartner = @ls_row-carrier
        INTO @DATA(lv_found).
      IF lv_found = abap_false.
        APPEND |Row { lv_rowno }: carrier { ls_row-carrier ALPHA = OUT } not a BP| TO rs_result-errors.
      ENDIF.
      CLEAR lv_found.

      SELECT SINGLE Carrier FROM i_freightordertp WITH PRIVILEGED ACCESS
        WHERE TransportationOrder = @ls_row-fo
        INTO @DATA(lv_tm_carrier).
      IF sy-subrc <> 0.
        APPEND |Row { lv_rowno }: FO { ls_row-fo ALPHA = OUT } not in TM| TO rs_result-errors.
      ELSEIF |{ lv_tm_carrier ALPHA = IN }| <> ls_row-carrier.
        APPEND |Row { lv_rowno }: FO is of carrier { lv_tm_carrier ALPHA = OUT }| TO rs_result-errors.
      ENDIF.
      CLEAR lv_tm_carrier.

      APPEND ls_row TO lt_rows.
    ENDLOOP.

    IF lt_rows IS INITIAL AND rs_result-errors IS INITIAL.
      APPEND `The file has no data rows` TO rs_result-errors.
    ENDIF.

    "-------------------------------------------------------------
    " 2b. per SO item + carrier: duplicates in the file
    "-------------------------------------------------------------
    IF lt_rows IS NOT INITIAL.
      SORT lt_rows BY so item carrier rowno.

      " saved carriers / freight orders of the SO items in the file
      SELECT FROM zsd_so_tmcar
        FIELDS salesorder, salesorderitem, carrier
        FOR ALL ENTRIES IN @lt_rows
        WHERE salesorder = @lt_rows-so AND salesorderitem = @lt_rows-item
        INTO TABLE @DATA(lt_cardb).

      SELECT FROM zsd_so_tmfo
        FIELDS salesorder, salesorderitem, carrier, freightorder
        FOR ALL ENTRIES IN @lt_rows
        WHERE salesorder = @lt_rows-so AND salesorderitem = @lt_rows-item
          AND carrier = @lt_rows-carrier
        INTO TABLE @DATA(lt_fodb).

      DATA(lt_seen) = VALUE tt_row( ).
      LOOP AT lt_rows INTO ls_row.
        IF line_exists( lt_seen[ so = ls_row-so item = ls_row-item carrier = ls_row-carrier fo = ls_row-fo ] ).
          APPEND |Row { ls_row-rowno }: FO { ls_row-fo ALPHA = OUT } twice in file| TO rs_result-errors.
          CONTINUE.
        ENDIF.
        APPEND ls_row TO lt_seen.

        IF NOT line_exists( lt_groups[ so = ls_row-so item = ls_row-item carrier = ls_row-carrier ] ).
          INSERT VALUE #( so      = ls_row-so
                          item    = ls_row-item
                          carrier = ls_row-carrier
                          exists  = xsdbool( line_exists( lt_cardb[ salesorder     = ls_row-so
                                                                    salesorderitem = ls_row-item
                                                                    carrier        = ls_row-carrier ] ) ) )
                 INTO TABLE lt_groups.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF rs_result-errors IS NOT INITIAL.
      RETURN.
    ENDIF.

    "-------------------------------------------------------------
    " 3. build the changes for ZR_SD_SO_TMCAR
    "-------------------------------------------------------------
    DATA(lv_n) = 0.
    LOOP AT lt_groups ASSIGNING FIELD-SYMBOL(<g>).
      lv_n += 1.
      CLEAR ls_cba.
      IF <g>-exists = abap_false.
        <g>-cid = |CAR{ lv_n }|.
        APPEND VALUE #( %cid           = <g>-cid
                        SalesOrder     = <g>-so
                        SalesOrderItem = <g>-item
                        Carrier        = <g>-carrier ) TO rs_result-car_c.
        ls_cba-%cid_ref = <g>-cid.
      ELSE.
        ls_cba-SalesOrder     = <g>-so.
        ls_cba-SalesOrderItem = <g>-item.
        ls_cba-Carrier        = <g>-carrier.
      ENDIF.

      LOOP AT lt_rows INTO ls_row WHERE so = <g>-so AND item = <g>-item AND carrier = <g>-carrier.
        IF line_exists( lt_fodb[ salesorder = <g>-so salesorderitem = <g>-item
                                 carrier = <g>-carrier freightorder = ls_row-fo ] ).
          rs_result-skipped += 1.             " already saved
          CONTINUE.
        ENDIF.
        APPEND VALUE #( %cid         = |FO{ ls_row-rowno }|
                        FreightOrder = ls_row-fo ) TO ls_cba-%target.
      ENDLOOP.

      IF ls_cba-%target IS NOT INITIAL.
        APPEND ls_cba TO rs_result-fo_c.
        IF <g>-exists = abap_true.
          rs_result-carextended += 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    rs_result-rows    = lines( lt_rows ).
    rs_result-focount = REDUCE i( INIT n = 0 FOR c IN rs_result-fo_c NEXT n = n + lines( c-%target ) ).
  ENDMETHOD.


  METHOD summary.
    rv_text = |{ is_result-rows } rows: { lines( is_result-car_c ) } carriers, { is_result-focount } FOs created|.
    IF is_result-skipped > 0.
      rv_text = |{ rv_text }, { is_result-skipped } existed|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
