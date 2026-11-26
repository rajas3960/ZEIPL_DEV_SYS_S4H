CLASS lsc_zmm_ih_weight DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zmm_ih_weight IMPLEMENTATION.

  METHOD save_modified.

  if zbp_mm_ih_weight=>gt_item is not INITIAL.
        MODIFY ZMM_APP04_IDB FROM TABLE @zbp_mm_ih_weight=>gt_item.
  ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_weightitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightItem RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightItem RESULT result.

    METHODS AutoFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~AutoFetchTWt RESULT result.

    METHODS ManualFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ManualFetchTWt RESULT result.
    METHODS ImgCapture FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ImgCapture RESULT result.

ENDCLASS.

CLASS lhc_weightitem IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY WeightHead BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA(ls_item) = VALUE #( lt_item[ 1 ] OPTIONAL ).
*******************************************************************
*                result = VALUE #( for gs_item in lt_item
*                     ( %tky = gs_item-%tky
**
**                     %field-Netweight = COND #( WHEN ( ls_item-Baseunit = 'TO' or ls_item-Baseunit = 'KG' )
**                                     THEN if_abap_behv=>fc-f-read_only
**                                     ELSE if_abap_behv=>fc-f-unrestricted )
**
*                     %action = VALUE #(
**                                            AutoFetchTWt = COND #( when ( ls_item-Baseunit = 'TO' or ls_item-Baseunit = 'KG' )
**                                            then if_abap_behv=>fc-o-enabled
**                                            ELSE if_abap_behv=>fc-o-disabled )
**
*                                       ManualFetchTWt = COND #( WHEN ( gs_item-Weightindicator = 'X' )
*                                                then if_abap_behv=>fc-o-disabled
*                                                ELSE if_abap_behv=>fc-o-enabled )
*
*
*                                         ) ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD AutoFetchTWt.
**************************************************************************
        DATA: lv_netwt TYPE ZMM_APP04_IDB-netweight,
              lv_grswt TYPE ZMM_APP04_IDB-netweight,
              lv_tarewt TYPE ZMM_APP04_IDB-netweight,
              lv_weiuom TYPE ZMM_APP04_IDB-weiuom,
              lv_penqty TYPE ZMM_APP04_IDB-pendqty,
              lv_total_netwt TYPE ZMM_APP04_IDB-pendqty,
              lv_grnqty TYPE ZMM_APP04_IDB-grnqty,
              lv_shortageqty TYPE ZMM_APP04_IDB-shortageqty,
              lv_mat_ovalwt TYPE ZMM_APP04_IDB-pendqty,
              lv_finalwt TYPE ZMM_APP04_IDB-pendqty.
**************************************************************************
        READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
        ENTITY WeightHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
        ENTITY WeightItem
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item)
        FAILED DATA(lt_failed).
**************************************************************************

        DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
        DATA(gt_keys) = keys.
        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).

        data: lv_wb_no type c LENGTH 10.
        data: lv_finalwet type ZMM_APP04_IDB-tareweight.
        DATA: lv_urlwt TYPE string,
              lv_urlim TYPE string.


        DATA: lt_update TYPE TABLE of ZMM_APP04_IDB,
              ls_update TYPE ZMM_APP04_IDB.


if ls_head-Grosswt is NOT INITIAL.

     "------------------------------------------------------------
     "Auto Fetch Weighment Logic
     "------------------------------------------------------------
  TRY.

      "------------------------------------------------------------
      " Create HTTP destination
      "------------------------------------------------------------
      CONDENSE gs_keys-%param-Weighmentmcno.
      CASE gs_keys-%param-Weighmentmcno.
            when 'WB-2'.
               lv_urlwt = 'http://15.207.178.30:6020'.
               lv_urlim = 'http://15.207.178.30:6020/launch'.
            when 'WB-7'.
               lv_urlwt = 'http://15.207.178.30:6070'.
               lv_urlim = 'http://15.207.178.30:6070/launch'.
            when 'WB-8.1'.
               lv_urlwt = 'http://15.207.178.30:6081'.
               lv_urlim = 'http://15.207.178.30:6081/launch'.
            when 'WB-8.2'.
               lv_urlwt = 'http://15.207.178.30:6082'.
               lv_urlim = 'http://15.207.178.30:6082/launch'.
            when 'WB-8.3'.
               lv_urlwt = 'http://15.207.178.30:6083'.
               lv_urlim = 'http://15.207.178.30:6083/launch'.
            when 'WB-10'.
               lv_urlwt = 'http://15.207.178.30:6100'.
               lv_urlim = 'http://15.207.178.30:6100/launch'.
        ENDCASE.

      DATA(lo_destination) =
        cl_http_destination_provider=>create_by_url(
*          i_url = 'http://15.207.178.30:6008' ).
          i_url = lv_urlwt ).

      DATA(lo_http_client) =
        cl_web_http_client_manager=>create_by_http_destination(
          i_destination = lo_destination ).

      "------------------------------------------------------------
      " Prepare request
      "------------------------------------------------------------
      DATA(lo_request) = lo_http_client->get_http_request( ).

      lo_request->set_uri_path(
        i_uri_path = '/weight' ).

      lo_request->set_header_field(
        i_name  = 'X-API-Key'
        i_value = 'enviro-1-15sep-2026-wb1-mm' ).

      "------------------------------------------------------------
      " Execute GET
      "------------------------------------------------------------
      DATA(lo_response) =
        lo_http_client->execute(
          if_web_http_client=>get ).

      DATA(ls_status) = lo_response->get_status( ).

      IF ls_status-code <> 200.

        APPEND VALUE #(
          %tky = ls_head-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Weight API error: { ls_status-code } { ls_status-reason }|
          )
        ) TO reported-weighthead.

        RETURN.

      ENDIF.

      "------------------------------------------------------------
      " Read JSON response
      "------------------------------------------------------------
      DATA(lv_response) = lo_response->get_text( ).

      "------------------------------------------------------------
      " JSON structure
      "------------------------------------------------------------
      TYPES:
        BEGIN OF ty_weight_response,
          raw_value TYPE string,
          wb_no     TYPE string,
        END OF ty_weight_response.

      DATA:ls_response TYPE ty_weight_response.

      xco_cp_json=>data->from_string(
        lv_response
      )->write_to(
        REF #( ls_response )
      ).

      "------------------------------------------------------------
      " Remove quotes from raw_value
      " Example:
      " \"2121210\"
      " becomes:
      " 2121210
      "------------------------------------------------------------
      DATA(lv_weight) = ls_response-raw_value.

      REPLACE ALL OCCURRENCES OF `"` IN
        lv_weight WITH ``.

      CONDENSE lv_weight NO-GAPS.
      CONDENSE ls_response-wb_no.
    if ls_response-wb_no is NOT INITIAL.
            IF ls_response-wb_no = '1'.
            lv_wb_no = 'WB-1'.
            ELSEIF ls_response-wb_no = '2'.
            lv_wb_no = 'WB-2'.
            ELSEIF ls_response-wb_no = '3'.
            lv_wb_no = 'WB-3'.
            ELSEIF ls_response-wb_no = '4'.
            lv_wb_no = 'WB-4'.
            ELSEIF ls_response-wb_no = '5'.
            lv_wb_no = 'WB-5'.
            ELSEIF ls_response-wb_no = '6'.
            lv_wb_no = 'WB-6'.
            ELSEIF ls_response-wb_no = '7'.
            lv_wb_no = 'WB-7'.
            ELSEIF ls_response-wb_no = '8'.
            lv_wb_no = 'WB-8'.
            ELSEIF ls_response-wb_no = '9'.
            lv_wb_no = 'WB-9'.
            ENDIF.

            SELECT SINGLE * FROM ZMM_WEIGHMENT_VH WITH PRIVILEGED ACCESS
            WHERE value_low = @lv_wb_no
            INTO @DATA(lv_weighmh).
    ENDIF.

            if lv_weight is not INITIAL and ls_status-code = '200'.

            CONDENSE lv_weight.

            lv_finalwet = lv_weight.
            ENDIF.

    CATCH cx_http_dest_provider_error INTO DATA(lx_dest).

      APPEND VALUE #(
        %tky = ls_head-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = |Destination error: { lx_dest->get_text( ) }|
        )
      ) TO reported-weighthead.

    CATCH cx_web_http_client_error INTO DATA(lx_http).

      APPEND VALUE #(
        %tky = ls_head-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = |HTTP error: { lx_http->get_text( ) }|
        )
      ) TO reported-weighthead.

  ENDTRY.
