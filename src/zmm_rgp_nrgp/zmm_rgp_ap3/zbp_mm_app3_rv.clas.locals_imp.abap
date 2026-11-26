CLASS lhc_GPline DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR GPline RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR GPline RESULT result.
    METHODS documentclose FOR MODIFY
      keys FOR ACTION gpline~documentclose RESULT result.

ENDCLASS.

CLASS lhc_GPline IMPLEMENTATION.

  METHOD get_instance_features.

  READ ENTITIES OF zmm_app3_rv IN LOCAL MODE
    ENTITY GPline
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_status).

  result = VALUE #(
    FOR ls_key IN lt_status
    (
      %tky = ls_key-%tky

      %action-Edit = COND #(
        WHEN ls_key-Closedocument = abap_true
          OR ( ls_key-Quantity - ls_key-Totrcvqty ) <= 0
        THEN if_abap_behv=>fc-o-disabled
        ELSE if_abap_behv=>fc-o-enabled
      )
    )
  ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD DocumentClose.


  DATA: lt_update TYPE TABLE OF zmm_app1_tb2,
        ls_update TYPE zmm_app1_tb2.

  READ ENTITIES OF zmm_app3_rv IN LOCAL MODE
    ENTITY GPline
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head).

  LOOP AT lt_head INTO DATA(ls_head).

    MOVE-CORRESPONDING ls_head TO ls_update.
    ls_update-closedocument = abap_true.

    APPEND ls_update TO lt_update.

    "Success message
    APPEND VALUE #(
      %tky = ls_head-%tky
      %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-success
        text = 'Document closed successfully'
      )
    ) TO reported-gpline.

  ENDLOOP.

  zbp_mm_app3_rv=>gt_closehead = lt_update.

  result = VALUE #(
    FOR ls_ord IN lt_head
    (
      %tky   = ls_ord-%tky
      %param = ls_ord
    )
  ).


  ENDMETHOD.

ENDCLASS.

CLASS lhc_GPLsno DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR GPLsno RESULT result.

    METHODS Upditem FOR DETERMINE ON MODIFY
       keys FOR GPLsno~Upditem.

    METHODS CrtItem FOR DETERMINE ON SAVE
       keys FOR GPLsno~CrtItem.

    METHODS ValiRecqty FOR VALIDATE ON SAVE
       keys FOR GPLsno~ValiRecqty.

ENDCLASS.

CLASS lhc_GPLsno IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.


  METHOD CrtItem.
**********************************************************************
    DATA : lt_citem TYPE TABLE OF zmm_app03_tb1,
           ls_citem TYPE zmm_app03_tb1.

**********************************************************************
    READ ENTITIES OF zmm_app3_rv IN LOCAL MODE
     ENTITY gpline
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_header)
     ENTITY gpline BY \_item
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_gplsno).
    DATA(ls_header) = lt_header[ 1 ].
    DATA(ls_gplsno) = lt_gplsno[ 1 ].
**********************************************************************
**********************************************************************
    ls_citem-uuid = ls_header-uuid.
    ls_citem-itemno = ls_header-itemno.

    ls_citem-uom = ls_header-Uom.
    try.
    ls_citem-createdby = cl_abap_context_info=>get_user_description(  ).
    CATCH cx_abap_context_info_error INTO DATA(lv_error).
        DATA(lv_1) = 1.
    ENDTRY.
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA'
            INTO DATE DATA(lv_date) TIME DATA(lv_time).
    ls_citem-indt = lv_date.
    ls_citem-intim = lv_time.
    ls_citem-invoice = ls_gplsno-invoice.
    ls_citem-maktx = ls_header-maktx.
    ls_citem-matnr = ls_header-matnr.
    ls_citem-quantity = ls_header-quantity.
    ls_citem-recvqty = ls_gplsno-recvqty.
    ls_citem-accqty = ls_gplsno-Accqty.
    ls_citem-rjtqty = ls_gplsno-Rjtqty.
    ls_citem-gateindate = lv_date.
    ls_citem-gateintime = lv_time.
**********************************************************************
    SELECT SINGLE itemno, MAX( sno ) AS sno FROM zmm_app03_tb1
    WHERE uuid = @ls_header-uuid AND itemno = @ls_header-itemno
    GROUP BY itemno INTO @DATA(ls_itm).
    IF sy-subrc = 0 AND NOT ls_itm IS INITIAL.
      ls_citem-sno = ls_itm-sno + 1.
    ELSE.
      ls_citem-sno = 1.
    ENDIF.
