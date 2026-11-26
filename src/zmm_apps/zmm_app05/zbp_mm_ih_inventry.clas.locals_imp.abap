CLASS lsc_zmm_ih_inventry DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zmm_ih_inventry IMPLEMENTATION.

  METHOD save_modified.
*********************************************************************
"" Migo Update in custom table level
*********************************************************************
    IF zbp_mm_ih_inventry=>cv_migo_doc IS NOT INITIAL.
      LOOP AT zbp_mm_ih_inventry=>cv_migo_doc-materialdocument ASSIGNING FIELD-SYMBOL(<fs_migo_mapped>).
        CONVERT KEY OF i_materialdocumenttp FROM <fs_migo_mapped>-%pid TO DATA(ls_migo_key).
        <fs_migo_mapped>-materialdocument = ls_migo_key-materialdocument.
        <fs_migo_mapped>-MaterialDocumentYear = ls_migo_key-MaterialDocumentYear.
      ENDLOOP.
      IF zbp_mm_ih_inventry=>gt_migoup IS NOT INITIAL.
        DATA(lt_hdrupd) = zbp_mm_ih_inventry=>gt_migoup.
        LOOP AT lt_hdrupd ASSIGNING FIELD-SYMBOL(<fs_upd>).
          <fs_upd>-materialdocument = ls_migo_key-MaterialDocument.
          <fs_upd>-materialdocumentyear = ls_migo_key-MaterialDocumentYear.
        ENDLOOP.
        MODIFY ZMM_APP04_HDB FROM TABLE @lt_hdrupd.
      ENDIF.
    ENDIF.
*********************************************************************
"" Inbound Delivery update in custom table
*********************************************************************
    if zbp_mm_ih_inventry=>cv_indlv_doc is NOT INITIAL.
      LOOP AT zbp_mm_ih_inventry=>cv_indlv_doc-inbounddelivery ASSIGNING FIELD-SYMBOL(<fs_Inbd_mapped>).
        CONVERT KEY OF I_InboundDeliveryTP FROM <fs_Inbd_mapped>-%key TO DATA(ls_Inbd_key).
        <fs_Inbd_mapped>-InboundDelivery = ls_Inbd_key-InboundDelivery.
      ENDLOOP.

        IF zbp_mm_ih_inventry=>gt_item IS NOT INITIAL.
        DATA(lt_Inbupd) = zbp_mm_ih_inventry=>gt_item.
        LOOP AT lt_Inbupd ASSIGNING FIELD-SYMBOL(<fs_Inupd>).
          <fs_Inupd>-inbounddelivery = ls_Inbd_key-InboundDelivery.
        ENDLOOP.
        MODIFY ZMM_APP04_IDB FROM TABLE @lt_Inbupd.
        ENDIF.

    ENDIF.
*********************************************************************
"" Item Details update in custom table
*********************************************************************
        if zbp_mm_ih_inventry=>gt_upitem is NOT INITIAL.
            MODIFY ZMM_APP04_IDB FROM TABLE @zbp_mm_ih_inventry=>gt_upitem.
        ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR GateHead RESULT result.

    METHODS GateCheckIn FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~GateCheckIn RESULT result.

    METHODS Purchase FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~Purchase RESULT result.
    METHODS WeightScrn FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~WeightScrn RESULT result.
    METHODS MigoPost FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~MigoPost RESULT result.
    METHODS GateSlipForm FOR MODIFY
      keys FOR ACTION GateHead~GateSlipForm RESULT result.

ENDCLASS.

CLASS lhc_GateHead IMPLEMENTATION.

  METHOD get_instance_features.

******************************************************************
            READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

*******************************************************************
            result = VALUE #( FOR gs_header IN lt_head
                            ( %tky   = gs_header-%tky

                     %action = VALUE #( GateCheckIn = COND #( when ls_head-Gateentryno is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled ) )

                       %field-Gateentryseries =  COND #( WHEN gs_header-Gateentryno is NOT INITIAL
                                                                  THEN if_abap_behv=>fc-f-read_only
                                                                  ELSE if_abap_behv=>fc-f-unrestricted )

                        ) ).