""----------------------------------------------------------------------
""----Weighment Capture ending point
""----------------------------------------------------------------------

""---weighment logic updating
if lv_weight is not INITIAL and ls_status-code = '200'.

            select uuid ,purchaseorder,purchaseorderitem,netweight,weiuom
                FROM ZMM_APP04_IDB WITH PRIVILEGED ACCESS
            WHERE uuid = @ls_head-Uuid
            into TABLE @DATA(gt_item).

            lv_total_netwt = REDUCE #(
                                  INIT lv_sum = CONV #( 0 )
                                  FOR ls_item IN gt_item
                                  NEXT lv_sum = lv_sum + ls_item-netweight ).
*        lv_count += 1.
        DATA(lv_tabix) = sy-tabix.
        SORT lt_item ASCENDING BY Purchaseorder Purchaseorderitem.
            DATA(gs_count) = 1.

        loop AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        if <ls_item> is ASSIGNED.

        if <ls_item>-Weightindicator is INITIAL and <ls_item>-Unloadind is not INITIAL.

"" this logic for GRN Posting logic---

            select SINGLE * from ZMM_APP10_DB WITH PRIVILEGED ACCESS
            WHERE gateentryseries = @ls_head-Gateentryseries
            and materialgroup = @<ls_item>-Materialgroup
            into @DATA(ls_master).


            if ls_head-Gateentryseries = 'G2'.        "Store material weighment logic
            if gs_count = 1.
             lv_grswt = ( ls_head-Grosswt - lv_total_netwt ).
             lv_tarewt = lv_weight.

            lv_netwt = lv_grswt - lv_weight.
            lv_finalwt = lv_netwt.
*            if lv_netwt > 0.
            ENDIF.
            ELSEIF ls_head-Gateentryseries = 'G1'.    "Raw material weighment logic

""---Weighment Split Logic
            lv_mat_ovalwt = REDUCE #(
                                    INIT lv_summat = 0
                                    FOR ls_itemmat IN lt_item
                                    WHERE ( Material = <ls_item>-Material )
                                    NEXT lv_summat = lv_summat + ls_itemmat-Pendqty
                                        ).

             lv_grswt = ( ls_head-Grosswt - lv_total_netwt ).
             lv_tarewt = lv_weight.

             lv_netwt = ( lv_grswt - lv_weight ).

             lv_finalwt = ( ( <ls_item>-Pendqty / lv_mat_ovalwt ) * lv_netwt ).
""---Weighment Split Logic

            ENDIF.
"" this logic for GRN Posting logic---
            if ls_master-challanqtyflag = 'X' and ( <ls_item>-Baseunit = 'KG' or <ls_item>-Baseunit = 'TO' ).
                lv_grnqty = <ls_item>-Challannetweight.
            ELSEIF ls_master-challanqtyflag = 'X' and ( <ls_item>-Baseunit ne 'KG' or <ls_item>-Baseunit ne 'TO' ).
                lv_grnqty = <ls_item>-Challanqty.
            ELSE.
                lv_grnqty = lv_netwt.
            ENDIF.
"" this logic for GRN Posting logic---


""------Shortage Qty Logic....
            if ls_head-Gateentryseries = 'G1'.
                lv_shortageqty = ( lv_finalwt - <ls_item>-Challannetweight  ).
            ENDIF.
