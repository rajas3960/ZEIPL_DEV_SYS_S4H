CLASS lhc_ZMM_I_GATEHEAD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zmm_i_gatehead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zmm_i_gatehead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zmm_i_gatehead RESULT result.

    METHODS print FOR MODIFY
      IMPORTING keys FOR ACTION zmm_i_gatehead~print RESULT result.

    METHODS Purchase FOR MODIFY
      IMPORTING keys FOR ACTION zmm_i_gatehead~Purchase RESULT result.
    METHODS head_modify FOR DETERMINE ON SAVE
      IMPORTING keys FOR ZMM_I_GATEHEAD~head_modify.
    METHODS GateCheckIn FOR MODIFY
      IMPORTING keys FOR ACTION ZMM_I_GATEHEAD~GateCheckIn RESULT result.

ENDCLASS.

CLASS lhc_ZMM_I_GATEHEAD IMPLEMENTATION.

  METHOD get_instance_features.
**********************************************************************
        READ ENTITIES OF zmm_i_gatehead IN LOCAL MODE
        ENTITY zmm_i_gatehead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(gt_head)
        FAILED FINAL(gt_failed).
**********************************************************************
        data(gs_head) =   VALUE #( gt_head[ 1 ] OPTIONAL ).
**********************************************************************
        result = VALUE #( for ls_keys in keys
                        ( %tky = ls_keys-%tky

                        %action = VALUE #( GateCheckIn = COND #( WHEN gs_head-Gateentryno is not INITIAL
                                                                        or gs_head-Gateentryid is INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )
*                                           SalesOrder = COND #( when gs_head-Gateentryno is not INITIAL
*                                                then if_abap_behv=>fc-o-enabled
*                                                ELSE if_abap_behv=>fc-o-disabled ) )

                                                 ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD print.
  ENDMETHOD.

  METHOD Purchase.
***********************************************************************
            data: lv_ven type ZMM_GATE_PHTB-vendor,
                  lv_po type ZMM_GATE_PITB-purchaseorder,
                  lv_poitem type ZMM_GATE_PITB-purchaseorderitem.
***********************************************************************
            READ ENTITIES OF zmm_i_gatehead IN LOCAL MODE
            ENTITY zmm_i_gatehead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_head)
            fAILED FINAL(gt_failed).

*******************************************************************
        DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
        DATA(gt_keys) = keys.
        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
        lv_ven = gs_keys-%param-Vendor.
        lv_po = gs_keys-%param-PurchaseOrder.
        lv_poitem = gs_keys-%param-PurchaseOrderItem.
*******************************************************************
                select single purchaseorder,gateentryno from ZMM_GATE_PHTB with PRIVILEGED ACCESS
                where purchaseorder = @lv_po
                into @DATA(wa_podb).

                select single purchaseorder, purchaseorderitem from zmm_gate_pitb WITH PRIVILEGED ACCESS
                where purchaseorder = @lv_po
                and purchaseorderitem = @lv_poitem
                into @DATA(wa_poitemdb).

*******************************************************************
            if lv_po is not INITIAL and lv_poitem is not INITIAL.

                    select a~PurchaseOrder,
                           a~Supplier,
                           a~PurchaseOrderDate,
                           b~SupplierName
                           from I_PurchaseOrderAPI01 as a
                           left outer join i_supplier as b on a~Supplier = b~Supplier
                           where a~PurchaseOrder = @lv_po
                           into table @DATA(lt_po).
*******************************************************************
                    select a~PurchaseOrder,
                           a~PurchaseOrderItem,
                           a~Material,
                           a~plant,
                           a~BaseUnit,
                           a~OrderQuantity,
                           b~PlantName,
                           c~ProductName
                           from I_PurchaseOrderItemAPI01 as a
                           LEFT OUTER JOIN I_Plant as b on a~Plant = b~Plant
                           LEFT OUTER JOIN I_ProductText as c on a~Material = c~Product
                           where PurchaseOrder = @lv_po
                           and   PurchaseOrderItem = @lv_poitem
                           into table @data(lt_poitem).

            endif.
