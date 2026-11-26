CLASS zcl_sd_owght_post_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

    TYPES ty_qty TYPE p LENGTH 8 DECIMALS 3.

    TYPES: BEGIN OF ty_req_item,
             salesdocument              TYPE c LENGTH 10,
             salesitem                  TYPE n LENGTH 6,
             material                   TYPE c LENGTH 40,
             plant                      TYPE c LENGTH 4,
             storagelocation            TYPE c LENGTH 4,
             netweight                  TYPE ty_qty,
             unit                       TYPE c LENGTH 3,
             independentrequirementtype TYPE c LENGTH 4,
             shippingpoint              TYPE c LENGTH 4,
             deliveryno                 TYPE c LENGTH 10,
             deliveritem                TYPE n LENGTH 6,
             transportdocumentn         TYPE c LENGTH 20,     ""custom field update added on 19.10.2026
             modeoftransport            TYPE c LENGTH 10,
             transportid                TYPE c LENGTH 10,
             vehiclerrno                TYPE c LENGTH 20,
             sdgateentryno              TYPE c LENGTH 20,
             transportdocumentd         TYPE d,
             vehicletype                TYPE c LENGTH 10,
             transportername            TYPE c LENGTH 20,
             gateentrydate              TYPE d,
             gateentrytime              TYPE t,
             freightorder               TYPE c LENGTH 20,     " FU -> FO, added on 30.10.2026

           END OF ty_req_item,
           tt_req_item TYPE STANDARD TABLE OF ty_req_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_request,
             operation     TYPE c LENGTH 10,
             gateentrytype TYPE c LENGTH 4,
             deliveryno    TYPE c LENGTH 10,
             Transporterid TYPE c LENGTH 10,
             items         TYPE tt_req_item,
           END OF ty_request.

    TYPES: BEGIN OF ty_resp_item,
             salesdocument TYPE c LENGTH 10,
             salesitem     TYPE n LENGTH 6,
             deliveryno    TYPE c LENGTH 10,
             deliveritem   TYPE n LENGTH 6,
           END OF ty_resp_item,
           tt_resp_item TYPE STANDARD TABLE OF ty_resp_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_response,
             success              TYPE abap_bool,
             message              TYPE string,
             deliveryno           TYPE c LENGTH 10,
             items                TYPE tt_resp_item,
             billingdocument      TYPE c LENGTH 10,
             billingdocumentdate  TYPE d,
             einvoiceno           TYPE string,
             einvoicedate         TYPE d,
             ewaybillno           TYPE string,
             ewaybilldate         TYPE d,
             materialdocument     TYPE c LENGTH 10,
             materialdocumentyear TYPE n LENGTH 4,
             Transporterid        TYPE c LENGTH 10,
             Transportername      TYPE c LENGTH 81,
             fomessage            TYPE string,                " FU -> FO, added on 30.10.2026
           END OF ty_response.

  PRIVATE SECTION.
    METHODS create_delivery
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    METHODS picking_qty
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    "! Sets the delivery quantity of the new delivery items to the net
    "! (gate) weight. CreateDlvFromSalesDocument has no quantity
    "! parameter and always takes the open order quantity.
    "! Returns an error text, or nothing when all went well.
    METHODS set_delivery_qty
      IMPORTING is_request        TYPE ty_request
                it_dlv_items      TYPE tt_resp_item
      RETURNING VALUE(rv_message) TYPE string.

    METHODS check_credit
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    METHODS get_billing
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    METHODS get_material_document
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    "! S/4 database format of the material: BTP stores the external
    "! format from the OData call (15000025), the stock views need the
    "! internal one (000000000015000025 for a numeric material)
    METHODS internal_material
      IMPORTING iv_material       TYPE clike
      RETURNING VALUE(rv_product) TYPE i_product-product.

    "! unrestricted stock - open production reservations (S/4 logic)
    METHODS available_stock
      IMPORTING is_item       TYPE ty_req_item
      RETURNING VALUE(rv_qty) TYPE ty_qty.

    "! <p class="shorttext synchronized" lang="en"></p>
    "!
    "! @parameter is_request | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter rs_response | <p class="shorttext synchronized" lang="en"></p>
    METHODS get_transporter
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    "! Starts the background assignment of the delivery's freight unit(s)
    "! to the items' freight order (ZCL_MM_FU_LINK_BG); returns a message
    METHODS link_freight_units
      IMPORTING is_request        TYPE ty_request
                iv_delivery       TYPE ty_response-deliveryno
      RETURNING VALUE(rv_message) TYPE string.