""------Shortage Qty Logic....

            MOVE-CORRESPONDING <ls_item> to ls_update.
            ls_update-grossweight = lv_grswt.
            ls_update-weiuom = 'TO'.
*            ls_update-netweight = lv_netwt.
            ls_update-netweight = lv_finalwt.
            ls_update-tareweight = lv_tarewt.
            ls_update-weightindicator = 'X'.
            ls_update-grnqty = lv_grnqty.
            ls_update-gateentryno = ls_head-Gateentryno.
            ls_update-shortageqty = lv_shortageqty.

            APPEND ls_update to lt_update.
            clear:lv_grswt,lv_netwt,lv_tarewt,lv_weiuom,lv_grnqty,lv_mat_ovalwt,lv_finalwt.
            gs_count += 1.
            ELSE.
            DATA(lv_msg) = |Weighment is done { <ls_item>-Purchaseorderitem } or Unload not started|.
            APPEND VALUE #( %tky        = <ls_item>-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msg ) )
               TO reported-weightitem.

            APPEND VALUE #( %tky = <ls_item>-%tky )
               TO failed-weightitem.
            RETURN.
            ENDIF.

        ENDIF.
        ENDLOOP.
        zbp_mm_ih_weight=>gt_item = lt_update.
"---success Msg Handling...
    if ls_status-code = '200'.
            Data(lv_msg1) = |Weighment { lv_finalwet }-Ton Capture Success|.

                      APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text     = lv_msg1
                        )
                      ) TO reported-weighthead.

    ENDIF.

    ENDIF.

""-----Image Capturing logic starting point----
"----------------------------------------------------------------------
             READ ENTITIES OF  zmm_ih_weight IN LOCAL MODE
             ENTITY WeightItem
             ALL FIELDS WITH CORRESPONDING #( keys )
             RESULT FINAL(lt_result).
**********************************************************************
            DATA: lv_imageCount TYPE ZMM_APP04_IDB-lineimagecount.

                    lv_imageCount = REDUCE #(
                            INIT total = CONV #( 0 )
                            FOR ls_result IN lt_result
                            NEXT total = total + ls_result-Lineimagecount ).

**********************************************************************
if ls_head-Imagecount = lv_imagecount
        AND lv_weight is not INITIAL and ls_status-code = '200'.

    GET TIME STAMP FIELD DATA(ts1).
    CONVERT TIME STAMP ts1 TIME ZONE 'INDIA' INTO DATE DATA(lv_date1) TIME DATA(lv_time1).

    DATA(lv_seno) = |{ lv_date1+6(2) }{ lv_date1+4(2) }{ lv_date1+0(4) }{ lv_time1+0(2) }{ lv_time1+2(2) }{ lv_time1+4(2) }|.

**********************************************************************
    TRY.

        "--------------------------------------------------
        " 1. Prepare Seqno
        "--------------------------------------------------
        DATA(lv_seqno) = lv_seno.

        "--------------------------------------------------
        " 2. Prepare JSON
        "--------------------------------------------------
        DATA(lv_json) =
          |\{"seqno":"{ lv_seqno }"\}|.

        "--------------------------------------------------
        " 3. Create HTTP Client
        "--------------------------------------------------
        DATA(lo_http_client1) =
          cl_web_http_client_manager=>create_by_http_destination(
            i_destination =
              cl_http_destination_provider=>create_by_url(
*                i_url = 'http://15.207.178.30:6008/launch'
                i_url = lv_urlim
              )
          ).

        "--------------------------------------------------
        " 4. Get HTTP Request
        "--------------------------------------------------
        DATA(lo_request1) =
          lo_http_client1->get_http_request( ).

        "--------------------------------------------------
        " 5. Set Headers
        "--------------------------------------------------
        lo_request1->set_header_field(
          i_name  = 'Content-Type'
          i_value = 'application/json'
        ).

        lo_request1->set_header_field(
          i_name  = 'X-API-Key'
          i_value = 'enviro-1-15sep-2026-wb1-mm'
        ).

        "--------------------------------------------------
        " 6. Set JSON Body
        "--------------------------------------------------
        lo_request1->set_text( lv_json ).

        "--------------------------------------------------
        " 7. Execute POST
        "--------------------------------------------------
        DATA(lo_response1) =
          lo_http_client1->execute(
            if_web_http_client=>post
          ).

        "--------------------------------------------------
        " 8. Get HTTP Status
        "--------------------------------------------------
        DATA(ls_status1) = lo_response1->get_status( ).

        "--------------------------------------------------
        " 9. Get Response Body
        "--------------------------------------------------
        DATA(lv_response1) =
          lo_response1->get_text( ).
**********************************************************************
        DATA:
              BEGIN OF ls_response1,
                seqno  TYPE string,
                status TYPE string,
                wb_no  TYPE string,
              END OF ls_response1.

             /ui2/cl_json=>deserialize(
               EXPORTING
                 json = lv_response1
               CHANGING
                 data = ls_response1
                ).
**********************************************************************
        DATA(gv_seqno)  = ls_response1-seqno.
        DATA(gv_status) = ls_response1-status.
        DATA(gv_wb_no)  = ls_response1-wb_no.
**********************************************************************
      CATCH cx_web_http_client_error INTO DATA(lx_http1).

      CATCH cx_http_dest_provider_error INTO DATA(lx_dest1).

    ENDTRY.
**********************************************************************
""--Msg handling....
if ls_status1-code = '202'.
            Data(lv_msgs) = |Ready for Image Capture wb_no { gv_wb_no }|.
                      APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text     = lv_msgs
                        )
                      ) TO reported-weighthead.
ENDIF.

