CLASS lhc_Head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Head RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Head RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Head RESULT result.

    METHODS MigoPost FOR MODIFY
       keys FOR ACTION Head~MigoPost RESULT result.
    METHODS InbDelivery FOR MODIFY
      keys FOR ACTION Head~InbDelivery RESULT result.
    METHODS Set_Inbound_dlv FOR DETERMINE ON MODIFY
      keys FOR Head~Set_Inbound_dlv.

ENDCLASS.

CLASS lhc_Head IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD MigoPost.
***********************************************************************
            DATA : gt_uphead TYPE TABLE OF ZMM_APP04_HDB,
                   gs_uphead type ZMM_APP04_HDB.
**************************************************************************
            READ ENTITIES OF zmm_ih_grn IN LOCAL MODE
            ENTITY Head
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY Head BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
**************************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA(ls_item) = VALUE #( lt_item[ 1 ] OPTIONAL ).
            data(gt_keys) = keys.
            data(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            data(lv_mvmt_type) = '101'.

            select purchaseorder,
                   purchaseorderitem,
                   baseunit,
                   sum( grnqty ) as FinalQty
                   from @lt_item as FinalItem
                   GROUP BY purchaseorder,purchaseorderitem,baseunit
                   INTO TABLE @DATA(Lv_final).

            sort Lv_final ASCENDING BY Purchaseorder Purchaseorderitem.
**************************************************************************
*if ls_head-Gateentryseries = 'G2'.

            LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
            if <ls_item> is ASSIGNED.

               if <ls_item>-Storagelocation is INITIAL.

              DATA(lv_bkmsg) = |Storage Location is Mandatory { <ls_item>-Purchaseorder }|.

              APPEND VALUE #( %tky = ls_head-%tky )
                  TO failed-head.

              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = lv_bkmsg
                )
              ) TO reported-head.

              RETURN.

            ENDIF.

                ENDIF.
            ENDLOOP.
***************************************************************************
        get TIME STAMP FIELD DATA(ts).
        CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**********************************************************************
            MODIFY ENTITIES OF I_InboundDeliveryTP PRIVILEGED
                ENTITY InboundDelivery
                EXECUTE CreateDlvFrmPurchasingDocument

            FROM VALUE #(
                    (   %cid = 'CREATE1'
                        %param = VALUE #(
                        supplier = ls_item-Vendor
                        deliverydate = lv_date
                        deliverytime = lv_time
                        deliverydocumentbysupplier = ls_head-Gateentryno
                        meansoftransporttype = ''
                        meansoftransport = ''

            %control = VALUE #(
                        supplier = if_abap_behv=>mk-on
                        deliverydate = if_abap_behv=>mk-on
                        deliverytime = if_abap_behv=>mk-on
                        deliverydocumentbysupplier = if_abap_behv=>mk-on
                        meansoftransporttype = if_abap_behv=>mk-on
                        meansoftransport = if_abap_behv=>mk-on

            _referencepurgdocumentitem = if_abap_behv=>mk-on )

                       _referencepurgdocumentitem = VALUE #(

                        FOR ls_poitem IN Lv_final

                        ( referencesddocument = ls_poitem-Purchaseorder
                          referencesddocumentitem = ls_poitem-Purchaseorderitem
           %control = VALUE #(
                            referencesddocument = if_abap_behv=>mk-on
                            referencesddocumentitem = if_abap_behv=>mk-on
                             ) )

                                 ) ) ) )
              MAPPED DATA(mapped_create)
              REPORTED DATA(reported_create)
              FAILED DATA(failed_create).

********************************************************************************
    IF mapped_create IS NOT INITIAL.
      IF failed_create IS INITIAL.
        zbp_mm_ih_grn=>cv_indlv_doc-inbounddelivery = mapped_create-inbounddelivery.
        zbp_mm_ih_grn=>gt_migoup = CORRESPONDING #( lt_head ).
      ENDIF.
    ENDIF.
********************************************************************************

*ENDIF.

