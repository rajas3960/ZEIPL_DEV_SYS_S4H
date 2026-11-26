CLASS lcl_qty DEFINITION FINAL.
  PUBLIC SECTION.
    " charge whose calculation rule quantity is the FO quantity
    CONSTANTS c_charge_type TYPE string VALUE `SF04`.

    TYPES tt_carrier_keys TYPE TABLE FOR READ IMPORT zr_mm_po_tmcar\\Carrier.

    CLASS-METHODS get_fo_qty
      IMPORTING iv_freightorder TYPE zmm_freight_order_id
      EXPORTING ev_qty          TYPE zmm_po_tmfo-foqty
                ev_unit         TYPE zmm_po_tmfo-founit.

    CLASS-METHODS recalc_allocation
      IMPORTING it_keys TYPE tt_carrier_keys.
ENDCLASS.


CLASS lcl_qty IMPLEMENTATION.

  METHOD get_fo_qty.
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


  METHOD recalc_allocation.
    CHECK it_keys IS NOT INITIAL.

    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( AllocatedQty ) WITH CORRESPONDING #( it_keys )
        RESULT DATA(lt_carrier).

    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier BY \_FreightOrder
        FIELDS ( PurchaseOrder PurchaseOrderItem Carrier FoQty ) WITH CORRESPONDING #( it_keys )
        RESULT DATA(lt_fo).

    DATA lt_update TYPE TABLE FOR UPDATE zr_mm_po_tmcar\\Carrier.
    DATA lv_total  TYPE zmm_po_tmcar-allocatedqty.

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      CLEAR lv_total.
      LOOP AT lt_fo INTO DATA(ls_fo)
           WHERE %is_draft         = ls_carrier-%is_draft
             AND PurchaseOrder     = ls_carrier-PurchaseOrder
             AND PurchaseOrderItem = ls_carrier-PurchaseOrderItem
             AND Carrier           = ls_carrier-Carrier.
        lv_total = lv_total + ls_fo-FoQty.
      ENDLOOP.

      IF lv_total <> ls_carrier-AllocatedQty.
        APPEND VALUE #( %tky         = ls_carrier-%tky
                        AllocatedQty = lv_total
                        %control-AllocatedQty = if_abap_behv=>mk-on )
               TO lt_update.
      ENDIF.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier UPDATE FROM lt_update.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_carrier DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Carrier RESULT result.

    METHODS fillFromPOAndCarrier FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Carrier~fillFromPOAndCarrier.

    METHODS calcAllocatedQty FOR DETERMINE ON SAVE
      IMPORTING keys FOR Carrier~calcAllocatedQty.

    METHODS checkPOItem FOR VALIDATE ON SAVE
      IMPORTING keys FOR Carrier~checkPOItem.

    METHODS checkCarrier FOR VALIDATE ON SAVE
      IMPORTING keys FOR Carrier~checkCarrier.

    METHODS checkAllocation FOR VALIDATE ON SAVE
      IMPORTING keys FOR Carrier~checkAllocation.

    METHODS long_msg
      IMPORTING severity      TYPE if_abap_behv_message=>t_severity
                text          TYPE string
      RETURNING VALUE(result) TYPE REF TO if_abap_behv_message.
ENDCLASS.


