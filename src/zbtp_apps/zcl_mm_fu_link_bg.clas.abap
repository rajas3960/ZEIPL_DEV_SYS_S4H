CLASS zcl_mm_fu_link_bg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_bgmc_op_single_tx_uncontr.

    TYPES ty_delivery     TYPE c LENGTH 10.
    TYPES ty_freightorder TYPE c LENGTH 20.
    TYPES ty_direction    TYPE c LENGTH 3.   " IN = inbound delivery, OUT = outbound

    METHODS constructor
      IMPORTING iv_delivery     TYPE ty_delivery
                iv_freightorder TYPE ty_freightorder
                iv_direction    TYPE ty_direction OPTIONAL.

    "! one row in ZMM_FU_LINK_LOG, committed at once (also used by the
    "! HTTP classes for QUEUED / NOT_QUEUED)
    CLASS-METHODS write_log
      IMPORTING iv_direction    TYPE ty_direction
                iv_delivery     TYPE ty_delivery
                iv_freightorder TYPE ty_freightorder
                iv_status       TYPE clike
                iv_message      TYPE clike.

  PRIVATE SECTION.
    DATA mv_delivery     TYPE ty_delivery.
    DATA mv_freightorder TYPE ty_freightorder.
    DATA mv_direction    TYPE ty_direction.

    METHODS log
      IMPORTING iv_status  TYPE clike
                iv_message TYPE clike.

    METHODS assign.
ENDCLASS.



CLASS ZCL_MM_FU_LINK_BG IMPLEMENTATION.


  METHOD constructor.
    mv_delivery     = iv_delivery.
    mv_freightorder = iv_freightorder.
    mv_direction    = iv_direction.
  ENDMETHOD.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
    log( iv_status = 'STARTED' iv_message = 'background job started' ).
    TRY.
        assign( ).
      CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
        ROLLBACK ENTITIES.
        log( iv_status = 'DUMP' iv_message = lx->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD assign.
    DATA lv_fo   TYPE ty_freightorder.
    DATA lv_msg  TYPE string.
    DATA lv_ok   TYPE abap_bool.
    DATA lv_try  TYPE i.
    DATA lv_ref  TYPE c LENGTH 35.

    lv_fo = mv_freightorder.
    lv_fo = |{ lv_fo ALPHA = IN }|.

    SELECT SINGLE TransportationOrderUUID
      FROM i_freightordertp WITH PRIVILEGED ACCESS
      WHERE TransportationOrder = @lv_fo
      INTO @DATA(lv_fo_uuid).
    IF sy-subrc <> 0.
      log( iv_status = 'NO_FO' iv_message = |freight order { lv_fo ALPHA = OUT } not found| ).
      RETURN.
    ENDIF.

    " freight unit(s) built from the delivery (inbound 58 / outbound 73),
    " reference ID = delivery with leading zeros to 35 characters.
    " 10.11.2026: TM builds them after the delivery save - wait up to 2 minutes
    lv_ref = mv_delivery.
    lv_ref = |{ lv_ref ALPHA = IN }|.

    DO 60 TIMES.
      SELECT TransportationOrderUUID, TranspOrdDocReferenceType
        FROM i_freightunitdocreftp WITH PRIVILEGED ACCESS
        WHERE TranspOrdDocReferenceID   = @lv_ref
          AND TranspOrdDocReferenceType IN ( '58', '73' )
        INTO TABLE @DATA(lt_fu).
      IF lt_fu IS NOT INITIAL.
        EXIT.
      ENDIF.
      WAIT UP TO 2 SECONDS.
    ENDDO.

    IF lt_fu IS INITIAL.
      log( iv_status = 'NO_FU' iv_message = 'no freight unit found within 2 minutes' ).
      RETURN.
    ENDIF.

    " direction from the reference type when the caller didn't pass it
    IF mv_direction IS INITIAL.
      mv_direction = COND #( WHEN lt_fu[ 1 ]-TranspOrdDocReferenceType = '73' THEN 'OUT' ELSE 'IN' ).
    ENDIF.

    " 10.11.2026: a parallel job (second truck on the same FO) may hold the
    " FO lock for a few seconds - try up to 5 times, 3 seconds apart
    DO 5 TIMES.
      lv_try = lv_try + 1.
      CLEAR: lv_msg, lv_ok.

      MODIFY ENTITIES OF i_freightordertp PRIVILEGED
        ENTITY FreightOrder
          EXECUTE AssignFreightUnit
          FROM VALUE #( ( TransportationOrderUUID = lv_fo_uuid
                          %param = VALUE #( _FreightUnits = VALUE #( FOR ls_fu IN lt_fu
                                                                     ( FreightUnitUUID          = ls_fu-TransportationOrderUUID
                                                                       %control-FreightUnitUUID = if_abap_behv=>mk-on ) )
                                            %control-_FreightUnits = if_abap_behv=>mk-on ) ) )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

      LOOP AT ls_reported-freightorder INTO DATA(ls_rep) WHERE %msg IS BOUND.
        DATA(lv_text) = ls_rep-%msg->if_message~get_text( ).
        lv_msg = |{ lv_msg } { lv_text }|.
        IF lv_text CS 'assigned to'.
          lv_ok = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_ok = abap_false AND lv_msg CS 'locked' AND lv_try < 5.
        ROLLBACK ENTITIES.
        WAIT UP TO 3 SECONDS.
        CONTINUE.
      ENDIF.
      EXIT.
    ENDDO.

    IF lv_ok = abap_false.
      ROLLBACK ENTITIES.
      log( iv_status  = COND string( WHEN lv_msg CS 'locked'          THEN `LOCKED`
                                     WHEN lv_msg CS 'already planned' THEN `ALREADY`
                                     WHEN ls_failed IS NOT INITIAL    THEN `REFUSED`
                                     ELSE                                  `TM_REFUSED` )
      iv_message = COND #( WHEN lv_msg IS INITIAL THEN `TM gave no confirmation - nothing assigned` ELSE lv_msg ) ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES RESPONSE OF i_freightordertp
      FAILED   DATA(ls_cfailed)
      REPORTED DATA(ls_creported).
    LOOP AT ls_creported-freightorder INTO DATA(ls_crep) WHERE %msg IS BOUND.
      lv_msg = |{ lv_msg } { ls_crep-%msg->if_message~get_text( ) }|.
    ENDLOOP.

    log( iv_status  = COND string( WHEN ls_cfailed IS INITIAL THEN `ASSIGNED` ELSE `SAVE_FAIL` )
         iv_message = lv_msg ).
  ENDMETHOD.


  METHOD log.
    write_log( iv_direction    = mv_direction
               iv_delivery     = mv_delivery
               iv_freightorder = mv_freightorder
               iv_status       = iv_status
               iv_message      = iv_message ).
  ENDMETHOD.


  METHOD write_log.
    DATA ls_log TYPE zmm_fu_link_log.
    TRY.
        ls_log-logid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.
    GET TIME STAMP FIELD ls_log-createdat.
    ls_log-direction    = iv_direction.
    ls_log-delivery     = iv_delivery.
    ls_log-freightorder = iv_freightorder.
    ls_log-status       = iv_status.
    ls_log-message      = iv_message.
    ls_log-username     = cl_abap_context_info=>get_user_technical_name( ).
    INSERT zmm_fu_link_log FROM @ls_log.
    COMMIT WORK.
  ENDMETHOD.
ENDCLASS.
