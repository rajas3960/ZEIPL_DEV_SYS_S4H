*----------------------------------------------------------------*
* SYSTEM: S/4HANA Public Cloud (developer extensibility, ADT)
* P5a (2026-11-20): TEST - does CreateDlvFrmPurchasingDocument create
* one inbound delivery line per reference when the SAME PO item is
* passed twice (one line per challan)?
*
* Creates ONE real test inbound delivery in client 100 (supplier ref
* "CHLN-TEST"). Fill the 3 constants, activate, F9 (Run as Console App).
* Output: delivery number + its lines (item, PO, PO item, qty).
* Delete the test delivery afterwards in "Manage Inbound Deliveries".
*----------------------------------------------------------------*
CLASS zcl_mm_dlv_split_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_mm_dlv_split_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " >>> fill in: an open PO item of a supplier
    CONSTANTS c_supplier TYPE c LENGTH 10 VALUE '0000100010'.
    CONSTANTS c_po       TYPE c LENGTH 10 VALUE '1100000483'.
    CONSTANTS c_po_item  TYPE n LENGTH 5  VALUE '00010'.

    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    " same EML as ZCL_MM_GATE_POST_HTTP->create_inbound_delivery, but the
    " PO item is referenced TWICE
    MODIFY ENTITIES OF i_inbounddeliverytp PRIVILEGED
      ENTITY InboundDelivery
      EXECUTE CreateDlvFrmPurchasingDocument
      FROM VALUE #( ( %cid   = 'CREATE1'
                      %param = VALUE #( supplier                   = c_supplier
                                        deliverydate               = lv_date
                                        deliverytime               = lv_time
                                        deliverydocumentbysupplier = 'CHLN-TEST'
                                        %control = VALUE #( supplier                   = if_abap_behv=>mk-on
                                                            deliverydate               = if_abap_behv=>mk-on
                                                            deliverytime               = if_abap_behv=>mk-on
                                                            deliverydocumentbysupplier = if_abap_behv=>mk-on
                                                            _referencepurgdocumentitem = if_abap_behv=>mk-on )
                                        _referencepurgdocumentitem = VALUE #(
                                          ( referencesddocument     = c_po
                                            referencesddocumentitem = c_po_item
                                            %control = VALUE #( referencesddocument     = if_abap_behv=>mk-on
                                                                referencesddocumentitem = if_abap_behv=>mk-on ) )
                                          ( referencesddocument     = c_po
                                            referencesddocumentitem = c_po_item
                                            %control = VALUE #( referencesddocument     = if_abap_behv=>mk-on
                                                                referencesddocumentitem = if_abap_behv=>mk-on ) ) ) ) ) )
      MAPPED DATA(ls_mapped)
      REPORTED DATA(ls_reported)
      FAILED DATA(ls_failed).

    IF ls_failed IS NOT INITIAL OR ls_mapped-inbounddelivery IS INITIAL.
      out->write( `CREATE FAILED:` ).
      LOOP AT ls_reported-inbounddelivery INTO DATA(ls_rep) WHERE %msg IS BOUND.
        out->write( ls_rep-%msg->if_message~get_text( ) ).
      ENDLOOP.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES BEGIN
      RESPONSE OF i_inbounddeliverytp
      FAILED DATA(ls_commit_failed)
      REPORTED DATA(ls_commit_reported).

    DATA lv_dlv TYPE c LENGTH 10.
    IF ls_commit_failed IS INITIAL.
      LOOP AT ls_mapped-inbounddelivery ASSIGNING FIELD-SYMBOL(<ls_dlv>).
        CONVERT KEY OF i_inbounddeliverytp FROM <ls_dlv>-%key TO DATA(ls_key).
        lv_dlv = ls_key-inbounddelivery.
      ENDLOOP.
    ELSE.
      out->write( `COMMIT FAILED:` ).
      LOOP AT ls_commit_reported-inbounddelivery INTO DATA(ls_crep) WHERE %msg IS BOUND.
        out->write( ls_crep-%msg->if_message~get_text( ) ).
      ENDLOOP.
    ENDIF.
    COMMIT ENTITIES END.

    IF lv_dlv IS INITIAL.
      RETURN.
    ENDIF.

    out->write( |Inbound delivery { lv_dlv } created. Lines:| ).
    SELECT InboundDelivery, InboundDeliveryItem, PurchaseOrder, PurchaseOrderItem,
           ActualDeliveryQuantity, DeliveryQuantityUnit
      FROM I_InboundDeliveryItem WITH PRIVILEGED ACCESS
      WHERE InboundDelivery = @lv_dlv
      ORDER BY InboundDeliveryItem
      INTO TABLE @DATA(lt_items).
    out->write( lt_items ).
    out->write( |{ lines( lt_items ) } line(s) for the PO item passed twice| ).
  ENDMETHOD.

ENDCLASS.