CLASS lhc_carrier IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.


  METHOD fillFromPOAndCarrier.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( PurchaseOrder PurchaseOrderItem Carrier CarrierName OrderUnit )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    DATA lt_update TYPE TABLE FOR UPDATE zr_mm_po_tmcar\\Carrier.

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      DATA(lv_unit) = ls_carrier-OrderUnit.
      SELECT SINGLE PurchaseOrderQuantityUnit
        FROM zmm_po_tmpoitem
        WHERE PurchaseOrder     = @ls_carrier-PurchaseOrder
          AND PurchaseOrderItem = @ls_carrier-PurchaseOrderItem
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
    MODIFY ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier UPDATE FROM lt_update.
  ENDMETHOD.


  METHOD calcAllocatedQty.
    lcl_qty=>recalc_allocation( CORRESPONDING #( keys ) ).
  ENDMETHOD.


  METHOD checkPOItem.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( PurchaseOrder PurchaseOrderItem )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      APPEND VALUE #( %tky = ls_carrier-%tky %state_area = 'CHECK_PO' ) TO reported-carrier.

      SELECT SINGLE @abap_true
        FROM zmm_po_tmpoitem WITH PRIVILEGED ACCESS
        WHERE PurchaseOrder     = @ls_carrier-PurchaseOrder
          AND PurchaseOrderItem = @ls_carrier-PurchaseOrderItem
        INTO @DATA(lv_exists).

      IF lv_exists = abap_false.
        APPEND VALUE #( %tky = ls_carrier-%tky ) TO failed-carrier.
        APPEND VALUE #( %tky        = ls_carrier-%tky
                        %state_area = 'CHECK_PO'
                        %msg        = long_msg(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = |PO { ls_carrier-PurchaseOrder } item { ls_carrier-PurchaseOrderItem } does not exist or is deleted| )
                        %element-PurchaseOrder     = if_abap_behv=>mk-on
                        %element-PurchaseOrderItem = if_abap_behv=>mk-on )
               TO reported-carrier.
      ENDIF.
      CLEAR lv_exists.
    ENDLOOP.
  ENDMETHOD.


  METHOD checkCarrier.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
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
                        %msg        = long_msg(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = |Carrier { ls_carrier-Carrier } is not a business partner| )
                        %element-Carrier = if_abap_behv=>mk-on )
               TO reported-carrier.
      ENDIF.
      CLEAR lv_exists.
    ENDLOOP.
  ENDMETHOD.


  METHOD checkAllocation.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier
        FIELDS ( PurchaseOrder PurchaseOrderItem Carrier AllocatedQty OrderUnit )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    LOOP AT lt_carrier INTO DATA(ls_carrier).
      APPEND VALUE #( %tky = ls_carrier-%tky %state_area = 'CHECK_QTY' ) TO reported-carrier.

      DATA(lv_text) = ``.
      IF ls_carrier-AllocatedQty <= 0.
        lv_text = |Add a freight order with an { lcl_qty=>c_charge_type } charge quantity; the carrier quantity is their total|.
      ELSE.
        SELECT SINGLE OrderQuantity
          FROM zmm_po_tmpoitem WITH PRIVILEGED ACCESS
          WHERE PurchaseOrder     = @ls_carrier-PurchaseOrder
            AND PurchaseOrderItem = @ls_carrier-PurchaseOrderItem
          INTO @DATA(lv_poqty).
        IF sy-subrc = 0.
          " saved allocations of the other carriers on this PO item
          SELECT SUM( allocatedqty )
            FROM zmm_po_tmcar
            WHERE purchaseorder     = @ls_carrier-PurchaseOrder
              AND purchaseorderitem = @ls_carrier-PurchaseOrderItem
              AND carrier          <> @ls_carrier-Carrier
            INTO @DATA(lv_others).
          IF lv_others + ls_carrier-AllocatedQty > lv_poqty.
            lv_text = |Carrier quantities total { lv_others + ls_carrier-AllocatedQty NUMBER = USER }|
                   && |, more than the PO item quantity { lv_poqty NUMBER = USER } { ls_carrier-OrderUnit }|.
          ENDIF.
        ENDIF.
        CLEAR: lv_poqty, lv_others.
      ENDIF.

      IF lv_text IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_carrier-%tky ) TO failed-carrier.
        APPEND VALUE #( %tky        = ls_carrier-%tky
                        %state_area = 'CHECK_QTY'
                        %msg        = long_msg(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = lv_text )
                        %element-AllocatedQty = if_abap_behv=>mk-on )
               TO reported-carrier.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD long_msg.
    " new_message_with_text cuts after 50 characters: split the text
    " over the 4 variables of ZMM_PO_TM_MSG 001 (&1&2&3&4)
    DATA lt_v TYPE STANDARD TABLE OF symsgv WITH EMPTY KEY.
    DATA(lv_rest) = text.
    WHILE lv_rest IS NOT INITIAL AND lines( lt_v ) < 4.
      DATA(lv_len) = nmin( val1 = 50 val2 = strlen( lv_rest ) ).
      " a blank at the end of a variable is lost: move it to the next one
      WHILE lv_len > 1 AND substring( val = lv_rest off = lv_len - 1 len = 1 ) = ` `.
        lv_len = lv_len - 1.
      ENDWHILE.
      APPEND substring( val = lv_rest len = lv_len ) TO lt_v.
      lv_rest = substring( val = lv_rest off = lv_len ).
    ENDWHILE.
    result = new_message( id       = 'ZMM_PO_TM_MSG'
                          number   = '001'
                          severity = severity
                          v1       = VALUE #( lt_v[ 1 ] OPTIONAL )
                          v2       = VALUE #( lt_v[ 2 ] OPTIONAL )
                          v3       = VALUE #( lt_v[ 3 ] OPTIONAL )
                          v4       = VALUE #( lt_v[ 4 ] OPTIONAL ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_freightorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS fillFoQty FOR DETERMINE ON MODIFY
      IMPORTING keys FOR FreightOrder~fillFoQty.

    METHODS sumCarrierQty FOR DETERMINE ON MODIFY
      IMPORTING keys FOR FreightOrder~sumCarrierQty.

    METHODS checkFreightOrder FOR VALIDATE ON SAVE
      IMPORTING keys FOR FreightOrder~checkFreightOrder.

    METHODS checkValidity FOR VALIDATE ON SAVE
      IMPORTING keys FOR FreightOrder~checkValidity.

    METHODS long_msg
      IMPORTING severity      TYPE if_abap_behv_message=>t_severity
                text          TYPE string
      RETURNING VALUE(result) TYPE REF TO if_abap_behv_message.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR FreightOrder RESULT result.

ENDCLASS.


CLASS lhc_freightorder IMPLEMENTATION.

  METHOD fillFoQty.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY FreightOrder
        FIELDS ( FreightOrder FoQty FoUnit )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fo).

    DATA lt_update TYPE TABLE FOR UPDATE zr_mm_po_tmcar\\FreightOrder.

    LOOP AT lt_fo INTO DATA(ls_fo).
      lcl_qty=>get_fo_qty( EXPORTING iv_freightorder = ls_fo-FreightOrder
                           IMPORTING ev_qty          = DATA(lv_qty)
                                     ev_unit         = DATA(lv_unit) ).
      IF lv_qty <> ls_fo-FoQty OR lv_unit <> ls_fo-FoUnit.
        APPEND VALUE #( %tky   = ls_fo-%tky
                        FoQty  = lv_qty
                        FoUnit = lv_unit
                        %control = VALUE #( FoQty  = if_abap_behv=>mk-on
                                            FoUnit = if_abap_behv=>mk-on ) )
               TO lt_update.
      ENDIF.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY FreightOrder UPDATE FROM lt_update.
  ENDMETHOD.


  METHOD sumCarrierQty.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY FreightOrder BY \_Carrier
        FIELDS ( Carrier )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_carrier).

    lcl_qty=>recalc_allocation( CORRESPONDING #( lt_carrier ) ).
  ENDMETHOD.


  METHOD checkFreightOrder.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY FreightOrder
        FIELDS ( FoUuid PurchaseOrder PurchaseOrderItem Carrier FreightOrder )
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
        lv_text = |Freight order { ls_fo-FreightOrder } does not exist in TM|.
      ELSEIF |{ lv_tm_carrier ALPHA = IN }| <> |{ ls_fo-Carrier ALPHA = IN }|.
        lv_text = |Freight order { ls_fo-FreightOrder } belongs to carrier { lv_tm_carrier ALPHA = OUT }|
               && |, not { ls_fo-Carrier ALPHA = OUT }|.
      ELSE.
        lcl_qty=>get_fo_qty( EXPORTING iv_freightorder = ls_fo-FreightOrder
                             IMPORTING ev_qty          = DATA(lv_qty)
                                       ev_unit         = DATA(lv_unit) ).
        SELECT SINGLE PurchaseOrderQuantityUnit
          FROM zmm_po_tmpoitem WITH PRIVILEGED ACCESS
          WHERE PurchaseOrder     = @ls_fo-PurchaseOrder
            AND PurchaseOrderItem = @ls_fo-PurchaseOrderItem
          INTO @DATA(lv_po_unit).
        IF lv_qty <= 0.
          lv_text = |Freight order { ls_fo-FreightOrder ALPHA = OUT } has no { lcl_qty=>c_charge_type } charge quantity in TM|
                 && |; calculate its charges first|.
        ELSEIF lv_unit <> lv_po_unit.
          lv_text = |Freight order { ls_fo-FreightOrder ALPHA = OUT } quantity is in { lv_unit }|
                 && |, the PO item in { lv_po_unit }|.
        ENDIF.
        CLEAR lv_po_unit.
      ENDIF.

      " an FO belongs to one PO item + carrier only (whole table);
      " repeats within this PO item + carrier = checkValidity
      IF lv_text IS INITIAL.
        SELECT SINGLE purchaseorder, purchaseorderitem
          FROM zmm_po_tmfo
          WHERE freightorder = @ls_fo-FreightOrder
            AND ( purchaseorder     <> @ls_fo-PurchaseOrder
               OR purchaseorderitem <> @ls_fo-PurchaseOrderItem
               OR carrier           <> @ls_fo-Carrier )
          INTO @DATA(ls_used).
        IF sy-subrc = 0.
          lv_text = |FO { ls_fo-FreightOrder ALPHA = OUT } used on PO { ls_used-purchaseorder ALPHA = OUT }/{ ls_used-purchaseorderitem ALPHA = OUT }|.
        ENDIF.
        CLEAR ls_used.
      ENDIF.

      CLEAR lv_tm_carrier.

      IF lv_text IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_fo-%tky ) TO failed-freightorder.
        APPEND VALUE #( %tky        = ls_fo-%tky
                        %state_area = 'CHECK_FO'
                        %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) )
                        %msg        = long_msg(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = lv_text )
                        %element-FreightOrder = if_abap_behv=>mk-on )
               TO reported-freightorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD checkValidity.
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY FreightOrder
        FIELDS ( PurchaseOrder PurchaseOrderItem Carrier FreightOrder ValidFrom ValidTo )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fo).

    " all freight orders of the same carriers (siblings), same draft state
    READ ENTITIES OF zr_mm_po_tmcar IN LOCAL MODE
      ENTITY Carrier BY \_FreightOrder
        FIELDS ( PurchaseOrder PurchaseOrderItem Carrier FreightOrder ValidFrom ValidTo )
        WITH VALUE #( FOR f IN lt_fo ( %tky = VALUE #( %is_draft         = f-%is_draft
                                                       PurchaseOrder     = f-PurchaseOrder
                                                       PurchaseOrderItem = f-PurchaseOrderItem
                                                       Carrier           = f-Carrier ) ) )
      RESULT DATA(lt_sibling).

    LOOP AT lt_fo INTO DATA(ls_fo).
      APPEND VALUE #( %tky        = ls_fo-%tky
                      %state_area = 'CHECK_DATES'
                      %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) ) )
             TO reported-freightorder.

      DATA(lv_text) = ``.
      IF ls_fo-ValidFrom IS INITIAL OR ls_fo-ValidTo IS INITIAL.
        lv_text = |Enter Valid From and Valid To for freight order { ls_fo-FreightOrder }|.
      ELSEIF ls_fo-ValidFrom > ls_fo-ValidTo.
        lv_text = |Valid From is after Valid To for freight order { ls_fo-FreightOrder }|.
      ELSE.
        LOOP AT lt_sibling INTO DATA(ls_other)
             WHERE %is_draft         = ls_fo-%is_draft
               AND PurchaseOrder     = ls_fo-PurchaseOrder
               AND PurchaseOrderItem = ls_fo-PurchaseOrderItem
               AND Carrier           = ls_fo-Carrier
               AND FoUuid           <> ls_fo-FoUuid.
          IF ls_other-FreightOrder = ls_fo-FreightOrder.
            lv_text = |Freight order { ls_fo-FreightOrder ALPHA = OUT } is entered twice for this carrier|.
            EXIT.
          ELSEIF ls_other-ValidFrom <= ls_fo-ValidTo AND ls_other-ValidTo >= ls_fo-ValidFrom.
            lv_text = |Freight order { ls_fo-FreightOrder ALPHA = OUT } ({ ls_fo-ValidFrom DATE = USER } - { ls_fo-ValidTo DATE = USER })|
                   && | overlaps freight order { ls_other-FreightOrder ALPHA = OUT } ({ ls_other-ValidFrom DATE = USER } - { ls_other-ValidTo DATE = USER })|.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lv_text IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_fo-%tky ) TO failed-freightorder.
        APPEND VALUE #( %tky        = ls_fo-%tky
                        %state_area = 'CHECK_DATES'
                        %path       = VALUE #( carrier = CORRESPONDING #( ls_fo ) )
                        %msg        = long_msg(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = lv_text )
                        %element-ValidFrom = if_abap_behv=>mk-on
                        %element-ValidTo   = if_abap_behv=>mk-on )
               TO reported-freightorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD long_msg.
    " new_message_with_text cuts after 50 characters: split the text
    " over the 4 variables of ZMM_PO_TM_MSG 001 (&1&2&3&4)
    DATA lt_v TYPE STANDARD TABLE OF symsgv WITH EMPTY KEY.
    DATA(lv_rest) = text.
    WHILE lv_rest IS NOT INITIAL AND lines( lt_v ) < 4.
      DATA(lv_len) = nmin( val1 = 50 val2 = strlen( lv_rest ) ).
      " a blank at the end of a variable is lost: move it to the next one
      WHILE lv_len > 1 AND substring( val = lv_rest off = lv_len - 1 len = 1 ) = ` `.
        lv_len = lv_len - 1.
      ENDWHILE.
      APPEND substring( val = lv_rest len = lv_len ) TO lt_v.
      lv_rest = substring( val = lv_rest off = lv_len ).
    ENDWHILE.
    result = new_message( id       = 'ZMM_PO_TM_MSG'
                          number   = '001'
                          severity = severity
                          v1       = VALUE #( lt_v[ 1 ] OPTIONAL )
                          v2       = VALUE #( lt_v[ 2 ] OPTIONAL )
                          v3       = VALUE #( lt_v[ 3 ] OPTIONAL )
                          v4       = VALUE #( lt_v[ 4 ] OPTIONAL ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    " saved FO lines: the freight order can no longer be changed
    SELECT fouuid
      FROM zmm_po_tmfo
      FOR ALL ENTRIES IN @keys
      WHERE fouuid = @keys-FoUuid
      INTO TABLE @DATA(lt_saved).

    result = VALUE #( FOR k IN keys
                      ( %tky                = k-%tky
                        %field-FreightOrder = COND #( WHEN line_exists( lt_saved[ fouuid = k-FoUuid ] )
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-mandatory ) ) ).
  ENDMETHOD.

ENDCLASS.