*        result = VALUE #( for ls_key in keys
*                     ( %tky = ls_key-%tky
*
*                     %action = VALUE #( Purchase = COND #( WHEN ls_head-Gateentryno  is not INITIAL
*                                            then if_abap_behv=>fc-o-enabled
*                                            ELSE if_abap_behv=>fc-o-disabled )
*
*                                       GateCheckIn = COND #( when ls_head-Gateentryno is not INITIAL
*                                                then if_abap_behv=>fc-o-disabled
*                                                ELSE if_abap_behv=>fc-o-enabled )
*
*                                       WeightScrn = COND #( when ls_head-Gateentryno is not INITIAL
*                                                then if_abap_behv=>fc-o-enabled
*                                                ELSE if_abap_behv=>fc-o-disabled )
*
*                                       MigoPost = COND #( when ls_head-Materialdocument is not INITIAL
*                                                then if_abap_behv=>fc-o-disabled
*                                                ELSE if_abap_behv=>fc-o-enabled )
*
*                                        Edit = COND #( WHEN ls_head-Gateentryno  is not INITIAL
*                                            then if_abap_behv=>fc-o-enabled
*                                            ELSE if_abap_behv=>fc-o-disabled ) )
*
*
*                                         ) ) .


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GateCheckIn.
***********************************************************************
        data: seqno type zmm_app04_hdb-gateentryseqno,
              gateno type zmm_app04_hdb-gateentryno,
              sydate type zmm_app04_hdb-gateentrydate.
***********************************************************************
            READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).
***********************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
        LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
            IF <fs_head> is ASSIGNED.

        SELECT SINGLE MAX( gateentryseqno ) AS gateentryseqno,
              gateentrydate
            FROM zmm_app04_hdb
            WHERE gateentrydate = @lv_date
            GROUP BY gateentrydate
            INTO @DATA(gs_seqno).
***********************************************************************
            if sy-subrc = 0 and gs_seqno-gateentryseqno is not INITIAL.
                seqno = gs_seqno-gateentryseqno + 1.
                gateno = |{ <fs_head>-Gateentryseries }{ lv_date }-{ seqno }|.
            else.
                seqno = '001'.
                gateno = |{ <fs_head>-Gateentryseries }{ lv_date }-{ seqno }|.
            endif.
***********************************************************************
           MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
           ENTITY GateHead
           UPDATE
           FIELDS ( Gateentryno Gateentryseqno Gateentrydate Gateentrytime )
           WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         gateentryno = gateno
                         Gateentryseqno = seqno
                         gateentrydate = lv_date
                         gateentrytime = lv_time
                         %control-Gateentryno = if_abap_behv=>mk-on
                         %control-Gateentryseqno = if_abap_behv=>mk-on
                         %control-Gateentrydate = if_abap_behv=>mk-on
                         %control-Gateentrytime = if_abap_behv=>mk-on
                         ) ).
***********************************************************************
            ENDIF.
        ENDLOOP.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD Purchase.
***********************************************************************
            data: lv_ven type ZMM_GATE_PHTB-vendor,
                  lv_po type ZMM_GATE_PITB-purchaseorder,
                  lv_poitem type ZMM_GATE_PITB-purchaseorderitem.
***********************************************************************
            READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT data(gt_head)
            ENTITY GateHead by \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(gt_item)
            fAILED data(gt_failed).

*******************************************************************
        DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
        DATA(gt_keys) = keys.
        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
        DATA: lv_subgate type zmm_app04_idb-subgateentryno.

        lv_ven = gs_keys-%param-Vendor.
        lv_po = gs_keys-%param-PurchaseOrder.
        lv_poitem = gs_keys-%param-PurchaseOrderItem.
