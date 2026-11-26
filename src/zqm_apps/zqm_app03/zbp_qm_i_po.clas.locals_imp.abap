CLASS lhc_POHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR POHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR POHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR POHead RESULT result.
    METHODS AddPO FOR DETERMINE ON SAVE
      keys FOR POHead~AddPO.
    METHODS GetInsp FOR MODIFY
      keys FOR ACTION POHead~GetInsp RESULT result.

ENDCLASS.

CLASS lhc_POHead IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD AddPO.
***************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY POHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

***************************************************************************

            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
            if <ls_head> is ASSIGNED.

                    select single PurchaseOrder,PurchaseOrderItem,
                                   DocumentCurrency,CompanyCode,plant,
                                   BaseUnit,OrderQuantity,Material,
                                   PurchaseOrderItemText,netamount,taxcode
                                   from I_PurchaseOrderItemAPI01 witH PRIVILEGED ACCESS
                                   where PurchaseOrder = @<ls_head>-Purchaseorder
                                   and PurchaseOrderItem = @<ls_head>-Purchaseorderitem
                                   into @data(wa_poitem).

                    select single PurchaseOrder,PurchaseOrderDate,PaymentTerms,Supplier from I_PurchaseOrderAPI01 wiTH PRIVILEGED ACCESS
                        where PurchaseOrder = @wa_poitem-PurchaseOrder
                        into @data(wa_podate).

                    select single CompanyCodeName from I_CompanyCode WITH PRIVILEGED ACCESS
                    where CompanyCode = @wa_poitem-CompanyCode
                    into @data(wa_ccname).

                    select single PlantName from I_Plant WITH PRIVILEGED ACCESS
                    where Plant = @wa_poitem-Plant
                    into @data(wa_plname).


           if wa_poitem is not INITIAL.

                    MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                    ENTITY POHead
                    UPDATE
                    FIELDS ( Orderdate Companycode Plant Baseunit
                             Orderquantity Documentcurrency Netamount
                             Material Materialdes Companycodename
                             Plantname Paymentterms Taxcode Suppllier )
                    WITH VALUE #( for key in keys
                                    ( %tky = <ls_head>-%tky
                                    Orderdate = wa_podate-PurchaseOrderDate
                                    Companycode = wa_poitem-CompanyCode
                                    Plant = wa_poitem-Plant
                                    Baseunit = wa_poitem-BaseUnit
                                    Orderquantity = wa_poitem-OrderQuantity
                                    Documentcurrency = wa_poitem-DocumentCurrency
                                    Netamount = wa_poitem-NetAmount
                                    Material = wa_poitem-Material
                                    Materialdes = wa_poitem-PurchaseOrderItemText
                                    Companycodename = wa_ccname
                                    Plantname = wa_plname
                                    Suppllier = wa_podate-Supplier
                                    Paymentterms = wa_podate-PaymentTerms
                                    Taxcode = wa_poitem-TaxCode

                                    %control-Orderdate = if_abap_behv=>mk-on
                                    %control-Companycode = if_abap_behv=>mk-on
                                    %control-Plant = if_abap_behv=>mk-on
                                    %control-Baseunit = if_abap_behv=>mk-on
                                    %control-Orderquantity = if_abap_behv=>mk-on
                                    %control-Documentcurrency = if_abap_behv=>mk-on
                                    %control-Netamount = if_abap_behv=>mk-on
                                    %control-Material = if_abap_behv=>mk-on
                                    %control-Materialdes = if_abap_behv=>mk-on
                                    %control-Companycodename = if_abap_behv=>mk-on
                                    %control-Plantname = if_abap_behv=>mk-on
                                    %control-Suppllier = if_abap_behv=>mk-on
                                    %control-Paymentterms = if_abap_behv=>mk-on
                                    %control-Taxcode = if_abap_behv=>mk-on
                                    ) ).

           endif.
            endif.
            endloop.

  ENDMETHOD.

  METHOD GetInsp.
***************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY POHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).
***************************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