**********************************************************************
    SELECT single max( gateinnumber ) FROM ZMM_APP03_TB1 WHERE uuid IS NOT INITIAL
    INTO @DATA(lt_gpentry).

     IF lt_gpentry IS INITIAL.
        ls_citem-gateinnumber = '1000000000'.
      ELSE.
      ls_citem-gateinnumber = lt_gpentry + 1.
    ENDIF.

    APPEND ls_citem TO lt_citem.
    zbp_mm_app3_rv=>gt_crtgpls = lt_citem.


  ENDMETHOD.

 METHOD upditem.
 DATA: lt_updated_hdr   TYPE TABLE OF zmm_app1_tb2,
        wa_updated_hdr   TYPE zmm_app1_tb2,
        gt_update   TYPE TABLE of zmm_app03_tb1,
        gs_update TYPE zmm_app03_tb1,
        lv_pending_qty   TYPE p DECIMALS 3,
        lv_total_recvqty TYPE p DECIMALS 3.

  " Read header and item data into local tables
  READ ENTITIES OF zmm_app3_rv IN LOCAL MODE
    ENTITY gpline
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rt_hdr_data)
    ENTITY gpline BY \_item
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rt_item_data).

  LOOP AT rt_hdr_data INTO DATA(ls_hdr_data).

    CLEAR: lv_total_recvqty.

    " Sum recvqty from all item lines that match this header
    LOOP AT rt_item_data INTO DATA(ls_item_data)
      WHERE uuid = ls_hdr_data-uuid AND itemno = ls_hdr_data-itemno.
      lv_total_recvqty = lv_total_recvqty + ls_item_data-recvqty.

      MOVE-CORRESPONDING ls_item_data to gs_update.
      APPEND gs_update to gt_update.
    ENDLOOP.

    " Calculate pending quantity
    lv_pending_qty = ls_hdr_data-quantity - lv_total_recvqty.

    " Update the header structure
    MOVE-CORRESPONDING ls_hdr_data TO wa_updated_hdr.
    wa_updated_hdr-totrcvqty = lv_total_recvqty.
    wa_updated_hdr-totopnqty = lv_pending_qty.

    APPEND wa_updated_hdr TO lt_updated_hdr.

  ENDLOOP.

  zbp_mm_app3_rv=>gt_updgpl = lt_updated_hdr.
  zbp_mm_app3_rv=>gt_up = gt_update.
  ENDMETHOD.


  METHOD ValiRecqty.
  DATA:   lv_pending_qty   TYPE p DECIMALS 3,
          lv_total_recvqty TYPE p DECIMALS 3.
     READ ENTITIES OF zmm_app3_rv IN LOCAL MODE
      ENTITY gpline
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(rt_hdr_data)
      ENTITY gpline BY \_item
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(rt_item_data).
        DATA(ls_item_data) = rt_item_data[ 1 ].
        DATA(ls_hdr_data) = rt_hdr_data[ 1 ].
  SELECT SUM( recvqty )
        FROM zmm_app03_tb1
        WHERE uuid   = @ls_hdr_data-uuid
          AND itemno = @ls_hdr_data-itemno
          INTO @lv_total_recvqty.

           IF lv_total_recvqty IS INITIAL.
          lv_total_recvqty = 0.
          ENDIF.
          lv_total_recvqty = lv_total_recvqty + ls_item_data-recvqty.
          lv_pending_qty = ls_hdr_data-quantity - lv_total_recvqty.

            IF ls_item_data-recvqty > ( ls_hdr_data-quantity - ( lv_total_recvqty - ls_item_data-recvqty ) )..
           APPEND VALUE #( %tky = ls_item_data-%tky ) to failed-gplsno.

           APPEND value #( %tky = keys[ 1 ]-%tky
           %msg = new_message_with_text(
           severity = if_abap_behv_message=>severity-error
           text = 'Entered quantity exceeds pending quantity'
            )
            ) to reported-gplsno.

           ENDIF.




  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_APP3_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMM_APP3_RV IMPLEMENTATION.

  METHOD save_modified.
**********************************************************************
    IF create-gplsno IS NOT INITIAL.
      IF zbp_mm_app3_rv=>gt_crtgpls IS NOT INITIAL.
        DATA(lt_gplsno) = zbp_mm_app3_rv=>gt_crtgpls.
        MODIFY zmm_app03_tb1 FROM TABLE @lt_gplsno.
      ENDIF.
    ENDIF.
**********************************************************************
 if zbp_mm_app3_rv=>gt_updgpl is not INITIAL.
 data(lt_gplitm) = zbp_mm_app3_rv=>gt_updgpl.
 MODIFY zmm_app1_tb2 from table @lt_gplitm.
 ENDIF.
**************************************************************************
  if zbp_mm_app3_rv=>gt_closehead is not INITIAL.
  MODIFY zmm_app1_tb2 from table @zbp_mm_app3_rv=>gt_closehead.
  ENDIF.
*************************************************************************
  if zbp_mm_app3_rv=>gt_up is not INITIAL.
  MODIFY zmm_app03_tb1 from table @zbp_mm_app3_rv=>gt_up.
  ENDIF.
*************************************************************************
  IF DELETE-gplsno IS NOT INITIAL.
    LOOP AT delete-gplsno INTO DATA(ls_gipentry).
    DELETE FROM zmm_app03_tb1 WHERE uuid = @ls_gipentry-Uuid AND itemno = @ls_gipentry-Itemno and sno = @ls_gipentry-Sno .
    ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
