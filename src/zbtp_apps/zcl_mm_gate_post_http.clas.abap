CLASS zcl_mm_gate_post_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

    TYPES ty_qty TYPE p LENGTH 7 DECIMALS 3.

    TYPES: BEGIN OF ty_req_item,
             purchaseorder       TYPE c LENGTH 10,
             purchaseorderitem   TYPE n LENGTH 5,
             plant               TYPE c LENGTH 4,
             material            TYPE c LENGTH 40,
             quantity            TYPE ty_qty,
             unit                TYPE c LENGTH 3,
             storagelocation     TYPE c LENGTH 4,
             InboundDelivery     TYPE c LENGTH 10,       "new One Added By 14.10.2026
             InboundDeliveryItem TYPE n LENGTH 6,     "new One Added By 14.10.2026
             freightorder        TYPE c LENGTH 20,        "new one added on 30.10.2026 FU -> FO
                ""custom field update Purpose added on 24.11.2026
             transportername    TYPE c LENGTH 20,
             gateentrydate      TYPE d,
             gateentrytime      TYPE t,
             challannumber     TYPE c LENGTH 20,
             challandate       TYPE d,
             ewaybillno        TYPE c LENGTH 20,
             ewaybilldate      TYPE d,
             lrno              TYPE c LENGTH 20,
             lrdate            TYPE d,
             Vehicleno         TYPE c LENGTH 15,
           END OF ty_req_item,
           tt_req_item TYPE STANDARD TABLE OF ty_req_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_request,
             operation         TYPE c LENGTH 10,
             purchaseorder     TYPE c LENGTH 10,
             purchaseorderitem TYPE n LENGTH 5,
             gateentryno       TYPE c LENGTH 20,
             supplier          TYPE c LENGTH 10,
             postingdate       TYPE d,
             Product           TYPE c LENGTH 40,        "new One added on 19.2026 RGP & NRGP
             Plant             TYPE c LENGTH 4,         "new One added on 19.2026 RGP & NRGP
             items             TYPE tt_req_item,
           END OF ty_request.

    TYPES: BEGIN OF ty_poitem,
             purchaseorder              TYPE c LENGTH 10,
             purchaseorderitem          TYPE n LENGTH 5,
             material                   TYPE c LENGTH 40,
             plant                      TYPE c LENGTH 4,
             baseunit                   TYPE c LENGTH 3,
             orderquantity              TYPE ty_qty,
             materialgroup              TYPE c LENGTH 9,
             plantname                  TYPE c LENGTH 30,
             productname                TYPE c LENGTH 40,
             supplier                   TYPE c LENGTH 10,
             purchaseorderdate          TYPE d,
             purchaseordertype          TYPE c LENGTH 4,
             suppliername               TYPE c LENGTH 80,
             purchasingdocumenttypename TYPE c LENGTH 20,
             incotermsclassification    TYPE c LENGTH 3,
           END OF ty_poitem,
           tt_poitem TYPE STANDARD TABLE OF ty_poitem WITH EMPTY KEY.

    ""New Code Added 14.10.2026 Starting
    TYPES: BEGIN OF ty_resp_item,
             purchaseorder       TYPE c LENGTH 10,
             purchaseorderitem   TYPE n LENGTH 5,
             InboundDelivery     TYPE c LENGTH 10,
             InboundDeliveryItem TYPE n LENGTH 6,
           END OF ty_resp_item,
           tt_resp_item TYPE STANDARD TABLE OF ty_resp_item WITH EMPTY KEY.
    ""New Code Added 14.10.2026 Ending

    ""New Code Added on 19.10.2026 for Get the Product details for RGP & NRGP
    TYPES: BEGIN OF ty_product,
             Product   TYPE c LENGTH 40,
             Plant     TYPE c LENGTH 4,
             BaseUnit  TYPE c LENGTH 3,
             Prodesc   TYPE c LENGTH 40,
             PlantName TYPE c LENGTH 30,
             Hsncode   TYPE c LENGTH 16,
             Netprice  TYPE p LENGTH 7 DECIMALS 2,
             Currency  TYPE c LENGTH 5,
           END OF ty_product,
           tt_product TYPE STANDARD TABLE OF ty_product WITH EMPTY KEY.

    ""New Code Added on 20.10.2026 for Get the Supplier address details for RGP & NRGP
    TYPES: BEGIN OF ty_sup_add,
             Supplier         TYPE c LENGTH 10,
             AddressID        TYPE c LENGTH 10,
             SupplierName     TYPE c LENGTH 80,
             StreetName       TYPE c LENGTH 35,
             BPAddrStreetName TYPE c LENGTH 60,
             gstin            TYPE c LENGTH 18,
             CityName         TYPE c LENGTH 35,
             PostalCode       TYPE c LENGTH 10,
             pan              TYPE c LENGTH 40,
             phone            TYPE c LENGTH 16,
             Region           TYPE c LENGTH 3,
             EmailAddress     TYPE c LENGTH 241,
           END OF ty_sup_add,
           tt_supaddress TYPE STANDARD TABLE OF ty_sup_add WITH EMPTY KEY.



    TYPES: BEGIN OF ty_response,
             success              TYPE abap_bool,
             message              TYPE string,
             materialdocument     TYPE c LENGTH 10,
             materialdocumentyear TYPE n LENGTH 4,
             inbounddelivery      TYPE c LENGTH 10,
             fomessage            TYPE string,                  "new one added on 30.10.2026 FU -> FO
             items                TYPE tt_resp_item,            ""New One added on 10.10.2026
             poitems              TYPE tt_poitem,
             products             TYPE tt_product,          "new one added on 19.10.2026 RGP & NRGP
             supaddress           TYPE tt_supaddress,
           END OF ty_response.

  PRIVATE SECTION.
    METHODS get_po_items
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    METHODS post_goods_receipt
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    METHODS create_inbound_delivery
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    "new One Added on 14.10.2026
    "! Sets the Inbound delivery quantity of the new delivery items to the net
    "! (gate) weight. CreateDlvFrmPurchasingDocument has no quantity
    "! parameter and always takes the open order quantity.
    "! Returns an error text, or nothing when all went well.
    METHODS set_delivery_qty
      IMPORTING is_request        TYPE ty_request
                it_dlv_items      TYPE tt_resp_item
      RETURNING VALUE(rv_message) TYPE string.

    "new one added on 30.10.2026
    "! Assigns the freight unit(s) built from the inbound delivery to the
    "! items' freight order (TM action AssignFreightUnit). Returns what
    "! happened; never raises and never rolls back the delivery.
    METHODS link_freight_units
      IMPORTING is_request        TYPE ty_request
                iv_delivery       TYPE ty_response-inbounddelivery
      RETURNING VALUE(rv_message) TYPE string.

    "! <p class="shorttext synchronized" lang="en"></p>
    "!
    "! @parameter is_request | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter rs_response | <p class="shorttext synchronized" lang="en"></p>
    METHODS get_product_details
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

    "! <p class="shorttext synchronized" lang="en"></p>
    "!
    "! @parameter is_request | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter rs_response | <p class="shorttext synchronized" lang="en"></p>
    METHODS get_supaddress_details
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response.