***************************************************************************
              select InspectionLot,InspLotCreatedOnLocalDate,
                        PurchasingDocument,PurchasingDocumentItem,
                        InspectionLotQuantity,InspectionLotType,MaterialDocument,
                         MaterialDocumentYear,MaterialDocumentItem
               from I_InspectionLot WITH PRIVILEGED ACCESS
                where PurchasingDocument = @ls_head-Purchaseorder
                and PurchasingDocumentItem = @ls_head-Purchaseorderitem
                and InspectionLotActualQuantity is not INITIAL
                into table @Data(lt_inspec).

***********************************************************************
            sort lt_inspec ASCENDING BY InspectionLot.

if lt_inspec is not INITIAL.

                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY POHead
                CREATE BY \_Insp
                AUTO FILL CID
                FIELDS ( Inspectionlot Baseunit Inspectionlotqty Inspectionlottype Inspectiondate
                         Materialdocument Materialdocumentitem Materialdocumentyear )
                WITH VALUE #( for gs_head in lt_head
                                (  %is_draft = gs_head-%is_draft
                                    %key =  CORRESPONDING #( gs_head )

                                   %target = VALUE #( for ls_inspec in lt_inspec
                                    ( %cid = |CID_{ ls_inspec-InspectionLot }_{ sy-tabix }|
                                       Inspectionlot = ls_inspec-InspectionLot
                                       Inspectiondate = ls_inspec-InspLotCreatedOnLocalDate
                                       Baseunit = ls_head-Baseunit
                                       Inspectionlotqty = ls_inspec-InspectionLotQuantity
                                       Inspectionlottype = ls_inspec-InspectionLotType
                                       Materialdocument = ls_inspec-MaterialDocument
                                       Materialdocumentitem = ls_inspec-MaterialDocumentItem
                                       Materialdocumentyear = ls_inspec-MaterialDocumentYear ) )
                                    ) )
                          REPORTED reported
                          fAILED failed
                          MAPPED mapped.
ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Inspection DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Inspection RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR inspection RESULT result.

    METHODS createresult FOR MODIFY
      keys FOR ACTION inspection~createresult RESULT result.

    METHODS getspecificaton FOR MODIFY
      keys FOR ACTION inspection~getspecificaton RESULT result.

    METHODS updateresult FOR MODIFY
      keys FOR ACTION inspection~updateresult RESULT result.

    METHODS updateud FOR MODIFY
      keys FOR ACTION inspection~updateud RESULT result.
    METHODS postinvoice FOR MODIFY
      keys FOR ACTION inspection~postinvoice RESULT result.

ENDCLASS.

CLASS lhc_Inspection IMPLEMENTATION.

  METHOD get_instance_features.

******************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY Inspection
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
******************************************************************
        result = VALUE #( for ls_key in keys
                     ( %tky = ls_key-%tky

                     %update = COND #( WHEN ls_head-Usagedecisioncode  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )
                     %action = VALUE #( Createresult = COND #( WHEN ls_head-Createindicator  is not INITIAL
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                                       updateresult = COND #(
                                                when ls_head-Updateindicator is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                WHEN ls_head-Createindicator is NOT INITIAL
                                                then if_abap_behv=>fc-o-enabled
                                                ELSE if_abap_behv=>fc-o-disabled )

                                       UpdateUD = COND #( WHEN ls_head-Udcodeindicator is not INITIAL
                                                            then if_abap_behv=>fc-o-disabled
                                                          when ls_head-Createindicator is not INITIAL
                                                                and ls_head-Updateindicator is NOT INITIAL
                                                then if_abap_behv=>fc-o-enabled
                                                ELSE if_abap_behv=>fc-o-disabled )

                                       PostInvoice = COND #( when ( ls_head-Postinvoiceflag is not INITIAL or ls_head-Totalamt is INITIAL )
                                                then if_abap_behv=>fc-o-disabled
                                                WHEN ( ls_head-Createindicator is INITIAL and ls_head-Updateindicator is INITIAL
                                                            and ls_head-Udcodeindicator is INITIAL )
                                                            then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )

                                       GetSpecificaton = COND #( when ls_head-Usagedecisioncode  is not INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                when ls_head-Getspindicator = 'X'
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )


                                            )


                                         ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD Createresult.
*****************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY Inspection
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY Inspection BY \_InspKPI
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).

            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY POHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_po).