ENDIF.


ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_item
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD ManualFetchTWt.
**************************************************************************
        DATA: lv_netwt TYPE ZMM_APP04_IDB-netweight,
              lv_grswt TYPE ZMM_APP04_IDB-netweight,
              lv_tarewt TYPE ZMM_APP04_IDB-netweight,
              lv_weiuom TYPE ZMM_APP04_IDB-weiuom,
              lv_penqty TYPE ZMM_APP04_IDB-pendqty,
              lv_total_netwt TYPE ZMM_APP04_IDB-pendqty,
              lv_grnqty TYPE ZMM_APP04_IDB-grnqty,
              lv_shortageqty TYPE ZMM_APP04_IDB-shortageqty,
              lv_mat_ovalwt TYPE ZMM_APP04_IDB-pendqty,
              lv_finalwt TYPE ZMM_APP04_IDB-pendqty.

        DATA: lt_update TYPE TABLE of ZMM_APP04_IDB,
              ls_update TYPE ZMM_APP04_IDB.
**************************************************************************
        READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
        ENTITY WeightHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_head)
        ENTITY WeightItem
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item)
        FAILED DATA(lt_failed).
**************************************************************************

            DATA(ls_header) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            DATA(lv_count) = lines( keys ).
**************************************************************************
"""" -- Value Validation-----
      if  gs_keys-%param-Weight is NOT INITIAL.
**************************************************************************
            select uuid ,purchaseorder,purchaseorderitem,netweight,weiuom
                FROM ZMM_APP04_IDB WITH PRIVILEGED ACCESS
            WHERE uuid = @ls_header-Uuid
            into TABLE @DATA(gt_item).

            lv_total_netwt = REDUCE #(
                                  INIT lv_sum = CONV #( 0 )
                                  FOR ls_item IN gt_item
                                  NEXT lv_sum = lv_sum + ls_item-netweight ).
*        lv_count += 1.
        DATA(lv_tabix) = sy-tabix.
        SORT lt_item ASCENDING BY Purchaseorder Purchaseorderitem.
            DATA(gs_count) = 1.

        loop AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        if <ls_item> is ASSIGNED.

        if <ls_item>-Weightindicator is INITIAL and <ls_item>-Unloadind is not INITIAL.

"" this logic for GRN Posting logic---

            select SINGLE * from ZMM_APP10_DB WITH PRIVILEGED ACCESS
            WHERE gateentryseries = @ls_header-Gateentryseries
            and materialgroup = @<ls_item>-Materialgroup
            into @DATA(ls_master).


            if ls_header-Gateentryseries = 'G2'.        "Store material weighment logic
            if gs_count = 1.
             lv_grswt = ( ls_header-Grosswt - lv_total_netwt ).
             lv_weiuom = gs_keys-%param-Unit.
             lv_tarewt = gs_keys-%param-Weight.

            lv_netwt = lv_grswt - gs_keys-%param-Weight.

*            if lv_netwt > 0.
            ENDIF.
            ELSEIF ls_header-Gateentryseries = 'G1'.    "Raw material weighment logic

""---Weighment Split Logic
            lv_mat_ovalwt = REDUCE #(
                                    INIT lv_summat = 0
                                    FOR ls_itemmat IN lt_item
                                    WHERE ( Material = <ls_item>-Material )
                                    NEXT lv_summat = lv_summat + ls_itemmat-Pendqty
                                        ).

             lv_grswt = ( ls_header-Grosswt - lv_total_netwt ).
             lv_weiuom = gs_keys-%param-Unit.
             lv_tarewt = gs_keys-%param-Weight.

             lv_netwt = lv_grswt - gs_keys-%param-Weight.

             lv_finalwt = ( ( <ls_item>-Pendqty / lv_mat_ovalwt ) * lv_netwt ).
""---Weighment Split Logic

            ENDIF.
"" this logic for GRN Posting logic---
            if ls_master-challanqtyflag = 'X' and ( <ls_item>-Baseunit = 'KG' or <ls_item>-Baseunit = 'TO' ).
                lv_grnqty = <ls_item>-Challannetweight.
            ELSEIF ls_master-challanqtyflag = 'X' and ( <ls_item>-Baseunit ne 'KG' or <ls_item>-Baseunit ne 'TO' ).
                lv_grnqty = <ls_item>-Challanqty.
            ELSEIF ls_master-challanqtyflag IS INITIAL and ls_header-Gateentryseries = 'G2'.
                lv_grnqty  = <ls_item>-Challanqty.
            ELSE.
                lv_grnqty = lv_netwt.
            ENDIF.
"" this logic for GRN Posting logic---


""------Shortage Qty Logic....
            if ls_header-Gateentryseries = 'G1'.
                lv_shortageqty = ( lv_finalwt - <ls_item>-Challannetweight  ).
            ENDIF.
""------Shortage Qty Logic....

            MOVE-CORRESPONDING <ls_item> to ls_update.
            ls_update-grossweight = lv_grswt.
            ls_update-weiuom = lv_weiuom.
*            ls_update-netweight = lv_netwt.
            ls_update-netweight = lv_finalwt.
            ls_update-tareweight = lv_tarewt.
            ls_update-weightindicator = 'X'.
            ls_update-grnqty = lv_grnqty.
            ls_update-gateentryno = ls_header-Gateentryno.
            ls_update-shortageqty = lv_shortageqty.

            APPEND ls_update to lt_update.
            clear:lv_grswt,lv_netwt,lv_tarewt,lv_weiuom,lv_grnqty,lv_mat_ovalwt,lv_finalwt.
            gs_count += 1.
            ELSE.
            DATA(lv_msg) = |Weighment is done { <ls_item>-Purchaseorderitem } or Unload not started|.
            APPEND VALUE #( %tky        = <ls_item>-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msg ) )
               TO reported-weightitem.

            APPEND VALUE #( %tky = <ls_item>-%tky )
               TO failed-weightitem.

            ENDIF.
*            zbp_mm_ih_weight=>gt_item = lt_update.


*                MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
*                ENTITY WeightItem
*                UPDATE
*                FIELDS ( Netweight Tareweight  Weiuom Grossweight Weightindicator )
*                WITH VALUE #(  for key in keys
*                               ( %tky = <ls_item>-%tky
*                                 Grossweight = lv_grswt1
*                                 Tareweight = gs_keys-%param-Weight
*                                 Weiuom = gs_keys-%param-Unit
*                                 Netweight = lv_netwt1
*                                 Weightindicator = 'X'
*
*                                %control-Grossweight = if_abap_behv=>mk-on
*                                %control-Tareweight = if_abap_behv=>mk-on
*                                %control-Weiuom = if_abap_behv=>mk-on
*                                %control-Netweight = if_abap_behv=>mk-on
*                                %control-Weightindicator = if_abap_behv=>mk-on
*                                 ) ).

*            ELSE.
*
*            DATA(lv_msg) = |Tare Weight { gs_keys-%param-Weight } is more then Gross Weight|.
*            APPEND VALUE #( %tky        = <ls_item>-%tky
*                        %state_area = 'Validate_Head'
*                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                             text     = lv_msg ) )
*               TO reported-weightitem.
*
*            APPEND VALUE #( %tky = <ls_item>-%tky )
*               TO failed-weightitem.
*
*            ENDIF.

        ENDIF.
        ENDLOOP.
        zbp_mm_ih_weight=>gt_item = lt_update.
    ELSE.

        DATA(lv_msgs) = |Weightment is Empty|.
        APPEND VALUE #( %tky        = ls_header-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgs ) )
               TO reported-weighthead.

        APPEND VALUE #( %tky = ls_header-%tky )
               TO failed-weighthead.


     ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_item
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD ImgCapture.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_WeightHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR WeightHead RESULT result.

    METHODS FirstImg FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~FirstImg RESULT result.

    METHODS SecondImg FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~SecondImg RESULT result.
    METHODS AutoFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~AutoFetchWt RESULT result.
    METHODS ManualFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~ManualFetchWt RESULT result.
    METHODS ImageValid FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~ImageValid RESULT result.
    METHODS Weighmentform FOR MODIFY
      keys FOR ACTION WeightHead~Weighmentform RESULT result.

ENDCLASS.

CLASS lhc_WeightHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY WeightHead by \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA(ls_item) = VALUE #( lt_item[ 1 ] OPTIONAL ).
******************************************************************
                result = VALUE #( for ls_key in keys
                     ( %tky = ls_head-%tky

                     %action = VALUE #( SecondImg = COND #( when ( ls_head-Unloadendindi = 'X' )
                                            then if_abap_behv=>fc-o-enabled
                                            ELSE if_abap_behv=>fc-o-disabled )

*                                        AutoFetchWt = COND #( when ( ls_item-Baseunit = 'TO' or ls_item-Baseunit = 'KG' )
*                                            then if_abap_behv=>fc-o-enabled
*                                            ELSE if_abap_behv=>fc-o-disabled )
*
*                                       ManualFetchWt = COND #( WHEN ( ls_item-Baseunit = 'TO' or ls_item-Baseunit = 'KG' )
*                                                then if_abap_behv=>fc-o-enabled
*                                                ELSE if_abap_behv=>fc-o-disabled )
*
*                                        Edit = COND #( WHEN ( ls_item-Baseunit = 'TO' or ls_item-Baseunit = 'KG' )
*                                            then if_abap_behv=>fc-o-disabled
*                                            ELSE if_abap_behv=>fc-o-enabled )

                                         ) ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD FirstImg.
**************************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weighthd)
            ENTITY WeightHead BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weightIt)
            FAILED FINAL(gt_failed).

***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD SecondImg.
**************************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weighthd)
            ENTITY WeightHead BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weightIt)
            FAILED FINAL(gt_failed).

***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD AutoFetchWt.
**************************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weighthd)
            ENTITY WeightHead BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weightIt)
            FAILED FINAL(gt_failed).

***********************************************************************
""----Weighment API

          DATA(ls_head) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
          DATA(gt_keys) = keys.
          DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).

          data: lv_finalwt type ZMM_APP04_IDB-tareweight.
          data: lv_wb_no type c LENGTH 10.
          DATA(lv_imagecount) = lines( gt_weightIt ).
          DATA: lv_urlwt TYPE string,
                lv_urlim TYPE string.

  IF ls_head IS INITIAL.
    RETURN.
  ENDIF.

  TRY.

      "------------------------------------------------------------
      " Create HTTP destination
      "------------------------------------------------------------
      CONDENSE gs_keys-%param-Weighmentmcno.
      CASE gs_keys-%param-Weighmentmcno.
            when 'WB-2'.
               lv_urlwt = 'http://15.207.178.30:6020'.
               lv_urlim = 'http://15.207.178.30:6020/launch'.
            when 'WB-7'.
               lv_urlwt = 'http://15.207.178.30:6070'.
               lv_urlim = 'http://15.207.178.30:6070/launch'.
            when 'WB-8.1'.
               lv_urlwt = 'http://15.207.178.30:6081'.
               lv_urlim = 'http://15.207.178.30:6081/launch'.
            when 'WB-8.2'.
               lv_urlwt = 'http://15.207.178.30:6082'.
               lv_urlim = 'http://15.207.178.30:6082/launch'.
            when 'WB-8.3'.
               lv_urlwt = 'http://15.207.178.30:6083'.
               lv_urlim = 'http://15.207.178.30:6083/launch'.
            when 'WB-10'.
               lv_urlwt = 'http://15.207.178.30:6100'.
               lv_urlim = 'http://15.207.178.30:6100/launch'.
        ENDCASE.


      DATA(lo_destination) =
        cl_http_destination_provider=>create_by_url(
*          i_url = 'http://15.207.178.30:6083' ).
          i_url = lv_urlwt ).

      DATA(lo_http_client) =
        cl_web_http_client_manager=>create_by_http_destination(
          i_destination = lo_destination ).

      "------------------------------------------------------------
      " Prepare request
      "------------------------------------------------------------
      DATA(lo_request) = lo_http_client->get_http_request( ).

      lo_request->set_uri_path(
        i_uri_path = '/weight' ).

      lo_request->set_header_field(
        i_name  = 'X-API-Key'
        i_value = 'enviro-1-15sep-2026-wb1-mm' ).

      "------------------------------------------------------------
      " Execute GET
      "------------------------------------------------------------
      DATA(lo_response) =
        lo_http_client->execute(
          if_web_http_client=>get ).

      DATA(ls_status) = lo_response->get_status( ).

      IF ls_status-code <> 200.

        APPEND VALUE #(
          %tky = ls_head-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Weight API error: { ls_status-code } { ls_status-reason }|
          )
        ) TO reported-weighthead.

        RETURN.

      ENDIF.

      "------------------------------------------------------------
      " Read JSON response
      "------------------------------------------------------------
      DATA(lv_response) = lo_response->get_text( ).

      "------------------------------------------------------------
      " JSON structure
      "------------------------------------------------------------
      TYPES:
        BEGIN OF ty_weight_response,
          raw_value TYPE string,
          wb_no     TYPE string,
        END OF ty_weight_response.

      DATA:ls_response TYPE ty_weight_response.

      xco_cp_json=>data->from_string(
        lv_response
      )->write_to(
        REF #( ls_response )
      ).

      "------------------------------------------------------------
      " Remove quotes from raw_value
      " Example:
      " \"2121210\"
      " becomes:
      " 2121210
      "------------------------------------------------------------
      DATA(lv_weight) = ls_response-raw_value.

      REPLACE ALL OCCURRENCES OF `"` IN
        lv_weight WITH ``.

      CONDENSE lv_weight NO-GAPS.
      CONDENSE ls_response-wb_no.
    if ls_response-wb_no is NOT INITIAL.
            IF ls_response-wb_no = '1'.
            lv_wb_no = 'WB-1'.
            ELSEIF ls_response-wb_no = '2'.
            lv_wb_no = 'WB-2'.
            ELSEIF ls_response-wb_no = '3'.
            lv_wb_no = 'WB-3'.
            ELSEIF ls_response-wb_no = '4'.
            lv_wb_no = 'WB-4'.
            ELSEIF ls_response-wb_no = '5'.
            lv_wb_no = 'WB-5'.
            ELSEIF ls_response-wb_no = '6'.
            lv_wb_no = 'WB-6'.
            ELSEIF ls_response-wb_no = '7'.
            lv_wb_no = 'WB-7'.
            ELSEIF ls_response-wb_no = '8.1'.
            lv_wb_no = 'WB-8.1'.
            ELSEIF ls_response-wb_no = '8.2'.
            lv_wb_no = 'WB-8.2'.
            ELSEIF ls_response-wb_no = '8.3'.
            lv_wb_no = 'WB-8.3'.
            ELSEIF ls_response-wb_no = '10'.
            lv_wb_no = 'WB-10'.
            ENDIF.

            SELECT SINGLE * FROM ZMM_WEIGHMENT_VH WITH PRIVILEGED ACCESS
            WHERE value_low = @lv_wb_no
            INTO @DATA(lv_weighmh).
    ENDIF.

            if lv_weight is not INITIAL and ls_status-code = '200'.

            CONDENSE lv_weight.
*            lv_finalwt = ( lv_weight / 1000 ).
            lv_finalwt = lv_weight.

      GET TIME STAMP FIELD DATA(ts).
      CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

          MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
          ENTITY WeightHead
          UPDATE
          FIELDS ( Grosswt Weighuom Weighmentmcno weighmentmcndes
                  Weighmentdate Weighmenttime Imagecount )
          WITH VALUE #(  FOR key IN keys
                         ( %tky = ls_head-%tky
                           Grosswt = lv_finalwt
                           Weighuom = 'TO'
                           Weighmentmcno = lv_wb_no
                           weighmentmcndes = lv_weighmh-text
                           Weighmentdate = lv_date
                           Weighmenttime = lv_time
                           Imagecount = lv_imagecount

                          %control-Grosswt = if_abap_behv=>mk-on
                          %control-Weighuom = if_abap_behv=>mk-on
                          %control-Weighmentmcno = if_abap_behv=>mk-on
                          %control-weighmentmcndes = if_abap_behv=>mk-on
                          %control-Weighmentdate = if_abap_behv=>mk-on
                          %control-Weighmenttime = if_abap_behv=>mk-on
                          %control-Imagecount = if_abap_behv=>mk-on
                           ) ).

            ENDIF.

    CATCH cx_http_dest_provider_error INTO DATA(lx_dest).

      APPEND VALUE #(
        %tky = ls_head-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = |Destination error: { lx_dest->get_text( ) }|
        )
      ) TO reported-weighthead.

    CATCH cx_web_http_client_error INTO DATA(lx_http).

      APPEND VALUE #(
        %tky = ls_head-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = |HTTP error: { lx_http->get_text( ) }|
        )
      ) TO reported-weighthead.

  ENDTRY.


""""-------Image Capture Function Starting
**********************************************************************
if lv_weight is not INITIAL and ls_status-code = '200'.

    GET TIME STAMP FIELD DATA(ts1).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date1) TIME DATA(lv_time1).

    DATA(lv_seno) = |{ lv_date1+6(2) }{ lv_date1+4(2) }{ lv_date1+0(4) }{ lv_time+0(2) }{ lv_time+2(2) }{ lv_time+4(2) }|.

