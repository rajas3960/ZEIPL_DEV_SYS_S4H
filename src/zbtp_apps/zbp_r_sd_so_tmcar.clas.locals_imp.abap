CLASS lhc_carrier DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Carrier RESULT result.

    METHODS fillFromSOAndCarrier FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Carrier~fillFromSOAndCarrier.

    METHODS checkSOItem FOR VALIDATE ON SAVE
      IMPORTING keys FOR Carrier~checkSOItem.

    METHODS checkCarrier FOR VALIDATE ON SAVE
      IMPORTING keys FOR Carrier~checkCarrier.
ENDCLASS.


CLASS lhc_carrier IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.


  METHOD fillFromSOAndCarrier.
    READ ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( SalesOrder SalesOrderItem Carrier CarrierName OrderUnit )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    DATA lt_update TYPE TABLE FOR UPDATE zr_sd_so_tmcar\\Carrier.

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      DATA(lv_unit) = ls_carrier-OrderUnit.
      SELECT SINGLE OrderQuantityUnit
        FROM zsd_so_tmsoitem
        WHERE SalesOrder     = @ls_carrier-SalesOrder
          AND SalesOrderItem = @ls_carrier-SalesOrderItem
        INTO @lv_unit.

      DATA(lv_name) = ls_carrier-CarrierName.
      SELECT SINGLE BusinessPartnerFullName
        FROM i_businesspartner WITH PRIVILEGED ACCESS
        WHERE BusinessPartner = @ls_carrier-Carrier
        INTO @lv_name.

      IF lv_unit <> ls_carrier-OrderUnit OR lv_name <> ls_carrier-CarrierName.
        APPEND VALUE #( %tky        = ls_carrier-%tky
                        OrderUnit   = lv_unit
                        CarrierName = lv_name
                        %control    = VALUE #( OrderUnit   = if_abap_behv=>mk-on
                                               CarrierName = if_abap_behv=>mk-on ) )
               TO lt_update.
      ENDIF.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY Carrier UPDATE FROM lt_update.
  ENDMETHOD.


  METHOD checkSOItem.
    READ ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( SalesOrder SalesOrderItem )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      APPEND VALUE #( %tky = ls_carrier-%tky %state_area = 'CHECK_SO' ) TO reported-carrier.

      SELECT SINGLE @abap_true
        FROM zsd_so_tmsoitem WITH PRIVILEGED ACCESS
        WHERE SalesOrder     = @ls_carrier-SalesOrder
          AND SalesOrderItem = @ls_carrier-SalesOrderItem
        INTO @DATA(lv_exists).

      IF lv_exists = abap_false.
        APPEND VALUE #( %tky = ls_carrier-%tky ) TO failed-carrier.
        APPEND VALUE #( %tky        = ls_carrier-%tky
                        %state_area = 'CHECK_SO'
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = |SO { ls_carrier-SalesOrder ALPHA = OUT }/{ CONV i( ls_carrier-SalesOrderItem ) } not found| )
                        %element-SalesOrder     = if_abap_behv=>mk-on
                        %element-SalesOrderItem = if_abap_behv=>mk-on )
               TO reported-carrier.
      ENDIF.
      CLEAR lv_exists.
    ENDLOOP.
  ENDMETHOD.


  METHOD checkCarrier.
    READ ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( Carrier )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      APPEND VALUE #( %tky = ls_carrier-%tky %state_area = 'CHECK_CARRIER' ) TO reported-carrier.

      SELECT SINGLE @abap_true
        FROM i_businesspartner WITH PRIVILEGED ACCESS
        WHERE BusinessPartner = @ls_carrier-Carrier
        INTO @DATA(lv_exists).

      IF lv_exists = abap_false.
        APPEND VALUE #( %tky = ls_carrier-%tky ) TO failed-carrier.
        APPEND VALUE #( %tky        = ls_carrier-%tky
                        %state_area = 'CHECK_CARRIER'
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = |Carrier { ls_carrier-Carrier ALPHA = OUT } is not a business partner| )
                        %element-Carrier = if_abap_behv=>mk-on )
               TO reported-carrier.
      ENDIF.
      CLEAR lv_exists.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_freightorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS checkFreightOrder FOR VALIDATE ON SAVE
      IMPORTING keys FOR FreightOrder~checkFreightOrder.

    METHODS checkDuplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR FreightOrder~checkDuplicate.