*****************************************************************************

            data(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
*****************************************************************************
            sort lt_inspresult ASCENDING BY Boocharacteristic.

            if lt_inspresult is not INITIAL.

            MODIFY ENTITIES OF i_inspectionlottp_2
            FORWARDING PRIVILEGED
            ENTITY InspectionCharacteristic
            CREATE BY \_InspectionResult
                FIELDS ( inspectionresultstatus  )

            WITH VALUE #(
                          FOR ls_inspresult IN lt_inspresult INDEX INTO lv_index
                          (
                            InspectionLot               = ls_inspresult-InspectionLot
                            InspPlanOperationInternalID = ls_inspresult-BoOperationID
                            InspectionCharacteristic    = ls_inspresult-BooCharacteristic

                        %target = VALUE #(
                                          (
                            %cid = |CID{ lv_index }|
                            InspectionLot               = ls_inspresult-InspectionLot
                            InspPlanOperationInternalID = ls_inspresult-BoOperationID
                            InspectionCharacteristic    = ls_inspresult-BooCharacteristic
                            inspectionresultstatus  = '2'
                          )
                            )
                          )
                        )
            FAILED   DATA(ls_failed)
            MAPPED   DATA(ls_mapped)
            REPORTED DATA(ls_reported).


            if ls_mapped-inspectionresult is NOT INITIAL.


                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                UPDATE
                FIELDS ( Createindicator )
                WITH VALUE #( for key in keys
                             ( %tky = ls_head-%tky
                             Createindicator = 'X'
                             %control-Createindicator = if_abap_behv=>mk-on

                             ) ).

            data(lv_success_msg) = |created successfully.|.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-inspection.

            ENDIF.

"------------------------------------------------------------
" Forward standard SAP error message to custom RAP application
"------------------------------------------------------------
            LOOP AT ls_reported-inspectioncharacteristic
             ASSIGNING FIELD-SYMBOL(<ls_std_msg>).

              APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = <ls_std_msg>-%msg
              ) TO reported-inspection.

            ENDLOOP.


"------------------------------------------------------------
" Mark custom RAP instance as failed
"------------------------------------------------------------
            IF ls_failed-inspectioncharacteristic IS NOT INITIAL.

              APPEND VALUE #(
                    %tky = ls_head-%tky
                  ) TO failed-inspection.

            ENDIF.
"------------------------------------------------------------

              ENDIF.
*******************************************************************
    result = VALUE #( FOR ls_hd IN lt_insphead
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************
  ENDMETHOD.

  METHOD GetSpecificaton.
******************************************************************************
        READ ENTITIES OF zqm_i_po IN LOCAL MODE
        ENTITY POHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
        ENTITY Inspection
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_inspe)
        FAILED DATA(lt_failed).

******************************************************************************
        DATA(ls_head) = VALUE #( lt_head[ 1 ]  OPTIONAL ).
******************************************************************************
            SELECT SINGLE uuid,purchaseorder,purchaseorderitem from ZQM_APP01_DB WITH PRIVILEGED ACCESS
            WHERE purchaseorder = @ls_head-Purchaseorder
            and purchaseorderitem = @ls_head-Purchaseorderitem
            INTO @DATA(ls_po).

            if ls_po is NOT INITIAL.
                SELECT boocharacteristic,plangroup,boocharacteristicversion,
                        booperationid,inspunit,inspectionspecid,inspectionspeplant,
                        masteric,specification,insptargetvalue,insplowerlimit,
                        inspupperlimit,inspresultmeanvalue,inspresultoriginalvalue,amtvalue
                FROM ZQM_MIC_DB WITH PRIVILEGED ACCESS
                WHERE uuid = @ls_po-uuid
                INto TABLE @DATA(lt_kpi).

                SORT lt_kpi ASCENDING BY boocharacteristic.

            ENDIF.
