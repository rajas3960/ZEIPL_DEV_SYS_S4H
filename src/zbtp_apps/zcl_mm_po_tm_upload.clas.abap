CLASS zcl_mm_po_tm_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_car_c TYPE TABLE FOR CREATE zr_mm_po_tmcar\\Carrier.
    TYPES tt_car_u TYPE TABLE FOR UPDATE zr_mm_po_tmcar\\Carrier.
    TYPES tt_fo_c  TYPE TABLE FOR CREATE zr_mm_po_tmcar\\Carrier\_FreightOrder.
    TYPES tt_fo_u  TYPE TABLE FOR UPDATE zr_mm_po_tmcar\\FreightOrder.

    TYPES: BEGIN OF ty_result,
             errors  TYPE string_table,
             car_c   TYPE tt_car_c,
             car_u   TYPE tt_car_u,
             fo_c    TYPE tt_fo_c,
             fo_u    TYPE tt_fo_u,
             rows    TYPE i,
             focount TYPE i,
           END OF ty_result.

    "! charge type whose calculation rule quantity is the FO quantity
    CONSTANTS c_charge_type TYPE string VALUE `SF04`.

    "! Read + check the file and build the changes (no data is changed)
    CLASS-METHODS prepare
      IMPORTING iv_file          TYPE xstring
      RETURNING VALUE(rs_result) TYPE ty_result.

    "! Text like "4 rows: 2 carriers created, 4 freight orders created, 0 updated"
    CLASS-METHODS summary
      IMPORTING is_result      TYPE ty_result
      RETURNING VALUE(rv_text) TYPE string.

    "! Freight order quantity from TM: SF04 calculation rule quantity
    CLASS-METHODS fo_qty
      IMPORTING iv_freightorder TYPE zmm_freight_order_id
      EXPORTING ev_qty          TYPE zmm_po_tmfo-foqty
                ev_unit         TYPE zmm_po_tmfo-founit.

  PRIVATE SECTION.
    TYPES ty_qty TYPE p LENGTH 13 DECIMALS 3.

    TYPES: BEGIN OF ty_excel,
             po        TYPE string,
             item      TYPE string,
             poqty     TYPE string,
             carrier   TYPE string,
             carqty    TYPE string,
             fo        TYPE string,
             validfrom TYPE string,
             validto   TYPE string,
           END OF ty_excel.

    TYPES: BEGIN OF ty_row,
             rowno   TYPE i,
             po      TYPE c LENGTH 10,
             item    TYPE n LENGTH 5,
             carrier TYPE c LENGTH 10,
             fo      TYPE c LENGTH 20,
             foqty   TYPE ty_qty,
             validfr TYPE d,
             validto TYPE d,
           END OF ty_row.
    TYPES tt_row TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    TYPES: BEGIN OF ty_group,
             po       TYPE c LENGTH 10,
             item     TYPE n LENGTH 5,
             carrier  TYPE c LENGTH 10,
             firstrow TYPE i,
             exists   TYPE abap_bool,
             total    TYPE ty_qty,
             cid      TYPE string,
           END OF ty_group.

    CLASS-METHODS to_date
      IMPORTING iv_text        TYPE string
      RETURNING VALUE(rv_date) TYPE d.
ENDCLASS.