********************************************************************
*if ls_header-Gateentryseries = 'G2'.
*TYPES: BEGIN OF ty_po_count,
*         purchaseorder TYPE ebeln,
*         item_count    TYPE i,
*       END OF ty_po_count.
*
*DATA gt_po_count TYPE TABLE OF ty_po_count.
*
*LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>)
*     GROUP BY <fs_item>-purchaseorder
*     INTO DATA(lv_po1).
*
*  DATA(lv_count) = 0.
*
*  LOOP AT GROUP lv_po1 ASSIGNING FIELD-SYMBOL(<fs_group>).
*    lv_count += 1.
*  ENDLOOP.
*
*  APPEND VALUE #(
*    purchaseorder = lv_po1
*    item_count    = lv_count
*  ) TO gt_po_count.
*
*ENDLOOP.
*DATA(lv_subcount) = lines( gt_po_count ).
*
*                    if lv_subcount is INITIAL.
*                        lv_subgate = |{ ls_header-Gateentryno }-A|.
*                    ELSEIF lv_subcount = '1'.
*                        lv_subgate = |{ ls_header-Gateentryno }-B|.
*                    ELSEIF lv_subcount = '2'.
*                        lv_subgate = |{ ls_header-Gateentryno }-C|.
*                    ELSEIF lv_subcount = '3'.
*                        lv_subgate = |{ ls_header-Gateentryno }-D|.
*                    ELSEIF lv_subcount = '4'.
*                        lv_subgate = |{ ls_header-Gateentryno }-E|.
*                    ELSEIF lv_subcount = '5'.
*                        lv_subgate = |{ ls_header-Gateentryno }-F|.
*                    ELSEIF lv_subcount = '6'.
*                        lv_subgate = |{ ls_header-Gateentryno }-G|.
*                    ELSEIF lv_subcount = '7'.
*                        lv_subgate = |{ ls_header-Gateentryno }-H|.
*                    ELSEIF lv_subcount = '8'.
*                        lv_subgate = |{ ls_header-Gateentryno }-I|.
*                    ELSEIF lv_subcount = '9'.
*                        lv_subgate = |{ ls_header-Gateentryno }-J|.
*                    ELSEIF lv_subcount = '10'.
*                        lv_subgate = |{ ls_header-Gateentryno }-K|.
*                    ENDIF.
*ENDIF.
*
*
***********************************************************************
*        if ls_header-Vendor is INITIAL.
*
*            select single PurchaseOrder, BaseUnit from I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS
*            where PurchaseOrder = @lv_po
*            into @DATA(lv_baseunit).
*
*                    select a~PurchaseOrder,
*                           a~Supplier,
*                           a~PurchaseOrderDate,
*                           a~PurchaseOrderType,
*                           b~SupplierName,
*                           c~PurchasingDocumentTypeName
*                           from I_PurchaseOrderAPI01 as a
*                           left outer join i_supplier as b on a~Supplier = b~Supplier
*                           LEFT OUTER JOIN I_PurchasingDocumentTypeText as c on a~PurchaseOrderType = c~PurchasingDocumentType
*                                            and c~PurchasingDocumentCategory = 'F'
*                                            and c~Language = 'E'
*                           where a~PurchaseOrder = @lv_po
*                           into table @DATA(lt_po).
*
*                    data(ls_po) = VALUE #( lt_po[ 1 ] OPTIONAL ).
********************************************************************
*            LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<gs_head>).
*            IF <gs_head> Is ASSIGNED.
*
*                    MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
*                    ENTITY GateHead
*                    UPDATE
*                    FIELDS ( Vendor Suppliername Poordertype
*                               Poordertypetext  Orderdate Pobaseunit )
*                        WITH VALUE #( for key in keys
*                                   (   %tky = <gs_head>-%tky
*                                    Vendor = ls_po-Supplier
*                                    Suppliername = ls_po-SupplierName
*                                    Poordertype = ls_po-PurchaseOrderType
*                                    Poordertypetext = ls_po-PurchasingDocumentTypeName
*                                    Orderdate = ls_po-PurchaseOrderDate
*                                    Pobaseunit = lv_baseunit-BaseUnit
*
*                                    %control-Vendor = if_abap_behv=>mk-on
*                                    %control-Suppliername = if_abap_behv=>mk-on
*                                    %control-Poordertype = if_abap_behv=>mk-on
*                                    %control-Poordertypetext = if_abap_behv=>mk-on
*                                    %control-Orderdate = if_abap_behv=>mk-on
*                                    %control-Pobaseunit = if_abap_behv=>mk-on
*                                    )  ).
*            ENDIF.
*            ENDLOOP.
*        ENdif.
*******************************************************************
        select single purchaseorder, purchaseorderitem from ZMM_APP04_IDB WITH PRIVILEGED ACCESS
                where purchaseorder = @lv_po
                and purchaseorderitem = @lv_poitem
                and uuid = @ls_header-Uuid
                into @DATA(wa_poitemdb).
*******************************************************************
        select single purchaseorder, purchaseorderitem from ZMM_APP04_IDB WITH PRIVILEGED ACCESS
                where purchaseorder = @lv_po
                and uuid = @ls_header-Uuid
                into @DATA(wa_poitemdb_st).

            if lv_po is not INITIAL and ls_header-Gateentryseries ne 'G2'.
*                and wa_poitemdb-purchaseorder is INITIAL and wa_poitemdb-purchaseorderitem is INITIAL.

*******************************************************************
            if lv_po is not INITIAL and lv_poitem is not INITIAL.

                    select a~PurchaseOrder,
                           a~PurchaseOrderItem,
                           a~Material,
                           a~plant,
                           a~OrderPriceUnit as BaseUnit,
                           a~OrderQuantity,
                           a~Materialgroup,
                           b~PlantName,
                           c~ProductName,
                           d~Supplier,
                           d~PurchaseOrderDate,
                           d~PurchaseOrderType,
                           e~SupplierName,
                           f~PurchasingDocumentTypeName,
                           cast( g~ConditionRateValue as dec( 13,2 ) ) as ConditionRateValue
                           from I_PurchaseOrderItemAPI01 as a
                           LEFT OUTER JOIN I_PurchaseOrderAPI01 as d on a~PurchaseOrder = d~PurchaseOrder
                           LEFT OUTER JOIN I_Plant as b on a~Plant = b~Plant
                           LEFT OUTER JOIN I_ProductText as c on a~Material = c~Product
                           LEFT OUTER JOIN i_supplier as e on d~Supplier = e~Supplier
                           LEFT OUTER JOIN I_PurchasingDocumentTypeText as f on d~PurchaseOrderType = f~PurchasingDocumentType
                                            and f~PurchasingDocumentCategory = 'F'
                                            and f~Language = 'E'
                           LEFT OUTER JOIN I_PurOrdItmPricingElementAPI01 as g ON g~PurchaseOrder = a~PurchaseOrder
                                           and g~PurchaseOrderItem = a~PurchaseOrderItem
                                           AND ( g~ConditionType = 'PMPO' OR g~ConditionType = 'PPR0' )
                                           AND g~ConditionRateValue is not INITIAL
                           where a~PurchaseOrder = @lv_po
                           and   a~PurchaseOrderItem = @lv_poitem
                           into table @data(lt_poitem).

            endif.