******************************************************************************
            LOOP AT lt_inspe ASSIGNING FIELD-SYMBOL(<ls_inspe>).
            if <ls_inspe> is ASSIGNED.

                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                CREATE BY \_InspKPI
                AUTO FILL CID
                FIELDS ( Plangroup Boocharacteristic Boocharacteristicversion Booperationid
                         Inspunit inspectionspecid inspectionspeplant masteric specification
                         insptargetvalue insplowerlimit inspupperlimit inspresultmeanvalue
                         inspresultoriginalvalue amtvalue  )

                WITH VALUE #( for gs_inspe in lt_inspe
                                (  %is_draft = gs_inspe-%is_draft
                                    %key =  CORRESPONDING #( gs_inspe )

                                   %target = VALUE #( for ls_kpi in lt_kpi
                                    ( %cid = |CID_{ ls_kpi-boocharacteristic }|

                                       Plangroup = ls_kpi-plangroup
                                       Boocharacteristic = ls_kpi-boocharacteristic
                                       Boocharacteristicversion = ls_kpi-boocharacteristicversion
                                       Booperationid = ls_kpi-booperationid
                                       Inspunit = ls_kpi-inspunit
                                       inspectionspecid = ls_kpi-inspectionspecid
                                       inspectionspeplant = ls_kpi-inspectionspeplant
                                       masteric = ls_kpi-masteric
                                       specification = ls_kpi-specification
                                       insptargetvalue = ls_kpi-insptargetvalue
                                       insplowerlimit = ls_kpi-insplowerlimit
                                       inspupperlimit = ls_kpi-inspupperlimit
                                       inspresultmeanvalue = ls_kpi-inspresultmeanvalue
                                       inspresultoriginalvalue = ls_kpi-inspresultoriginalvalue
                                       amtvalue = ls_kpi-amtvalue ) )
                                    ) )

                          REPORTED reported
                          fAILED failed
                          MAPPED mapped.

            ENDIF.
            ENDLOOP.

            if mapped-inspspecif is NOT INITIAL.

                data(ls_inhd) = VALUE #( lt_inspe[ 1 ] OPTIONAL ).

                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                UPDATE
                FIELDS ( Getspindicator )
                WITH VALUE #( for key in keys
                             ( %tky = ls_inhd-%tky
                             Getspindicator = 'X'
                             %control-updateindicator = if_abap_behv=>mk-on

                             ) ).

            data(lv_success_msg) = |Updated successfully.|.
              APPEND VALUE #(
                %tky = ls_inhd-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-inspection .


            ENDIF.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_inspe
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD updateresult.
*****************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY Inspection
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY Inspection BY \_InspKPI
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************
            DATA(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
*****************************************************************************
            sort lt_inspresult ASCENDING BY Boocharacteristic.

            if lt_inspresult is NOT INITIAL.

            MODIFY ENTITY i_inspectionresulttp_2
              UPDATE
              FIELDS (
                        InspectionResultStatus
                        InspectionResultMeanValue
                        InspectionValuationResult
                        InspectionResultHasMeanValue
                        InspectionResultOriginalValue
                        InspResultValidValuesNumber
                      )
              WITH VALUE #(
                          FOR ls_inspresult IN lt_inspresult
                            (
                          inspectionlot               = ls_inspresult-Inspectionlot
                          inspplanoperationinternalid = ls_inspresult-Booperationid
                          inspectioncharacteristic    = ls_inspresult-Boocharacteristic
                          InspectionResultStatus      = '5'
                          InspectionResultMeanValue   = ls_inspresult-Inspresultmeanvalue
                          InspectionResultOriginalValue = ls_inspresult-Inspresultoriginalvalue
                          InspectionValuationResult   = 'A'

                          InspResultValidValuesNumber = '1'
                          InspectionResultHasMeanValue = 'X'
                        )
                      )
              MAPPED DATA(gs_mapped)
              FAILED   DATA(gs_failed)
              REPORTED DATA(gs_reported).

              if gs_failed-inspectionresult is INITIAL.
                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                UPDATE
                FIELDS ( updateindicator )
                WITH VALUE #( for key in keys
                             ( %tky = ls_head-%tky
                             updateindicator = 'X'
                             %control-updateindicator = if_abap_behv=>mk-on

                             ) ).

            data(lv_success_msg) = |Result Updated successfully.|.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-inspection .
              ENDIF.
            ENDIF.

"------------------------------------------------------------
" Forward standard SAP error message to custom RAP application
"------------------------------------------------------------
            LOOP AT gs_reported-inspectionresult
             ASSIGNING FIELD-SYMBOL(<ls_std_msg>).

              APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = <ls_std_msg>-%msg
              ) TO reported-inspection.

            ENDLOOP.