**********************************************************************
    TRY.

        "--------------------------------------------------
        " 1. Prepare Seqno
        "--------------------------------------------------
        DATA(lv_seqno) = lv_seno.

        "--------------------------------------------------
        " 2. Prepare JSON
        "--------------------------------------------------
        DATA(lv_json) =
          |\{"seqno":"{ lv_seqno }"\}|.

        "--------------------------------------------------
        " 3. Create HTTP Client
        "--------------------------------------------------
        DATA(lo_http_client1) =
          cl_web_http_client_manager=>create_by_http_destination(
            i_destination =
              cl_http_destination_provider=>create_by_url(
*                i_url = 'http://15.207.178.30:6083/launch'
                i_url = lv_urlim
              )
          ).

        "--------------------------------------------------
        " 4. Get HTTP Request
        "--------------------------------------------------
        DATA(lo_request1) =
          lo_http_client1->get_http_request( ).

        "--------------------------------------------------
        " 5. Set Headers
        "--------------------------------------------------
        lo_request1->set_header_field(
          i_name  = 'Content-Type'
          i_value = 'application/json'
        ).

        lo_request1->set_header_field(
          i_name  = 'X-API-Key'
          i_value = 'enviro-1-15sep-2026-wb1-mm'
        ).

        "--------------------------------------------------
        " 6. Set JSON Body
        "--------------------------------------------------
        lo_request1->set_text( lv_json ).

        "--------------------------------------------------
        " 7. Execute POST
        "--------------------------------------------------
        DATA(lo_response1) =
          lo_http_client1->execute(
            if_web_http_client=>post
          ).

        "--------------------------------------------------
        " 8. Get HTTP Status
        "--------------------------------------------------
        DATA(ls_status1) = lo_response1->get_status( ).

        "--------------------------------------------------
        " 9. Get Response Body
        "--------------------------------------------------
        DATA(lv_response1) =
          lo_response1->get_text( ).
