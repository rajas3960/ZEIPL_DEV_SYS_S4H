CLASS lhc_WeightHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR WeightHead RESULT result.

    METHODS AutoFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~AutoFetchWt RESULT result.

    METHODS CrtDelivery FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~CrtDelivery RESULT result.

    METHODS PickingQty FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~PickingQty RESULT result.

    METHODS Weighmentslip FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~Weighmentslip RESULT result.

    METHODS ManualFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~ManualFetchWt RESULT result.
    METHODS TransExit FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~TransExit RESULT result.
    METHODS DeliveryPG FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~DeliveryPG RESULT result.
    METHODS PickQtyMdy FOR DETERMINE ON MODIFY
       keys FOR WeightHead~PickQtyMdy.
    METHODS ImagVald FOR MODIFY
       keys FOR ACTION WeightHead~ImagVald RESULT result.
    METHODS CancelGateEntry FOR MODIFY
       keys FOR ACTION WeightHead~CancelGateEntry RESULT result.

    METHODS UpDlyheadertext FOR MODIFY
       keys FOR ACTION WeightHead~UpDlyheadertext RESULT result.

ENDCLASS.

CLASS lhc_WeightHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item)
    FAILED DATA(lt_failed).

******************************************************************
    DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(ls_item1) = VALUE #( lt_item[ 1 ] OPTIONAL ).
******************************************************************
    result = VALUE #( FOR ls_item IN lt_item
         ( %tky = ls_head-%tky



                     %update = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                     %action = VALUE #(
                                CrtDelivery = COND #( WHEN ( ls_head-Deliyindicator = 'X' or ls_head-Cancelgateentry is NOT INITIAL )
                                THEN if_abap_behv=>fc-o-disabled
                                WHEN ( ls_item-Netweight  IS NOT INITIAL AND ls_head-Imagevalid = 'X' )
                                THEN if_abap_behv=>fc-o-enabled
                                ELSE if_abap_behv=>fc-o-disabled )

                           PickingQty = COND #( WHEN ( ls_head-Pickqtyindicator = 'X' OR ls_head-Gateentrytype = 'SD2'
                                                                or ls_head-Cancelgateentry is NOT INITIAL )
                                    THEN if_abap_behv=>fc-o-disabled
                                    WHEN ls_head-Deliyindicator = 'X'
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled )

                           DeliveryPG = COND #( WHEN ( ls_head-Giindicator = 'X' or ls_head-Cancelgateentry is NOT INITIAL )
                                    THEN if_abap_behv=>fc-o-disabled
                                    WHEN ( ls_head-Pickqtyindicator = 'X' OR ls_head-gateentrytype = 'SD2' )
                                    THEN if_abap_behv=>fc-o-enabled

                                    ELSE if_abap_behv=>fc-o-disabled )

                           ImagVald = COND #( WHEN ( ls_head-Imagevalid = 'X' or ls_head-Cancelgateentry  is not INITIAL )
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

                           AutoFetchWt = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

                           ManualFetchWt = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

                           CancelGateEntry = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

                           TransExit = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )

                            Edit = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )
*
*                                        %delete = COND #( WHEN ls_head-Weigmentindicator  is not INITIAL
*                                            then if_abap_behv=>fc-o-disabled
*                                            ELSE if_abap_behv=>fc-o-enabled )

                             ) ) ) .

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD AutoFetchWt.
**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_weighthd)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_weightIt)
    FAILED FINAL(gt_failed).
***********************************************************************
""----mock api testing

    DATA(ls_head) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
    DATA(lv_imagecount) = lines( gt_weightIt ).
    DATA(gt_keys) = keys.
    DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).

    data: lv_finalwt type ZSD_APP05_HDB-tarewt.
    data: lv_wb_no type c LENGTH 10.
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

            SELECT SINGLE * FROM ZSD_WEIGHT_VH WITH PRIVILEGED ACCESS
            WHERE value_low = @lv_wb_no
            INTO @DATA(lv_weighmh).
    ENDIF.

            if lv_weight is not INITIAL and ls_status-code = '200'.

            CONDENSE lv_weight.
*            lv_finalwt = ( lv_weight / 1000 ).
            lv_finalwt = lv_weight.

      GET TIME STAMP FIELD DATA(ts).
      CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

          MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
          ENTITY WeightHead
          UPDATE
          FIELDS ( Tarewt Weighuom Weighmentmcno weighmentmcndes
                  Weighmentdate Weighmenttime Imagecount )
          WITH VALUE #(  FOR key IN keys
                         ( %tky = ls_head-%tky
                           Tarewt = lv_finalwt
                           Weighuom = 'TO'
                           Weighmentmcno = lv_wb_no
                           weighmentmcndes = lv_weighmh-text
                           Weighmentdate = lv_date
                           Weighmenttime = lv_time
                           Imagecount = lv_imagecount

                          %control-Tarewt = if_abap_behv=>mk-on
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

*            Data(lv_msg) = |seqno-{ gv_seqno } status-{ gv_status } wb_no { gv_wb_no }|.
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

  METHOD CrtDelivery.
**************************************************************************
    DATA:lv_seldate TYPE datum.
    DATA: lt_hd          TYPE TABLE OF zsd_app05_hdb,
          ls_hd          TYPE  zsd_app05_hdb,
          lv_qty         TYPE zsd_app05_idb-tareweight,
          lv_net_weight  TYPE zsd_app05_idb-tareweight,
          lv_mat         TYPE zsd_app05_idb-material,
          lv_brokamt     TYPE I_SalesDocument-TotalNetAmount,
          lv_totsalesamt TYPE I_SalesDocument-TotalNetAmount,
          lv_bkfinalamt  TYPE I_SalesDocument-TotalNetAmount,
          lv_Examt       TYPE I_SalesDocument-TotalNetAmount,
          lv_dlydcotype  TYPE I_DeliveryDocument-DeliveryDocumentType.

**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_weighthd)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_weightIt)
    FAILED DATA(gt_failed).

***********************************************************************
    DATA(ls_header) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
    DATA(ls_item) = VALUE #( gt_weightit[ 1 ]  OPTIONAL ).

***********************************************************************
    SELECT SINGLE SalesDocument, SalesDocumentItem, CommittedDeliveryDate AS seldate
            FROM I_SalesDocumentItem WITH PRIVILEGED ACCESS
    WHERE SalesDocument = @ls_item-Salesdocument
    AND SalesDocumentItem = @ls_item-Salesitem
    INTO @DATA(ls_sodata).
***********************************************************************
    IF ls_sodata-seldate IS NOT INITIAL.
      lv_seldate = ls_sodata-seldate.
    ELSE.
      lv_seldate = cl_abap_context_info=>get_system_date(  ).
    ENDIF.
************************************************************************
    lv_net_weight = REDUCE #(
                                  INIT total = 0
                                  FOR ls_weight IN gt_weightit
                                  NEXT total = total + ls_weight-Netweight
                                             ).
************************************************************************
    SORT gt_weightit ASCENDING BY Salesdocument Salesitem.

    "---------------------------------------------------------------
    " 1. Validate Storage Location and Stock Availability
    "---------------------------------------------------------------
    LOOP AT gt_weightit ASSIGNING FIELD-SYMBOL(<gs_item>).

      IF <gs_item>-storagelocation IS INITIAL.

        APPEND VALUE #( %tky = ls_header-%tky )
          TO failed-weighthead.

        APPEND VALUE #(
          %tky = ls_header-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Storage Location is mandatory'
          )
        ) TO reported-weighthead.

        RETURN.

      ENDIF.

      IF <gs_item>-Netweight IS NOT INITIAL.

        if ( <gs_item>-Independentrequirementtype = 'BB6' OR <gs_item>-Independentrequirementtype = '040' ).     ""Make To Order Process Validation for specified Customer
        SELECT SINGLE * FROM zsd_open_stk WITH PRIVILEGED ACCESS
        WHERE Product = @<gs_item>-Material
        AND Plant = @<gs_item>-plant
        AND StorageLocation = @<gs_item>-storagelocation
        AND SDDocument = @<gs_item>-Salesdocument
        AND SDDocumentItem = @<gs_item>-Salesitem
        INTO @DATA(ls_stock).

        ELSE.
        SELECT SINGLE * FROM zsd_open_stk WITH PRIVILEGED ACCESS            "" its normal Validation for Stock Availability
        WHERE Product = @<gs_item>-Material
        AND Plant = @<gs_item>-plant
        AND StorageLocation = @<gs_item>-storagelocation
        and sddocument is INITIAL
        INTO @ls_stock.
        ENDIF.

        SELECT SINGLE * FROM zsd_prd_stk WITH PRIVILEGED ACCESS             "" its normal Validation for Stock Availability
        WHERE Product = @ls_stock-Product
        AND plant = @ls_stock-plant
        AND StorageLocation = @ls_stock-storagelocation
        INTO @DATA(ls_prdstock).

        lv_qty = ( ls_stock-MatlWrhsStkQtyInMatlBaseUnit - ( ls_prdstock-PrdQty - ls_prdstock-WitdraQty ) ).

        IF <gs_item>-Netweight > lv_qty.
          lv_mat = |{ <gs_item>-Material ALPHA = OUT }|.

          DATA(lv_msg1) = |Only { lv_qty } TO of material { lv_mat } available|.

          APPEND VALUE #( %tky = ls_header-%tky )
              TO failed-weighthead.

          APPEND VALUE #(
            %tky = ls_header-%tky
            %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = lv_msg1
            )
          ) TO reported-weighthead.
          RETURN.
        ENDIF.
      ENDIF.

    ENDLOOP.