"------------------------------------------------------------
" Mark custom RAP instance as failed
"------------------------------------------------------------
            IF gs_failed-inspectionresult IS NOT INITIAL.

              APPEND VALUE #(
                    %tky = ls_head-%tky
                  ) TO failed-inspection.

            ENDIF.
"------------------------------------------------------------

*******************************************************************
    result = VALUE #( FOR ls_hd IN lt_insphead
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************

  ENDMETHOD.

  METHOD UpdateUD.
*****************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY Inspection
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY Inspection BY \_InspKPI
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY POHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_po).

            DATA(ls_po) = VALUE #( lt_po[ 1 ] OPTIONAL ).

            DATA(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
*******************************************************************
            select SINGLE value_low,text FROM ZQM_UD_VH WITH PRIVILEGED ACCESS
            where value_low = @gs_keys-%param-Usagedecisioncode
            INTO @DATA(ls_ud).

            LOOP at lt_insphead ASSIGNING FIELD-SYMBOL(<ls_insphead>).
            if <ls_insphead> is ASSIGNED.

                MODIFY ENTITY I_InspectionLotTP_2
                  EXECUTE RecordUsageDecision
                  FROM VALUE #(
                      ( %key-inspectionlot = <ls_insphead>-Inspectionlot
                        %param-selectedcodesetplant = ls_po-Plant
                        %param-%control-selectedcodesetplant = if_abap_behv=>mk-on
                        %param-insplotusgedcsnselectedset = 'ZUD01'
                        %param-%control-insplotusgedcsnselectedset = if_abap_behv=>mk-on
                        %param-insplotusagedecisioncodegroup = 'ZUD01'
                        %param-%control-insplotusagedecisioncodegroup = if_abap_behv=>mk-on
                        %param-inspectionlotusagedecisioncode = gs_keys-%param-Usagedecisioncode
                        %param-%control-inspectionlotusagedecisioncode = if_abap_behv=>mk-on
*                        %param-insplotiscompletionforced = 'X'
*                        %param-%control-insplotiscompletionforced = if_abap_behv=>mk-on
                        )
                      )
              RESULT   DATA(ls_result)
              FAILED   DATA(ls_failed)
              REPORTED DATA(ls_reported).


              if ls_result is not INITIAL.
                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                UPDATE
                FIELDS ( Udcodeindicator Usagedecisioncode Usagedecisiontext )
                WITH VALUE #( for key in keys
                             ( %tky = ls_head-%tky
                             Udcodeindicator = 'X'
                             Usagedecisioncode = gs_keys-%param-Usagedecisioncode
                             usagedecisiontext = ls_ud-text
                             %control-Udcodeindicator = if_abap_behv=>mk-on
                             %control-Usagedecisioncode = if_abap_behv=>mk-on
                             %control-Usagedecisiontext = if_abap_behv=>mk-on
                             ) ).

            data(lv_success_msg) = |Usage Decision Completed.|.
              APPEND VALUE #(
                %tky = ls_head-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-inspection .
              ENDIF.

            ENDIF.
"------------------------------------------------------------
" Forward standard SAP error message to custom RAP application
"------------------------------------------------------------
            LOOP AT ls_reported-inspectionlot
             ASSIGNING FIELD-SYMBOL(<ls_std_msg>).

              APPEND VALUE #(
                        %tky = ls_head-%tky
                        %msg = <ls_std_msg>-%msg
              ) TO reported-inspection.

            ENDLOOP.


"------------------------------------------------------------
" Mark custom RAP instance as failed
"------------------------------------------------------------
            IF ls_failed-inspectionlot IS NOT INITIAL.

              APPEND VALUE #(
                    %tky = ls_head-%tky
                  ) TO failed-inspection.

            ENDIF.
"------------------------------------------------------------

            ENDLOOP.
*******************************************************************
    result = VALUE #( FOR ls_hd IN lt_insphead
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************
  ENDMETHOD.

  METHOD PostInvoice.
*********************************************************************
                READ ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY POHead
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT FINAL(lt_po)
                FAILED FINAL(lt_failed).
*********************************************************************
                READ ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT FINAL(lt_Inpes)
                FAILED FINAL(lt_failed1).
**************************************************************************
            DATA(ls_po) = VALUE #( lt_po[ 1 ] OPTIONAL ).
            DATA(ls_Inspe) = VALUE #( lt_Inpes[ 1 ] OPTIONAL ).
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).