*              MODIFY ENTITIES OF i_materialdocumenttp PRIVILEGED
*                ENTITY MaterialDocument
*                 CREATE FROM VALUE #( ( %cid = 'CID_001'
*                             goodsmovementcode = '01'
*                             postingdate = gs_keys-%param-PostingDate
*                             documentdate = lv_date
*                             %control-goodsmovementcode = cl_abap_behv=>flag_changed
*                             %control-postingdate = cl_abap_behv=>flag_changed
*                             %control-documentdate = cl_abap_behv=>flag_changed
*                         ) )
***********************************************************************
*                 ENTITY MaterialDocument
*                 CREATE BY \_MaterialDocumentItem
*                 FROM VALUE #(
*                 FOR ls_poitem IN lt_item (
*                 %cid_ref = 'CID_001'
*                 %target = VALUE #( ( %cid = 'CID_ITM_' && ls_poitem-Gateentryno
*                 plant = ls_poitem-Plant
*                 material = ls_poitem-Material
*                 PurchaseOrder = ls_poitem-Purchaseorder
*                 PurchaseOrderItem = ls_poitem-Purchaseorderitem
*                 GoodsMovementType = lv_mvmt_type
*                 GoodsMovementRefDocType = 'B'
*                 QuantityInEntryUnit = ls_poitem-Grnqty
*                 entryunit = ls_poitem-Baseunit
*                 storagelocation = ls_poitem-Storagelocation
*                 YY1_GateEntryNo_MMI = ls_head-Gateentryno
*
**                 IssuingOrReceivingPlant = 'MHU3'
**                 IssuingOrReceivingStorageLoc = 'U3GN'
*
*
*                 %control-plant = cl_abap_behv=>flag_changed
*                 %control-material = cl_abap_behv=>flag_changed
*                 %control-GoodsMovementType = cl_abap_behv=>flag_changed
*                 %control-PurchaseOrder = cl_abap_behv=>flag_changed
*                 %control-PurchaseOrderItem = cl_abap_behv=>flag_changed
*                 %control-QuantityInEntryUnit = cl_abap_behv=>flag_changed
*                 %control-entryunit = cl_abap_behv=>flag_changed
*                  %control-GoodsMovementRefDocType = cl_abap_behv=>flag_changed
*                  %control-StorageLocation = cl_abap_behv=>flag_changed
*                  %control-YY1_GateEntryNo_MMI = cl_abap_behv=>flag_changed
*
*             ) )
*                ) )
*                 MAPPED DATA(ls_create_mapped)
*                 FAILED DATA(ls_create_failed)
*                 REPORTED DATA(ls_create_reported).
*
*************************************************************************
*      IF ls_create_failed IS INITIAL.
*        zbp_mm_ih_grn=>cv_migo_doc-materialdocument = ls_create_mapped-materialdocument.
*        LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_up>).
*        if <ls_up> is ASSIGNED.
*            MOVE-CORRESPONDING <ls_up> to gs_uphead.
*            APPEND gs_uphead to gt_uphead.
*        ENDIF.
*        ENDLOOP.
*            zbp_mm_ih_grn=>gt_migoup = gt_uphead.
*      endif.
*
***************************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************


  ENDMETHOD.

  METHOD InbDelivery.
  ENDMETHOD.

  METHOD Set_Inbound_dlv.
***********************************************************************
            DATA : gt_uphead TYPE TABLE OF ZMM_APP04_HDB,
                   gs_uphead type ZMM_APP04_HDB.
