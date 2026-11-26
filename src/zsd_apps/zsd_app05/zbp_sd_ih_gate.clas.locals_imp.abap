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

    METHODS Print FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~Print RESULT result.

    METHODS SalesOrder FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~SalesOrder RESULT result.

    METHODS headmodify FOR DETERMINE ON SAVE
      IMPORTING keys FOR GateHead~headmodify.
    METHODS CancelGateEntry FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~CancelGateEntry RESULT result.

ENDCLASS.

CLASS lhc_GateHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zsd_ih_gate IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

******************************************************************
        result = VALUE #( for ls_key in keys
                     ( %tky = ls_key-%tky

                     %action = VALUE #( GateCheckIn = COND #( WHEN ls_head-Gateentryno  is INITIAL
                                            then if_abap_behv=>fc-o-enabled
                                            WHEN ls_head-Cancelgateentry is NOT INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-disabled )

                                       CancelGateEntry = COND #( when ls_head-Cancelgateentry is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )
*
                                       SalesOrder = COND #( when ls_head-Cancelgateentry is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )
*
                                        Edit = COND #( WHEN ls_head-Cancelgateentry  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )
*
*                                        %delete = COND #( WHEN ls_head-Weigmentindicator  is not INITIAL
*                                            then if_abap_behv=>fc-o-disabled
*                                            ELSE if_abap_behv=>fc-o-enabled )

                                         ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GateCheckIn.
***********************************************************************
        data: seqno type ZSD_APP05_HDB-gateentrysequence,
              gateno type ZSD_APP05_HDB-gateentryno,
              sydate type ZSD_APP05_HDB-gateentrydate.
***********************************************************************
        READ ENTITIES OF zsd_ih_gate IN LOCAL MODE
        ENTITY GateHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(gt_head)
        FAILED FINAL(gt_failed).

***********************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
        LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
            IF <fs_head> is ASSIGNED.
***********************************************************************
        SELECT SINGLE MAX( gateentrysequence ) AS gateentrysequence,
              gateentrydate
            FROM ZSD_APP05_HDB
            WHERE gateentrydate = @lv_date
            GROUP BY gateentrydate
            INTO @DATA(gs_seqno).
***********************************************************************
            if sy-subrc = 0 and gs_seqno-gateentrysequence is not INITIAL.
                seqno = gs_seqno-gateentrysequence + 1.
                gateno = |{ <fs_head>-Gateentrytype }{ lv_date }-{ seqno }|.
            else.
                seqno = '001'.
                gateno = |{ <fs_head>-Gateentrytype }{ lv_date }-{ seqno }|.
            endif.

***********************************************************************
           MODIFY ENTITIES OF zsd_ih_gate IN LOCAL MODE
           ENTITY GateHead
           UPDATE
           FIELDS ( Gateentryno Gateentrysequence Gateentrydate Gateentrytime )
           WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         gateentryno = gateno
                         gateentrysequence = seqno
                         gateentrydate = lv_date
                         gateentrytime = lv_time
                         %control-Gateentryno = if_abap_behv=>mk-on
                         %control-Gateentrysequence = if_abap_behv=>mk-on
                         %control-Gateentrydate = if_abap_behv=>mk-on
                         %control-Gateentrytime = if_abap_behv=>mk-on
                         ) ).
***********************************************************************
            endif.
        ENDLOOP.
***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD Print.
***********************************************************************
   READ ENTITIES OF zsd_ih_gate IN LOCAL MODE
          ENTITY GateHead
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT FINAL(gt_head)
          FAILED FINAL(gt_failed).
***********************************************************************
          DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
          DATA(gt_keys) = keys.
          DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
***********************************************************************
    if ls_header-Gateentryno is not INITIAL.

        TRY.
            "Initialize Template Store Client
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_name                  = 'ZADS_CS'
             iv_service_instance_name = 'ZADS_OUT_REST'
            ).

            DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZSD_LOADING_SLIP'
                                                                  iv_root_node = 'ZSD_CE_GATE' ) .

           data: printque type c LENGTH 32.

              printque = 'ADOBE_DEFAULT'.

            TRY.
                lo_store->get_schema_by_name( iv_form_name = 'ZSD_LOADING_SLIP' ).
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