**************************************************************************
            data: lv_json type STANDARD TABLE OF string,
                  lv_url type string,
                  lv_auth type string,
                  lv_message_err type string,
                  lv_invoice    TYPE belnr_d,
                  lv_fiscalyear TYPE gjahr.
**************************************************************************
          DATA: lt_items      TYPE STANDARD TABLE OF string,
                lv_item_str   TYPE string,
                lv_items_json TYPE string.
         DATA lv_post_isodate TYPE string.
         DATA lv_docu_isodate TYPE string.
         DATA lv_amt TYPE I_PurchaseOrderItemAPI01-NetAmount.
         DATA lv_toamt TYPE I_PurchaseOrderItemAPI01-NetAmount.
***************************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date1) TIME DATA(lv_time).

                if ls_po-Taxcode is NOT INITIAL.

*                    select single * from ZQM_PO_TAX WITH PRIVILEGED ACCESS
*                    where PurchaseOrder = @ls_po-Purchaseorder
*                    and PurchaseOrderItem = @ls_po-Purchaseorderitem
*                    into @DATA(ls_taxamt).
**                lv_amt = ls_po-Totalamt + ls_taxamt-IGSTAmount + ls_taxamt-CGSTAmount + ls_taxamt-SGSTAmount.
                  case ls_po-Taxcode.
                        when '1C'.
                            lv_amt = ( ls_Inspe-Totalamt * 18 ) / 100.
                        when '1A'.
                            lv_amt = ( ls_Inspe-Totalamt * 5 ) / 100.
                        when '1B'.
                            lv_amt = ( ls_Inspe-Totalamt * 12 ) / 100.
                        when '1H'.
                            lv_amt = ( ls_Inspe-Totalamt * 18 ) / 100.
                        when '1F'.
                            lv_amt = ( ls_Inspe-Totalamt * 5 ) / 100.
                        when '1G'.
                            lv_amt = ( ls_Inspe-Totalamt * 12 ) / 100.
                        when others.
                            lv_amt = '0.00'.

                   ENDCASE.

*                  lv_amt =
                ENDIF.

                lv_toamt = ls_Inspe-Totalamt + lv_amt.

                lv_docu_isodate = |{ lv_date1 DATE = ISO }|.
                lv_post_isodate = |{ gs_keys-%param-PostingDate DATE = ISO }|.
                data(lv_suppitem) = '1'.
                data(lv_subDebitCredit) = 'X'.
                data(lv_busplace) = '2100'.
                data(tax) = 'true'.
                data(lv_sts) = 'A'.
***************************************************************************
                if ls_po-Taxcode is not INITIAL.
                    data(taxcode) = ls_po-Taxcode.
                ELSE.
                    taxcode = '10'.
                ENDIF.
***************************************************************************
                if ls_po-Paymentterms is not INITIAL.
                data(lv_pay) = ls_po-Paymentterms.
                ELSE.
                lv_pay = '0001'.
                ENDIF.
***************************************************************************

            data(ls_json) = '{ "CompanyCode": "' && ls_po-Companycode &&
                    '","DocumentDate": "' && lv_docu_isodate &&
                    'T00:00","PostingDate": "' && lv_post_isodate &&
                    'T00:00' &&
                    '","DocumentCurrency": "' && ls_po-Documentcurrency &&
                    '","InvoiceGrossAmount": "' && lv_toamt &&
                    '","InvoicingParty": "' && ls_po-Suppllier &&
                    '","SupplierInvoiceIDByInvcgParty": "' && gs_keys-%param-Reference &&
                    '","BusinessPlace": "' && lv_busplace &&
                    '","PaymentTerms": "' && lv_pay &&
                    '","SupplierInvoiceStatus": "' && lv_sts &&
                    '","TaxIsCalculatedAutomatically": ' && tax &&
                    ',"TaxDeterminationDate": "' && lv_post_isodate &&
                    'T00:00' &&
                    '","SupplierInvoiceIsCreditMemo": "' && lv_subDebitCredit &&
                    '","to_SuplrInvcItemPurOrdRef": { ' &&
                '"results": [ ' &&
                        ' { ' &&
                            ' "SupplierInvoiceItem": "' && lv_suppitem &&
                            '","PurchaseOrder": "' && ls_po-Purchaseorder &&
                            '","PurchaseOrderItem": "' && ls_po-Purchaseorderitem &&
                            '","ReferenceDocument": "' && ls_Inspe-Materialdocument &&
                            '","ReferenceDocumentFiscalYear": "' && ls_Inspe-Materialdocumentyear &&
                            '","ReferenceDocumentItem": "' && ls_Inspe-Materialdocumentitem &&
                            '","IsSubsequentDebitCredit": "' && lv_subDebitCredit &&
                            '","DocumentCurrency": "' && ls_po-Documentcurrency &&
                            '","SupplierInvoiceItemAmount": "' && ls_Inspe-Totalamt &&
                            '","QuantityInPurchaseOrderUnit": "' && ls_Inspe-Inspectionlotqty &&
                            '","PurchaseOrderQuantityUnit": "' && ls_po-Baseunit &&
                            '","TaxCode": "' && taxcode &&
                        '" }' &&
                            ']' &&
                        '}' &&
                    '}'.