*******************************************************************

                  MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
                  ENTITY GateHead
                  CREATE BY \_Item
                  AUTO FILL CID
                  FIELDS ( Purchaseorder Purchaseorderitem Vendor Materialgroup
                            Suppliername Gateentryno Material Materialtext Gateentryseries Poperunitprice
                            Plant Plantname Baseunit Quantity Poordertype Poordertypetext Orderdate )
                    WITH VALUE #( for gs_head in gt_head
                                ( %is_draft = gs_head-%is_draft
                                  %key = CORRESPONDING #( gs_head )

                                  %target = VALUE #( for ls_poitem in lt_poitem
                                  ( %cid = |CID{ ls_poitem-PurchaseOrderItem }|
                                               Purchaseorder = ls_poitem-PurchaseOrder
                                               Purchaseorderitem = ls_poitem-PurchaseOrderItem
                                               Vendor = ls_poitem-Supplier
                                               Suppliername = ls_poitem-SupplierName
                                               Gateentryno = gs_head-Gateentryno
                                               Gateentryseries = gs_head-Gateentryseries
                                               Material = ls_poitem-Material
                                               Materialtext = ls_poitem-ProductName
                                               Plant = ls_poitem-Plant
                                               Plantname = ls_poitem-PlantName
                                               Baseunit = ls_poitem-BaseUnit
                                               Quantity = ls_poitem-OrderQuantity
                                               Materialgroup = ls_poitem-Materialgroup
                                               Poordertype = ls_poitem-PurchaseOrderType
                                               Poordertypetext = ls_poitem-PurchasingDocumentTypeName
                                               Orderdate = ls_poitem-PurchaseOrderDate
                                               Poperunitprice = ls_poitem-conditionratevalue
                                 )  ) ) )
                    MAPPED mapped
                    FAILED failed
                    REPORTED reported.
************************************************************************
            ELSEIF lv_po is not INITIAL and ls_header-Gateentryseries = 'G2' .
*            and wa_poitemdb_st is INITIAL.

                    select a~PurchaseOrder,
                           a~PurchaseOrderItem,
                           a~Material,
                           a~plant,
                           a~OrderPriceUnit as BaseUnit,
                           a~OrderQuantity,
                           a~Materialgroup,
                           b~PlantName,
                           c~ProductName,
                           d~Supplier,
                           d~PurchaseOrderDate,
                           d~PurchaseOrderType,
                           e~SupplierName,
                           f~PurchasingDocumentTypeName,
                           cast( g~ConditionRateValue as dec( 13,2 ) ) as ConditionRateValue
                           from I_PurchaseOrderItemAPI01 as a
                           LEFT OUTER JOIN I_PurchaseOrderAPI01 as d on a~PurchaseOrder = d~PurchaseOrder
                           LEFT OUTER JOIN I_Plant as b on a~Plant = b~Plant
                           LEFT OUTER JOIN I_ProductText as c on a~Material = c~Product
                           LEFT OUTER JOIN i_supplier as e on d~Supplier = e~Supplier
                           LEFT OUTER JOIN I_PurchasingDocumentTypeText as f on d~PurchaseOrderType = f~PurchasingDocumentType
                                            and f~PurchasingDocumentCategory = 'F'
                                            and f~Language = 'E'
                           LEFT OUTER JOIN I_PurOrdItmPricingElementAPI01 as g ON g~PurchaseOrder = a~PurchaseOrder
                                           and g~PurchaseOrderItem = a~PurchaseOrderItem
                                           AND ( g~ConditionType = 'PMP0' OR g~ConditionType = 'PPR0' )
                                           AND g~ConditionRateValue is NOT INITIAL
                           where a~PurchaseOrder = @lv_po
                           AND a~IsCompletelyDelivered is INITIAL
                           into table @data(lt_poitem_st).

                SORT lt_poitem_st BY PurchaseOrderItem ASCENDING.

                  MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
                  ENTITY GateHead
                  CREATE BY \_Item
                  AUTO FILL CID
                  FIELDS ( Purchaseorder Purchaseorderitem Vendor Materialgroup
                            Suppliername Gateentryno Material Materialtext Poperunitprice
                            Plant Plantname Baseunit Quantity Subgateentryno Poordertype Poordertypetext Orderdate )
                    WITH VALUE #( for gs_head in gt_head
                                ( %is_draft = gs_head-%is_draft
                                  %key = CORRESPONDING #( gs_head )

                                  %target = VALUE #( for ls_poitem_st in lt_poitem_st
                                  ( %cid = |CID{ ls_poitem_st-PurchaseOrderItem }|
                                               Purchaseorder = ls_poitem_st-PurchaseOrder
                                               Purchaseorderitem = ls_poitem_st-PurchaseOrderItem
                                               Vendor = ls_poitem_st-Supplier
                                               Suppliername = ls_poitem_st-SupplierName
                                               Gateentryno = gs_head-Gateentryno
                                               Gateentryseries = gs_head-Gateentryseries
                                               Subgateentryno = lv_subgate
                                               Material = ls_poitem_st-Material
                                               Materialtext = ls_poitem_st-ProductName
                                               Plant = ls_poitem_st-Plant
                                               Plantname = ls_poitem_st-PlantName
                                               Baseunit = ls_poitem_st-BaseUnit
                                               Quantity = ls_poitem_st-OrderQuantity
                                               Materialgroup = ls_poitem_st-Materialgroup
                                               Poordertype = ls_poitem_st-PurchaseOrderType
                                               Poordertypetext = ls_poitem_st-PurchasingDocumentTypeName
                                               Orderdate = ls_poitem_st-PurchaseOrderDate
                                               Poperunitprice = ls_poitem_st-conditionratevalue

                                 )  ) ) )
                    MAPPED mapped
                    FAILED failed
                    REPORTED reported.