************************************************************************
    IF ls_header-Gateentrytype = 'SD1'.
      lv_dlydcotype = 'LF'.
    ELSEIF ls_header-Gateentrytype = 'SD2'.
      lv_dlydcotype = 'LR'.
    ENDIF.
************************************************************************
    MODIFY ENTITIES OF I_OutboundDeliveryTP PRIVILEGED
      ENTITY OutboundDelivery
      EXECUTE CreateDlvFromSalesDocument
      FROM VALUE #(
                    ( %cid = 'DLV001'
                      %param = VALUE #(
                      %control = VALUE #(

                  ShippingPoint = if_abap_behv=>mk-on
                  DeliverySelectionDate = if_abap_behv=>mk-on
                  DeliveryDocumentType = if_abap_behv=>mk-on   )
                  ShippingPoint = ls_item-Shippingpoint
                  DeliverySelectionDate = lv_seldate
                  DeliveryDocumentType = lv_dlydcotype

            _ReferenceSDDocumentItem = VALUE #(
                        FOR gs_item IN gt_weightIt
                        (
                         %control = VALUE #(
                  ReferenceSDDocument = if_abap_behv=>mk-on
                  ReferenceSDDocumentItem = if_abap_behv=>mk-on
                                            )
                  ReferenceSDDocument = gs_item-Salesdocument
                  ReferenceSDDocumentItem = gs_item-Salesitem

                     ) )

                                            ) ) )
          MAPPED DATA(ls_mapped)
          REPORTED DATA(ls_reported_modify)
          FAILED DATA(ls_failed_modify).

*        LOOP AT gt_weightit ASSIGNING FIELD-SYMBOL(<is_item>).
*            if <is_item> is ASSIGNED.
*
*            SELECT SINGLE * FROM ZSD_OPEN_STK WITH PRIVILEGED ACCESS
*            WHERE Product = @<is_item>-Material
*            and Plant = @<is_item>-plant
*            and StorageLocation = @<is_item>-storagelocation
*            into @DATA(ls_stock).
*
*            SELECT SINGLE * FROM zsd_prd_stk WITH PRIVILEGED ACCESS
*            WHERE Product = @ls_stock-Product
*            and plant = @ls_stock-plant
*            AND StorageLocation = @ls_stock-storagelocation
*            INTO @DATA(ls_prdstock).
*
*
*            lv_qty = ls_stock-MatlWrhsStkQtyInMatlBaseUnit - ls_prdstock-PrdQty - ls_prdstock-WitdraQty.
*
*            ENDif.
*        ENDLOOP.
*
************************************************************************
*if ls_item-Storagelocation is not INITIAL.
*
*            select SINGLE * FROM I_SalesDocument WITH PRIVILEGED ACCESS
*            WHERE SalesDocument = @ls_item-Salesdocument
*            INTO @DATA(ls_saleshd).
*
*                   SELECT
*                        SUM( orderquantity ) AS total_order_qty,
*                        SUM( netamount )      AS total_net_value,
*                        SUM( taxamount )     AS total_tax_amt
*                        FROM i_salesdocumentitem
*                  WHERE salesdocument = @ls_saleshd-SalesDocument
*                  INTO @DATA(ls_total).
************************************************************************
*""--Broker Screen validation.
*        if ( ls_saleshd-Salesdocument is NOT INITIAL and ls_saleshd-Distributionchannel = '30' )
*                and ( ls_saleshd-salesdocumenttype = 'ZDOM' OR ls_saleshd-salesdocumenttype = 'ZEXP' ).
*
*
*                   SELECT SINGLE * FROM I_SalesOrderPartner WITH PRIVILEGED ACCESS
*                   WHERE SalesOrder = @ls_saleshd-SalesDocument
*                   and  PartnerFunction = 'ZB'
*                   INTO @DATA(gs_broker).
*
*                   SELECT SINGLE * FROM ZSD_BROKER_CDS WITH PRIVILEGED ACCESS
*                   WHERE Brokerid = @gs_broker-Customer
*                   INTO @DATA(ls_cusbk).
*
*                   if ls_saleshd-SalesDocumentType = 'ZEXP'.
*                   lv_examt = ls_saleshd-PriceDetnExchangeRate * ls_total-total_net_value.
*                   ELSE.
*                   lv_examt = ls_total-total_net_value.
*                   ENDIF.
*
*                   lv_totsalesamt = lv_examt + ls_total-total_tax_amt.
*                   lv_brokamt =  lv_totsalesamt / ls_total-total_order_qty.
*                   lv_bkfinalamt = lv_brokamt * lv_net_weight.
*
*                if  lv_bkfinalamt > ls_cusbk-Open_bal .
*
*                 Data(lv_bkmsg) = |Broker limit exceeded the value { lv_bkfinalamt }|.
*
*                     APPEND VALUE #( %tky = ls_header-%tky )
*                         TO failed-weighthead.
*
*                      APPEND VALUE #(
*                        %tky = ls_header-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = lv_bkmsg
*                        )
*                      ) TO reported-weighthead.
*                else.
*
************************************************************************
*    MODIFY ENTITIES OF I_OutboundDeliveryTP PRIVILEGED
*      ENTITY OutboundDelivery
*      EXECUTE CreateDlvFromSalesDocument
*      FROM VALUE #(
*                    ( %cid = 'DLV001'
*                      %param = VALUE #(
*                      %control = VALUE #(
*
*                  ShippingPoint = if_abap_behv=>mk-on
*                  DeliverySelectionDate = if_abap_behv=>mk-on
*                  DeliveryDocumentType = if_abap_behv=>mk-on   )
*                  ShippingPoint = ls_item-Plant
*                  DeliverySelectionDate = lv_seldate
*                  DeliveryDocumentType = 'LF'
*
*            _ReferenceSDDocumentItem = VALUE #(
*                        FOR gs_item IN gt_weightIt
*                        (
*                         %control = VALUE #(
*                  ReferenceSDDocument = if_abap_behv=>mk-on
*                  ReferenceSDDocumentItem = if_abap_behv=>mk-on
*                                            )
*                  ReferenceSDDocument = gs_item-Salesdocument
*                  ReferenceSDDocumentItem = gs_item-Salesitem
*
*                     ) )
*                     ) ) )
*          MAPPED DATA(ls_mapped)
*          REPORTED DATA(ls_reported_modify)
*          FAILED DATA(ls_failed_modify).
*
*                ENDIF.
************************************************************************
****---LC Screen Validation...
*
*        ELSEIF ( ls_saleshd-Salesdocument is NOT INITIAL and ls_saleshd-Distributionchannel = '50' )
*                and ( ls_saleshd-salesdocumenttype = 'ZDOM' OR ls_saleshd-salesdocumenttype = 'ZEXP' ).
*
*                clear: lv_totsalesamt,lv_brokamt,lv_bkfinalamt, lv_examt.
*
*
*                   SELECT SINGLE * FROM ZSD_LC_CDS WITH PRIVILEGED ACCESS
*                   WHERE SalesDocument = @ls_saleshd-SalesDocument
*                   INTO @DATA(ls_cuslc).
*
*                   if ls_saleshd-SalesDocumentType = 'ZEXP'.
*                   lv_examt = ls_saleshd-PriceDetnExchangeRate * ls_total-total_net_value.
*                   ELSE.
*                   lv_examt = ls_total-total_net_value.
*                   ENDIF.
*
*                   lv_totsalesamt = lv_examt + ls_total-total_tax_amt.
*                   lv_brokamt =  lv_totsalesamt / ls_total-total_order_qty.
*                   lv_bkfinalamt = lv_brokamt * lv_net_weight.
*
*                if  lv_bkfinalamt > ls_cuslc-Balance_amt .
*
*                 Data(lv_lcmsg) = |LC limit exceeded the value{ lv_bkfinalamt }|.
*
*                     APPEND VALUE #( %tky = ls_header-%tky )
*                         TO failed-weighthead.
*
*                      APPEND VALUE #(
*                        %tky = ls_header-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = lv_lcmsg
*                        )
*                      ) TO reported-weighthead.
*                else.
*
************************************************************************
*    MODIFY ENTITIES OF I_OutboundDeliveryTP PRIVILEGED
*      ENTITY OutboundDelivery
*      EXECUTE CreateDlvFromSalesDocument
*      FROM VALUE #(
*                    ( %cid = 'DLV001'
*                      %param = VALUE #(
*                      %control = VALUE #(
*
*                  ShippingPoint = if_abap_behv=>mk-on
*                  DeliverySelectionDate = if_abap_behv=>mk-on
*                  DeliveryDocumentType = if_abap_behv=>mk-on   )
*                  ShippingPoint = ls_item-Plant
*                  DeliverySelectionDate = lv_seldate
*                  DeliveryDocumentType = 'LF'
*
*            _ReferenceSDDocumentItem = VALUE #(
*                        FOR gs_item IN gt_weightIt
*                        (
*                         %control = VALUE #(
*                  ReferenceSDDocument = if_abap_behv=>mk-on
*                  ReferenceSDDocumentItem = if_abap_behv=>mk-on
*                                            )
*                  ReferenceSDDocument = gs_item-Salesdocument
*                  ReferenceSDDocumentItem = gs_item-Salesitem
*
*                     ) )
*                     ) ) )
*          MAPPED ls_mapped
*          REPORTED ls_reported_modify
*          FAILED ls_failed_modify.
*
*                ENDIF.
*
*        ELSE.
************************************************************************
****---Standard Delivery Creation
*if lv_net_weight > lv_qty.
*            lv_mat = |{ ls_item-Material ALPHA = OUT }|.
*
*            Data(lv_msg1) = |Only { lv_qty } TO of material { lv_mat } available|.
*
*                     APPEND VALUE #( %tky = ls_header-%tky )
*                         TO failed-weighthead.
*
*                      APPEND VALUE #(
*                        %tky = ls_header-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = lv_msg1
*                        )
*                      ) TO reported-weighthead.
*
*ELSE.
*
*
*    MODIFY ENTITIES OF I_OutboundDeliveryTP PRIVILEGED
*      ENTITY OutboundDelivery
*      EXECUTE CreateDlvFromSalesDocument
*      FROM VALUE #(
*                    ( %cid = 'DLV001'
*                      %param = VALUE #(
*                      %control = VALUE #(
*
*                  ShippingPoint = if_abap_behv=>mk-on
*                  DeliverySelectionDate = if_abap_behv=>mk-on
*                  DeliveryDocumentType = if_abap_behv=>mk-on   )
*                  ShippingPoint = ls_item-Plant
*                  DeliverySelectionDate = lv_seldate
*                  DeliveryDocumentType = 'LF'
*
*            _ReferenceSDDocumentItem = VALUE #(
*                        FOR gs_item IN gt_weightIt
*                        (
*                         %control = VALUE #(
*                  ReferenceSDDocument = if_abap_behv=>mk-on
*                  ReferenceSDDocumentItem = if_abap_behv=>mk-on
*                                            )
*                  ReferenceSDDocument = gs_item-Salesdocument
*                  ReferenceSDDocumentItem = gs_item-Salesitem
*
*                     ) )
*                     ) ) )
*          MAPPED ls_mapped
*          REPORTED ls_reported_modify
*          FAILED ls_failed_modify.
*
*ENDIF.
*
*        ENDIF.
*
*
************************************************************************
**            lv_net_weight = REDUCE #(
**                                          INIT total = 0
**                                          FOR ls_weight IN gt_weightit
**                                          NEXT total = total + ls_weight-Netweight
**                                                     ).
***********************************************************************
    IF ls_mapped IS NOT INITIAL.
      IF ls_failed_modify IS INITIAL.
        zbp_sd_ih_weight=>cv_dlv_doc-outbounddelivery = ls_mapped-outbounddelivery.
        zbp_sd_ih_weight=>cv_dlvitem_doc-outbounddeliveryitem = ls_mapped-outbounddeliveryitem.
        MOVE-CORRESPONDING ls_header TO ls_hd.
        APPEND ls_hd TO lt_hd.
        zbp_sd_ih_weight=>gt_head = lt_hd.
        zbp_sd_ih_weight=>gt_item = CORRESPONDING #( gt_weightIt ).
      ENDIF.