**********************************************************************
        DATA:
              BEGIN OF ls_response1,
                seqno  TYPE string,
                status TYPE string,
                wb_no  TYPE string,
              END OF ls_response1.

             /ui2/cl_json=>deserialize(
               EXPORTING
                 json = lv_response1
               CHANGING
                 data = ls_response1
                ).
**********************************************************************
        DATA(gv_seqno)  = ls_response1-seqno.
        DATA(gv_status) = ls_response1-status.
        DATA(gv_wb_no)  = ls_response1-wb_no.
**********************************************************************
      CATCH cx_web_http_client_error INTO DATA(lx_http1).

      CATCH cx_http_dest_provider_error INTO DATA(lx_dest1).

    ENDTRY.

""--Msg handling

    if ls_status-code = '200'.
            Data(lv_msg1) = |Weighment { lv_finalwt }-Ton Capture Success|.

                      APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text     = lv_msg1
                        )
                      ) TO reported-weighthead.

    ENDIF.
            Data(lv_msg) = |Ready for Image Capture wb_no { gv_wb_no }|.
                      APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text     = lv_msg
                        )
                      ) TO reported-weighthead.


**********************************************************************
    ENDIF.


***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD ManualFetchWt.
**************************************************************************
            data: lv_weight TYPE ZMM_APP04_HDB-netwt,
                  lv_tarewt TYPE ZMM_APP04_HDB-netwt,
                  lv_netwt TYPE ZMM_APP04_HDB-netwt.