************************************************************************


*            else.
*
*              data(lv_msg) = |Order Already Exists-{ ls_header-Gateentryno }|.
*              APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
*              APPEND VALUE #( %tky = ls_header-%tky
*              %state_area = 'Validate_Head'
*              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                              text = lv_msg )
*                               ) TO reported-gatehead.
*
            ENDIF.
************************************************************************
    result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************


  ENDMETHOD.

  METHOD WeightScrn.
************************************************************************
*            READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
*            ENTITY GateHead
*            ALL FIELDS WITH CORRESPONDING #( keys )
*            RESULT FINAL(lt_gatehd)
*            FAILED FINAL(lt_failed).
************************************************************************
*            LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
*            IF <ls_hd> is ASSIGNED.
*
*                    MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
*                    ENTITY GateHead
*                    UPDATE
*                    FIELDS ( Weighmentindicator )
*                        WITH VALUE #( for key in keys
*                                   (   %tky = <ls_hd>-%tky
*                                    Weighmentindicator = 'X'
*                                    %control-Weighmentindicator = if_abap_behv=>mk-on
*                                    )  ).
*            ENDIF.
*            ENDLOOP.
*************************************************************************
*    result = VALUE #( FOR ls_ord IN lt_gatehd
*                         ( %tky   = ls_ord-%tky
*                           %param = ls_ord ) ).
************************************************************************

  ENDMETHOD.

  METHOD MigoPost.
***********************************************************************
            DATA : gt_uphead TYPE TABLE OF ZMM_APP04_HDB,
                   gs_uphead type ZMM_APP04_HDB.
***********************************************************************

                READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
                ENTITY GateHead
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT FINAL(lt_head)
                ENTITY GateHead BY \_Item
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT FINAL(lt_poitem)
                FAILED FINAL(lt_failed).

***********************************************************************
            data(ls_header) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            data(gt_keys) = keys.
            data(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            data(lv_mvmt_type) = '101'.

***********************************************************************
            data: lv_item type I_PURCHASEORDERITEMAPI01-PurchaseOrderItem.
*            sort lt_poitem ASCENDING by Purchaseorderitem.



        get TIME STAMP FIELD DATA(ts).
        CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************


              MODIFY ENTITIES OF i_materialdocumenttp PRIVILEGED
                ENTITY MaterialDocument
                 CREATE FROM VALUE #( ( %cid = 'CID_001'
                             goodsmovementcode = '01'
                             postingdate = gs_keys-%param-PostingDate
                             documentdate = lv_date
                             %control-goodsmovementcode = cl_abap_behv=>flag_changed
                             %control-postingdate = cl_abap_behv=>flag_changed
                             %control-documentdate = cl_abap_behv=>flag_changed
                         ) )