***********************************************************************
      """---Picking Qty Indicator updated

      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      UPDATE
      FIELDS ( Picqtindicator )
      WITH VALUE #(  FOR key IN keys
                     ( %tky = ls_header-%tky
                       Picqtindicator = 'X'
                       %control-Picqtindicator = if_abap_behv=>mk-on
                       ) ).

    ENDIF.
    "------------------------------------------------------------
    " Handle standard SAP messages
    "------------------------------------------------------------

    LOOP AT ls_reported_modify-outbounddelivery
         INTO DATA(ls_std_reported).

      APPEND VALUE #(
        %tky = ls_item-%tky
        %msg = ls_std_reported-%msg
      ) TO reported-weightitem.

    ENDLOOP.
    "------------------------------------------------------------
    " Handle failure
    "------------------------------------------------------------

    IF ls_failed_modify-outbounddelivery IS NOT INITIAL.

      APPEND VALUE #(
        %tky = ls_item-%tky
      ) TO failed-weightitem.

    ENDIF.
*
*ELSE.
*            Data(lv_stmg) = |Storage Location is mandatory|.
*
*                     APPEND VALUE #( %tky = ls_header-%tky )
*                         TO failed-weighthead.
*
*                      APPEND VALUE #(
*                        %tky = ls_header-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = lv_stmg
*                        )
*                      ) TO reported-weighthead.
*
*ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD PickingQty.
**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_weighthd)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_weightIt)
    FAILED FINAL(gt_failed).
**************************************************************************
    DATA(ls_header) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).

    SORT gt_weightIt ASCENDING BY Salesitem.
***********************************************************************
    LOOP AT gt_weightIt ASSIGNING FIELD-SYMBOL(<fs_item>).
      IF <fs_item> IS ASSIGNED.

        MODIFY ENTITIES OF I_OutboundDeliveryTP PRIVILEGED
        ENTITY OutboundDeliveryItem
        UPDATE
          FIELDS (
                    ActualDeliveredQtyInOrderUnit
                    OrderQuantityUnit
                    YY1_PickQty_DLI
                    )
          WITH VALUE #( (
                          ActualDeliveredQtyInOrderUnit = <fs_item>-netweight
                          OrderQuantityUnit             = <fs_item>-baseunit
                          YY1_PickQty_DLI = 'X'
              %tky-OutboundDelivery         = <fs_item>-Deliveryno
              %tky-OutboundDeliveryItem     = <fs_item>-Deliveritem
                                       ) )
          FAILED   DATA(ls_failed_upddlv)
          REPORTED DATA(ls_reported_upddlv)
          MAPPED DATA(ls_mapped).

        IF ls_failed_upddlv IS INITIAL.

          MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
          ENTITY WeightHead
          UPDATE
          FIELDS ( Pickqtyindicator )
          WITH VALUE #(  FOR key IN keys
                       ( %tky = ls_header-%tky
               Pickqtyindicator = 'X'
               %control-Pickqtyindicator = if_abap_behv=>mk-on
               ) ).
        ENDIF.
        "------------------------------------------------------------
        " Forward standard SAP error message to custom RAP application
        "------------------------------------------------------------
        LOOP AT ls_reported_upddlv-outbounddeliveryitem
         ASSIGNING FIELD-SYMBOL(<ls_std_msg>).

          APPEND VALUE #(
                    %tky = <fs_item>-%tky
                    %msg = <ls_std_msg>-%msg
          ) TO reported-weightitem.

        ENDLOOP.


        "------------------------------------------------------------
        " Mark custom RAP instance as failed
        "------------------------------------------------------------
        IF ls_failed_upddlv-outbounddeliveryitem IS NOT INITIAL.

          APPEND VALUE #(
                %tky = <fs_item>-%tky
              ) TO failed-weightitem.

        ENDIF.
        "------------------------------------------------------------

      ENDIF.
    ENDLOOP.


***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD Weighmentslip.

**********************************************************************************************
          READ ENTITIES OF ZSD_IH_WEIGHT IN LOCAL MODE
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

            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZSD_WEIGHT_SLIP'
                                                                  iv_root_node = 'ZSD_CE_WEIGHT' ) .

            data: printque type c LENGTH 32.

              printque = 'ADOBE_DEFAULT'.

            TRY.
                lo_store->get_schema_by_name( iv_form_name = 'ZSD_WEIGHT_SLIP' ).
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
              iv_form_name     = 'ZSD_WEIGHT_SLIP'
              iv_template_name = 'WEIGHMENT_SLIP'
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

                    MODIFY ENTITIES OF ZSD_IH_WEIGHT IN LOCAL MODE
                    ENTITY WeightHead
                    UPDATE
                    FIELDS ( Attachmentwt Mimetypewt Filenamewt )
                        WITH VALUE #( for key in keys
                                   (   %tky = ls_header-%tky
                                    Attachmentwt = lv_pdf
                                    Mimetypewt = 'application/pdf'
                                    Filenamewt = lv_name
                                    %control-Attachmentwt = if_abap_behv=>mk-on
                                    %control-Mimetypewt = if_abap_behv=>mk-on
                                    %control-Filenamewt = if_abap_behv=>mk-on
                                    )  ).

                endif.
*
        endif.
**********************************************************************************************************************
               result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).



  ENDMETHOD.

  METHOD ManualFetchWt.
**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
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
    DATA(lv_itemcount) = lines( gt_weightIt ).
**************************************************************************
    """" -- Value Validation-----
    IF gs_keys-%param-Unit IS NOT INITIAL
              AND gs_keys-%param-Weight IS NOT INITIAL.