ENDCLASS.



CLASS zcl_mm_gate_post_http IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA ls_request TYPE ty_request.

    " a plain GET (browser) is a connectivity check only
    IF request->get_method( ) <> 'POST'.
      response->set_text( `ZMM_GATE_POST is reachable. Use POST with a JSON body.` ).
      RETURN.
    ENDIF.

    /ui2/cl_json=>deserialize( EXPORTING json        = request->get_text( )
                                         pretty_name = /ui2/cl_json=>pretty_mode-low_case
                               CHANGING  data        = ls_request ).

    DATA(ls_response) = SWITCH ty_response( ls_request-operation
                          WHEN 'POITEMS' THEN get_po_items( ls_request )
                          WHEN 'MIGO'    THEN post_goods_receipt( ls_request )
                          WHEN 'INBDLV'  THEN create_inbound_delivery( ls_request )
                          WHEN 'PRODUCT'  THEN get_product_details( ls_request )   "new one added on 19.10.2026 for RGP & NRGP
                          WHEN 'SUPADD'  THEN get_supaddress_details( ls_request )   "new one added on 20.10.2026 for RGP & NRGP

                          ELSE VALUE #( message = |Unknown operation "{ ls_request-operation }"| ) ).

    response->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
    response->set_text( /ui2/cl_json=>serialize( data        = ls_response
                                                 pretty_name = /ui2/cl_json=>pretty_mode-low_case ) ).
  ENDMETHOD.


  METHOD get_po_items.
    DATA lt_item_range TYPE RANGE OF i_purchaseorderitemapi01-purchaseorderitem.

    " no item given = all items of the PO (G2 series)
    IF is_request-purchaseorderitem IS NOT INITIAL.
      lt_item_range = VALUE #( ( sign = 'I' option = 'EQ' low = is_request-purchaseorderitem ) ).
    ENDIF.

    " Reads the custom view ZMM_GATE_POITEM2 (same joins as the S/4
    " Purchase SELECT, authorizationCheck #NOT_REQUIRED). Reading
    " I_PurchaseOrderItemAPI01 directly found nothing for the
    " communication user COM_GATE_POST, which has no business roles.
    SELECT purchaseorder, purchaseorderitem, material, plant, baseunit, orderquantity,
           materialgroup, plantname, productname, supplier, purchaseorderdate,
           purchaseordertype, suppliername, purchasingdocumenttypename,
           incotermsclassification
      FROM zmm_gate_poitem2
      WHERE purchaseorder     =  @is_request-purchaseorder
        AND purchaseorderitem IN @lt_item_range
      ORDER BY purchaseorderitem
      INTO CORRESPONDING FIELDS OF TABLE @rs_response-poitems.

    IF rs_response-poitems IS INITIAL.
      " say which view can see the PO, to tell authorization from data problems
      SELECT COUNT(*) FROM zmm_poitvh2
        WHERE purchaseorder = @is_request-purchaseorder
        INTO @DATA(lv_vh_count).
      SELECT COUNT(*) FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        WHERE purchaseorder = @is_request-purchaseorder
        INTO @DATA(lv_api_count).
      rs_response-message = |PO { is_request-purchaseorder } { is_request-purchaseorderitem } not found in S/4| &&
                            | (items seen: value help view { lv_vh_count }, API view { lv_api_count })|.
    ELSE.
      rs_response-success = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD post_goods_receipt.
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date).

    " same EML as the S/4 MigoPost action
    MODIFY ENTITIES OF i_materialdocumenttp PRIVILEGED
      ENTITY MaterialDocument
        CREATE FROM VALUE #( ( %cid                       = 'CID_001'
                               goodsmovementcode          = '01'
                               postingdate                = is_request-postingdate
                               documentdate               = lv_date
                               %control-goodsmovementcode = cl_abap_behv=>flag_changed
                               %control-postingdate       = cl_abap_behv=>flag_changed
                               %control-documentdate      = cl_abap_behv=>flag_changed ) )
      ENTITY MaterialDocument
        CREATE BY \_MaterialDocumentItem
        FROM VALUE #( FOR ls_item IN is_request-items
                      ( %cid_ref = 'CID_001'
                        %target  = VALUE #( ( %cid                             = |CID_ITM_{ ls_item-purchaseorder }{ ls_item-purchaseorderitem }|
                                              plant                            = ls_item-plant
                                              material                         = ls_item-material
                                              purchaseorder                    = ls_item-purchaseorder
                                              purchaseorderitem                = ls_item-purchaseorderitem
                                              goodsmovementtype                = '101'
                                              goodsmovementrefdoctype          = 'B'
                                              quantityinentryunit              = ls_item-quantity
                                              entryunit                        = ls_item-unit
                                              storagelocation                  = ls_item-storagelocation
                                              yy1_gateentryno_mmi              = is_request-gateentryno
                                              %control-plant                   = cl_abap_behv=>flag_changed
                                              %control-material                = cl_abap_behv=>flag_changed
                                              %control-goodsmovementtype       = cl_abap_behv=>flag_changed
                                              %control-purchaseorder           = cl_abap_behv=>flag_changed
                                              %control-purchaseorderitem       = cl_abap_behv=>flag_changed
                                              %control-quantityinentryunit     = cl_abap_behv=>flag_changed
                                              %control-entryunit               = cl_abap_behv=>flag_changed
                                              %control-goodsmovementrefdoctype = cl_abap_behv=>flag_changed
                                              %control-storagelocation         = cl_abap_behv=>flag_changed
                                              %control-yy1_gateentryno_mmi     = cl_abap_behv=>flag_changed ) ) ) )
      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      LOOP AT ls_reported-materialdocument INTO DATA(ls_rep_head) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_rep_head-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      LOOP AT ls_reported-materialdocumentitem INTO DATA(ls_rep_item) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_rep_item-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES BEGIN
      RESPONSE OF i_materialdocumenttp
      FAILED DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS INITIAL.
      LOOP AT ls_mapped-materialdocument ASSIGNING FIELD-SYMBOL(<ls_doc>).
        CONVERT KEY OF i_materialdocumenttp FROM <ls_doc>-%pid TO DATA(ls_doc_key).
        rs_response-materialdocument     = ls_doc_key-materialdocument.
        rs_response-materialdocumentyear = ls_doc_key-materialdocumentyear.
      ENDLOOP.
      rs_response-success = abap_true.
    ELSE.
      LOOP AT ls_commit_reported-materialdocument INTO DATA(ls_crep_head) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_crep_head-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      LOOP AT ls_commit_reported-materialdocumentitem INTO DATA(ls_crep_item) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_crep_item-%msg->if_message~get_text( ) } |.
      ENDLOOP.
    ENDIF.

    COMMIT ENTITIES END.
  ENDMETHOD.


  METHOD create_inbound_delivery.
  " 25.11.2026 regenerate in Test after YY1_3 v7 (YY1_VEHICLERRNO_DLH)
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

