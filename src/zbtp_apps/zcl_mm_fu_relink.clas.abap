*----------------------------------------------------------------*
* SYSTEM: S/4HANA Public Cloud   ADT console class (F9)
* F8 (10.11.2026): ZCL_MM_FU_RELINK - one-off re-run of the FU -> FO
* link for deliveries whose latest ZMM_FU_LINK_LOG row is NOT a real
* assignment (ASSIGNED without "assigned to" = TM refusal logged as
* success before F7, REFUSED, NO_FU, LOCKED, TM_REFUSED, DUMP, or a
* job that never finished).
*   c_run = abap_false : list only (first run)
*   c_run = abap_true  : run ZCL_MM_FU_LINK_BG for each listed delivery
*                        (synchronously, writes the usual log rows)
* Delete the class after use. Put it in the package of ZCL_MM_FU_LINK_BG.
*----------------------------------------------------------------*
CLASS zcl_mm_fu_relink DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_run TYPE abap_bool VALUE abap_true.

    "! deliveries that must not be re-linked (80001380 = duplicate
    "! delivery of SD120261105-013, to be deleted)
    CONSTANTS c_skip TYPE c LENGTH 10 VALUE '0080001380'.
ENDCLASS.



CLASS ZCL_MM_FU_RELINK IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    SELECT delivery, freightorder, direction, status, message, createdat
      FROM zmm_fu_link_log
      ORDER BY delivery, createdat DESCENDING
      INTO TABLE @DATA(lt_log)."#EC CI_NOWHERE

    DATA lv_count TYPE i.

    LOOP AT lt_log INTO DATA(ls_grp) GROUP BY ls_grp-delivery INTO DATA(lv_delivery).
      " newest row of this delivery
      DATA(ls_last) = VALUE #( lt_log[ delivery = lv_delivery ] OPTIONAL ).

      " done when ANY run of this delivery really assigned the FU
      " (0180000391: first run assigned, second run "already planned")
      DATA(lv_done) = abap_false.
      LOOP AT GROUP lv_delivery INTO DATA(ls_row).
        IF ( ls_row-status = 'ASSIGNED' AND ls_row-message CS 'assigned to' ) OR ls_row-status = 'ALREADY'.
          lv_done = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_done = abap_true OR lv_delivery = c_skip.
        CONTINUE.
      ENDIF.

      lv_count = lv_count + 1.
      out->write( |{ ls_last-direction } { lv_delivery ALPHA = OUT } FO { ls_last-freightorder ALPHA = OUT } | &&
                  |last { ls_last-status }: { substring( val = ls_last-message len = nmin( val1 = strlen( ls_last-message ) val2 = 80 ) ) }| ).

      IF c_run = abap_true.
        TRY.
            DATA(lo_job) = NEW zcl_mm_fu_link_bg( iv_delivery     = CONV #( lv_delivery )
                                                  iv_freightorder = CONV #( ls_last-freightorder )
                                                  iv_direction    = CONV #( ls_last-direction ) ).
            lo_job->if_bgmc_op_single_tx_uncontr~execute( ).
          CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
            out->write( |  run failed: { lx->get_text( ) }| ).
            CONTINUE.
        ENDTRY.

        SELECT status, message FROM zmm_fu_link_log
          WHERE delivery = @lv_delivery
          ORDER BY createdat DESCENDING
          INTO @DATA(ls_new)
          UP TO 1 ROWS.
        ENDSELECT.
        out->write( |  -> { ls_new-status }: { substring( val = ls_new-message len = nmin( val1 = strlen( ls_new-message ) val2 = 80 ) ) }| ).
      ENDIF.
    ENDLOOP.

    out->write( |{ lv_count } deliveries { COND #( WHEN c_run = abap_true THEN `re-run` ELSE `to re-run (list only)` ) }| ).
  ENDMETHOD.
ENDCLASS.