**************************************************************************
      GET TIME STAMP FIELD DATA(ts).
      CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**************************************************************************
      SELECT SINGLE * FROM  zsd_weight_vh WITH PRIVILEGED ACCESS
      WHERE value_low = @gs_keys-%param-Weighmentmcno
      AND language = 'E'
      INTO @DATA(ls_mcno).
**************************************************************************
      LOOP AT gt_weighthd ASSIGNING FIELD-SYMBOL(<ls_weight>).
        IF <ls_weight> IS ASSIGNED.

          MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
          ENTITY WeightHead
          UPDATE
          FIELDS ( Tarewt Weighuom Weighmentmcno weighmentmcndes
                  Weighmentdate Weighmenttime Imagecount )
          WITH VALUE #(  FOR key IN keys
                         ( %tky = <ls_weight>-%tky
                           Tarewt = gs_keys-%param-Weight
                           Weighuom = gs_keys-%param-Unit
                           Weighmentmcno = gs_keys-%param-Weighmentmcno
                           weighmentmcndes = ls_mcno-text
                           Weighmentdate = lv_date
                           Weighmenttime = lv_time
                           Imagecount = lv_itemcount

                          %control-Tarewt = if_abap_behv=>mk-on
                          %control-Weighuom = if_abap_behv=>mk-on
                          %control-Weighmentmcno = if_abap_behv=>mk-on
                          %control-weighmentmcndes = if_abap_behv=>mk-on
                          %control-Weighmentdate = if_abap_behv=>mk-on
                          %control-Weighmenttime = if_abap_behv=>mk-on
                          %control-Imagecount = if_abap_behv=>mk-on
                           ) ).

        ENDIF.
      ENDLOOP.
***********************************************************************
      LOOP AT gt_weightit ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item> IS ASSIGNED.

          MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
          ENTITY WeightItem
          UPDATE
          FIELDS ( Tareweight  )
          WITH VALUE #(  FOR key IN keys
                         ( %tky = <ls_item>-%tky
                           Tareweight = gs_keys-%param-Weight
                          %control-Grossweight = if_abap_behv=>mk-on
                           ) ).
        ENDIF.
      ENDLOOP.

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

  METHOD TransExit.
**********************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_head)
    FAILED FINAL(gt_failed).
**********************************************************************
    DATA(ls_header) = VALUE #( gt_head[ 1 ] OPTIONAL ).

    IF ls_header-Deliveryno IS NOT INITIAL.

      SELECT SINGLE BillingDocument,BillingDocumentItem,BillingDocumentDate
                   FROM I_BillingDocumentItemBasic WITH PRIVILEGED ACCESS
      WHERE ReferenceSDDocument = @ls_header-Deliveryno
      INTO    @DATA(ls_billing).
      IF sy-subrc = 0.
        SELECT SINGLE * FROM zsd_eway_cds WITH PRIVILEGED ACCESS
        WHERE ElectronicDocSourceKey = @ls_billing-BillingDocument
        INTO @DATA(ls_Eway).
      ENDIF.
    ENDIF.
**********************************************************************
**  Gate Exit Validation
**---------------------------------------------------------------------
    IF ls_billing IS NOT INITIAL.

      LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
        IF <fs_head> IS ASSIGNED.

          MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
          ENTITY WeightHead
          UPDATE
          FIELDS ( Transferexit Billingdocument billingdocumentdate Einvoiceno
                      Einvoicedate Ewaybillno Ewaybilldate )
          WITH VALUE #( FOR key IN keys
                      ( %tky = ls_header-%tky
                   Transferexit = 'X'
                   Billingdocument = ls_billing-BillingDocument
                   billingdocumentdate = ls_billing-BillingDocumentDate
                   Einvoiceno = ls_eway-EinvoiceNo
                   Einvoicedate = ls_eway-EinvoiceDate
                   Ewaybillno = ls_eway-EwayBillNo
                   Ewaybilldate = ls_eway-Ewaybilldate

                   %control-Transferexit = if_abap_behv=>mk-on
                   %control-Billingdocument = if_abap_behv=>mk-on
                   %control-billingdocumentdate = if_abap_behv=>mk-on
                   %control-Einvoiceno = if_abap_behv=>mk-on
                   %control-Einvoicedate = if_abap_behv=>mk-on
                   %control-Ewaybillno = if_abap_behv=>mk-on
                   %control-Ewaybilldate = if_abap_behv=>mk-on
                   ) ).

        ENDIF.
      ENDLOOP.
    ELSE.
      DATA(lv_msg) = |The billing & E-Way Bill have not been generated.|.

      APPEND VALUE #( %tky = ls_header-%tky )
          TO failed-weighthead.

      APPEND VALUE #(
        %tky = ls_header-%tky
        %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-error
        text     = lv_msg
        )
      ) TO reported-weighthead.
    ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD DeliveryPG.
**************************************************************************
    DATA:lv_seldate TYPE datum.
    DATA: lt_hd          TYPE TABLE OF zsd_app05_hdb,
          ls_hd          TYPE  zsd_app05_hdb,
          lv_qty         TYPE zsd_app05_idb-tareweight,
          lv_net_weight  TYPE zsd_app05_idb-tareweight,
          lv_mat         TYPE zsd_app05_idb-material,
          lv_brokamt     TYPE I_SalesDocument-TotalNetAmount,
          lv_totsalesamt TYPE I_SalesDocument-TotalNetAmount,
          lv_bkfinalamt  TYPE I_SalesDocument-TotalNetAmount,
          lv_Examt       TYPE I_SalesDocument-TotalNetAmount.
**************************************************************************
    DATA: lv_json        TYPE STANDARD TABLE OF string,
          lv_url         TYPE string,
          lv_auth        TYPE string,


          lv_message_err TYPE string,
          lv_invoice     TYPE belnr_d,
          lv_fiscalyear  TYPE gjahr.
    "------------------------------------------------------------
    " API Error Response Structure
    "------------------------------------------------------------
    TYPES: BEGIN OF ty_error_message,
             lang  TYPE string,
             value TYPE string,
           END OF ty_error_message.

    TYPES: BEGIN OF ty_error,
             code    TYPE string,
             message TYPE ty_error_message,
           END OF ty_error.

    TYPES: BEGIN OF ty_api_response,
             error TYPE ty_error,
           END OF ty_api_response.

    DATA: ls_api_response  TYPE ty_api_response,
          lv_error_message TYPE string.

**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_weighthd)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_weightIt)
    FAILED FINAL(gt_failed).

***********************************************************************
    DATA(ls_header) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
    DATA(ls_item) = VALUE #( gt_weightit[ 1 ] OPTIONAL ).
**************************************************************************
    ""for Return Delivery case No Need Any Validation---
    IF ls_header-Gateentrytype = 'SD1'.
      LOOP AT gt_weightit ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item> IS ASSIGNED.

          SELECT SINGLE * FROM I_SalesDocument WITH PRIVILEGED ACCESS
          WHERE SalesDocument = @<ls_item>-Salesdocument
          INTO @DATA(ls_saleshd).

          SELECT
               SUM( orderquantity ) AS total_order_qty,
               SUM( netamount )      AS total_net_value,
               SUM( taxamount )     AS total_tax_amt
               FROM i_salesdocumentitem
         WHERE salesdocument = @<ls_item>-SalesDocument
         INTO @DATA(ls_total).