*----------------------------------------------------------------*
    " a repeated call for the same gate entry + PO item (e.g. BTP timed
    " out but S/4 finished) returns the delivery created the first time
    " instead of creating a second one. Since 20.11.2026 one delivery per
    " PO item: the existing delivery must contain the requested PO item.
    DATA(ls_first) = VALUE #( is_request-items[ 1 ] OPTIONAL ).
    IF is_request-gateentryno IS NOT INITIAL AND ls_first IS NOT INITIAL.
      SELECT SINGLE d~InboundDelivery
        FROM i_inbounddelivery WITH PRIVILEGED ACCESS AS d
          INNER JOIN i_inbounddeliveryitem WITH PRIVILEGED ACCESS AS i
            ON i~InboundDelivery = d~InboundDelivery
        WHERE d~DeliveryDocumentBySupplier = @is_request-gateentryno
          AND i~PurchaseOrder              = @ls_first-purchaseorder
          AND i~PurchaseOrderItem          = @ls_first-purchaseorderitem
        INTO @DATA(lv_existing).
      IF sy-subrc = 0.
        SELECT InboundDelivery, InboundDeliveryItem, PurchaseOrder, PurchaseOrderItem
          FROM I_InboundDeliveryItem WITH PRIVILEGED ACCESS
          WHERE InboundDelivery = @lv_existing
          INTO TABLE @DATA(lt_exist_item).
        rs_response = VALUE #( success         = abap_true
                               inbounddelivery = lv_existing
                               message         = |Delivery { lv_existing ALPHA = OUT } already existed for gate entry { is_request-gateentryno }|
                               items           = VALUE #( FOR e IN lt_exist_item
                                                          ( purchaseorder       = e-PurchaseOrder
                                                            purchaseorderitem   = e-PurchaseOrderItem
                                                            inbounddelivery     = e-InboundDelivery
                                                            inbounddeliveryitem = e-InboundDeliveryItem ) ) ).
        " link again in case the first run didn't (a second assignment is ignored)
        rs_response-fomessage = link_freight_units( is_request  = is_request
                                                    iv_delivery = lv_existing ).
        RETURN.
      ENDIF.
    ENDIF.


    " same EML as the S/4 InbDelivery action, except referencesddocumentitem
    " now has its %control flag set too (the S/4 version only flagged the PO)
    MODIFY ENTITIES OF i_inbounddeliverytp PRIVILEGED
      ENTITY InboundDelivery
      EXECUTE CreateDlvFrmPurchasingDocument
      FROM VALUE #( ( %cid   = 'CREATE1'
                      %param = VALUE #( supplier                   = is_request-supplier
                                        deliverydate               = lv_date
                                        deliverytime               = lv_time
                                        deliverydocumentbysupplier = is_request-gateentryno
                                        meansoftransporttype       = ''
                                        meansoftransport           = ''
                                        %control = VALUE #( supplier                   = if_abap_behv=>mk-on
                                                            deliverydate               = if_abap_behv=>mk-on
                                                            deliverytime               = if_abap_behv=>mk-on
                                                            deliverydocumentbysupplier = if_abap_behv=>mk-on
                                                            meansoftransporttype       = if_abap_behv=>mk-on
                                                            meansoftransport           = if_abap_behv=>mk-on
                                                            _referencepurgdocumentitem = if_abap_behv=>mk-on )
                                        _referencepurgdocumentitem = VALUE #(
                                          FOR ls_item IN is_request-items
                                          ( referencesddocument     = ls_item-purchaseorder
                                            referencesddocumentitem = ls_item-purchaseorderitem
                                            %control = VALUE #( referencesddocument     = if_abap_behv=>mk-on
                                                                 ) ) ) ) ) )
      MAPPED DATA(ls_mapped)
      REPORTED DATA(ls_reported)
      FAILED DATA(ls_failed).

    IF ls_failed IS NOT INITIAL OR ls_mapped-inbounddelivery IS INITIAL.
      LOOP AT ls_reported-inbounddelivery INTO DATA(ls_rep) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_rep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES BEGIN
      RESPONSE OF i_inbounddeliverytp
      FAILED DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS INITIAL.
      LOOP AT ls_mapped-inbounddelivery ASSIGNING FIELD-SYMBOL(<ls_dlv>).
        " same CONVERT KEY as the S/4 saver (from %key)
        CONVERT KEY OF i_inbounddeliverytp FROM <ls_dlv>-%key TO DATA(ls_dlv_key).
        rs_response-inbounddelivery = ls_dlv_key-inbounddelivery.
      ENDLOOP.
      rs_response-success = abap_true.
    ELSE.
      LOOP AT ls_commit_reported-inbounddelivery INTO DATA(ls_crep) WHERE %msg IS BOUND.
        rs_response-message = |{ rs_response-message }{ ls_crep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
    ENDIF.

    COMMIT ENTITIES END.

    "New one added by 10.10.2026
    " 4. Inbound delivery item per order item (also works for return deliveries)
    IF rs_response-success = abap_true.
*      SELECT DeliveryDocument, DeliveryDocumentItem, ReferenceSDDocument, ReferenceSDDocumentItem
*        FROM i_deliverydocumentitem WITH PRIVILEGED ACCESS
*        WHERE DeliveryDocument = @rs_response-deliveryno
*        INTO TABLE @DATA(lt_dlvitem).


      SELECT InboundDelivery ,InboundDeliveryItem ,PurchaseOrder,PurchaseOrderItem
        FROM I_InboundDeliveryItem WITH PRIVILEGED ACCESS
        WHERE InboundDelivery = @rs_response-inbounddelivery
        INTO TABLE @DATA(lt_Indlvitem).

      rs_response-items = VALUE #( FOR d IN lt_Indlvitem
                                   ( purchaseorder = d-PurchaseOrder
                                     purchaseorderitem     = d-PurchaseOrderItem
                                     inbounddelivery    = d-InboundDelivery
                                     inbounddeliveryitem   = d-InboundDeliveryItem ) ).

      " 5. Inbound delivery quantity = net (gate) weight (2026-10-08). The delivery
      "    exists already, so a failure here is reported as a warning text
      "    and the delivery number still goes back to BTP.
      DATA(lv_qty_error) = set_delivery_qty( is_request   = is_request
                                             it_dlv_items = rs_response-items ).
      IF lv_qty_error IS NOT INITIAL.
        rs_response-message = |Inbound Delivery quantity not set to the net weight: { lv_qty_error }|.