***************************************************************************
TRY.
          CONSTANTS lc_dev TYPE string VALUE 'https://my437525-api.s4hana.cloud.sap/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice'.
          CONSTANTS lc_qas TYPE string VALUE 'https://my425571-api.s4hana.cloud.sap/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice'.
          CONSTANTS lc_prd TYPE string VALUE 'https://my437194-api.s4hana.cloud.sap/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice'.
***************************************************************************
            try.
                DATA(system_url) = cl_abap_context_info=>get_system_url( ).
                catch CX_ABAP_CONTEXT_INFO_ERROR  INTO DATA(lx_erro1).
                 DATA(lv_err1) = lx_erro1->get_text( ).
            endtry.
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

***********************************************************************
            DATA(lo_regex) = cl_abap_regex=>create_pcre( pattern = '<message[^>]*>([^<]*)</message>' ).

            FIND REGEX lo_regex
             IN lv_response
             SUBMATCHES lv_message_err.


            if lv_message_err is not INITIAL.

             APPEND VALUE #( %tky = ls_Inspe-%tky )
                 TO failed-inspection.

              APPEND VALUE #(
                %tky = ls_Inspe-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                          text     = lv_message_err
                       )
              ) TO reported-inspection .

            endif.
************************************************************************

            FIND FIRST OCCURRENCE OF PCRE
                `SupplierInvoice='([^']+)',FiscalYear='([^']+)'`
            IN lv_response
            SUBMATCHES lv_invoice lv_fiscalyear.
************************************************************************

            if lv_invoice is not INITIAL and lv_fiscalyear is NOT INITIAL.

                MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                ENTITY Inspection
                UPDATE
                FIELDS ( Supplierinvoice Fiscalyear Postinvoiceflag
                          Reference Postingdate )
                WITH VALUE #( for key in keys
                             ( %tky = ls_Inspe-%tky
                             Supplierinvoice = lv_invoice
                             Fiscalyear = lv_fiscalyear
                             Reference = gs_keys-%param-Reference
                             Postingdate = gs_keys-%param-PostingDate
                             Postinvoiceflag = 'X'
                             %control-Supplierinvoice = if_abap_behv=>mk-on
                             %control-Fiscalyear = if_abap_behv=>mk-on
                             %control-Postinvoiceflag = if_abap_behv=>mk-on
                             %control-Reference = if_abap_behv=>mk-on
                             %control-Postingdate = if_abap_behv=>mk-on
                             ) ).

            data(lv_success_msg) = |Park Invoice-{ lv_invoice } created successfully.|.
              APPEND VALUE #(
                %tky = ls_Inspe-%tky
                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                          text     = lv_success_msg
                       )
              ) TO reported-inspection .

            ENDIF.

    CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(lv_check).
          DATA(lv_error) = lv_check.
ENDTRY.
*************************************************************************
    result = VALUE #( FOR ls_ord IN lt_inpes
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

ENDCLASS.

CLASS lhc_InspSpecif DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR InspSpecif RESULT result.
    METHODS update FOR DETERMINE ON MODIFY
      keys FOR inspspecif~update.

ENDCLASS.