***********************************************************************
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

***********************************************************************
               DATA(lt_keys)     = lo_fdp_util->get_keys( ).
            lt_keys[ name = 'UUID' ]-value = gt_head[ 1 ]-Uuid.
***********************************************************************
         data(lt_xsd) = lo_fdp_util->get_xsd( ).
***********************************************************************
*           "Convert the XSD File converstion for Form Purpose
             data(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

                TRY.
                DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
                "out->write( 'Service data retrieved' ).
              CATCH cx_fp_fdp_error INTO DATA(lo_exception).
            ENDTRY.
***********************************************************************
        DATA(ls_template) = lo_store->get_template_by_name(
              iv_get_binary    = abap_true
              iv_form_name     = 'ZSD_LOADING_SLIP'
              iv_template_name = 'LOADING_SLIP'
            ).
***********************************************************************
cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                       "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                                 iv_xml_data     = lv_xml
                                                 iv_xdp_layout   = ls_template-xdp_template
                                                 is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                       IMPORTING
                                       " TODO: variable is assigned but never used (ABAP cleaner)
                                                 ev_trace_string = DATA(lv_trace)
                                                 ev_pdf          = DATA(lv_pdf) ).




***********************************************************************
             DATA: lv_name TYPE c LENGTH 120.
            lv_name = |Loading Slip-{ gt_head[ 1 ]-Gateentryno }|.
***********************************************************************
                cl_print_queue_utils=>create_queue_item_by_data(
              iv_qname            = printque
              iv_print_data       = lv_pdf
              iv_name_of_main_doc = lv_name
              iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
            ).

          CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
            " out->write( 'Exception occurred.' ).
        ENDTRY.
***********************************************************************
           if lv_pdf is not iNITIAL.

                    MODIFY ENTITIES OF zsd_ih_gate IN LOCAL MODE
                    ENTITY GateHead
                    UPDATE
                    FIELDS ( Attachmentload Mimetypeload Filenameload )
                        WITH VALUE #( for key in keys
                                   (   %tky = ls_header-%tky
                                    Attachmentload = lv_pdf
                                    Mimetypeload = 'application/pdf'
                                    Filenameload = lv_name
                                    %control-Attachmentload = if_abap_behv=>mk-on
                                    %control-Mimetypeload = if_abap_behv=>mk-on
                                    %control-Filenameload = if_abap_behv=>mk-on
                                    )  ).

                endif.
*
        endif.

***********************************************************************
       result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************


  ENDMETHOD.

  METHOD SalesOrder.
***********************************************************************
            data: lv_cus type ZSD_APP05_IDB-customer,
                  lv_so type ZSD_APP05_IDB-salesdocument,
                  lv_soitem type ZSD_APP05_IDB-salesitem,
                  lv_numcus TYPE n LENGTH 10,
                  lv_billfrom TYPE ZSD_APP05_HDB-billingfrom,
                  lv_consignee TYPE ZSD_APP05_HDB-billingfrom,
                  lv_billTO TYPE ZSD_APP05_HDB-billingfrom,
                  lv_broker TYPE ZSD_APP05_HDB-billingfrom.
***********************************************************************
            READ ENTITIES OF zsd_ih_gate IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_head)
            fAILED FINAL(gt_failed).

*******************************************************************
        DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).
        DATA(gt_keys) = keys.
        DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
        lv_cus = gs_keys-%param-Customer.
        lv_so = gs_keys-%param-Salesdocument.
        lv_soitem = gs_keys-%param-SalesDocumentItem.
        lv_numcus = gs_keys-%param-Customer.