**************************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weighthd)
            ENTITY WeightHead BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_weightIt)
            FAILED FINAL(gt_failed).
**************************************************************************
            DATA(ls_header) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            DATA(lv_imagecount) = lines( gt_weightIt ).
**************************************************************************
"""" -- Value Validation-----
      if gs_keys-%param-Weight is NOT INITIAL.
**************************************************************************
            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**************************************************************************
            select single * from  ZMM_WEIGHMENT_VH WITH PRIVILEGED ACCESS
            WHERE value_low = @gs_keys-%param-Weighmentmcno
            and language = 'E'
            INTO @DATA(ls_mcno).
**************************************************************************
            LOOP at gt_weighthd ASSIGNING FIELD-SYMBOL(<ls_weight>).
            if <ls_weight> is ASSIGNED.

*                if <ls_weight>-Gateentryseries = 'G1' and <ls_weight>-Grosswt is INITIAL.
*                    clear lv_weight.
*                    lv_weight = gs_keys-%param-Weight.
*                ELSEIF <ls_weight>-Gateentryseries = 'G1' and <ls_weight>-Grosswt is not INITIAL.
*
*                 Data(lv_msg) = |Already Captured 1st Weight-{ <ls_weight>-Grosswt }|.
*                     APPEND VALUE #( %tky = ls_header-%tky )
*                         TO failed-weighthead.
*                      APPEND VALUE #(
*                        %tky = ls_header-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = lv_msg
*                        )
*                      ) TO reported-weighthead.
*
*                    RETURN.
*
*                ENDIF.
*                IF <ls_weight>-Gateentryseries = 'G2' and <ls_weight>-Grosswt is INITIAL.
*                    clear lv_weight.
*                    lv_weight = gs_keys-%param-Weight.
*                ELSEIF <ls_weight>-Gateentryseries = 'G2' and <ls_weight>-Grosswt is not INITIAL.
*                    clear: lv_weight,lv_netwt.
*                    lv_netwt = <ls_weight>-Grosswt - gs_keys-%param-Weight.
*                    lv_weight = <ls_weight>-Grosswt.
*                    lv_tarewt = gs_keys-%param-Weight.
*                ENDIF.

                MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
                ENTITY WeightHead
                UPDATE
                FIELDS ( Grosswt Imagecount
*                        Tarewt Netwt
                        Weighuom Weighmentmcno weighmentmcndes
                        Weighmentdate Weighmenttime )
                WITH VALUE #(  for key in keys
                               ( %tky = <ls_weight>-%tky
                                 Grosswt = gs_keys-%param-Weight
*                                 Tarewt = lv_tarewt
*                                 Netwt = lv_netwt
                                 Weighmentmcno = gs_keys-%param-Weighmentmcno
                                 Weighuom = gs_keys-%param-Unit
                                 weighmentmcndes = ls_mcno-text
                                 Weighmentdate = lv_date
                                 Weighmenttime = lv_time
                                 Imagecount = lv_imagecount

                                %control-Grosswt = if_abap_behv=>mk-on
*                                %control-Tarewt = if_abap_behv=>mk-on
*                                %control-Netwt = if_abap_behv=>mk-on
                                %control-Weighmentmcno = if_abap_behv=>mk-on
                                %control-Weighuom = if_abap_behv=>mk-on
                                %control-weighmentmcndes = if_abap_behv=>mk-on
                                %control-Weighmentdate = if_abap_behv=>mk-on
                                %control-Weighmenttime = if_abap_behv=>mk-on
                                %control-Imagecount = if_abap_behv=>mk-on
                                 ) ).

            ENDIF.
            ENDLOOP.
***********************************************************************
*            if ls_header-Gateentryseries = 'G1'.
*            LOOP AT gt_weightit ASSIGNING FIELD-SYMBOL(<ls_item>).
*            if <ls_item> is ASSIGNED.
*
*                MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
*                ENTITY WeightItem
*                UPDATE
*                FIELDS ( Grossweight Weiuom )
*                WITH VALUE #(  for key in keys
*                               ( %tky = <ls_item>-%tky
*                                 Grossweight = gs_keys-%param-Weight
*                                 Weiuom = gs_keys-%param-Unit
*                                %control-Grossweight = if_abap_behv=>mk-on
*                                %control-Weiuom = if_abap_behv=>mk-on
*                                 ) ).
*            ENDIF.
*            ENDLOOP.
*            ENDIF.

    ELSE.

        DATA(lv_msgs) = |Weightment is Empty|.
        APPEND VALUE #( %tky        = ls_header-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgs ) )
               TO reported-weighthead.

        APPEND VALUE #( %tky = ls_header-%tky )
               TO failed-weighthead.


     ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD ImageValid.
***********************************************************************
            READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
            ENTITY WeightHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_gatehd)
            FAILED FINAL(lt_failed).
***********************************************************************
            LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
            IF <ls_hd> is ASSIGNED.

                    MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
                    ENTITY WeightHead
                    UPDATE
                    FIELDS ( Imagevaldindicator )
                        WITH VALUE #( for key in keys
                                   (   %tky = <ls_hd>-%tky
                                    Imagevaldindicator = 'X'
                                    %control-Imagevaldindicator = if_abap_behv=>mk-on
                                    )  ).
            ENDIF.
            ENDLOOP.
************************************************************************
    result = VALUE #( FOR ls_ord IN lt_gatehd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD Weighmentform.
**********************************************************************************************
          READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
          ENTITY WeightHead
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT FINAL(gt_head)
          FAILED FINAL(gt_failed).
**************************************************************************************************
          DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
          DATA(gt_keys) = keys.
          DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
**************************************************************************************************
    if ls_header-Gateentryno is not INITIAL.

        TRY.
            "Initialize Template Store Client
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_name                  = 'ZADS_CS'
             iv_service_instance_name = 'ZADS_OUT_REST'
            ).

            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZWEIGHT_SLIP_CE_SD'
                                                                  iv_root_node = 'ZMM_WEIGHT_SLIP_CE' ) .

            data: printque type c LENGTH 32.

              printque = 'ADOBE_DEFAULT'.

            TRY.
                lo_store->get_schema_by_name( iv_form_name = 'ZMM_WEIGHT_SLIP' ).
                "   out->write( 'Schema found in form' ).
              CATCH zcx_fp_tmpl_store_error INTO DATA(lo_tmpl_error).
                "  out->write( 'No schema in form found' ).
                IF lo_tmpl_error->mv_http_status_code = 404 OR lo_tmpl_error->mv_http_status_code = 403 .
                  "Upload service definition
*                  lo_store->set_schema(
*                    iv_form_name = 'GATEFORM'
*                    is_data      = VALUE #( note = '' schema_name = 'schema' xsd_schema = lo_fdp_util->get_xsd( ) )
*                  ).
                ELSE.

                ENDIF.
            ENDTRY.
****************************************************************************************************************
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
***********************************************************************************************************
                     DATA(lt_keys)     = lo_fdp_util->get_keys( ).
            lt_keys[ name = 'UUID' ]-value = gt_head[ 1 ]-Uuid.
*******************************************************************************************************************
            data(lt_xsd) = lo_fdp_util->get_xsd( ).
*****************************************************************************************************************
*               *           "Convert the XSD File converstion for Form Purpose
             data(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

                TRY.
                DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
                "out->write( 'Service data retrieved' ).
              CATCH cx_fp_fdp_error INTO DATA(lo_exception).
            ENDTRY.
**************************************************************************************************************
         DATA(ls_template) = lo_store->get_template_by_name(
              iv_get_binary    = abap_true
              iv_form_name     = 'ZMM_WEIGHT_SLIP'
              iv_template_name = 'WEIGHT_SLIP'
            ).
**************************************************************************
      cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                       "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                 iv_xml_data     = lv_xml
                                                 iv_xdp_layout   = ls_template-xdp_template
                                                 is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                       IMPORTING
                                       " TODO: variable is assigned but never used (ABAP cleaner)
                                                 ev_trace_string = DATA(lv_trace)
                                                 ev_pdf          = DATA(lv_pdf) ).




********************************************************************************************************************
           DATA: lv_name TYPE c LENGTH 120.
            lv_name = |Weighment Slip-{ gt_head[ 1 ]-Gateentryno }|.
*             DATA: lv_pdf TYPE xstring.
***************************************************************************************************************************
            cl_print_queue_utils=>create_queue_item_by_data(
              iv_qname            = printque
              iv_print_data       = lv_pdf
              iv_name_of_main_doc = lv_name
              iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
            ).

          CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
            " out->write( 'Exception occurred.' ).
        ENDTRY.
***************************************************************************************************************************
           if lv_pdf is not iNITIAL.

                    MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
                    ENTITY WeightHead
                    UPDATE
                    FIELDS ( Weighslipattcmt Weighmimetype Weighfilename )
                        WITH VALUE #( for key in keys
                                   (   %tky = ls_header-%tky
                                    Weighslipattcmt = lv_pdf
                                    Weighmimetype = 'application/pdf'
                                    Weighfilename = lv_name
                                    %control-Weighslipattcmt = if_abap_behv=>mk-on
                                    %control-Weighmimetype = if_abap_behv=>mk-on
                                    %control-Weighfilename = if_abap_behv=>mk-on
                                    )  ).

                endif.
*
        endif.
**********************************************************************************************************************
               result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).


  ENDMETHOD.



ENDCLASS.