CLASS lhc_InspSpecif IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD Update.
*****************************************************************************
            DATA : lv_value type i,
                   lv_value1 TYPE p DECIMALS 2,
                   lv_text   TYPE string,
                   lv_amt TYPE ZQM_SLAB_DB-fromslabamt,
                   lv_final type ZQM_MIC_DB-amtvalue.
*****************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY POHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_po).

            DATA(ls_po) = VALUE #( lt_po[ 1 ] OPTIONAL ).

            if ls_po-Purchaseorder is NOT INITIAL.
                    SELECT SINGLE uuid,purchaseorder,purchaseorderitem
                            FROM zqm_app01_db WITH PRIVILEGED ACCESS
                            WHERE purchaseorder = @ls_po-Purchaseorder
                            and purchaseorderitem = @ls_po-Purchaseorderitem
                            INTO @DATA(ls_1stapp).
            ENDIF.
*****************************************************************************
            READ ENTITIES OF zqm_i_po IN LOCAL MODE
            ENTITY Inspection
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_insphead)
            ENTITY InspSpecif
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_inspresult)
            FAILED DATA(lt_failed).
*****************************************************************************

            data(ls_head) = VALUE #( lt_insphead[ 1 ] OPTIONAL ).
            sort lt_inspresult ASCENDING BY Boocharacteristic.

            loop AT lt_inspresult ASSIGNING FIELD-SYMBOL(<ls_result>).
            if <ls_result> is ASSIGNED.

                    if <ls_result>-Inspresultmeanvalue is not INITIAL.

                            lv_value = TRUNC( <ls_result>-Inspresultmeanvalue * 1000 ).
                            lv_value1 = ( lv_value / 1000 ).
                            lv_amt = lv_value1.
                            lv_text = |{ lv_value1 DECIMALS = 2 }|.

                            IF lv_text CP '*.00'.
                                REPLACE FIRST OCCURRENCE OF '.00' IN lv_text WITH ''.
                            ENDIF.
*****************************************************************************
                    if lv_amt is not INITIAL.

                    select single * from @lt_inspresult as res
                    left outer join ZQM_SLAB_DB as h on @ls_1stapp-Uuid = h~uuid
                                and res~plangroup = h~plangroup
                                and res~boocharacteristic = h~boocharacteristic
                                and @lv_amt between h~toslabamt and h~fromslabamt
                    where res~Uuid = @<ls_result>-Uuid
                    and res~plangroup = @<ls_result>-Plangroup
                    and res~boocharacteristic = @<ls_result>-Boocharacteristic
                    and h~minusplus = 'Minus'
                    into @DATA(ls_slab).

                    if ls_slab-h is INITIAL.

                    select single * from @lt_inspresult as res
                    left outer join ZQM_SLAB_DB as h on @ls_1stapp-Uuid = h~uuid
                                and res~plangroup = h~plangroup
                                and res~boocharacteristic = h~boocharacteristic
                    and @lv_amt between  h~fromslabamt and h~toslabamt
                    where res~Uuid = @<ls_result>-Uuid
                    and res~plangroup = @<ls_result>-Plangroup
                    and res~boocharacteristic = @<ls_result>-Boocharacteristic
                    and h~minusplus = 'Plus'
                    into @ls_slab.
                    ENDif.

                            if ls_slab-h is not INITIAL.
                            lv_final = ls_po-Orderquantity * ls_slab-h-amountnew.
                            ENDIF.

                    ENDIF.
*****************************************************************************
                    if lv_text is NOT INITIAL.

                    MODIFY ENTITIES OF zqm_i_po IN LOCAL MODE
                    ENTITY InspSpecif
                    UPDATE
                    FIELDS ( Inspresultoriginalvalue Amtvalue )
                    WITH VALUE #( for key in keys
                                ( %tky = <ls_result>-%tky
                                   Inspresultoriginalvalue = lv_text
                                   Amtvalue = lv_final
                                   %control-Inspresultoriginalvalue = if_abap_behv=>mk-on
                                   %control-Amtvalue = if_abap_behv=>mk-on
                                   ) ).

                    ENDIF.
                    CLear lv_final.
                    ENDIF.
            ENDIF.
*****************************************************************************
            ENDLOOP.

  ENDMETHOD.

ENDCLASS.