*******************************************************************
*"""---Dispatch Planning Validation
*
*        select SINGLE * FROM ZSD_ORDERITEM_VH WITH PRIVILEGED ACCESS
*        WHERE SalesDocument = @lv_so
*        AND SalesDocumentItem = @lv_soitem
*        AND Customer = @lv_numcus
**        AND Dispatchdate = @sy-datum
*        INTO @DATA(ls_disvalid).
*
*if ls_disvalid is NOT INITIAL.
*******************************************************************
                select single salesdocument, salesitem from ZSD_APP05_IDB WITH PRIVILEGED ACCESS
                where salesdocument = @lv_so
                and salesitem = @lv_soitem
                and uuid = @ls_header-Uuid
                into @DATA(wa_salesitemdb).
*******************************************************************
        if lv_so is not INITIAL and lv_soitem is not INITIAL and ls_header-Gateentrytype = 'SD1'.

                 select  a~SalesDocument,
                                a~SalesDocumentItem,
                                a~plant,
                                a~Product,
                                a~Batch,
                                a~OrderQuantity,
                                a~BaseUnit,
                                a~soldtoparty,
                                a~Division,
                                a~SalesDocumentType,
                                a~DistributionChannel,
                                a~ShippingPoint,
                                a~Independentrequirementtype,
                                b~PlantName,
                                c~ProductName,
                                d~CustomerName
                                from I_SalesDocumentItem as a
                                LEFT OUTER JOIN I_Plant as b on a~Plant = b~Plant
                                LEFT OUTER JOIN I_ProductText as c on a~Product = c~Product
                                LEFT OUTER JOIN I_Customer as d on a~soldtoparty = d~Customer
                                where a~SalesDocument = @lv_so
                                and a~SalesDocumentItem = @lv_soitem
                                and a~SDProcessStatus ne 'C'
                                into table @data(lt_soitem).

        ELSEIF lv_so is not INITIAL and lv_soitem is not INITIAL and ls_header-Gateentrytype = 'SD2'.

                 select  a~CustomerReturn as SalesDocument,
                                a~CustomerReturnItem as SalesDocumentItem,
                                a~plant,
                                a~Product,
                                a~Batch,
                                a~OrderQuantity,
                                a~BaseUnit,
                                a~soldtoparty,
                                a~Division,
                                e~customerreturntype as SalesDocumentType,
                                a~DistributionChannel,
                                a~ShippingPoint,
                                b~PlantName,
                                c~ProductName,
                                d~CustomerName
                                from I_CustomerReturnItem as a
                                INNER JOIN I_CUSTOMERRETURN as e ON a~CustomerReturn = e~CustomerReturn
                                LEFT OUTER JOIN I_Plant as b on a~Plant = b~Plant
                                LEFT OUTER JOIN I_ProductText as c on a~Product = c~Product
                                LEFT OUTER JOIN I_Customer as d on a~soldtoparty = d~Customer
                                where a~CustomerReturn = @lv_so
                                and a~CustomerReturnItem = @lv_soitem
*                                and a~SDProcessStatus ne 'C'
                                into table @lt_soitem.

        endif.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""----Sales Order Complete and rejection Validation

if lt_soitem is NOT INITIAL.

*******************************************************************
****-----Gate Entry Header update in Gate Entry Header Table-----*****

        if ls_header-Customer is INITIAL.
        data(ls_orderhd) = VALUE #( lt_soitem[ 1 ] optional ).

""---From Place Logic...

            SELECT single Plant,PlantName,AddressID FROM I_Plant WITH PRIVILEGED ACCESS
			WHERE Plant = @ls_orderhd-Plant
			INTO @DATA(ls_plant).
""---Billing From Logic...
            SELECT SINGLE * FROM ZPLANT_ADD WITH PRIVILEGED ACCESS
            WHERE AddressID = @ls_plant-AddressID
            INTO @DATA(ls_billing).

            lv_billfrom = |{ ls_billing-StreetName } { ls_billing-CityName } { ls_billing-PostalCode } { ls_billing-CountryName } { ls_billing-RegionName }|.

""---Consignee logic......
            SELECT * FROM ZSD_PARTNER WITH PRIVILEGED ACCESS
            WHERE SalesOrder = @ls_orderhd-SalesDocument
            INTO table @DATA(lt_consignee).


            DATA(ls_conWE) = VALUE #( lt_consignee[ PartnerFunction = 'WE' ] OPTIONAL ).
            DATA(ls_conRE) = VALUE #( lt_consignee[ PartnerFunction = 'RE' ] OPTIONAL ).
            DATA(ls_conZB) = VALUE #( lt_consignee[ PartnerFunction = 'ZB' ] OPTIONAL ).

            SELECT SINGLE * FROM ZPLANT_ADD WITH PRIVILEGED ACCESS
            WHERE AddressID = @ls_conWE-AddressID
            INTO @DATA(ls_conAdd).

            SELECT SINGLE * FROM ZPLANT_ADD WITH PRIVILEGED ACCESS
            WHERE AddressID = @ls_conRE-AddressID
            INTO @DATA(ls_BillAdd).

            SELECT SINGLE * FROM ZPLANT_ADD WITH PRIVILEGED ACCESS
            WHERE AddressID = @ls_conZB-AddressID
            INTO @DATA(ls_brokAdd).

            lv_consignee = |{ ls_conAdd-StreetName } { ls_conAdd-CityName } { ls_conAdd-PostalCode } { ls_conAdd-CountryName } { ls_conAdd-RegionName }|.
            lv_billto = |{ ls_BillAdd-StreetName } { ls_BillAdd-CityName } { ls_BillAdd-PostalCode } { ls_BillAdd-CountryName } { ls_BillAdd-RegionName }|.
            lv_broker = |{ ls_brokAdd-StreetName } { ls_brokAdd-CityName } { ls_brokAdd-PostalCode } { ls_brokAdd-CountryName } { ls_brokAdd-RegionName }|.
***********************************************************************
        MODIFY ENTITIES OF zsd_ih_gate IN LOCAL MODE
        ENTITY GateHead
        UPDATE
        FIELDS ( Customer Customername Division Fromplace
                Billingfrom Consignee Billto Broker )
         WITH VALUE #( for key IN keys
                            ( %tky = ls_header-%tky
                         Customer = ls_orderhd-SoldToParty
                         Customername = ls_orderhd-CustomerName
                         Division = ls_orderhd-Division
                         Fromplace = ls_plant-PlantName
                         Billingfrom = lv_billfrom
                         Consignee = lv_consignee
                         Billto = lv_billto
                         Broker = lv_broker

                         %control-Gateentrydate = if_abap_behv=>mk-on
                         %control-Gateentrytime = if_abap_behv=>mk-on
                         %control-Division = if_abap_behv=>mk-on
                         %control-Fromplace = if_abap_behv=>mk-on
                         %control-Billingfrom = if_abap_behv=>mk-on
                         %control-Consignee = if_abap_behv=>mk-on
                         %control-Billto = if_abap_behv=>mk-on
                         %control-Broker = if_abap_behv=>mk-on
                         ) ).
        ENDIF.
*******************************************************************
*****-----Sales Order Item Creation in Gate Entry Item Table-----*****
        if wa_salesitemdb-salesdocument is INITIAL and wa_salesitemdb-salesitem is INITIAL .

                MODIFY ENTITIES OF zsd_ih_gate IN LOCAL MODE
                ENTITY GateHead
                CREATE BY \_Item
                AUTO FILL CID
                FIELDS ( Salesdocument Salesitem Gateentryno Plant Customer Customername Shippingpoint Independentrequirementtype
                        Plantname Material Materialdesc Baseunit Batch Quantity Ordertype Distributionchannel )
                WITH VALUE #( for ls_head in gt_head
                                (  %is_draft = ls_head-%is_draft
                                    %key =  CORRESPONDING #( ls_head )
                                   %target = VALUE #( for ls_saitem in lt_soitem
                                    ( %cid = |CID{ ls_saitem-SalesDocumentItem }|
                                       Salesdocument = ls_saitem-SalesDocument
                                       Salesitem = ls_saitem-SalesDocumentItem
                                       Gateentryno = ls_head-Gateentryno
                                       Plant = ls_saitem-Plant
                                       Plantname = ls_saitem-PlantName
                                       Material = ls_saitem-Product
                                       materialdesc = ls_saitem-ProductName
                                       batch = ls_saitem-Batch
                                       baseunit = ls_saitem-BaseUnit
                                       quantity = ls_saitem-OrderQuantity
                                       Customer = ls_saitem-SoldToParty
                                       Customername = ls_saitem-CustomerName
                                       Ordertype = ls_saitem-SalesDocumentType
                                       Distributionchannel = ls_saitem-DistributionChannel
                                       Shippingpoint = ls_saitem-ShippingPoint
                                       Independentrequirementtype = ls_saitem-IndependentRequirementType ) )
                                    ) )
                          REPORTED reported
                          fAILED failed
                          MAPPED mapped.
********************************************************************
        else.
              data(lv_msg) = |Order Already Exists-{ ls_header-gateentryno }|.
              APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
              APPEND VALUE #( %tky = ls_header-%tky
              %state_area = 'Validate_Head'
              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = lv_msg )
                               ) TO reported-gatehead.
        endif.
************************************************************************
*else.
*              data(lv_rej) = |Order { lv_so } has already been completed or rejected|.
*              APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
*              APPEND VALUE #( %tky = ls_header-%tky
*              %state_area = 'Validate_Head'
*              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                              text = lv_rej )
*                               ) TO reported-gatehead.
*ENDIF.
************************************************************************
ELSE.

              data(lv_val) = |This Order { lv_so } is Closed|.
              APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
              APPEND VALUE #( %tky = ls_header-%tky
              %state_area = 'Validate_Head'
              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = lv_val )
                               ) TO reported-gatehead.
ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD headmodify.
***********************************************************************
        data: seqno type ZSD_APP05_HDB-gateentrysequence,
              gateno type ZSD_APP05_HDB-gateentryno,
              sydate type ZSD_APP05_HDB-gateentrydate,
              gateid type ZSD_APP05_HDB-gateentryid.
***********************************************************************
        READ ENTITIES OF zsd_ih_gate IN LOCAL MODE
        ENTITY GateHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(gt_head)
        FAILED FINAL(gt_failed).

***********************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
        LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
            IF <fs_head> is ASSIGNED.

***********************************************************************
               if <fs_head>-Gateentrytype is not INITIAL.
                    select SINGLE value_low,text from ZSD_TYPE_VH WITH PRIVILEGED ACCESS
                    where value_low = @<fs_head>-Gateentrytype
                    into @DATA(gs_gatetype).
               endif.
***********************************************************************
                if <fs_head>-Gateno is NOT INITIAL.
                    select SINGLE * from ZSD_GATENO_VH WITH PRIVILEGED ACCESS
                    where value_low = @<fs_head>-Gateno
                    INTO @DATA(gs_gateno).

                ENDIF.
***********************************************************************
        SELECT SINGLE MAX( gateentryid ) AS gateentryid
            FROM ZSD_APP05_HDB
            INTO @DATA(gs_id).

        if gs_id is not INITIAL.
            gateid = gs_id + 1.
         else.
            gateid = '1000000001'.
        endif.

************************************************************************
           MODIFY ENTITIES OF zsd_ih_gate IN LOCAL MODE
           ENTITY GateHead
           UPDATE
           FIELDS ( Gateentryid Gateentryiddate Gateentryidtime Gateentrytypetext Gatenodes )
           WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         Gateentryid = gateid
                         Gateentryiddate = lv_date
                         gateentryidtime = lv_time
                         Gateentrytypetext = gs_gatetype-text
                         Gatenodes = gs_gateno-text

                         %control-Gateentryid = if_abap_behv=>mk-on
                         %control-Gateentryiddate = if_abap_behv=>mk-on
                         %control-Gateentrytypetext = if_abap_behv=>mk-on
                         %control-Gatenodes = if_abap_behv=>mk-on
                         ) ).
************************************************************************

            endif.
        ENDLOOP.

  ENDMETHOD.

  METHOD CancelGateEntry.
**********************************************************************
            READ ENTITIES OF zsd_ih_gate IN LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(gt_head)
            FAILED FINAL(gt_failed).
**********************************************************************
            DATA(ls_header) = VALUE #( gt_head[ 1 ] optional ).

        LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
            IF <fs_head> is ASSIGNED.

                MODIFY ENTITIES OF zsd_ih_gate IN LOCAL MODE
                ENTITY GateHead
                UPDATE
                FIELDS ( Cancelgateentry )
                WITH VALUE #( for key IN keys
                            ( %tky = <fs_head>-%tky
                         Cancelgateentry = 'X'
                         %control-Cancelgateentry = if_abap_behv=>mk-on
                         ) ).

            ENDIF.
        ENDLOOP.

***********************************************************************
    result = VALUE #( FOR ls_ord IN gt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateItem RESULT result.

ENDCLASS.

CLASS lhc_GateItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