ENDCLASS.



CLASS zcl_sd_owght_post_http IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA ls_request TYPE ty_request.

    " a plain GET (browser) is a connectivity check only
    IF request->get_method( ) <> 'POST'.
      response->set_text( `ZSD_OWGHT_POST is reachable. Use POST with a JSON body.` ).
      RETURN.
    ENDIF.

    /ui2/cl_json=>deserialize( EXPORTING json        = request->get_text( )
                                         pretty_name = /ui2/cl_json=>pretty_mode-low_case
                               CHANGING  data        = ls_request ).
    CONDENSE ls_request-gateentrytype.

    DATA(ls_response) = SWITCH ty_response( ls_request-operation
                          WHEN 'CRTDLV'   THEN create_delivery( ls_request )
                          WHEN 'PICK'     THEN picking_qty( ls_request )
                          WHEN 'PGICHECK' THEN check_credit( ls_request )
                          WHEN 'BILLING'  THEN get_billing( ls_request )
                          WHEN 'MATDOC'   THEN get_material_document( ls_request )
                          WHEN 'TRANSP'   THEN get_transporter( ls_request )
                          ELSE VALUE #( message = |Unknown operation "{ ls_request-operation }"| ) ).

    response->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
    response->set_text( /ui2/cl_json=>serialize( data        = ls_response
                                                 pretty_name = /ui2/cl_json=>pretty_mode-low_case ) ).
  ENDMETHOD.


  METHOD internal_material.
    DATA lv_numeric TYPE n LENGTH 18.

    rv_product = iv_material.
    SELECT SINGLE @abap_true FROM i_product WITH PRIVILEGED ACCESS
      WHERE Product = @rv_product
      INTO @DATA(lv_found).
    IF lv_found = abap_true.
      RETURN.
    ENDIF.

    " numeric material number without leading zeros -> pad to 18
    DATA(lv_text) = condense( CONV string( iv_material ) ).
    IF lv_text IS NOT INITIAL AND lv_text CO '0123456789' AND strlen( lv_text ) <= 18.
      lv_numeric = lv_text.
      rv_product = lv_numeric.
    ENDIF.
  ENDMETHOD.


  METHOD available_stock.
    DATA lv_stock TYPE ty_qty.

    DATA(lv_product) = internal_material( is_item-material ).

    IF is_item-independentrequirementtype = 'BB6' OR is_item-independentrequirementtype = '040'.
      " make-to-order: stock of this order item
      SELECT SINGLE MatlWrhsStkQtyInMatlBaseUnit FROM zsd_open_stk1 WITH PRIVILEGED ACCESS
        WHERE Product         = @lv_product
          AND Plant           = @is_item-plant
          AND StorageLocation = @is_item-storagelocation
          AND SDDocument      = @is_item-salesdocument
          AND SDDocumentItem  = @is_item-salesitem
        INTO @lv_stock.
    ELSE.
      " normal stock
      SELECT SINGLE MatlWrhsStkQtyInMatlBaseUnit FROM zsd_open_stk1 WITH PRIVILEGED ACCESS
        WHERE Product         = @lv_product
          AND Plant           = @is_item-plant
          AND StorageLocation = @is_item-storagelocation
          AND SDDocument      IS INITIAL
        INTO @lv_stock.
    ENDIF.

    SELECT SINGLE PrdQty, WitdraQty FROM zsd_prd_stk1 WITH PRIVILEGED ACCESS
      WHERE Product         = @lv_product
        AND Plant           = @is_item-plant
        AND StorageLocation = @is_item-storagelocation
      INTO @DATA(ls_prd).

    rv_qty = lv_stock - ( ls_prd-PrdQty - ls_prd-WitdraQty ).
  ENDMETHOD.


  METHOD create_delivery.
    DATA lv_seldate  TYPE d.
    DATA lv_dlvtype  TYPE c LENGTH 4.
    DATA lv_existing TYPE c LENGTH 10.

    IF is_request-items IS INITIAL.
      rs_response-message = 'No items to deliver'.
      RETURN.
    ENDIF.

    DATA(ls_first) = is_request-items[ 1 ].

    " 0. 10.11.2026: one delivery per gate entry (retry after a lost answer)
    IF ls_first-sdgateentryno IS NOT INITIAL.
      SELECT SINGLE OutboundDelivery FROM i_outbounddeliverytp WITH PRIVILEGED ACCESS
        WHERE yy1_sdgateentryno_dlh = @ls_first-sdgateentryno
        INTO @lv_existing.
    ENDIF.
    IF lv_existing IS INITIAL.
      DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
      " delivery of today, no gate entry number yet, not goods-issued,
      " that holds the first SO item of this truck
      SELECT h~OutboundDelivery
        FROM i_outbounddeliverytp WITH PRIVILEGED ACCESS AS h
          INNER JOIN i_deliverydocumentitem AS i
            ON i~DeliveryDocument = h~OutboundDelivery
        WHERE h~CreationDate               = @lv_today
          AND h~yy1_sdgateentryno_dlh      = @space
          AND h~OverallGoodsMovementStatus <> 'C'
          AND i~ReferenceSDDocument        = @ls_first-salesdocument
          AND i~ReferenceSDDocumentItem    = @ls_first-salesitem
        ORDER BY h~OutboundDelivery
        INTO TABLE @DATA(lt_match)
        UP TO 1 ROWS.
      lv_existing = VALUE #( lt_match[ 1 ]-OutboundDelivery OPTIONAL ).
    ENDIF.

    IF lv_existing IS NOT INITIAL.
      rs_response-deliveryno = lv_existing.
      rs_response-success    = abap_true.
      rs_response-message    = |Delivery { lv_existing ALPHA = OUT } already existed for gate entry| &&
                               | { ls_first-sdgateentryno } - no new delivery created|.
    ELSE.

      " 1. storage location and stock (same checks as the S/4 CrtDelivery)
      LOOP AT is_request-items INTO DATA(ls_item).
        IF ls_item-storagelocation IS INITIAL.
          rs_response-message = 'Storage Location is mandatory'.
          RETURN.
        ENDIF.
        IF ls_item-netweight IS INITIAL.
          CONTINUE.
        ENDIF.
        DATA(lv_available) = available_stock( ls_item ).
        IF ls_item-netweight > lv_available.
          rs_response-message = |Only { lv_available } TO of material { ls_item-material ALPHA = OUT } available| &&
                                | in plant { ls_item-plant } / storage location { ls_item-storagelocation }|.
          RETURN.
        ENDIF.
      ENDLOOP.

      " 2. selection date and delivery type
      SELECT SINGLE CommittedDeliveryDate FROM i_salesdocumentitem WITH PRIVILEGED ACCESS
        WHERE SalesDocument     = @ls_first-salesdocument
          AND SalesDocumentItem = @ls_first-salesitem
        INTO @lv_seldate.
      IF lv_seldate IS INITIAL.
        lv_seldate = cl_abap_context_info=>get_system_date( ).
      ENDIF.

      lv_dlvtype = SWITCH #( is_request-gateentrytype WHEN 'SD1' THEN 'LF'
                                                      WHEN 'SD2' THEN 'LR' ).

      " 3. delivery (same EML as the S/4 CrtDelivery)
      MODIFY ENTITIES OF i_outbounddeliverytp PRIVILEGED
        ENTITY OutboundDelivery
        EXECUTE CreateDlvFromSalesDocument
        FROM VALUE #( ( %cid   = 'DLV001'
                        %param = VALUE #( %control = VALUE #( shippingpoint         = if_abap_behv=>mk-on
                                                              deliveryselectiondate = if_abap_behv=>mk-on
                                                              deliverydocumenttype  = if_abap_behv=>mk-on )
                                          shippingpoint         = ls_first-shippingpoint
                                          deliveryselectiondate = lv_seldate
                                          deliverydocumenttype  = lv_dlvtype

                                          _referencesddocumentitem = VALUE #(
                                            FOR itm IN is_request-items
                                            ( %control = VALUE #( referencesddocument     = if_abap_behv=>mk-on
                                                                  referencesddocumentitem = if_abap_behv=>mk-on )
                                              referencesddocument     = itm-salesdocument
                                              referencesddocumentitem = itm-salesitem ) ) ) ) )
        MAPPED DATA(ls_mapped)
        REPORTED DATA(ls_reported)
        FAILED DATA(ls_failed).

      IF ls_failed IS NOT INITIAL OR ls_mapped-outbounddelivery IS INITIAL.
        LOOP AT ls_reported-outbounddelivery INTO DATA(ls_rep) WHERE %msg IS BOUND.
          rs_response-message = |{ rs_response-message }{ ls_rep-%msg->if_message~get_text( ) } |.
        ENDLOOP.
        IF rs_response-message IS INITIAL.
          rs_response-message = 'The delivery could not be created'.
        ENDIF.
        ROLLBACK ENTITIES.
        RETURN.
      ENDIF.

      COMMIT ENTITIES BEGIN
        RESPONSE OF i_outbounddeliverytp
        FAILED DATA(ls_commit_failed)
        REPORTED DATA(ls_commit_reported).

      IF ls_commit_failed IS INITIAL.
        LOOP AT ls_mapped-outbounddelivery ASSIGNING FIELD-SYMBOL(<ls_dlv>).
          " same CONVERT KEY as the S/4 saver (from %pid)
          CONVERT KEY OF i_outbounddeliverytp FROM <ls_dlv>-%pid TO DATA(ls_dlv_key).
          rs_response-deliveryno = ls_dlv_key-outbounddelivery.
        ENDLOOP.
        rs_response-success = abap_true.
      ELSE.
        LOOP AT ls_commit_reported-outbounddelivery INTO DATA(ls_crep) WHERE %msg IS BOUND.
          rs_response-message = |{ rs_response-message }{ ls_crep-%msg->if_message~get_text( ) } |.
        ENDLOOP.
      ENDIF.

      COMMIT ENTITIES END.
    ENDIF.

    " 4. delivery item per order item (also works for return deliveries)
    IF rs_response-success = abap_true.
      SELECT DeliveryDocument, DeliveryDocumentItem, ReferenceSDDocument, ReferenceSDDocumentItem
        FROM i_deliverydocumentitem WITH PRIVILEGED ACCESS
        WHERE DeliveryDocument = @rs_response-deliveryno
        INTO TABLE @DATA(lt_dlvitem).

      rs_response-items = VALUE #( FOR d IN lt_dlvitem
                                   ( salesdocument = d-ReferenceSDDocument
                                     salesitem     = d-ReferenceSDDocumentItem
                                     deliveryno    = d-DeliveryDocument
                                     deliveritem   = d-DeliveryDocumentItem ) ).

      " 5. delivery quantity = net (gate) weight (2026-10-08). The delivery
      "    exists already, so a failure here is reported as a warning text
      "    and the delivery number still goes back to BTP.
      DATA(lv_qty_error) = set_delivery_qty( is_request   = is_request
                                             it_dlv_items = rs_response-items ).
      IF lv_qty_error IS NOT INITIAL.
        rs_response-message = |{ rs_response-message } Delivery quantity not set to the net weight: { lv_qty_error }| &&
                              | Use Picking Qty to set it.|.
      ENDIF.

      " 6. freight unit(s) of the delivery -> item's freight order
      "    (background job, added on 30.10.2026; a second run on an existing
      "    delivery only logs ALREADY)
      rs_response-fomessage = link_freight_units( is_request  = is_request
                                                  iv_delivery = rs_response-deliveryno ).
    ENDIF.
  ENDMETHOD.


  METHOD set_delivery_qty.
    " plain list first; the MODIFY below builds the EML table itself
    " (same form as in picking_qty)
    TYPES: BEGIN OF ty_upd,
             deliveryno  TYPE c LENGTH 10,
             deliveritem TYPE n LENGTH 6,
             netweight   TYPE ty_qty,
             unit        TYPE c LENGTH 3,
           END OF ty_upd.
    DATA lt_update TYPE STANDARD TABLE OF ty_upd WITH EMPTY KEY.

    LOOP AT is_request-items INTO DATA(ls_item) WHERE netweight IS NOT INITIAL.
      " order numbers may come with or without leading zeros
      LOOP AT it_dlv_items INTO DATA(ls_dlv)
           WHERE salesitem = ls_item-salesitem.
        IF condense( |{ ls_dlv-salesdocument ALPHA = OUT }| ) = condense( |{ ls_item-salesdocument ALPHA = OUT }| ).
          APPEND VALUE #( deliveryno  = ls_dlv-deliveryno
                          deliveritem = ls_dlv-deliveritem
                          netweight   = ls_item-netweight
                          unit        = ls_item-unit )
                 TO lt_update.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF lt_update IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_cusfield) = VALUE #( is_request-items[ 1 ] OPTIONAL ).

    MODIFY ENTITIES OF i_outbounddeliverytp PRIVILEGED
      ENTITY OutboundDeliveryItem
      UPDATE FIELDS ( ActualDeliveredQtyInOrderUnit OrderQuantityUnit )
      WITH VALUE #( FOR u IN lt_update
                    ( %tky-OutboundDelivery         = u-deliveryno
                      %tky-OutboundDeliveryItem     = u-deliveritem
                      ActualDeliveredQtyInOrderUnit = u-netweight
                      OrderQuantityUnit             = u-unit ) )

      "new one added on 19.10.2026 custom field update
      " 05.11.2026: ONE row per delivery header - one row per item gave the
      " dump DUPLICATE_UPDATE as soon as a truck had 2 or more lines
      ENTITY OutboundDelivery
      UPDATE FIELDS ( yy1_transportdocumentn_dlh yy1_modeoftransport_dlh yy1_vehiclerrno_dlh
                      yy1_transportid_dlh yy1_sdgateentryno_dlh yy1_transportdocumentd_dlh
                      yy1_vehicletype_dlh yy1_transportername_dlh YY1_GateEntryDate_DLH
                      YY1_GateEntryTime_DLH )
      WITH VALUE #( FOR GROUPS lv_dlv OF u IN lt_update GROUP BY u-deliveryno
                    ( %tky-OutboundDelivery          = lv_dlv
                      yy1_transportdocumentn_dlh = ls_cusfield-transportdocumentn
                      yy1_modeoftransport_dlh    = ls_cusfield-modeoftransport
                      yy1_vehiclerrno_dlh        = ls_cusfield-vehiclerrno
                      yy1_transportid_dlh        = ls_cusfield-transportid
                      yy1_sdgateentryno_dlh      = ls_cusfield-sdgateentryno
                      yy1_transportdocumentd_dlh = ls_cusfield-transportdocumentd
                      yy1_vehicletype_dlh        = ls_cusfield-vehicletype
                      yy1_transportername_dlh    = ls_cusfield-transportername
                      YY1_GateEntryDate_DLH      = ls_cusfield-gateentrydate
                      YY1_GateEntryTime_DLH      = ls_cusfield-gateentrytime ) )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      LOOP AT ls_reported-outbounddeliveryitem INTO DATA(ls_rep) WHERE %msg IS BOUND.
        rv_message = |{ rv_message }{ ls_rep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      LOOP AT ls_reported-outbounddelivery INTO DATA(ls_rep_h) WHERE %msg IS BOUND.
        rv_message = |{ rv_message }{ ls_rep_h-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      IF rv_message IS INITIAL.
        rv_message = 'update rejected'.
      ENDIF.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES BEGIN
      RESPONSE OF i_outbounddeliverytp
      FAILED DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS NOT INITIAL.
      LOOP AT ls_commit_reported-outbounddeliveryitem INTO DATA(ls_crep) WHERE %msg IS BOUND.
        rv_message = |{ rv_message }{ ls_crep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      LOOP AT ls_commit_reported-outbounddelivery INTO DATA(ls_crep_h) WHERE %msg IS BOUND.
        rv_message = |{ rv_message }{ ls_crep_h-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      IF rv_message IS INITIAL.
        rv_message = 'save failed'.
      ENDIF.
    ENDIF.

    COMMIT ENTITIES END.
  ENDMETHOD.


  METHOD link_freight_units.   "new one added on 30.10.2026
    " one freight order on the delivery -> its freight unit(s) are assigned
    " in the background (ZCL_MM_FU_LINK_BG, bgPF): TM builds them after the
    " delivery save. Every step is logged in ZMM_FU_LINK_LOG (direction OUT).
    DATA lt_fo TYPE SORTED TABLE OF ty_req_item-freightorder WITH UNIQUE KEY table_line.
    LOOP AT is_request-items INTO DATA(ls_item) WHERE freightorder IS NOT INITIAL.
      INSERT ls_item-freightorder INTO TABLE lt_fo.
    ENDLOOP.
    IF lt_fo IS INITIAL.
      RETURN.
    ENDIF.
    IF lines( lt_fo ) > 1.
      rv_message = |Several freight orders on delivery { iv_delivery ALPHA = OUT } - assign the freight units in TM|.
      RETURN.
    ENDIF.

    DATA(lv_fo) = lt_fo[ 1 ].
    TRY.
        DATA(lo_process) = cl_bgmc_process_factory=>get_default( )->create( ).
        lo_process->set_name( |Assign FU of delivery { iv_delivery ALPHA = OUT }| ).
        lo_process->set_operation_tx_uncontrolled( NEW zcl_mm_fu_link_bg( iv_delivery     = iv_delivery
                                                                          iv_freightorder = lv_fo
                                                                          iv_direction    = 'OUT' ) ).
        lo_process->save_for_execution( ).
        COMMIT WORK.
        zcl_mm_fu_link_bg=>write_log( iv_direction    = 'OUT'
                                      iv_delivery     = iv_delivery
                                      iv_freightorder = lv_fo
                                      iv_status       = 'QUEUED'
                                      iv_message      = 'background job handed to bgPF' ).
        rv_message = |Freight unit will be assigned to freight order { lv_fo ALPHA = OUT } in a few seconds|.
      CATCH cx_bgmc INTO DATA(lx_bgmc).
        zcl_mm_fu_link_bg=>write_log( iv_direction    = 'OUT'
                                      iv_delivery     = iv_delivery
                                      iv_freightorder = lv_fo
                                      iv_status       = 'NOT_QUEUED'
                                      iv_message      = lx_bgmc->get_text( ) ).
        rv_message = |Freight unit not assigned (background start failed): { lx_bgmc->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.


  METHOD picking_qty.
    " same EML as the S/4 PickingQty, all items in one call
    " (StorageLocation can't be changed through I_OutboundDeliveryItemTP;
    " BTP sets it with the standard API before PGI)
    MODIFY ENTITIES OF i_outbounddeliverytp PRIVILEGED
      ENTITY OutboundDeliveryItem
      UPDATE FIELDS ( ActualDeliveredQtyInOrderUnit OrderQuantityUnit YY1_PickQty_DLI )
      WITH VALUE #( FOR itm IN is_request-items
                    ( %tky-OutboundDelivery           = itm-deliveryno
                      %tky-OutboundDeliveryItem       = itm-deliveritem
                      ActualDeliveredQtyInOrderUnit   = itm-netweight
                      OrderQuantityUnit               = itm-unit
                      YY1_PickQty_DLI                 = 'X' ) )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      LOOP AT ls_reported-outbounddeliveryitem INTO DATA(ls_rep) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_rep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      IF rs_response-message IS INITIAL.
        rs_response-message = 'The picking quantity could not be updated'.
      ENDIF.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES BEGIN
      RESPONSE OF i_outbounddeliverytp
      FAILED DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS INITIAL.
      rs_response-success = abap_true.
    ELSE.
      LOOP AT ls_commit_reported-outbounddeliveryitem INTO DATA(ls_crep) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_crep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
    ENDIF.

    COMMIT ENTITIES END.
  ENDMETHOD.


  METHOD check_credit.
    DATA lv_value  TYPE decfloat34.
    DATA lv_amount TYPE decfloat34.

    " return deliveries (SD2) need no check, as in S/4
    IF is_request-gateentrytype <> 'SD1'.
      rs_response-success = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_request-items INTO DATA(ls_item).

      SELECT SINGLE SalesDocument, DistributionChannel, SalesDocumentType, PriceDetnExchangeRate
        FROM i_salesdocument WITH PRIVILEGED ACCESS
        WHERE SalesDocument = @ls_item-salesdocument
        INTO @DATA(ls_so).
      IF sy-subrc <> 0
         OR ( ls_so-SalesDocumentType <> 'ZDOM' AND ls_so-SalesDocumentType <> 'ZEXP' )
         OR ( ls_so-DistributionChannel <> '30' AND ls_so-DistributionChannel <> '50' ).
        CONTINUE.
      ENDIF.

      SELECT SUM( OrderQuantity ) AS total_order_qty,
             SUM( NetAmount )     AS total_net_value,
             SUM( TaxAmount )     AS total_tax_amt
        FROM i_salesdocumentitem WITH PRIVILEGED ACCESS
        WHERE SalesDocument = @ls_so-SalesDocument
        INTO @DATA(ls_total).
      IF ls_total-total_order_qty = 0.
        CONTINUE.
      ENDIF.

      " order value in INR per unit x weighed net quantity
      IF ls_so-SalesDocumentType = 'ZEXP'.
        lv_value = ls_so-PriceDetnExchangeRate * ls_total-total_net_value.
      ELSE.
        lv_value = ls_total-total_net_value.
      ENDIF.
      lv_value  = lv_value + ls_total-total_tax_amt.
      lv_amount = lv_value / ls_total-total_order_qty * ls_item-netweight.

      IF ls_so-DistributionChannel = '30'.
        " broker
        SELECT SINGLE Customer FROM i_salesorderpartner WITH PRIVILEGED ACCESS
          WHERE SalesOrder      = @ls_so-SalesDocument
            AND PartnerFunction = 'ZB'
          INTO @DATA(lv_broker).
        SELECT SINGLE Open_bal FROM zsd_broker_cds WITH PRIVILEGED ACCESS
          WHERE Brokerid = @lv_broker
          INTO @DATA(lv_open_bal).
        IF lv_amount > lv_open_bal.
          rs_response-message = |Broker limit exceeded the value { lv_amount DECIMALS = 2 }|.
          RETURN.
        ENDIF.
      ELSE.
        " LC (distribution channel 50)
        SELECT SINGLE Balance_amt FROM zsd_lc_cds WITH PRIVILEGED ACCESS
          WHERE SalesDocument = @ls_so-SalesDocument
          INTO @DATA(lv_balance).
        IF lv_amount > lv_balance.
          rs_response-message = |LC limit exceeded the value { lv_amount DECIMALS = 2 }|.
          RETURN.
        ENDIF.
      ENDIF.

    ENDLOOP.

    rs_response-success = abap_true.
  ENDMETHOD.


  METHOD get_billing.
    SELECT SINGLE BillingDocument, BillingDocumentDate
      FROM i_billingdocumentitembasic WITH PRIVILEGED ACCESS
      WHERE ReferenceSDDocument = @is_request-deliveryno
      INTO @DATA(ls_billing).
    IF sy-subrc <> 0.
      rs_response-message = 'The billing & E-Way Bill have not been generated.'.
      RETURN.
    ENDIF.

    SELECT SINGLE EinvoiceNo, EinvoiceDate, EwayBillNo, Ewaybilldate
      FROM zsd_eway_cds WITH PRIVILEGED ACCESS
      WHERE ElectronicDocSourceKey = @ls_billing-BillingDocument
      INTO @DATA(ls_eway).

    rs_response-billingdocument     = ls_billing-BillingDocument.
    rs_response-billingdocumentdate = ls_billing-BillingDocumentDate.
    rs_response-einvoiceno          = ls_eway-EinvoiceNo.
    rs_response-einvoicedate        = ls_eway-EinvoiceDate.
    rs_response-ewaybillno          = ls_eway-EwayBillNo.
    rs_response-ewaybilldate        = ls_eway-Ewaybilldate.
    rs_response-success             = abap_true.
  ENDMETHOD.


  METHOD get_material_document.
    SELECT SINGLE MaterialDocumentYear, MaterialDocument
      FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
      WHERE DeliveryDocument = @is_request-deliveryno
      INTO @DATA(ls_matdoc).
    IF sy-subrc <> 0.
      rs_response-message = |No material document found for delivery { is_request-deliveryno }|.
      RETURN.
    ENDIF.

    rs_response-materialdocument     = ls_matdoc-MaterialDocument.
    rs_response-materialdocumentyear = ls_matdoc-MaterialDocumentYear.
    rs_response-success              = abap_true.
  ENDMETHOD.


  METHOD get_transporter.
    SELECT SINGLE * FROM zsd_bp_ztrp_vh1 WITH PRIVILEGED ACCESS
    WHERE Transporterid = @is_request-transporterid
    INTO @DATA(ls_trans).

    IF sy-subrc <> 0.
      rs_response-message = |No Transporter found for S/4 { is_request-transporterid }|.
      RETURN.
    ENDIF.

    rs_response-transporterid     = ls_trans-Transporterid.
    rs_response-transportername   = ls_trans-Transportername.
    rs_response-success           = abap_true.

  ENDMETHOD.
ENDCLASS.