*--------------------------------------------------------------------*
          """Broker Validation Starting Point.....
*--------------------------------------------------------------------*
          IF ( ls_saleshd-Salesdocument IS NOT INITIAL AND ls_saleshd-Distributionchannel = '30' )
                  AND ( ls_saleshd-salesdocumenttype = 'ZDOM' OR ls_saleshd-salesdocumenttype = 'ZEXP' ).


            SELECT SINGLE * FROM I_SalesOrderPartner WITH PRIVILEGED ACCESS
            WHERE SalesOrder = @ls_saleshd-SalesDocument
            AND  PartnerFunction = 'ZB'
            INTO @DATA(gs_broker).

            SELECT SINGLE * FROM zsd_broker_cds WITH PRIVILEGED ACCESS
            WHERE Brokerid = @gs_broker-Customer
            INTO @DATA(ls_cusbk).

            IF ls_saleshd-SalesDocumentType = 'ZEXP'.
              lv_examt = ls_saleshd-PriceDetnExchangeRate * ls_total-total_net_value.
            ELSE.
              lv_examt = ls_total-total_net_value.
            ENDIF.

            lv_totsalesamt = lv_examt + ls_total-total_tax_amt.
            lv_brokamt =  lv_totsalesamt / ls_total-total_order_qty.
            lv_bkfinalamt = lv_brokamt * <ls_item>-Netweight.

            IF  lv_bkfinalamt > ls_cusbk-Open_bal .

              DATA(lv_bkmsg) = |Broker limit exceeded the value { lv_bkfinalamt }|.

              APPEND VALUE #( %tky = ls_header-%tky )
                  TO failed-weighthead.

              APPEND VALUE #(
                %tky = ls_header-%tky
                %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = lv_bkmsg
                )
              ) TO reported-weighthead.

              RETURN.

            ENDIF.
*--------------------------------------------------------------------*
            """LC Screen Validation-----
*--------------------------------------------------------------------*
          ELSEIF ( ls_saleshd-Salesdocument IS NOT INITIAL AND ls_saleshd-Distributionchannel = '50' )
                   AND ( ls_saleshd-salesdocumenttype = 'ZDOM' OR ls_saleshd-salesdocumenttype = 'ZEXP' ).

            CLEAR: lv_totsalesamt,lv_brokamt,lv_bkfinalamt, lv_examt.


            SELECT SINGLE * FROM zsd_lc_cds WITH PRIVILEGED ACCESS
            WHERE SalesDocument = @ls_saleshd-SalesDocument
            INTO @DATA(ls_cuslc).

            IF ls_saleshd-SalesDocumentType = 'ZEXP'.
              lv_examt = ls_saleshd-PriceDetnExchangeRate * ls_total-total_net_value.
            ELSE.
              lv_examt = ls_total-total_net_value.
            ENDIF.

            lv_totsalesamt = lv_examt + ls_total-total_tax_amt.
            lv_brokamt =  lv_totsalesamt / ls_total-total_order_qty.
            lv_bkfinalamt = lv_brokamt * <ls_item>-Netweight.

            IF  lv_bkfinalamt > ls_cuslc-Balance_amt .

              DATA(lv_lcmsg) = |LC limit exceeded the value{ lv_bkfinalamt }|.

              APPEND VALUE #( %tky = ls_header-%tky )
                  TO failed-weighthead.

              APPEND VALUE #(
                %tky = ls_header-%tky
                %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = lv_lcmsg
                )
              ) TO reported-weighthead.
              RETURN.
            ENDIF.
*--------------------------------------------------------------------*
            """LC Screen Validation-----
*--------------------------------------------------------------------*
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDIF.
*--------------------------------------------------------------------*
    """PGI Starting Area  -----
*--------------------------------------------------------------------*
    IF ls_header-Deliveryno IS NOT INITIAL.

      TRY.

          DATA(lv_delivery) = ls_header-Deliveryno.

*--------------------------------------------------------------------*
* Get system URL
*--------------------------------------------------------------------*
          TRY.
              DATA(system_url) =
              cl_abap_context_info=>get_system_url( ).
            CATCH cx_abap_context_info_error  INTO DATA(lx_erro1).
              DATA(lv_err1) = lx_erro1->get_text( ).
          ENDTRY.
*--------------------------------------------------------------------*
* Determine host
*--------------------------------------------------------------------*
          DATA(lv_host) = COND string(
            WHEN system_url CS 'my437525'
              THEN 'https://my437525-api.s4hana.cloud.sap'

            WHEN system_url CS 'my425571'
              THEN 'https://my425571-api.s4hana.cloud.sap'

            WHEN system_url CS 'my437194'
              THEN 'https://my437194-api.s4hana.cloud.sap'

            ELSE ''
              ).

*--------------------------------------------------------------------*
* Authentication
*--------------------------------------------------------------------*
          lv_auth = 'INTEGRATION_001:Eipl@#sarabap1234567'.

          DATA(lv_auth_base64) =
              cl_web_http_utility=>encode_base64( lv_auth ).

*--------------------------------------------------------------------*
* Create ONE HTTP destination
*--------------------------------------------------------------------*
          DATA(lo_destination) =
            cl_http_destination_provider=>create_by_url( lv_host ).

*--------------------------------------------------------------------*
* Create ONE HTTP client
*--------------------------------------------------------------------*
          DATA(lo_client) =
            cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

          DATA(lo_request) =
            lo_client->get_http_request( ).

*--------------------------------------------------------------------*
* GET Delivery - Fetch CSRF Token + ETag
*--------------------------------------------------------------------*
* Based On the Delivery
*--------------------------------------------------------------------*
          CONDENSE ls_header-Gateentrytype.
          IF ls_header-Gateentrytype = 'SD1'.
            lo_request->set_uri_path(
              |/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/| &&
              |A_OutbDeliveryHeader(DeliveryDocument='{ lv_delivery }')|
                ).
          ELSEIF    ls_header-Gateentrytype = 'SD2'.
            lo_request->set_uri_path(
              |/sap/opu/odata/sap/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/| &&
              |A_ReturnsDeliveryHeader(DeliveryDocument='{ lv_delivery }')|
                ).
          ENDIF.
*--------------------------------------------------------------------*
          lo_request->set_header_fields(
            VALUE #(
                  ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )

                  ( name  = 'Accept' value = 'application/json' )

                  ( name  = 'X-CSRF-Token' value = 'fetch' )
                    )
                  ).

*--------------------------------------------------------------------*
* Execute GET
*--------------------------------------------------------------------*
          DATA(lo_get_response) =
            lo_client->execute( if_web_http_client=>get ).

*--------------------------------------------------------------------*
* Get CSRF Token
*--------------------------------------------------------------------*
          DATA(lv_xcsrf) =
            lo_get_response->get_header_field( 'x-csrf-token' ).

*--------------------------------------------------------------------*
* Get ETag
*--------------------------------------------------------------------*
          DATA(lv_etag) =
            lo_get_response->get_header_field( 'etag' ).

*--------------------------------------------------------------------*
* Validate CSRF
*--------------------------------------------------------------------*
          IF lv_xcsrf IS INITIAL.

            APPEND VALUE #(
              %tky = ls_header-%tky
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |CSRF token not received for delivery { lv_delivery }|
              )
            ) TO reported-weighthead.

            RETURN.

          ENDIF.

*--------------------------------------------------------------------*
* Validate ETag
*--------------------------------------------------------------------*
          IF lv_etag IS INITIAL.

            APPEND VALUE #(
                %tky = ls_header-%tky
                %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |ETag not received for delivery { lv_delivery }|
                )
              ) TO reported-weighthead.

            RETURN.

          ENDIF.

*--------------------------------------------------------------------*
* POST - Post Goods Issue
*--------------------------------------------------------------------*
* based Delivery Document
*--------------------------------------------------------------------*
          IF ls_header-Gateentrytype = 'SD1'.
            lo_request->set_uri_path(
              |/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/| &&
              |PostGoodsIssue?DeliveryDocument='{ lv_delivery }'|
                ).
          ELSEIF ls_header-Gateentrytype = 'SD2'.
            lo_request->set_uri_path(
              |/sap/opu/odata/sap/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/| &&
              |PostGoodsReceipt?DeliveryDocument='{ lv_delivery }'|
                ).
          ENDIF.
*--------------------------------------------------------------------*
* Set POST headers
*--------------------------------------------------------------------*
          lo_request->set_header_fields(
            VALUE #(
                  ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )

                  ( name  = 'Accept' value = 'application/json' )

                  ( name  = 'Content-Type' value = 'application/json' )

                  ( name  = 'X-CSRF-Token' value = lv_xcsrf )

                  ( name  = 'If-Match' value = lv_etag )
                    )
                  ).

*--------------------------------------------------------------------*
* Execute POST
*--------------------------------------------------------------------*
          DATA(lo_post_response) =
            lo_client->execute(
              if_web_http_client=>post ).

*--------------------------------------------------------------------*
* Get status
*--------------------------------------------------------------------*
          DATA(lv_status) =
                lo_post_response->get_status( ).

          DATA(lv_response_text) =
                lo_post_response->get_text( ).