**********************************************************************
                 ENTITY MaterialDocument
                 CREATE BY \_MaterialDocumentItem
                 FROM VALUE #(
                 FOR ls_poitem IN lt_poitem (
                 %cid_ref = 'CID_001'
                 %target = VALUE #( ( %cid = 'CID_ITM_' && ls_poitem-Purchaseorderitem
                 plant = ls_poitem-Plant
                 material = ls_poitem-Material
                 PurchaseOrder = ls_poitem-Purchaseorder
                 PurchaseOrderItem = ls_poitem-Purchaseorderitem
                 GoodsMovementType = lv_mvmt_type
                 GoodsMovementRefDocType = 'B'
                 QuantityInEntryUnit = ls_poitem-Netweight
                 entryunit = ls_poitem-Baseunit
                 storagelocation = ls_poitem-Storagelocation
                 YY1_GateEntryNo_MMI = ls_header-Gateentryno

*                 IssuingOrReceivingPlant = 'MHU3'
*                 IssuingOrReceivingStorageLoc = 'U3GN'


                 %control-plant = cl_abap_behv=>flag_changed
                 %control-material = cl_abap_behv=>flag_changed
                 %control-GoodsMovementType = cl_abap_behv=>flag_changed
                 %control-PurchaseOrder = cl_abap_behv=>flag_changed
                 %control-PurchaseOrderItem = cl_abap_behv=>flag_changed
                 %control-QuantityInEntryUnit = cl_abap_behv=>flag_changed
                 %control-entryunit = cl_abap_behv=>flag_changed
                  %control-GoodsMovementRefDocType = cl_abap_behv=>flag_changed
                  %control-StorageLocation = cl_abap_behv=>flag_changed
                  %control-YY1_GateEntryNo_MMI = cl_abap_behv=>flag_changed

             ) )
                ) )
                 MAPPED DATA(ls_create_mapped)
                 FAILED DATA(ls_create_failed)
                 REPORTED DATA(ls_create_reported).

************************************************************************
      IF ls_create_failed IS INITIAL.
        zbp_mm_ih_inventry=>cv_migo_doc-materialdocument = ls_create_mapped-materialdocument.
            MOVE-CORRESPONDING ls_header to gs_uphead.
            APPEND gs_uphead to gt_uphead.
            zbp_mm_ih_inventry=>gt_migoup = gt_uphead.
      endif.

*************************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD GateSlipForm.
*********************************************************************************************
          READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
          ENTITY GateHead
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT FINAL(gt_head)
          FAILED FINAL(gt_failed).
*************************************************************************************************
          DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
          DATA(gt_keys) = keys.
          DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
*************************************************************************************************
    if ls_header-Gateentryno is not INITIAL.

        TRY.
            "Initialize Template Store Client
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_name                  = 'ZADS_CS'
             iv_service_instance_name = 'ZADS_OUT_REST'
            ).

            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZMM_ENTRY_SLIP_SD'
                                                                  iv_root_node = 'ZMM_ENTRY_SLIP_CE' ) .

            data: printque type c LENGTH 32.

              printque = 'ADOBE_DEFAULT'.

            TRY.
                lo_store->get_schema_by_name( iv_form_name = 'ZMM_ENTRY_SLIP' ).
                "   out->write( 'Schema found in form' ).
              CATCH zcx_fp_tmpl_store_error INTO DATA(lo_tmpl_error).
                "  out->write( 'No schema in form found' ).
                IF lo_tmpl_error->mv_http_status_code = 404 OR lo_tmpl_error->mv_http_status_code = 403 .
                  "Upload service definition
*                  lo_store->set_schema(
*                    iv_form_name = 'ENTRY_SLIP'
*                    is_data      = VALUE #( note = '' schema_name = 'schema' xsd_schema = lo_fdp_util->get_xsd( ) )
*                  ).
                ELSE.

                ENDIF.
            ENDTRY.
***************************************************************************************************************
              TYPES: BEGIN OF ty_schema_body,
                 xsd_schema  TYPE xstring,
                 schema_name TYPE c LENGTH 30,
                 note        TYPE c LENGTH 280,
               END OF ty_schema_body.

        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA lv_xdp TYPE ty_schema_body.
        lv_xdp = VALUE #( note        = ''
                          schema_name = 'schema'
                          xsd_schema  = lo_fdp_util->get_xsd( ) ).
**********************************************************************************************************
                     DATA(lt_keys)     = lo_fdp_util->get_keys( ).
            lt_keys[ name = 'UUID' ]-value = gt_head[ 1 ]-Uuid.
******************************************************************************************************************
            data(lt_xsd) = lo_fdp_util->get_xsd( ).