CLASS zcl_mm_po_tm_upload IMPLEMENTATION.


  METHOD prepare.
    DATA lt_excel  TYPE STANDARD TABLE OF ty_excel WITH EMPTY KEY.
    DATA lt_rows   TYPE tt_row.
    DATA lt_groups TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY po item carrier.
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
        APPEND `The file could not be read. Upload an .xlsx file.` TO rs_result-errors.
        RETURN.
    ENDTRY.
    IF lines( lt_excel ) > 0.
      DELETE lt_excel INDEX 1.                  " column titles
    ENDIF.

    "-------------------------------------------------------------
    " 2a. row by row: format + S/4 checks (column E is ignored)
    "-------------------------------------------------------------
    LOOP AT lt_excel INTO DATA(ls_x).
      DATA(lv_rowno) = sy-tabix + 1.          " row number as in Excel
      IF condense( ls_x-po ) = `` AND condense( ls_x-fo ) = `` AND condense( ls_x-carrier ) = ``.
        CONTINUE.                             " blank row
      ENDIF.

      DATA(ls_row) = VALUE ty_row( rowno = lv_rowno ).
      DATA(lv_rowerr) = lines( rs_result-errors ).

      IF condense( ls_x-po ) = ``.
        APPEND |Row { lv_rowno }: PO is empty| TO rs_result-errors.
      ELSE.
        ls_row-po = |{ condense( ls_x-po ) ALPHA = IN WIDTH = 10 }|.
      ENDIF.

      DATA(lv_item) = condense( ls_x-item ).
      IF matches( val = lv_item pcre = `\d{1,5}` ).
        ls_row-item = lv_item.
      ELSE.
        APPEND |Row { lv_rowno }: line item '{ ls_x-item }' is not a number| TO rs_result-errors.
      ENDIF.

      IF condense( ls_x-carrier ) = ``.
        APPEND |Row { lv_rowno }: carrier is empty| TO rs_result-errors.
      ELSE.
        ls_row-carrier = |{ condense( ls_x-carrier ) ALPHA = IN WIDTH = 10 }|.
      ENDIF.

      IF condense( ls_x-fo ) = ``.
        APPEND |Row { lv_rowno }: freight order is empty| TO rs_result-errors.
      ELSE.
        ls_row-fo = |{ condense( ls_x-fo ) ALPHA = IN WIDTH = 20 }|.
      ENDIF.

      ls_row-validfr = to_date( ls_x-validfrom ).
      ls_row-validto = to_date( ls_x-validto ).
      IF ls_row-validfr IS INITIAL.
        APPEND |Row { lv_rowno }: Valid From '{ ls_x-validfrom }' is not a date| TO rs_result-errors.
      ENDIF.
      IF ls_row-validto IS INITIAL.
        APPEND |Row { lv_rowno }: Valid To '{ ls_x-validto }' is not a date| TO rs_result-errors.
      ENDIF.
      IF ls_row-validfr IS NOT INITIAL AND ls_row-validto IS NOT INITIAL
         AND ls_row-validfr > ls_row-validto.
        APPEND |Row { lv_rowno }: Valid From is after Valid To| TO rs_result-errors.
      ENDIF.

      IF lines( rs_result-errors ) > lv_rowerr.
        CONTINUE.                             " format errors: skip S/4 checks
      ENDIF.

      SELECT SINGLE PurchaseOrderQuantityUnit FROM zmm_po_tmpoitem
        WHERE PurchaseOrder = @ls_row-po AND PurchaseOrderItem = @ls_row-item
        INTO @DATA(lv_po_unit).
      IF sy-subrc <> 0.
        APPEND |Row { lv_rowno }: PO { ls_row-po ALPHA = OUT } item { CONV i( ls_row-item ) } does not exist or is deleted| TO rs_result-errors.
      ENDIF.

      SELECT SINGLE @abap_true FROM i_businesspartner WITH PRIVILEGED ACCESS
        WHERE BusinessPartner = @ls_row-carrier
        INTO @DATA(lv_found).
      IF lv_found = abap_false.
        APPEND |Row { lv_rowno }: carrier { ls_row-carrier ALPHA = OUT } is not a business partner| TO rs_result-errors.
      ENDIF.
      CLEAR lv_found.

      SELECT SINGLE Carrier FROM i_freightordertp WITH PRIVILEGED ACCESS
        WHERE TransportationOrder = @ls_row-fo
        INTO @DATA(lv_tm_carrier).
      IF sy-subrc <> 0.
        APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } does not exist in TM| TO rs_result-errors.
      ELSEIF |{ lv_tm_carrier ALPHA = IN }| <> ls_row-carrier.
        APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } belongs to carrier { lv_tm_carrier ALPHA = OUT }, not { ls_row-carrier ALPHA = OUT }| TO rs_result-errors.
      ELSE.
        fo_qty( EXPORTING iv_freightorder = ls_row-fo
                IMPORTING ev_qty          = DATA(lv_qty)
                          ev_unit         = DATA(lv_unit) ).
        IF lv_qty <= 0.
          APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } has no { c_charge_type } charge quantity in TM; calculate its charges first| TO rs_result-errors.
        ELSEIF lv_po_unit IS NOT INITIAL AND lv_unit <> lv_po_unit.
          APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } quantity is in { lv_unit }, the PO item in { lv_po_unit }| TO rs_result-errors.
        ELSE.
          ls_row-foqty = lv_qty.
        ENDIF.
      ENDIF.

      " an FO belongs to one PO item + carrier only: saved data ...
      SELECT SINGLE purchaseorder, purchaseorderitem, carrier
        FROM zmm_po_tmfo
        WHERE freightorder = @ls_row-fo
          AND ( purchaseorder     <> @ls_row-po
             OR purchaseorderitem <> @ls_row-item
             OR carrier           <> @ls_row-carrier )
        INTO @DATA(ls_used).
      IF sy-subrc = 0.
        APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } is already used on PO { ls_used-purchaseorder ALPHA = OUT }|
            && | item { CONV i( ls_used-purchaseorderitem ) }, carrier { ls_used-carrier ALPHA = OUT }| TO rs_result-errors.
      ENDIF.
      CLEAR ls_used.
      " ... and earlier rows of this file
      LOOP AT lt_rows INTO DATA(ls_prev)
           WHERE fo = ls_row-fo
             AND ( po <> ls_row-po OR item <> ls_row-item OR carrier <> ls_row-carrier ).
        APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } is also in row { ls_prev-rowno }|
            && | for PO { ls_prev-po ALPHA = OUT } item { CONV i( ls_prev-item ) }| TO rs_result-errors.
        EXIT.
      ENDLOOP.

      " an FO belongs to one PO item + carrier only: saved data ...
      SELECT SINGLE purchaseorder, purchaseorderitem, carrier
        FROM zmm_po_tmfo
        WHERE freightorder = @ls_row-fo
          AND ( purchaseorder     <> @ls_row-po
             OR purchaseorderitem <> @ls_row-item
             OR carrier           <> @ls_row-carrier )
        INTO @DATA(ls_fo_owner).
      IF sy-subrc = 0.
        APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } is already used on PO { ls_fo_owner-purchaseorder ALPHA = OUT }|
            && | item { CONV i( ls_fo_owner-purchaseorderitem ) }, carrier { ls_fo_owner-carrier ALPHA = OUT }| TO rs_result-errors.
      ENDIF.
      CLEAR ls_fo_owner.
      " ... and earlier rows of this file
      LOOP AT lt_rows INTO DATA(ls_fo_prev)
           WHERE fo = ls_row-fo
             AND ( po <> ls_row-po OR item <> ls_row-item OR carrier <> ls_row-carrier ).
        APPEND |Row { lv_rowno }: freight order { ls_row-fo ALPHA = OUT } is also in row { ls_fo_prev-rowno }|
            && | for PO { ls_fo_prev-po ALPHA = OUT } item { CONV i( ls_fo_prev-item ) }| TO rs_result-errors.
        EXIT.
      ENDLOOP.

      CLEAR: lv_tm_carrier, lv_po_unit.

      APPEND ls_row TO lt_rows.
    ENDLOOP.

    IF lt_rows IS INITIAL AND rs_result-errors IS INITIAL.
      APPEND `The file has no data rows` TO rs_result-errors.
    ENDIF.

    "-------------------------------------------------------------
    " 2b. per PO item + carrier: totals, duplicates, overlaps
    "-------------------------------------------------------------
    IF lt_rows IS NOT INITIAL.
      SORT lt_rows BY po item carrier rowno.

      " saved carriers of the PO items in the file
      SELECT FROM zmm_po_tmcar
        FIELDS purchaseorder, purchaseorderitem, carrier, allocatedqty
        FOR ALL ENTRIES IN @lt_rows
        WHERE purchaseorder = @lt_rows-po AND purchaseorderitem = @lt_rows-item
        INTO TABLE @DATA(lt_cardb).

      " saved freight orders of the carriers in the file
      SELECT FROM zmm_po_tmfo
        FIELDS fouuid, purchaseorder, purchaseorderitem, carrier, freightorder, validfrom, validto, foqty
        FOR ALL ENTRIES IN @lt_rows
        WHERE purchaseorder = @lt_rows-po AND purchaseorderitem = @lt_rows-item
          AND carrier = @lt_rows-carrier
        INTO TABLE @DATA(lt_fodb).

      LOOP AT lt_rows INTO ls_row.
        IF NOT line_exists( lt_groups[ po = ls_row-po item = ls_row-item carrier = ls_row-carrier ] ).
          INSERT VALUE #( po       = ls_row-po
                          item     = ls_row-item
                          carrier  = ls_row-carrier
                          firstrow = ls_row-rowno
                          exists   = xsdbool( line_exists( lt_cardb[ purchaseorder     = ls_row-po
                                                                     purchaseorderitem = ls_row-item
                                                                     carrier           = ls_row-carrier ] ) ) )
                 INTO TABLE lt_groups.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_groups ASSIGNING FIELD-SYMBOL(<g>).
        " freight orders of this carrier: file rows + saved ones not in the file
        TYPES: BEGIN OF ty_period,
                 rowno TYPE i,
                 fo    TYPE c LENGTH 20,
                 fr    TYPE d,
                 to    TYPE d,
                 qty   TYPE ty_qty,
               END OF ty_period.
        DATA lt_period TYPE STANDARD TABLE OF ty_period WITH EMPTY KEY.
        CLEAR lt_period.
        LOOP AT lt_rows INTO ls_row WHERE po = <g>-po AND item = <g>-item AND carrier = <g>-carrier.
          IF line_exists( lt_period[ fo = ls_row-fo ] ).
            APPEND |Row { ls_row-rowno }: freight order { ls_row-fo ALPHA = OUT } is in the file twice for carrier { ls_row-carrier ALPHA = OUT }| TO rs_result-errors.
            CONTINUE.
          ENDIF.
          APPEND VALUE #( rowno = ls_row-rowno fo = ls_row-fo fr = ls_row-validfr to = ls_row-validto qty = ls_row-foqty ) TO lt_period.
        ENDLOOP.
        LOOP AT lt_fodb INTO DATA(ls_fodb)
             WHERE purchaseorder = <g>-po AND purchaseorderitem = <g>-item AND carrier = <g>-carrier.
          IF NOT line_exists( lt_period[ fo = ls_fodb-freightorder ] ).
            APPEND VALUE #( rowno = 0 fo = ls_fodb-freightorder fr = ls_fodb-validfrom to = ls_fodb-validto qty = ls_fodb-foqty ) TO lt_period.
          ENDIF.
        ENDLOOP.
        LOOP AT lt_period INTO DATA(ls_p1) WHERE rowno > 0.
          LOOP AT lt_period INTO DATA(ls_p2) WHERE fo <> ls_p1-fo AND fr <= ls_p1-to AND to >= ls_p1-fr.
            APPEND |Row { ls_p1-rowno }: freight order { ls_p1-fo ALPHA = OUT } ({ ls_p1-fr DATE = USER } - { ls_p1-to DATE = USER })|
                && | overlaps freight order { ls_p2-fo ALPHA = OUT } ({ ls_p2-fr DATE = USER } - { ls_p2-to DATE = USER })| TO rs_result-errors.
            EXIT.
          ENDLOOP.
        ENDLOOP.

        " carrier quantity after the upload = all its freight order quantities
        <g>-total = REDUCE ty_qty( INIT s = CONV ty_qty( 0 ) FOR p IN lt_period NEXT s = s + p-qty ).
      ENDLOOP.

      " all carriers of a PO item together <= PO item quantity
      DATA(lt_items) = lt_rows.
      SORT lt_items BY po item.
      DELETE ADJACENT DUPLICATES FROM lt_items COMPARING po item.
      LOOP AT lt_items INTO DATA(ls_item).
        DATA(lv_total) = CONV ty_qty( 0 ).
        LOOP AT lt_groups INTO DATA(ls_g) WHERE po = ls_item-po AND item = ls_item-item.
          lv_total = lv_total + ls_g-total.
        ENDLOOP.
        LOOP AT lt_cardb INTO DATA(ls_cardb)
             WHERE purchaseorder = ls_item-po AND purchaseorderitem = ls_item-item.
          IF NOT line_exists( lt_groups[ po = ls_item-po item = ls_item-item carrier = ls_cardb-carrier ] ).
            lv_total = lv_total + ls_cardb-allocatedqty.
          ENDIF.
        ENDLOOP.
        SELECT SINGLE OrderQuantity, PurchaseOrderQuantityUnit FROM zmm_po_tmpoitem
          WHERE PurchaseOrder = @ls_item-po AND PurchaseOrderItem = @ls_item-item
          INTO @DATA(ls_poqty).
        IF sy-subrc = 0 AND lv_total > ls_poqty-OrderQuantity.
          APPEND |Row { ls_item-rowno }: freight order quantities of PO { ls_item-po ALPHA = OUT } item { CONV i( ls_item-item ) } total|
              && | { lv_total NUMBER = USER }, more than the PO item quantity { ls_poqty-OrderQuantity NUMBER = USER } { ls_poqty-PurchaseOrderQuantityUnit }| TO rs_result-errors.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "-------------------------------------------------------------
    " errors -> caller reports them, nothing is built
    "-------------------------------------------------------------
    IF rs_result-errors IS NOT INITIAL.
      RETURN.
    ENDIF.

    "-------------------------------------------------------------
    " 3. build the changes for ZR_MM_PO_TMCAR
    "    (FoQty and AllocatedQty are filled by the BO itself)
    "-------------------------------------------------------------
    DATA(lv_n) = 0.
    LOOP AT lt_groups ASSIGNING <g>.
      lv_n += 1.
      IF <g>-exists = abap_false.
        <g>-cid = |CAR{ lv_n }|.
        APPEND VALUE #( %cid              = <g>-cid
                        PurchaseOrder     = <g>-po
                        PurchaseOrderItem = <g>-item
                        Carrier           = <g>-carrier ) TO rs_result-car_c.
      ENDIF.

      CLEAR ls_cba.
      IF <g>-exists = abap_false.
        ls_cba-%cid_ref = <g>-cid.
      ELSE.
        ls_cba-PurchaseOrder     = <g>-po.
        ls_cba-PurchaseOrderItem = <g>-item.
        ls_cba-Carrier           = <g>-carrier.
      ENDIF.

      LOOP AT lt_rows INTO ls_row WHERE po = <g>-po AND item = <g>-item AND carrier = <g>-carrier.
        READ TABLE lt_fodb INTO ls_fodb
             WITH KEY purchaseorder = <g>-po purchaseorderitem = <g>-item
                      carrier = <g>-carrier freightorder = ls_row-fo.
        IF sy-subrc = 0.
          IF ls_fodb-validfrom <> ls_row-validfr OR ls_fodb-validto <> ls_row-validto.
            APPEND VALUE #( FoUuid    = ls_fodb-fouuid
                            ValidFrom = ls_row-validfr
                            ValidTo   = ls_row-validto ) TO rs_result-fo_u.
          ENDIF.
        ELSE.
          APPEND VALUE #( %cid         = |FO{ ls_row-rowno }|
                          FreightOrder = ls_row-fo
                          ValidFrom    = ls_row-validfr
                          ValidTo      = ls_row-validto ) TO ls_cba-%target.
        ENDIF.
      ENDLOOP.
      IF ls_cba-%target IS NOT INITIAL.
        APPEND ls_cba TO rs_result-fo_c.
      ENDIF.
    ENDLOOP.

    rs_result-rows    = lines( lt_rows ).
    rs_result-focount = REDUCE i( INIT n = 0 FOR c IN rs_result-fo_c NEXT n = n + lines( c-%target ) ).

  ENDMETHOD.


  METHOD summary.
    rv_text = |{ is_result-rows } rows: { lines( is_result-car_c ) } carriers created,|
           && | { is_result-focount } freight orders created, { lines( is_result-fo_u ) } updated|.
  ENDMETHOD.


  METHOD fo_qty.
    CLEAR: ev_qty, ev_unit.
    SELECT FROM i_freightordertp WITH PRIVILEGED ACCESS AS f
      INNER JOIN i_frtordchrgelementtp WITH PRIVILEGED ACCESS AS e
        ON e~TransportationOrderUUID = f~TransportationOrderUUID
      INNER JOIN i_frtordchrgcalcruletp WITH PRIVILEGED ACCESS AS r
        ON r~TranspChargeItemElementUUID = e~TranspChargeItemElementUUID
      FIELDS r~TranspRateCalcRuleQtyUnit           AS unit,
             SUM( r~TranspChrgDataSourceQuantity ) AS qty
      WHERE f~TransportationOrder = @iv_freightorder
        AND e~TranspChargeType    = @c_charge_type
      GROUP BY r~TranspRateCalcRuleQtyUnit
      INTO TABLE @DATA(lt_qty).

    " one unit only; several units = no usable quantity
    IF lines( lt_qty ) = 1.
      ev_qty  = lt_qty[ 1 ]-qty.
      ev_unit = lt_qty[ 1 ]-unit.
    ENDIF.
  ENDMETHOD.


  METHOD to_date.
    DATA lv_d TYPE string.
    DATA lv_m TYPE string.
    DATA lv_y TYPE string.

    " drop a time part, e.g. '01.10.2026 00:00:00'
    DATA(lv_full) = condense( iv_text ).
    SPLIT lv_full AT space INTO DATA(lv_text) DATA(lv_rest) ##NEEDED.
    IF lv_text IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_dots) = replace( val = lv_text pcre = `[/-]` with = `.` occ = 0 ).

    IF matches( val = lv_text pcre = `\d{1,5}(\.\d+)?` ).
      " Excel date cell: days since 30.12.1899
      SPLIT lv_text AT '.' INTO DATA(lv_days) DATA(lv_frac) ##NEEDED.
      rv_date = '18991230'.
      rv_date = rv_date + CONV i( lv_days ).
      RETURN.
    ELSEIF matches( val = lv_text pcre = `\d{8}` ).
      lv_y = lv_text(4).
      lv_m = lv_text+4(2).
      lv_d = lv_text+6(2).
    ELSEIF matches( val = lv_dots pcre = `\d{4}\.\d{1,2}\.\d{1,2}` ).
      SPLIT lv_dots AT '.' INTO lv_y lv_m lv_d.
    ELSEIF matches( val = lv_dots pcre = `\d{1,2}\.\d{1,2}\.\d{4}` ).
      SPLIT lv_dots AT '.' INTO lv_d lv_m lv_y.
    ELSE.
      RETURN.
    ENDIF.

    IF CONV i( lv_m ) NOT BETWEEN 1 AND 12 OR CONV i( lv_d ) NOT BETWEEN 1 AND 31.
      RETURN.
    ENDIF.

    rv_date = |{ lv_y }{ lv_m WIDTH = 2 ALIGN = RIGHT PAD = '0' }{ lv_d WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
  ENDMETHOD.
ENDCLASS.