*--------------------------------------------------------------------*
* Check result
*--------------------------------------------------------------------*
          IF lv_status-code >= 200
             AND lv_status-code < 300.

            SELECT SINGLE MaterialDocumentYear ,MaterialDocument ,MaterialDocumentItem,
                        DeliveryDocument ,DeliveryDocumentItem FROM I_MaterialDocumentItem_2 WITH PRIVILEGED ACCESS
                        WHERE DeliveryDocument = @ls_header-Deliveryno
                        INTO @DATA(ls_pgi).
            IF ls_pgi IS NOT INITIAL.

              MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
              ENTITY WeightHead
              UPDATE
              FIELDS ( Materialdocument Materialdocumentyear Giindicator )
              WITH VALUE #(  FOR key IN keys
                 ( %tky = ls_header-%tky
                   Materialdocument = ls_pgi-MaterialDocument
                   Materialdocumentyear = ls_pgi-MaterialDocumentYear
                   Giindicator = 'X'
                  %control-Materialdocument = if_abap_behv=>mk-on
                  %control-Materialdocumentyear = if_abap_behv=>mk-on
                  %control-Giindicator = if_abap_behv=>mk-on
                   ) ).
            ENDIF.

            APPEND VALUE #(
              %tky = ls_header-%tky
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-success
              text     = |PGI posted successfully for delivery { ls_pgi-MaterialDocument }.|
              )
                ) TO reported-weighthead.

          ELSE.


            "----------------------------------------------------------
            " Deserialize API Error JSON
            "----------------------------------------------------------
            TRY.

                /ui2/cl_json=>deserialize(
                  EXPORTING
                    json = lv_response_text
                  CHANGING
                    data = ls_api_response ).

                "Get actual SAP error message
                lv_error_message = ls_api_response-error-message-value.

              CATCH cx_root INTO DATA(lx_json_error).

                "If JSON parsing fails
                lv_error_message = |PGI failed. HTTP { lv_status-code }|.

            ENDTRY.
            "----------------------------------------------------------

            DATA(lv_msg_len) = strlen( lv_error_message ).

            DATA(lv_v1) = COND string(
                  WHEN lv_msg_len > 0
                    THEN substring(
                     val = lv_error_message
                     off = 0
                     len = COND #( WHEN lv_msg_len > 50
                       THEN 50
                       ELSE lv_msg_len ) )
                  ELSE '' ).
            "----------------------------------------------------------
            DATA(lv_v2) = COND string(
                  WHEN lv_msg_len > 50
                   THEN substring(
                     val = lv_error_message
                     off = 50
                     len = COND #( WHEN lv_msg_len > 100
                               THEN 50
                               ELSE lv_msg_len - 50 ) )
                      ELSE '' ).
            "----------------------------------------------------------
            DATA(lv_v3) = COND string(
                  WHEN lv_msg_len > 100
                  THEN substring(
                     val = lv_error_message
                     off = 100
                     len = COND #( WHEN lv_msg_len > 150
                           THEN 50
                           ELSE lv_msg_len - 100 ) )
                  ELSE '' ).
            "----------------------------------------------------------
            DATA(lv_v4) = COND string(
                  WHEN lv_msg_len > 150
                  THEN substring(
                     val = lv_error_message
                     off = 150
                     len = COND #( WHEN lv_msg_len > 200
                           THEN 50
                           ELSE lv_msg_len - 150 ) )
                      ELSE '' ).

            "----------------------------------------------------------
            APPEND VALUE #( %tky = ls_header-%tky )
                TO failed-weighthead.

            APPEND VALUE #(
              %tky = ls_header-%tky
              %msg = new_message(
              id = 'ZSD_ERROR'
              number = '001'
              severity = if_abap_behv_message=>severity-error

          v1 = lv_v1
          v2 = lv_v2
          v3 = lv_v3
          v4 = lv_v4
           )

           ) TO reported-weighthead.


          ENDIF.

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        CATCH cx_http_dest_provider_error
              cx_web_http_client_error
              cx_web_message_error
              INTO DATA(lx_error).

          APPEND VALUE #(
          %tky = ls_header-%tky
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = lx_error->get_text( )
            )
          ) TO reported-weighthead.

      ENDTRY.

    ENDIF.

***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weighthd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD PickQtyMdy.
  ENDMETHOD.

  METHOD ImagVald.
***********************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(lt_gatehd)
    FAILED FINAL(lt_failed).
***********************************************************************
    LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
      IF <ls_hd> IS ASSIGNED.

        MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
        UPDATE
        FIELDS ( Imagevalid )
            WITH VALUE #( FOR key IN keys
                       (   %tky = <ls_hd>-%tky
                        Imagevalid = 'X'
                        %control-Imagevalid = if_abap_behv=>mk-on
                        )  ).
      ENDIF.
    ENDLOOP.
************************************************************************
    result = VALUE #( FOR ls_ord IN lt_gatehd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD CancelGateEntry.
***********************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(lt_gatehd)
    FAILED FINAL(lt_failed).
***********************************************************************
    LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
      IF <ls_hd> IS ASSIGNED.

        MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
        UPDATE
        FIELDS ( Cancelgateentry )
            WITH VALUE #( FOR key IN keys
                       (   %tky = <ls_hd>-%tky
                        Cancelgateentry = 'X'
                        %control-Cancelgateentry = if_abap_behv=>mk-on
                        )  ).
      ENDIF.
    ENDLOOP.
************************************************************************
    result = VALUE #( FOR ls_ord IN lt_gatehd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD UpDlyheadertext.
***********************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    FAILED DATA(lt_failed).
***********************************************************************
    DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
***********************************************************************
    DATA: lv_json        TYPE STANDARD TABLE OF string,
          lv_url         TYPE string,
          lv_auth        TYPE string,
          lv_message_err TYPE string,
          lv_invoice     TYPE belnr_d,
          lv_fiscalyear  TYPE gjahr.
**************************************************************************
    DATA: lt_items      TYPE STANDARD TABLE OF string,
          lv_item_str   TYPE string,
          lv_items_json TYPE string.
    DATA(id1) = 'JGVN'.
    DATA(id2) = 'JGEB'.
    DATA(id3) = 'JGTD'.
    DATA(id4) = 'Z018'.
    DATA(lv_r) = 'R'.
    DATA(lang) = 'EN'.
    DATA(lv_user_format) = |{ cl_abap_context_info=>get_system_date( ) DATE = ENVIRONMENT }|.
*    DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
*    DATA(lv_formatted_date) = |{ lv_system_date+6(2) }.{ lv_system_date+4(2) }.{ lv_system_date(4) }|.
*                data(del) = '80000757'.
******************************* Vehicleno Text ****************************
    DATA(ls_json) = '{ "DeliveryDocument": "' && ls_head-Deliveryno &&
                        '","TextElement": "' && id1 &&
                        '","Language": "' && lang &&
                        '","TextElementText": "' && ls_head-Vehicleno &&
                        '" }'.
******************************* Vehicle Type ****************************
    DATA(ls_json1) = '{ "DeliveryDocument": "' && ls_head-Deliveryno &&
                        '","TextElement": "' && id2 &&
                        '","Language": "' && lang &&
                        '","TextElementText": "' && lv_r &&
                        '" }'.
******************************* Transport Date ***************************
    DATA(ls_json2) = '{ "DeliveryDocument": "' && ls_head-Deliveryno &&
                        '","TextElement": "' && id3 &&
                        '","Language": "' && lang &&
                        '","TextElementText": "' && lv_user_format &&
                        '" }'.
******************************* Transport ID ***************************
    DATA(lv_transid) = |{ ls_head-Transportid ALPHA = OUT }|.
    DATA(ls_json3) = '{ "DeliveryDocument": "' && ls_head-Deliveryno &&
                        '","TextElement": "' && id4 &&
                        '","Language": "' && lang &&
                        '","TextElementText": "' && lv_transid &&
                        '" }'.
***************************************************************************
    TRY.
        CONSTANTS lc_dev TYPE string VALUE 'https://my437525-api.s4hana.cloud.sap/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeaderText'.
        CONSTANTS lc_qas TYPE string VALUE 'https://my437525-api.s4hana.cloud.sap/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeaderText'.
        CONSTANTS lc_prd TYPE string VALUE 'https://my437525-api.s4hana.cloud.sap/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeaderText'.
***************************************************************************
        TRY.
            DATA(system_url) = cl_abap_context_info=>get_system_url( ).
          CATCH cx_abap_context_info_error  INTO DATA(lx_erro1).
            DATA(lv_err1) = lx_erro1->get_text( ).
        ENDTRY.
***************************************************************************
        IF system_url CS 'my437525'.
          lv_url = lc_dev.
        ELSEIF system_url CS 'my425571'.
          lv_url = lc_qas.
        ELSEIF system_url CS 'my437194'.
          lv_url = lc_prd.
        ENDIF.