****************************************************************************************************************
*               *           "Convert the XSD File converstion for Form Purpose
             data(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

                TRY.
                DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
                "out->write( 'Service data retrieved' ).
              CATCH cx_fp_fdp_error INTO DATA(lo_exception).
            ENDTRY.
*************************************************************************************************************
         DATA(ls_template) = lo_store->get_template_by_name(
              iv_get_binary    = abap_true
              iv_form_name     = 'ZMM_ENTRY_SLIP'
              iv_template_name = 'ENTRY_SLIP'
            ).
*************************************************************************
      cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                       "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                 iv_xml_data     = lv_xml
                                                 iv_xdp_layout   = ls_template-xdp_template
                                                 is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                       IMPORTING
                                       " TODO: variable is assigned but never used (ABAP cleaner)
                                                 ev_trace_string = DATA(lv_trace)
                                                 ev_pdf          = DATA(lv_pdf) ).




*******************************************************************************************************************
           DATA: lv_name TYPE c LENGTH 120.
            lv_name = |Entry Slip-{ gt_head[ 1 ]-Gateentryno }|.
*             DATA: lv_pdf TYPE xstring.
**************************************************************************************************************************
            cl_print_queue_utils=>create_queue_item_by_data(
              iv_qname            = printque
              iv_print_data       = lv_pdf
              iv_name_of_main_doc = lv_name
              iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
            ).

          CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
            " out->write( 'Exception occurred.' ).
        ENDTRY.
**************************************************************************************************************************
           if lv_pdf is not iNITIAL.

                    MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
                    ENTITY GateHead
                    UPDATE
                    FIELDS ( Entryslipattcmt Entrymimetype Entryfilename )
                        WITH VALUE #( for key in keys
                                   (   %tky = ls_header-%tky
                                    Entryslipattcmt = lv_pdf
                                    Entrymimetype = 'application/pdf'
                                    Entryfilename = lv_name
                                    %control-Entryslipattcmt = if_abap_behv=>mk-on
                                    %control-Entrymimetype = if_abap_behv=>mk-on
                                    %control-Entryfilename = if_abap_behv=>mk-on
                                    )  ).

                endif.

        endif.
*********************************************************************************************************************
               result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).



  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateItem RESULT result.
    METHODS challanqtycal FOR DETERMINE ON MODIFY
      keys FOR gateitem~challanqtycal.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR gateitem RESULT result.

    METHODS inbdelivery FOR MODIFY
      keys FOR ACTION gateitem~inbdelivery RESULT result.
    METHODS challaninput FOR MODIFY
      keys FOR ACTION gateitem~challaninput RESULT result.

ENDCLASS.

CLASS lhc_GateItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD ChallanQtyCal.
***********************************************************************************
            DATA: lv_chnetqty TYPE ZMM_II_INVENTRY-Challannetweight.
***********************************************************************************
            READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY GateItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
***********************************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

            LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
            if <ls_item> is ASSIGNED.
                if <ls_item>-Challangrossweight is NOT INITIAL.
                    lv_chnetqty = ( <ls_item>-Challangrossweight - <ls_item>-Challantareweight ).

                    MODIFY ENTITIES OF zmm_ih_inventry IN LOCAL MODE
                    ENTITY GateItem
                    UPDATE
                    FIELDS ( Challannetweight )
						WITH VALUE #( for key in keys
								   (   %tky = <ls_item>-%tky
									Challannetweight = lv_chnetqty
									%control-Challannetweight = if_abap_behv=>mk-on
									)  ).
                ENDIF.
            ENDIF.
            ENDLOOP.
***********************************************************************************
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD InbDelivery.
***********************************************************************************
            READ ENTITIES OF zmm_ih_inventry IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY GateItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_poitem)
            FAILED DATA(lt_failed).
***********************************************************************************
            DATA(ls_pohead) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA(ls_item) = VALUE #( lt_poitem[ 1 ] OPTIONAL ).
            sort lt_poitem ASCENDING BY Purchaseorder Purchaseorderitem.
***********************************************************************************
        get TIME STAMP FIELD DATA(ts).
        CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

********************************************************************************

            MODIFY ENTITIES OF I_InboundDeliveryTP PRIVILEGED
                ENTITY InboundDelivery
                EXECUTE CreateDlvFrmPurchasingDocument

            FROM VALUE #(
                    (   %cid = 'CREATE1'
                        %param = VALUE #(
                        supplier = ls_item-Vendor
                        deliverydate = lv_date
                        deliverytime = lv_time
                        deliverydocumentbysupplier = ls_pohead-Gateentryno
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

                        FOR ls_poitem IN lt_poitem

                        ( referencesddocument = ls_poitem-Purchaseorder
                          referencesddocumentitem = ls_poitem-Purchaseorderitem
           %control = VALUE #(
                            referencesddocument = if_abap_behv=>mk-on ) )

                                 ) ) ) )
              MAPPED DATA(mapped_create)
              REPORTED DATA(reported_create)
              FAILED DATA(failed_create).

********************************************************************************
    IF mapped_create IS NOT INITIAL.
      IF failed_create IS INITIAL.
        zbp_mm_ih_inventry=>cv_indlv_doc-inbounddelivery = mapped_create-inbounddelivery.
        zbp_mm_ih_inventry=>gt_item = CORRESPONDING #( lt_poitem ).
      ENDIF.
    ENDIF.