*******************************************************************
        if lt_po is not INITIAL and wa_podb-purchaseorder is INITIAL
                        and wa_poitemdb-purchaseorderitem is INITIAL.


                 MODIFY ENTITIES OF zmm_i_gatehead IN LOCAL MODE
                 ENTITY zmm_i_gatehead
                 CREATE BY \_pohead
                 AUTO FILL CID
                 FIELDS ( purchaseorder vendor gateentryno suppliername orderdate )

                 WITH VALUE #( for gs_head in gt_head
                             ( %is_draft = gs_head-%is_draft
                               %key = CORRESPONDING #( gs_head  )
                               %target = VALUE #( for ls_po in lt_po INDEX INTO iv_idx
                                               ( %cid = |CID{ iv_idx }|
                                               Purchaseorder = ls_po-PurchaseOrder
                                               Gateentryno = gs_head-Gateentryno
                                               Vendor = ls_po-Supplier
                                               Suppliername = ls_po-SupplierName
                                               Orderdate = ls_po-PurchaseOrderDate

                                               ) )
                                              ) )

                CREATE BY \_poitem
                AUTO FILL CID
                FIELDS ( Purchaseorder Purchaseorderitem Gateentryno
                         Material Materialtext Plant Plantname
                         Baseunit Quantity )

                with VALUE #( for gs_head in gt_head
                             ( %is_draft = gs_head-%is_draft
                               %key = CORRESPONDING #( gs_head )

                               %target = VALUE #( for ls_poitem in lt_poitem
                                             ( %cid = |CID{ ls_poitem-PurchaseOrderItem }|
                                               Purchaseorder = ls_poitem-PurchaseOrder
                                               Purchaseorderitem = ls_poitem-PurchaseOrderItem
                                               Gateentryno = gs_head-Gateentryno
                                               Material = ls_poitem-Material
                                               Materialtext = ls_poitem-ProductName
                                               Plant = ls_poitem-Plant
                                               Plantname = ls_poitem-PlantName
                                               Baseunit = ls_poitem-BaseUnit
                                               Quantity = ls_poitem-OrderQuantity
                                             ) )
                                            ) )
                  REPORTED reported
                  FAILED failed
                  MAPPED mapped.
************************************************************************
                  elseif wa_podb-purchaseorder is not INITIAL and wa_poitemdb-purchaseorderitem is INITIAL.


                MODIFY ENTITIES OF zmm_i_gatehead IN LOCAL MODE
                ENTITY zmm_i_gatehead
                CREATE BY \_poitem
                AUTO FILL CID
                FIELDS ( Purchaseorder Purchaseorderitem Gateentryno
                         Material Materialtext Plant Plantname
                         Baseunit Quantity )

                with VALUE #( for gs_head in gt_head
                             ( %is_draft = gs_head-%is_draft
                               %key = CORRESPONDING #( gs_head )

                               %target = VALUE #( for ls_poitem in lt_poitem
                                             ( %cid = |CID{ ls_poitem-PurchaseOrderItem }|
                                               Purchaseorder = ls_poitem-PurchaseOrder
                                               Purchaseorderitem = ls_poitem-PurchaseOrderItem
                                               Gateentryno = gs_head-Gateentryno
                                               Material = ls_poitem-Material
                                               Materialtext = ls_poitem-ProductName
                                               Plant = ls_poitem-Plant
                                               Plantname = ls_poitem-PlantName
                                               Baseunit = ls_poitem-BaseUnit
                                               Quantity = ls_poitem-OrderQuantity
                                             ) )
                                            ) )
                  REPORTED reported
                  FAILED failed
                  MAPPED mapped.
************************************************************************
        else.

              data(lv_msg) = |Order Already Exists-{ ls_header-Gateentryno }|.
              APPEND VALUE #( %tky = ls_header-%tky ) TO failed-zmm_i_gatehead.
              APPEND VALUE #( %tky = ls_header-%tky
              %state_area = 'Validate_Head'
              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = lv_msg )
                               ) TO reported-zmm_i_gatehead.

        endif.