***************************************************************************
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
             cl_http_destination_provider=>create_by_url( lv_url ).

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
        DATA(lo_web_http_client_post) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers with API Key for API Sandbox
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        DATA(lo_web_http_request_post) = lo_web_http_client->get_http_request( ).

        lv_auth = 'INTEGRATION_001:Eipl@#sarabap1234567'.

        DATA(lv_auth_base64) = cl_web_http_utility=>encode_base64( lv_auth ).

        lo_web_http_request->set_header_fields(
          VALUE #(

          ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
          ( name  = 'Content-Type' value = 'application/json' )
          ( name  = 'X-CSRF-Token' value = 'fetch' )
           )
        ).

        DATA(lo_web_http_response_get) = lo_web_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response_get) = lo_web_http_response_get->get_header_fields( ).


        DATA(lv_xcsrf) = lo_web_http_response_get->get_header_field(  'x-csrf-token' ).

        lo_web_http_request_post->set_header_fields(
          VALUE #(

          ( name  = 'Authorization' value = |Basic { lv_auth_base64 }| )
          ( name  = 'Content-Type' value = 'application/json' )
          ( name  = 'X-CSRF-Token' value = lv_xcsrf )
           )
        ).

        lo_web_http_request_post->set_text( ls_json ).
        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        lo_web_http_request_post->set_text( ls_json1 ).
        "set request method and execute request
        DATA(lo_web_http_response1) = lo_web_http_client->execute( if_web_http_client=>post ).
        DATA(lv_response1) = lo_web_http_response->get_text( ).

        lo_web_http_request_post->set_text( ls_json2 ).
        "set request method and execute request
        DATA(lo_web_http_response2) = lo_web_http_client->execute( if_web_http_client=>post ).
        DATA(lv_response2) = lo_web_http_response->get_text( ).

***********************************************************************
        DATA(lo_regex) = cl_abap_regex=>create_pcre( pattern = '<message[^>]*>([^<]*)</message>' ).

        FIND REGEX lo_regex
         IN lv_response
         SUBMATCHES lv_message_err.


        IF lv_message_err IS NOT INITIAL.

          APPEND VALUE #( %tky = ls_head-%tky )
              TO failed-weighthead.

          APPEND VALUE #(
            %tky = ls_head-%tky
            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                      text     = lv_message_err
                   )
          ) TO reported-weighthead .

        ENDIF.

*************************************************************************
        DATA lv_delivery_document TYPE string.
        DATA lv_start             TYPE i.
        DATA lv_end               TYPE i.
*************************************************************************
        lv_start = find(
            val = lv_response
            sub = '<d:DeliveryDocument>' ).

        IF lv_start >= 0.

          lv_start = lv_start + strlen( '<d:DeliveryDocument>' ).

          lv_end = find(
          val = lv_response
          sub = '</d:DeliveryDocument>'
          off = lv_start ).

          IF lv_end >= 0.

            lv_delivery_document =
                substring(
                    val = lv_response
                    off = lv_start
                    len = lv_end - lv_start ).

          ENDIF.

        ENDIF.
*************************************************************************
        CONDENSE lv_delivery_document.
        IF lv_delivery_document IS NOT INITIAL.
          DATA(lv_success_msg) = |Header Text-{ lv_delivery_document } created successfully.|.
          APPEND VALUE #(
            %tky = ls_head-%tky
            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                      text     = lv_success_msg
                   )
          ) TO reported-weighthead .

        ENDIF.
*************************************************************************
      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
    ENDTRY.

*************************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

ENDCLASS.

CLASS lhc_WeightItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightItem RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightItem RESULT result.

    METHODS AutoFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~AutoFetchTWt RESULT result.

    METHODS ImgCapture FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ImgCapture RESULT result.

    METHODS ManualFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ManualFetchTWt RESULT result.

ENDCLASS.

CLASS lhc_WeightItem IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item)
    FAILED DATA(lt_failed).
******************************************************************
    DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(ls_item1) = VALUE #( lt_item[ 1 ] OPTIONAL ).
******************************************************************
    result = VALUE #( FOR gs_head IN lt_head
         ( %tky = ls_item1-%tky

         %action = VALUE #(
                                ImgCapture = COND #( WHEN gs_head-Loadendindi = 'X'
                                THEN if_abap_behv=>fc-o-enabled
                                ELSE if_abap_behv=>fc-o-disabled )

                           AutoFetchTWt = COND #( WHEN gs_head-Loadendindi = 'X'
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled )

                           ManualFetchTWt = COND #( WHEN gs_head-Loadendindi = 'X'
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled )

*                                        Edit = COND #( WHEN ls_head-Weigmentindicator  is not INITIAL
*                                            then if_abap_behv=>fc-o-disabled
*                                            ELSE if_abap_behv=>fc-o-enabled ) )
*
*                                        %delete = COND #( WHEN ls_head-Weigmentindicator  is not INITIAL
*                                            then if_abap_behv=>fc-o-disabled
*                                            ELSE if_abap_behv=>fc-o-enabled )

                             ) ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD AutoFetchTWt.
**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_weighthd)
    ENTITY WeightItem
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(gt_weightIt)
    FAILED DATA(gt_failed).
************************************************************************
        DATA(ls_head) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
        data: lv_wb_no type c LENGTH 10.
        data: lv_finalwet type ZSD_APP05_HDB-tarewt.

        DATA: lt_upwtitem TYPE TABLE of ZSD_APP05_IDB,
              ls_upwtitem TYPE ZSD_APP05_IDB.
        DATA: lv_netwt TYPE zsd_app05_idb-netweight,
              lv_finalwt TYPE ZSD_APP05_IDB-netweight,
              lv_total_netwt TYPE ZSD_APP05_IDB-openqty.

        DATA(gt_keys) = keys.
        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).

        DATA: lv_urlwt TYPE string,
              lv_urlim TYPE string.


************************************************************************

    if ls_head-Tarewt is NOT INITIAL.

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

            SELECT SINGLE * FROM ZSD_WEIGHT_VH WITH PRIVILEGED ACCESS
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
""----Weighment Capture ending point

**********************************************************************
        sort gt_weightIt ASCENDING by Salesdocument Salesitem.

        LOOP AT gt_weightIt ASSIGNING FIELD-SYMBOL(<gs_weight>).
        if <gs_weight> is ASSIGNED.

""---Weighment Split Logic
            lv_total_netwt = REDUCE #(
                                    INIT lv_sum = 0
                                    FOR ls_item IN gt_weightIt
                                    WHERE ( Material = <gs_weight>-Material )
                                    NEXT lv_sum = lv_sum + ls_item-OpenQty
                                        ).
""---Weighment Split Logic
          CONDENSE ls_head-Gateentrytype.
          IF ls_head-Gateentrytype = 'SD1'.
            lv_netwt =  ( lv_finalwet - <gs_weight>-Tareweight ) .
          ELSEIF ls_head-Gateentrytype = 'SD2'.
            lv_netwt =  ( <gs_weight>-Tareweight - lv_finalwet ) .
          ENDIF.

*          IF lv_netwt > 0.

                lv_finalwt = ( ( <gs_weight>-OpenQty / lv_total_netwt ) * lv_netwt ).

                MOVE-CORRESPONDING <gs_weight> to ls_upwtitem.
                ls_upwtitem-netweight = lv_finalwt.
                ls_upwtitem-grossweight = lv_finalwet.
                ls_upwtitem-weighmentmcno = lv_weighmh-value_low.
                ls_upwtitem-weighmentmcndes = lv_weighmh-text.

                APPEND ls_upwtitem to lt_upwtitem.
*          ELSE.
*
*            DATA(lv_msg) = |Net Weight { lv_netwt } is Wrong|.
*            APPEND VALUE #( %tky        = <gs_weight>-%tky
*                        %state_area = 'Validate_Head'
*                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                             text     = lv_msg ) )
*               TO reported-weightitem.
*
*            APPEND VALUE #( %tky = <gs_weight>-%tky )
*               TO failed-weightitem.
*                RETURN.
*          ENDIF.


        ENDIF.
        ENDLOOP.

**********************************************************************
            if lt_upwtitem is NOT INITIAL.
                zbp_sd_ih_weight=>gt_upwtitem = lt_upwtitem.
            ENDIF.

**********************************************************************
""---Image Capturing Logic Starting Point

            READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
            ENTITY WeightItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
**********************************************************************
            DATA: lv_imageCount TYPE zsd_app05_idbd-itemimagecount.

                    lv_imageCount = REDUCE #(
                            INIT total = CONV #( 0 )
                            FOR ls_item IN lt_item
                            NEXT total = total + ls_item-Itemimagecount ).

**********************************************************************
if ls_head-Imagecount = lv_imagecount.

**********************************************************************
if lv_weight is not INITIAL and ls_status-code = '200'.

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
""--Msg handling

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

*            Data(lv_msg) = |seqno-{ gv_seqno } status-{ gv_status } wb_no { gv_wb_no }|.
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

    ELSE.
            DATA(lv_msgv) = |1st Weighment { ls_head-Tarewt } is Empty|.
            APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgv ) )
               TO reported-weighthead.

            APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-weighthead.
    ENDIF.
************************************************************************
    result = VALUE #( FOR ls_ord IN gt_weightIt
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD ImgCapture.
**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_weighthd)
    ENTITY WeightHead BY \_Item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(gt_weightIt)
    FAILED FINAL(gt_failed).

