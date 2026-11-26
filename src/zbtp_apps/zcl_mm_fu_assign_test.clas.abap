CLASS zcl_mm_fu_assign_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS ZCL_MM_FU_ASSIGN_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " outbound delivery + freight order of the test (set both)
    CONSTANTS lc_delivery TYPE c LENGTH 10 VALUE '0080001321'.
    CONSTANTS lc_fo       TYPE c LENGTH 20 VALUE '00000000006600000252'.

    DATA lv_ref TYPE c LENGTH 35.
    lv_ref = lc_delivery.
    lv_ref = |{ lv_ref ALPHA = IN }|.

    " 1. every freight unit document reference to this delivery, any type
    SELECT TransportationOrderUUID, TranspOrdDocReferenceType
      FROM i_freightunitdocreftp WITH PRIVILEGED ACCESS
      WHERE TranspOrdDocReferenceID = @lv_ref
      INTO TABLE @DATA(lt_ref).
    out->write( |1. FU references to delivery { lc_delivery }: { lines( lt_ref ) }| ).
    LOOP AT lt_ref INTO DATA(ls_ref).
      out->write( |   FU uuid { ls_ref-TransportationOrderUUID } type "{ ls_ref-TranspOrdDocReferenceType }"| ).
    ENDLOOP.
    IF lt_ref IS INITIAL.
      out->write( `   -> TM built no freight unit for this delivery (TM configuration for LF?)` ).
      RETURN.
    ENDIF.

    " 2. the freight order
    SELECT SINGLE TransportationOrderUUID FROM i_freightordertp WITH PRIVILEGED ACCESS
      WHERE TransportationOrder = @lc_fo
      INTO @DATA(lv_fo_uuid).
    out->write( |2. FO { lc_fo ALPHA = OUT } found: { xsdbool( sy-subrc = 0 ) }| ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " 3. try the assignment and print what TM says
    MODIFY ENTITIES OF i_freightordertp PRIVILEGED
      ENTITY FreightOrder
        EXECUTE AssignFreightUnit
        FROM VALUE #( ( TransportationOrderUUID = lv_fo_uuid
                        %param = VALUE #( _FreightUnits = VALUE #( FOR r IN lt_ref
                                                                   ( FreightUnitUUID          = r-TransportationOrderUUID
                                                                     %control-FreightUnitUUID = if_abap_behv=>mk-on ) )
                                          %control-_FreightUnits = if_abap_behv=>mk-on ) ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    LOOP AT ls_reported-freightorder INTO DATA(ls_rep) WHERE %msg IS BOUND.
      out->write( |   TM: { ls_rep-%msg->if_message~get_text( ) }| ).
    ENDLOOP.

    IF ls_failed IS INITIAL.
      COMMIT ENTITIES RESPONSE OF i_freightordertp
        FAILED   DATA(ls_cfailed)
        REPORTED DATA(ls_creported).
      LOOP AT ls_creported-freightorder INTO DATA(ls_crep) WHERE %msg IS BOUND.
        out->write( |   TM (save): { ls_crep-%msg->if_message~get_text( ) }| ).
      ENDLOOP.
      out->write( |3. assignment { COND #( WHEN ls_cfailed IS INITIAL THEN `SAVED` ELSE `FAILED ON SAVE` ) }| ).
    ELSE.
      ROLLBACK ENTITIES.
      out->write( `3. assignment REFUSED (see TM messages above)` ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