************************************************************************
            READ ENTITIES OF zmm_i_gatehead IN LOCAL MODE
            ENTITY zmm_i_gatehead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_pohead)
            fAILED FINAL(gt_pofailed).

    result = VALUE #( FOR ls_ord IN gt_pohead
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD head_modify.
************************************************************************
            data: gateid type zmm_gate_htb-gateentryid.
***********************************************************************
            READ ENTITIES OF zmm_i_gatehead IN LOCAL MODE
            ENTITY zmm_i_gatehead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).
***********************************************************************
            data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
***********************************************************************
            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************

            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
                if <ls_head> is ASSIGNED.

                select SINGLE CompanyCode,CompanyCodeName from I_CompanyCodeStdVH with PRIVILEGED ACCESS
                where CompanyCode = @<ls_head>-companycode
                into @DATA(gs_companycode).

                select single value_low,text from  ZGATE_SERIES_VH with PRIVILEGED ACCESS
                where value_low = @<ls_head>-Gateentryseries
                into @DATA(gs_gateentryseries).

                select single value_low,text from  ZMGATE_TYPE_VH with PRIVILEGED ACCESS
                where value_low = @<ls_head>-Gateentrytype
                into @DATA(gs_gateentrytype).

***********************************************************************
                SELECT SINGLE MAX( gateentryid ) AS gateentryid
                FROM zmm_gate_htb
                INTO @DATA(gs_id).

                if gs_id is not INITIAL.
                gateid = gs_id + 1.
                 else.
                gateid = '2000000001'.
                endif.

************************************************************************
                MODIFY ENTITIES OF zmm_i_gatehead IN LOCAL MODE
                ENTITY zmm_i_gatehead
                UPDATE
                FIELDS ( Gateentryid Gateentryiddate Companyname Gateentryseriesdes
                         Gateentrytypedes )
                WITH VALUE #(  for key in keys
                               ( %tky = <ls_head>-%tky
                                 Gateentryid = gateid
                                 Gateentryiddate = lv_date
                                 Companyname = gs_companycode-CompanyCodeName
                                 Gateentryseriesdes = gs_gateentryseries-text
                                 Gateentrytypedes = gs_gateentrytype-text

                                %control-Gateentryid = if_abap_behv=>mk-on
                                %control-Gateentryiddate = if_abap_behv=>mk-on
                                %control-Companyname = if_abap_behv=>mk-on
                                %control-Gateentryseriesdes = if_abap_behv=>mk-on
                                %control-Gateentrytypedes = if_abap_behv=>mk-on
                                 ) ).
************************************************************************
                endif.
            ENDLOOP.
************************************************************************
  ENDMETHOD.

  METHOD GateCheckIn.
***********************************************************************
        data: seqno type ZMM_GATE_HTB-gateentryseqno,
              gateno type ZMM_GATE_HTB-gateentryno,
              sydate type ZMM_GATE_HTB-gateentrydate.
***********************************************************************
            READ ENTITIES OF zmm_i_gatehead IN LOCAL MODE
            ENTITY zmm_i_gatehead
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
            FROM ZMM_GATE_HTB
            WHERE gateentrydate = @lv_date
            GROUP BY gateentrydate
            INTO @DATA(gs_seqno).
***********************************************************************
            if sy-subrc = 0 and gs_seqno-gateentryseqno is not INITIAL.
                seqno = gs_seqno-gateentryseqno + 1.
                gateno = |{ <fs_head>-Gateentrytype }{ lv_date }-{ seqno }|.
            else.
                seqno = '001'.
                gateno = |{ <fs_head>-Gateentrytype }{ lv_date }-{ seqno }|.
            endif.
***********************************************************************
           MODIFY ENTITIES OF zmm_i_gatehead IN LOCAL MODE
           ENTITY zmm_i_gatehead
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

ENDCLASS.

CLASS lhc_ZMM_I_PGATEHEAD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zmm_i_pgatehead RESULT result.

ENDCLASS.

CLASS lhc_ZMM_I_PGATEHEAD IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZMM_I_PGATEITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zmm_i_pgateitem RESULT result.

ENDCLASS.

CLASS lhc_ZMM_I_PGATEITEM IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_I_GATEHEAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMM_I_GATEHEAD IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