**************************************************************************
    TYPES ty_qty TYPE p LENGTH 7 DECIMALS 3.
    TYPES: BEGIN OF ty_upd,
             Inbdeliveryno  TYPE c LENGTH 10,
             Inbdeliveritem TYPE n LENGTH 6,
             purchaseorder  TYPE c LENGTH 10,
             purchaseorderitem TYPE n LENGTH 5,
             netweight   TYPE ty_qty,
             unit        TYPE c LENGTH 3,
           END OF ty_upd.
    DATA lt_update TYPE STANDARD TABLE OF ty_upd WITH EMPTY KEY.

            READ ENTITIES OF zmm_ih_grn IN LOCAL MODE
            ENTITY Head
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY Head BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
**************************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA(gs_item) = VALUE #( lt_item[ 1 ] OPTIONAL ).
            data(gt_keys) = keys.
            data(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            data(lv_mvmt_type) = '101'.

            select purchaseorder,
                   purchaseorderitem,
                   baseunit,
                   sum( grnqty ) as FinalQty
                   from @lt_item as FinalItem
                   GROUP BY purchaseorder,purchaseorderitem,baseunit
                   INTO TABLE @DATA(Lv_final).

            sort Lv_final ASCENDING BY Purchaseorder Purchaseorderitem.
**************************************************************************
    if ls_head-Inbounddelivery is NOT INITIAL.

      SELECT InboundDelivery ,InboundDeliveryItem ,PurchaseOrder,PurchaseOrderItem
        FROM I_InboundDeliveryItem WITH PRIVILEGED ACCESS
        WHERE InboundDelivery = @ls_head-inbounddelivery
        INTO TABLE @DATA(lt_Indlvitem).
    ENdif.

    LOOP AT lt_Indlvitem INTO DATA(ls_item) WHERE PurchaseOrder IS NOT INITIAL.
      " order numbers may come with or without leading zeros
      LOOP AT Lv_final INTO DATA(ls_dlv)
           WHERE purchaseorderitem = ls_item-purchaseorderitem.
        IF condense( |{ ls_dlv-purchaseorder ALPHA = OUT }| ) = condense( |{ ls_item-purchaseorder ALPHA = OUT }| ).
          APPEND VALUE #( Inbdeliveryno  = ls_item-inbounddelivery
                          Inbdeliveritem = ls_item-inbounddeliveryitem
                          purchaseorder = ls_dlv-Purchaseorder
                          purchaseorderitem = ls_dlv-Purchaseorderitem
                          netweight   = ls_dlv-FinalQty
                          unit        = ls_dlv-Baseunit )
                 TO lt_update.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF lt_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF I_InboundDeliveryTP PRIVILEGED
      ENTITY InboundDeliveryItem
      UPDATE FIELDS ( ActualDeliveredQtyInOrderUnit OrderQuantityUnit )
      WITH VALUE #( FOR u IN lt_update
                    ( %tky-InboundDelivery         = u-inbdeliveryno
                      %tky-InboundDeliveryItem     = u-inbdeliveritem
                      ActualDeliveredQtyInOrderUnit = u-netweight
                      OrderQuantityUnit             = u-unit ) )

      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZMM_II_GRN DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zmm_ii_grn RESULT result.

ENDCLASS.

CLASS lhc_ZMM_II_GRN IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_IH_GRN DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMM_IH_GRN IMPLEMENTATION.

  METHOD save_modified.
*********************************************************************
"" Migo Update in custom table level
*********************************************************************
*    IF zbp_mm_ih_grn=>cv_migo_doc IS NOT INITIAL.
*      LOOP AT zbp_mm_ih_grn=>cv_migo_doc-materialdocument ASSIGNING FIELD-SYMBOL(<fs_migo_mapped>).
*        CONVERT KEY OF i_materialdocumenttp FROM <fs_migo_mapped>-%pid TO DATA(ls_migo_key).
*        <fs_migo_mapped>-materialdocument = ls_migo_key-materialdocument.
*        <fs_migo_mapped>-MaterialDocumentYear = ls_migo_key-MaterialDocumentYear.
*      ENDLOOP.
*      IF zbp_mm_ih_grn=>gt_migoup IS NOT INITIAL.
*        DATA(lt_hdrupd) = zbp_mm_ih_grn=>gt_migoup.
*        LOOP AT lt_hdrupd ASSIGNING FIELD-SYMBOL(<fs_upd>).
*          <fs_upd>-materialdocument = ls_migo_key-MaterialDocument.
*          <fs_upd>-materialdocumentyear = ls_migo_key-MaterialDocumentYear.
*        ENDLOOP.
*        MODIFY ZMM_APP04_HDB FROM TABLE @lt_hdrupd.
*      ENDIF.
*    ENDIF.
*********************************************************************
"" Inbound Delivery update in custom table
*********************************************************************
    if zbp_mm_ih_grn=>cv_indlv_doc is NOT INITIAL.
      LOOP AT zbp_mm_ih_grn=>cv_indlv_doc-inbounddelivery ASSIGNING FIELD-SYMBOL(<fs_Inbd_mapped>).
        CONVERT KEY OF I_InboundDeliveryTP FROM <fs_Inbd_mapped>-%key TO DATA(ls_Inbd_key).
        <fs_Inbd_mapped>-InboundDelivery = ls_Inbd_key-InboundDelivery.
      ENDLOOP.

        IF zbp_mm_ih_grn=>gt_migoup IS NOT INITIAL.
        DATA(lt_Inbupd) = zbp_mm_ih_grn=>gt_migoup.
        LOOP AT lt_Inbupd ASSIGNING FIELD-SYMBOL(<fs_Inupd>).
          <fs_Inupd>-inbounddelivery = ls_Inbd_key-InboundDelivery.
        ENDLOOP.
        MODIFY ZMM_APP04_HDB FROM TABLE @lt_Inbupd.
        ENDIF.

    ENDIF.
*********************************************************************

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