*                              &&
*                              | Use Picking Qty to set it.|.
      ENDIF.

      " 6. Freight unit(s) built from the delivery -> item's freight order
      "    (new one added on 30.10.2026). After step 5, so TM has the
      "    freight unit with the net weight quantity.
      rs_response-fomessage = link_freight_units( is_request  = is_request
                                                  iv_delivery = rs_response-inbounddelivery ).
    ENDIF.

  ENDMETHOD.


  METHOD set_delivery_qty.   ""new one added on 14.10.2026 starting

    " plain list first; the MODIFY below builds the EML table itself
    " (same form as in picking_qty)
    TYPES: BEGIN OF ty_upd,
             Inbdeliveryno  TYPE c LENGTH 10,
             Inbdeliveritem TYPE n LENGTH 6,
             netweight      TYPE ty_qty,
             unit           TYPE c LENGTH 3,
           END OF ty_upd.
    DATA lt_update TYPE STANDARD TABLE OF ty_upd WITH EMPTY KEY.

    LOOP AT is_request-items INTO DATA(ls_item) WHERE quantity IS NOT INITIAL.
      " order numbers may come with or without leading zeros
      LOOP AT it_dlv_items INTO DATA(ls_dlv)
           WHERE purchaseorderitem = ls_item-purchaseorderitem.
        IF condense( |{ ls_dlv-purchaseorder ALPHA = OUT }| ) = condense( |{ ls_item-purchaseorder ALPHA = OUT }| ).
          APPEND VALUE #( Inbdeliveryno  = ls_dlv-inbounddelivery
                          Inbdeliveritem = ls_dlv-inbounddeliveryitem
                          netweight   = ls_item-quantity
                          unit        = ls_item-unit )
                 TO lt_update.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF lt_update IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_cusfield) = VALUE #( is_request-items[ 1 ] OPTIONAL ).  ""New code added on 24.11.2026

    MODIFY ENTITIES OF I_InboundDeliveryTP PRIVILEGED
      ENTITY InboundDeliveryItem
      UPDATE FIELDS ( ActualDeliveredQtyInOrderUnit OrderQuantityUnit )
      WITH VALUE #( FOR u IN lt_update
                    ( %tky-InboundDelivery         = u-inbdeliveryno
                      %tky-InboundDeliveryItem     = u-inbdeliveritem
                      ActualDeliveredQtyInOrderUnit = u-netweight
                      OrderQuantityUnit             = u-unit ) )

      "new one added on 19.10.2026 custom field update
      " 05.11.2026: ONE row per delivery header - one row per item gave the
      " dump DUPLICATE_UPDATE as soon as a truck had 2 or more lines
      ENTITY InboundDelivery
      UPDATE FIELDS ( YY1_MMChallanNo_DLH YY1_MMChallanDate_DLH
                       YY1_MMEWayBillNo_DLH YY1_MMEWayBillDate_DLH
                       YY1_MMLRNumber_DLH YY1_MMLRDate_DLH YY1_VehicleRRNo_DLH YY1_VehicleNumber_DLH
                       yy1_transportername_dlh YY1_GateEntryDate_DLH
                      YY1_GateEntryTime_DLH )
      WITH VALUE #( FOR GROUPS lv_dlv OF u IN lt_update GROUP BY u-inbdeliveryno
                    ( %tky-InboundDelivery          = lv_dlv
                      yy1_transportername_dlh    = ls_cusfield-transportername
                      YY1_GateEntryDate_DLH      = ls_cusfield-gateentrydate
                      YY1_GateEntryTime_DLH      = ls_cusfield-gateentrytime
                      YY1_VehicleRRNo_DLH        = ls_cusfield-vehicleno
                      YY1_MMChallanNo_DLH    = ls_cusfield-challannumber
                      YY1_MMChallanDate_DLH      = ls_cusfield-challandate
                      YY1_MMEWayBillNo_DLH      = ls_cusfield-ewaybillno
                      YY1_MMEWayBillDate_DLH = ls_cusfield-ewaybilldate
                      YY1_MMLRNumber_DLH    = ls_cusfield-lrno
                      YY1_MMLRDate_DLH      = ls_cusfield-lrdate
*                      YY1_VehicleNumber_DLH   = ls_cusfield-vehicleno

                      ) )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      LOOP AT ls_reported-inbounddeliveryitem INTO DATA(ls_rep) WHERE %msg IS BOUND.
        rv_message = |{ rv_message }{ ls_rep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      IF rv_message IS INITIAL.
        rv_message = 'update rejected'.
      ENDIF.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES BEGIN
      RESPONSE OF I_InboundDeliveryTP
      FAILED DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS NOT INITIAL.
      LOOP AT ls_commit_reported-inbounddeliveryitem INTO DATA(ls_crep) WHERE %msg IS BOUND.
        rv_message = |{ rv_message }{ ls_crep-%msg->if_message~get_text( ) } |.
      ENDLOOP.
      IF rv_message IS INITIAL.
        rv_message = 'save failed'.
      ENDIF.
    ENDIF.

    COMMIT ENTITIES END.

  ENDMETHOD. ""new one added on 14.10.2026 starting


  METHOD link_freight_units.   "new one added on 30.10.2026
    " BTP sends the freight order per item. One freight order on the
    " delivery -> its freight unit(s) are assigned in the background
    " (ZCL_MM_FU_LINK_BG, bgPF): TM builds the freight unit after the
    " delivery save, and waiting for it here made BTP time out (504).
    " Every step is logged in ZMM_FU_LINK_LOG (direction IN).
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
                                                                          iv_direction    = 'IN' ) ).
        lo_process->save_for_execution( ).
        COMMIT WORK.
        zcl_mm_fu_link_bg=>write_log( iv_direction    = 'IN'
                                      iv_delivery     = iv_delivery
                                      iv_freightorder = lv_fo
                                      iv_status       = 'QUEUED'
                                      iv_message      = 'background job handed to bgPF' ).
        rv_message = |Freight unit will be assigned to freight order { lv_fo ALPHA = OUT } in a few seconds|.
      CATCH cx_bgmc INTO DATA(lx_bgmc).
        zcl_mm_fu_link_bg=>write_log( iv_direction    = 'IN'
                                      iv_delivery     = iv_delivery
                                      iv_freightorder = lv_fo
                                      iv_status       = 'NOT_QUEUED'
                                      iv_message      = lx_bgmc->get_text( ) ).
        rv_message = |Freight unit not assigned (background start failed): { lx_bgmc->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.


  METHOD get_product_details.   "new added on 19.10.2026

    SELECT Product,Plant,Baseunit,Prodesc,PlantName,Hsncode,
                Netprice,Currency
             FROM  zmm_get_product WITH PRIVILEGED ACCESS
             WHERE Product = @is_request-product
             AND Plant = @is_request-plant
             INTO CORRESPONDING FIELDS OF TABLE @rs_response-products.

    IF rs_response-products IS INITIAL.
      " say which view can see the PO, to tell authorization from data problems
      rs_response-message = |Product { is_request-product } { is_request-plant } not found in S/4| &&
                            | (items seen: value help view, API view)|.
    ELSE.
      rs_response-success = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_supaddress_details.  "new added on 20.10.2026

    SELECT Supplier,AddressID,SupplierName,StreetName ,BPAddrStreetName,gstin,
            CityName,PostalCode,pan,phone,Region,EmailAddress
            FROM zmm_sup_add WITH PRIVILEGED ACCESS
            WHERE Supplier = @is_request-supplier
            INTO CORRESPONDING FIELDS OF TABLE @rs_response-supaddress.

    IF rs_response-supaddress IS INITIAL.
      " say which view can see the PO, to tell authorization from data problems
      rs_response-message = |Supplier Address { is_request-supplier } not found in S/4| &&
                            | (items seen: value help view, API view)|.
    ELSE.
      rs_response-success = abap_true.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