ENDCLASS.


CLASS lhc_freightorder IMPLEMENTATION.

  METHOD checkFreightOrder.
    " FO exists in TM and belongs to the carrier of this line
    READ ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY FreightOrder
        FIELDS ( Carrier FreightOrder )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fo).

    LOOP AT lt_fo INTO DATA(ls_fo).
      APPEND VALUE #( %tky        = ls_fo-%tky
                      %state_area = 'CHECK_FO'
                      %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) ) )
             TO reported-freightorder.

      DATA(lv_text) = ``.
      SELECT SINGLE Carrier
        FROM i_freightordertp WITH PRIVILEGED ACCESS
        WHERE TransportationOrder = @ls_fo-FreightOrder
        INTO @DATA(lv_tm_carrier).
      IF sy-subrc <> 0.
        lv_text = |FO { ls_fo-FreightOrder ALPHA = OUT } not found in TM|.
      ELSEIF |{ lv_tm_carrier ALPHA = IN }| <> |{ ls_fo-Carrier ALPHA = IN }|.
        lv_text = |FO { ls_fo-FreightOrder ALPHA = OUT } is of carrier { lv_tm_carrier ALPHA = OUT }|.
      ENDIF.
      CLEAR lv_tm_carrier.

      IF lv_text IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_fo-%tky ) TO failed-freightorder.
        APPEND VALUE #( %tky        = ls_fo-%tky
                        %state_area = 'CHECK_FO'
                        %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) )
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = lv_text )
                        %element-FreightOrder = if_abap_behv=>mk-on )
               TO reported-freightorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD checkDuplicate.
    " the same freight order only once per carrier
    READ ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY FreightOrder
        FIELDS ( SalesOrder SalesOrderItem Carrier FreightOrder )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fo).

    READ ENTITIES OF zr_sd_so_tmcar IN LOCAL MODE
      ENTITY Carrier BY \_FreightOrder
        FIELDS ( SalesOrder SalesOrderItem Carrier FreightOrder )
        WITH VALUE #( FOR f IN lt_fo ( %tky = VALUE #( %is_draft      = f-%is_draft
                                                       SalesOrder     = f-SalesOrder
                                                       SalesOrderItem = f-SalesOrderItem
                                                       Carrier        = f-Carrier ) ) )
      RESULT DATA(lt_sibling).

    LOOP AT lt_fo INTO DATA(ls_fo).
      APPEND VALUE #( %tky        = ls_fo-%tky
                      %state_area = 'CHECK_DUP'
                      %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) ) )
             TO reported-freightorder.

      DATA(lv_count) = 0.
      LOOP AT lt_sibling INTO DATA(ls_other)
           WHERE %is_draft      = ls_fo-%is_draft
             AND SalesOrder     = ls_fo-SalesOrder
             AND SalesOrderItem = ls_fo-SalesOrderItem
             AND Carrier        = ls_fo-Carrier
             AND FreightOrder   = ls_fo-FreightOrder.
        lv_count += 1.
      ENDLOOP.

      IF lv_count > 1.
        APPEND VALUE #( %tky = ls_fo-%tky ) TO failed-freightorder.
        APPEND VALUE #( %tky        = ls_fo-%tky
                        %state_area = 'CHECK_DUP'
                        %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) )
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = |FO { ls_fo-FreightOrder ALPHA = OUT } entered twice| )
                        %element-FreightOrder = if_abap_behv=>mk-on )
               TO reported-freightorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