***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_weightIt
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD ManualFetchTWt.
**************************************************************************
    DATA: lv_netwt TYPE zsd_app05_idb-netweight,
          lv_finalwt TYPE ZSD_APP05_IDB-netweight,
          lv_total_netwt TYPE ZSD_APP05_IDB-openqty.
**************************************************************************
        DATA: lt_upwtitem TYPE TABLE of ZSD_APP05_IDB,
              ls_upwtitem TYPE ZSD_APP05_IDB.

**************************************************************************
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
    ENTITY WeightHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    ENTITY WeightItem
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item)
    FAILED DATA(lt_failed).
**************************************************************************
    DATA(ls_header) = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(gt_keys) = keys.
    DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
    sort lt_item ASCENDING BY Salesdocument Salesitem.
**************************************************************************
    """" -- Value Validation-----
    IF gs_keys-%param-Unit IS NOT INITIAL
              AND gs_keys-%param-Weight IS NOT INITIAL.
**************************************************************************
    """sales order Open overall sum Qty

*            lv_total_netwt = REDUCE #(
*                                  INIT lv_sum = 0
*                                  FOR ls_item IN lt_item
*                                  NEXT lv_sum = lv_sum + ls_item-OpenQty ).
************************************************************************




**************************************************************************
      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item> IS ASSIGNED.

""---Weighment Split Logic
            lv_total_netwt = REDUCE #(
                                    INIT lv_sum = 0
                                    FOR ls_item IN lt_item
                                    WHERE ( Material = <ls_item>-Material )
                                    NEXT lv_sum = lv_sum + ls_item-OpenQty
                                        ).
""---Weighment Split Logic

          CONDENSE ls_header-Gateentrytype.
          IF ls_header-Gateentrytype = 'SD1'.
            lv_netwt =  ( gs_keys-%param-Weight - <ls_item>-Tareweight ) .
          ELSEIF ls_header-Gateentrytype = 'SD2'.
            lv_netwt =  ( <ls_item>-Tareweight - gs_keys-%param-Weight ) .
          ENDIF.

          IF lv_netwt > 0.

                lv_finalwt = ( ( <ls_item>-OpenQty / lv_total_netwt ) * lv_netwt ).

                MOVE-CORRESPONDING <ls_item> to ls_upwtitem.
                ls_upwtitem-netweight = lv_finalwt.
                ls_upwtitem-grossweight = gs_keys-%param-Weight.

                APPEND ls_upwtitem to lt_upwtitem.
          ELSE.

            DATA(lv_msg) = |Net Weight { lv_netwt } is Wrong|.
            APPEND VALUE #( %tky        = <ls_item>-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msg ) )
               TO reported-weightitem.

            APPEND VALUE #( %tky = <ls_item>-%tky )
               TO failed-weightitem.

          ENDIF.

        ENDIF.
      ENDLOOP.

""---Updating table value updateing
            if lt_upwtitem is not INITIAL.
            zbp_sd_ih_weight=>gt_upwtitem = lt_upwtitem.
            endif.

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

ENDCLASS.

CLASS lsc_ZSD_IH_WEIGHT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSD_IH_WEIGHT IMPLEMENTATION.

  METHOD save_modified.
**********************************************************************
    IF zbp_sd_ih_weight=>cv_dlv_doc IS NOT INITIAL.
      LOOP AT zbp_sd_ih_weight=>cv_dlv_doc-outbounddelivery ASSIGNING FIELD-SYMBOL(<fs_dlv_mapped>).
        CONVERT KEY OF I_OutboundDeliveryTP FROM <fs_dlv_mapped>-%pid TO DATA(ls_dlv_key).
        <fs_dlv_mapped>-OutboundDelivery = ls_dlv_key-OutboundDelivery.
      ENDLOOP.

      DATA(lt_head) = zbp_sd_ih_weight=>gt_head.
      LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<fs_upd>).
        <fs_upd>-deliveryno = ls_dlv_key-OutboundDelivery.
        <fs_upd>-deliyindicator = 'X'.

      ENDLOOP.
      MODIFY zsd_app05_hdb FROM TABLE @lt_head.
    ENDIF.
**********************************************************************
    IF zbp_sd_ih_weight=>cv_dlvitem_doc IS NOT INITIAL.

      DATA(lt_item) = zbp_sd_ih_weight=>gt_item.
      SORT lt_item ASCENDING BY salesdocument salesitem.
      DATA(lv_index) = 0.

      LOOP AT zbp_sd_ih_weight=>cv_dlvitem_doc-outbounddeliveryitem
           ASSIGNING FIELD-SYMBOL(<fs_dlvitem_mapped>).

        lv_index = lv_index + 1.

        "----------------------------------------------------------
        " Convert temporary key to actual Delivery / Delivery Item
        "----------------------------------------------------------
        CONVERT KEY OF I_OutboundDeliveryItemTP
          FROM <fs_dlvitem_mapped>-%key
          TO DATA(ls_dlvitem_key).

        "----------------------------------------------------------
        " Actual Delivery Number
        "----------------------------------------------------------
        <fs_dlvitem_mapped>-OutboundDelivery =
          ls_dlvitem_key-OutboundDelivery.

        "----------------------------------------------------------
        " Actual Delivery Item
        "----------------------------------------------------------
        <fs_dlvitem_mapped>-OutboundDeliveryItem =
          ls_dlvitem_key-OutboundDeliveryItem.


        "----------------------------------------------------------
        " Update corresponding custom table record
        "----------------------------------------------------------
        READ TABLE lt_item
          ASSIGNING FIELD-SYMBOL(<fs_upditem>)
          INDEX lv_index.

        IF sy-subrc = 0.

          <fs_upditem>-deliveryno =
            ls_dlvitem_key-OutboundDelivery.

          <fs_upditem>-deliveritem =
            ls_dlvitem_key-OutboundDeliveryItem.

        ENDIF.

      ENDLOOP.


      "----------------------------------------------------------
      " Update custom table
      "----------------------------------------------------------
      MODIFY zsd_app05_idb FROM TABLE @lt_item.

    ENDIF.
**********************************************************************
*    IF zbp_sd_ih_weight=>cv_dlvitem_doc IS NOT INITIAL.
*      DATA(lt_item) = zbp_sd_ih_weight=>gt_item.
*
*      LOOP AT zbp_sd_ih_weight=>cv_dlvitem_doc-outbounddeliveryitem ASSIGNING FIELD-SYMBOL(<fs_dlvitem_mapped>).
*        CONVERT KEY OF I_OutboundDeliveryItemTP FROM <fs_dlvitem_mapped>-%key TO DATA(ls_dlvitem_key).
*        <fs_dlvitem_mapped>-OutboundDelivery = ls_dlvitem_key-OutboundDelivery.
*        <fs_dlvitem_mapped>-OutboundDeliveryItem = ls_dlvitem_key-OutboundDeliveryItem.
*
*        LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_upditem>) WHERE
*                                salesitem = <fs_dlvitem_mapped>-OutboundDeliveryItem.
*          <fs_upditem>-deliveryno = ls_dlvitem_key-OutboundDelivery.
*          <fs_upditem>-deliveritem = ls_dlvitem_key-OutboundDeliveryItem.
*        ENDLOOP.
*      ENDLOOP.
*      MODIFY zsd_app05_idb FROM TABLE @lt_item.
*    ENDIF.
**********************************************************************
*    IF zbp_sd_ih_weight=>cv_mat_doc IS NOT INITIAL.
*      LOOP AT zbp_sd_ih_weight=>cv_mat_doc-materialdocument ASSIGNING FIELD-SYMBOL(<fs_migo_mapped>).
*        CONVERT KEY OF I_MaterialDocumentTP FROM <fs_migo_mapped>-%pid TO DATA(ls_migo_key).
*        <fs_migo_mapped>-MaterialDocument = ls_migo_key-MaterialDocument.
*        <fs_migo_mapped>-MaterialDocumentYear = ls_migo_key-MaterialDocumentYear.
*      ENDLOOP.
*
*      DATA(lt_migo) = zbp_sd_ih_weight=>gt_migohead.
*      LOOP AT lt_migo ASSIGNING FIELD-SYMBOL(<fs_migo>).
*        <fs_migo>-materialdocument = ls_migo_key-MaterialDocument.
*        <fs_migo>-materialdocumentyear = ls_migo_key-MaterialDocumentYear.
*        <fs_migo>-giindicator = 'X'.
*      ENDLOOP.
*      MODIFY zsd_app05_hdb FROM TABLE @lt_migo.
*    ENDIF.
**********************************************************************
""" Weighment Update-----
        if zbp_sd_ih_weight=>gt_upwtitem is NOT INITIAL.
            MODIFY zsd_app05_idb FROM TABLE @zbp_sd_ih_weight=>gt_upwtitem.
        ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