********************************************************************************
               result = VALUE #( FOR ls_ord IN lt_poitem
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).

  ENDMETHOD.

  METHOD ChallanInput.

********************************************************************************
            READ ENTITIES OF zmm_ih_inventry in LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY GateItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
********************************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] optional ).
            sort lt_item ASCENDING BY Purchaseorder Purchaseorderitem.
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            DATA: lv_subgate type zmm_app04_idb-subgateentryno.
            DATA: lv_trans TYPE n LENGTH 10.
            data: up_item TYPE TABLE of zmm_app04_idb,
                  ups_item TYPE zmm_app04_idb.
********************************************************************************
                lv_trans = gs_keys-%param-trasporterid.

                SELECT SINGLE * FROM ZMM_BP_ZTRP_VH WITH PRIVILEGED ACCESS
                WHERE Transporterid = @lv_trans
                INTO @DATA(ls_transname).
********************************************************************************

                SELECT * FROM zmm_app04_idb WITH PRIVILEGED ACCESS
                WHERE uuid = @ls_head-Uuid
                AND challanno is NOT INITIAL
                INTO TABLE @DATA(t_item).

                DATA(t_item_count) = lines( t_item ).

            if ls_head-Gateentryseries = 'G2'.

            TYPES: BEGIN OF ty_po_count,
                    invoiceno TYPE c LENGTH 20,
                    item_count    TYPE i,
            END OF ty_po_count.

            DATA gt_Inv_count TYPE TABLE OF ty_po_count.

********************************************************************************
            LOOP AT t_item ASSIGNING FIELD-SYMBOL(<gs_item>)
             GROUP BY <gs_item>-challanno
             INTO DATA(lv_Ino1).

              DATA(lv_count) = 0.

              LOOP AT GROUP lv_Ino1 ASSIGNING FIELD-SYMBOL(<fs_group>).
                lv_count += 1.
              ENDLOOP.

              APPEND VALUE #(
                invoiceno = lv_Ino1
                item_count    = lv_count
              ) TO gt_Inv_count.

            ENDLOOP.

            DATA(lv_subcount) = lines( gt_Inv_count ).
            DATA(lv_finalCount) = lv_subcount.

                    if lv_finalCount = '0'.
                        lv_subgate = |{ ls_head-Gateentryno }-A|.
                    ELSEIF lv_finalCount = '1'.
                        lv_subgate = |{ ls_head-Gateentryno }-B|.
                    ELSEIF lv_finalCount = '2'.
                        lv_subgate = |{ ls_head-Gateentryno }-C|.
                    ELSEIF lv_finalCount = '3'.
                        lv_subgate = |{ ls_head-Gateentryno }-D|.
                    ELSEIF lv_finalCount = '4'.
                        lv_subgate = |{ ls_head-Gateentryno }-E|.
                    ELSEIF lv_finalCount = '5'.
                        lv_subgate = |{ ls_head-Gateentryno }-F|.
                    ELSEIF lv_finalCount = '6'.
                        lv_subgate = |{ ls_head-Gateentryno }-G|.
                    ELSEIF lv_finalCount = '7'.
                        lv_subgate = |{ ls_head-Gateentryno }-H|.
                    ELSEIF lv_finalCount = '8'.
                        lv_subgate = |{ ls_head-Gateentryno }-I|.
                    ELSEIF lv_finalCount = '9'.
                        lv_subgate = |{ ls_head-Gateentryno }-J|.
                    ELSEIF lv_finalCount = '10'.
                        lv_subgate = |{ ls_head-Gateentryno }-K|.
                    ENDIF.
ENDIF.


**********************************************************************

            LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
            if <fs_item> is ASSIGNED.

                    MOVE-CORRESPONDING <fs_item> to ups_item.
                    ups_item-challanno = gs_keys-%param-Challanno.
                    ups_item-challandate = gs_keys-%param-Challandate.
                    ups_item-trasporterid = gs_keys-%param-trasporterid.
                    ups_item-trasportername = ls_transname-Transportername.
                    ups_item-lrno = gs_keys-%param-lrno.
                    ups_item-lrdate = gs_keys-%param-lrdate.
                    ups_item-subgateentryno = lv_subgate.

                    APPEND ups_item to up_item.
            ENDIF.
            ENDLOOP.
                if up_item is NOT INITIAL.
                    zbp_mm_ih_inventry=>gt_upitem = up_item.
                ENDIF.
********************************************************************************
               result = VALUE #( FOR ls_item IN lt_item
                         ( %tky   = ls_item-%tky
                           %param = ls_item ) ).
  ENDMETHOD.

ENDCLASS.
