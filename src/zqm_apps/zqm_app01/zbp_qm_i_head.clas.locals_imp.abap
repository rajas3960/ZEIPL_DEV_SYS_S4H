CLASS lhc_QMHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR QMHeader RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR QMHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR QMHeader RESULT result.

    METHODS GetMIC FOR MODIFY
      IMPORTING keys FOR ACTION QMHeader~GetMIC RESULT result.
    METHODS AddPO FOR DETERMINE ON SAVE
      IMPORTING keys FOR QMHeader~AddPO.
    METHODS POValid FOR VALIDATE ON SAVE
      IMPORTING keys FOR QMHeader~POValid.
    METHODS UpInsp FOR MODIFY
      IMPORTING keys FOR ACTION QMHeader~UpInsp RESULT result.

ENDCLASS.

CLASS lhc_QMHeader IMPLEMENTATION.

  METHOD get_instance_features.

*********************************************************************
                READ ENTITIES OF zqm_i_head IN LOCAL MODE
                ENTITY QMHeader
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(lt_head)
                FAILED DATA(lt_failed).

**********************************************************************
        data(gs_head) =   VALUE #( lt_head[ 1 ] OPTIONAL ).
**********************************************************************
        result = VALUE #( for ls_keys in keys
                        ( %tky = ls_keys-%tky

                        %action = VALUE #( GetMIC = COND #( WHEN gs_head-Material is INITIAL
                                                then if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )
                                                 ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GetMIC.
*********************************************************************
            data: lc_mic TYPE ZQM_MIC_DB.

            READ ENTITIES OF zqm_i_head IN LOCAL MODE
            ENTITY QMHeader
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY QMHeader by \_ItemMIC
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_mic)
            FAILED DATA(lt_failed).
*********************************************************************

            data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
            if <ls_head> is ASSIGNED.
*********************************************************************
                    SELECT * from zinspection_plan WITH PRIVILEGED ACCESS
                    where Material = @<ls_head>-Material
                    and Plant = @<ls_head>-Plant
                    into table @DATA(lt_insplan).
*********************************************************************
            sort lt_insplan  ASCENDING BY BOOCharacteristic.
*********************************************************************
                    SELECT * FROM ZQM_MIC_DB WITH PRIVILEGED ACCESS
                    WHERE uuid = @ls_head-Uuid
                    INTO TABLE @DATA(lt_table).

            if lt_insplan is not INITIAL AND lt_table is INITIAL.

                    MODIFY ENTITIES OF zqm_i_head IN LOCAL MODE
                    ENTITY QMHeader
                    CREATE BY \_ItemMIC
                    AUTO FILL CID
                    FIELDS ( Plangroup Boocharacteristic Masteric Booperationid
                             Inspunit Inspectionspecid Inspectionspeplant Boocharacteristicversion
                             Insptargetvalue Insplowerlimit Inspupperlimit Inspectionlot )
                    WITH VALUE #( for gs_head in lt_head
                                   (  %is_draft = gs_head-%is_draft
                                      %key = CORRESPONDING #( gs_head )
                                      %target = VALUE #( for ls_mic in lt_insplan
                                      ( %cid = |CID{ ls_mic-BOOCharacteristic }|
                                      Plangroup = ls_mic-InspectionPlanGroup
                                      Inspectionlot = <ls_head>-Inspectionlot
                                      Boocharacteristic = ls_mic-BOOCharacteristic
                                      Boocharacteristicversion = ls_mic-BOOCharacteristicVersion
                                      Booperationid = ls_mic-BOOOperationInternalID
                                      Inspunit = ls_mic-InspectionSpecificationUnit
                                      Inspectionspecid = ls_mic-InspectionSpecification
                                      Inspectionspeplant = ls_mic-InspectionSpecificationPlant
                                      Insptargetvalue = ls_mic-InspSpecTargetValue
                                      Insplowerlimit = ls_mic-InspSpecLowerLimit
                                      Inspupperlimit = ls_mic-InspSpecUpperLimit
                                      Masteric = ls_mic-kpi
                                       ) ) ) )
                    REPORTED reported
                    fAILED failed
                    MAPPED mapped.
            ELSEIF lt_insplan is not INITIAL AND lt_table is not INITIAL.

                LOOP AT lt_insplan INTO DATA(ls_insplan).

                  READ TABLE lt_table
                    WITH KEY plangroup = ls_insplan-InspectionPlanGroup
                             boocharacteristic = ls_insplan-BOOCharacteristic
                             boocharacteristicversion = ls_insplan-BOOCharacteristicVersion
                    TRANSPORTING NO FIELDS.

                  IF sy-subrc <> 0.

                    MODIFY ENTITIES OF zqm_i_head IN LOCAL MODE
                    ENTITY QMHeader
                    CREATE BY \_ItemMIC
                    AUTO FILL CID
                    FIELDS ( Plangroup Boocharacteristic Masteric Booperationid
                             Inspunit Inspectionspecid Inspectionspeplant Boocharacteristicversion
                             Insptargetvalue Insplowerlimit Inspupperlimit Inspectionlot )
                    WITH VALUE #( for gs_head in lt_head

                                   (  %is_draft = gs_head-%is_draft
                                      %key = CORRESPONDING #( gs_head )

                                      %target = VALUE #(
                                      ( %cid = |CID{ ls_insplan-BOOCharacteristic }|
                                      Plangroup = ls_insplan-InspectionPlanGroup
                                      Inspectionlot = <ls_head>-Inspectionlot
                                      Boocharacteristic = ls_insplan-BOOCharacteristic
                                      Boocharacteristicversion = ls_insplan-BOOCharacteristicVersion
                                      Booperationid = ls_insplan-BOOOperationInternalID
                                      Inspunit = ls_insplan-InspectionSpecificationUnit
                                      Inspectionspecid = ls_insplan-InspectionSpecification
                                      Inspectionspeplant = ls_insplan-InspectionSpecificationPlant
                                      Insptargetvalue = ls_insplan-InspSpecTargetValue
                                      Insplowerlimit = ls_insplan-InspSpecLowerLimit
                                      Inspupperlimit = ls_insplan-InspSpecUpperLimit
                                      Masteric = ls_insplan-kpi
                                       ) ) ) )
                    REPORTED reported
                    fAILED failed
                    MAPPED mapped.

                  ENDIF.

                    ENDLOOP.

            else.

              data(lv_msg) = |Create the Inspection plan group|.
              APPEND VALUE #( %tky = ls_head-%tky ) TO failed-qmheader.
              APPEND VALUE #( %tky = ls_head-%tky
              %state_area = 'Validate_Head'
              %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = lv_msg )
                               ) TO reported-qmheader.
            endif.

            endif.
            endloop.
*********************************************************************
    result = VALUE #( FOR ls_hd IN lt_head
                         ( %tky   = ls_hd-%tky
                           %param = ls_hd ) ).

*********************************************************************

  ENDMETHOD.

  METHOD AddPO.
***************************************************************************
DATA: lv_text TYPE string VALUE '>60.1%',
      lv_num  TYPE string.
      lv_num = lv_text.
REPLACE ALL OCCURRENCES OF PCRE '[^0-9.]' IN lv_text WITH ''.

***************************************************************************
            READ ENTITIES OF zqm_i_head IN LOCAL MODE
            ENTITY QMHeader
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

                    select single InspectionLot,InspLotCreatedOnLocalDate,
                                  PurchasingDocument,PurchasingDocumentItem,
                                  InspectionLotQuantity,InspectionLotType,MaterialDocument,
                                  MaterialDocumentYear,MaterialDocumentItem
                                  from I_InspectionLot WITH PRIVILEGED ACCESS
                                  where PurchasingDocument = @<ls_head>-Purchaseorder
                                  and PurchasingDocumentItem = @<ls_head>-Purchaseorderitem
                                  into @Data(wa_insp).

                    select single CompanyCodeName from I_CompanyCode WITH PRIVILEGED ACCESS
                    where CompanyCode = @wa_poitem-CompanyCode
                    into @data(wa_ccname).

                    select single PlantName from I_Plant WITH PRIVILEGED ACCESS
                    where Plant = @wa_poitem-Plant
                    into @data(wa_plname).


           if wa_poitem is not INITIAL.

                    MODIFY ENTITIES OF zqm_i_head IN LOCAL MODE
                    ENTITY QMHeader
                    UPDATE
                    FIELDS ( Orderdate Companycode Plant Baseunit
                             Orderquantity Documentcurrency Netamount
                             Material Materialdes Inspectionlot Inspectiondate
                             Inspectionlotqty Inspectionlottype Materialdocument
                             Materialdocumentitem Materialdocumentyear Companycodename
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
                                    Inspectionlot = wa_insp-InspectionLot
                                    Inspectiondate = wa_insp-InspLotCreatedOnLocalDate
                                    Inspectionlotqty = wa_insp-InspectionLotQuantity
                                    Inspectionlottype = wa_insp-InspectionLotType
                                    Materialdocument = wa_insp-MaterialDocument
                                    Materialdocumentitem = wa_insp-MaterialDocumentItem
                                    Materialdocumentyear = wa_insp-MaterialDocumentYear
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
                                    %control-Inspectionlot = if_abap_behv=>mk-on
                                    %control-Inspectiondate = if_abap_behv=>mk-on
                                    %control-Inspectionlotqty = if_abap_behv=>mk-on
                                    %control-Inspectionlottype = if_abap_behv=>mk-on
                                    %control-Materialdocument = if_abap_behv=>mk-on
                                    %control-Materialdocumentitem = if_abap_behv=>mk-on
                                    %control-Materialdocumentyear = if_abap_behv=>mk-on
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

  METHOD POValid.

****************************************************************************
            READ ENTITIES OF zqm_i_head IN LOCAL MODE
            ENTITY QMHeader
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

            data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
****************************************************************************

             select single purchaseorder,purchaseorderitem from zqm_app01_db WITH PRIVILEGED ACCESS
             where purchaseorder = @ls_head-Purchaseorder
             and purchaseorderitem = @ls_head-Purchaseorderitem
             into @data(wa_valid).

             if wa_valid-purchaseorder is not INITIAL and wa_valid-purchaseorderitem is not INITIAL.

                data(lv_msg) = |This Purchase already created-{ ls_head-Purchaseorder }|.
                apPEND value #( %tky = ls_head-%tky )
                    to failed-qmheader.
                APPEND VALUE #( %tky = ls_head-%tky
                                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                text = lv_msg )
                                %element-Purchaseorder = if_abap_behv=>mk-on )
                                to reported-qmheader.
             ENDIF.
****************************************************************************
  ENDMETHOD.

  METHOD UpInsp.
*****************************************************************************
*
*            READ ENTITIES OF zqm_i_head IN LOCAL MODE
*            ENTITY QMHeader
*            ALL FIELDS WITH CORRESPONDING #( keys )
*            RESULT FINAL(lt_head)
*            FAILED FINAL(lt_failed).
*
****************************************************************************
*
*            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
*            if <ls_head> is ASSIGNED.
*
*                    select single InspectionLot,InspLotCreatedOnLocalDate,
*                                  PurchasingDocument,PurchasingDocumentItem,
*                                  InspectionLotQuantity,InspectionLotType,MaterialDocument,
*                                  MaterialDocumentYear,MaterialDocumentItem
*                                  from I_InspectionLot WITH PRIVILEGED ACCESS
*                                  where PurchasingDocument = @<ls_head>-Purchaseorder
*                                  and PurchasingDocumentItem = @<ls_head>-Purchaseorderitem
*                                  into @Data(wa_insp).
*
*           if wa_insp is not INITIAL.
*
*                    MODIFY ENTITIES OF zqm_i_head IN LOCAL MODE
*                    ENTITY QMHeader
*                    UPDATE
*                    FIELDS ( Inspectionlot Inspectiondate
*                             Inspectionlotqty Inspectionlottype Materialdocument
*                             Materialdocumentitem Materialdocumentyear )
*                    WITH VALUE #( for key in keys
*                                    ( %tky = <ls_head>-%tky
*                                    Inspectionlot = wa_insp-InspectionLot
*                                    Inspectiondate = wa_insp-InspLotCreatedOnLocalDate
*                                    Inspectionlotqty = wa_insp-InspectionLotQuantity
*                                    Inspectionlottype = wa_insp-InspectionLotType
*                                    Materialdocument = wa_insp-MaterialDocument
*                                    Materialdocumentitem = wa_insp-MaterialDocumentItem
*                                    Materialdocumentyear = wa_insp-MaterialDocumentYear
*
*                                    %control-Inspectionlot = if_abap_behv=>mk-on
*                                    %control-Inspectiondate = if_abap_behv=>mk-on
*                                    %control-Inspectionlotqty = if_abap_behv=>mk-on
*                                    %control-Inspectionlottype = if_abap_behv=>mk-on
*                                    %control-Materialdocument = if_abap_behv=>mk-on
*                                    %control-Materialdocumentitem = if_abap_behv=>mk-on
*                                    %control-Materialdocumentyear = if_abap_behv=>mk-on
*                                    ) ).
*
*           endif.
*            endif.
*            endloop.
**********************************************************************
*    result = VALUE #( FOR ls_hd IN lt_head
*                         ( %tky   = ls_hd-%tky
*                           %param = ls_hd ) ).
*
**********************************************************************

  ENDMETHOD.

ENDCLASS.

CLASS lhc_QMMic DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR QMMic RESULT result.

ENDCLASS.

CLASS lhc_QMMic IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_QMSlab DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR QMSlab RESULT result.
    METHODS addslno FOR DETERMINE ON MODIFY
      IMPORTING keys FOR qmslab~addslno.
    METHODS amtcal FOR DETERMINE ON MODIFY
      IMPORTING keys FOR qmslab~amtcal.

ENDCLASS.

CLASS lhc_QMSlab IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD AddSlno.
******************************************************************************
            data: ls_slno type zqm_slab_db-slabno,
                  gt_slap type table of zqm_slab_db,
                  gs_slap type zqm_slab_db,
                  lv_count type n LENGTH 2,
                  lv_res TYPE ZQM_SLAB_DB-minusplus.
******************************************************************************

            READ ENTITIES OF zqm_i_head IN LOCAL MODE
            ENTITY QMHeader
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT data(lt_head)
*            ENTITY QMHeader BY \_ItemMIC
            ENTITY QMMic
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_mic)
            ENTITY QMMic by \_ItemSlab
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_slab)
            FAILED DATA(lt_failed).
******************************************************************************
            data(ls_head) = value #( lt_head[ 1 ] OPTIONAL ).
            DATA(ls_mic) = VALUE #( lt_mic[ 1 ] OPTIONAL ).

            if ls_mic-Specification is not INITIAL.
                data(lv_spch) = ls_mic-Specification+0(1).
            ENDIF.
            CONDENSE lv_spch.
                CASE lv_spch.
                      WHEN '>'.
                        lv_res = 'Minus'.
                      WHEN '<'.
                        lv_res = 'Plus'.
                      WHEN OTHERS.
                        lv_res = ''.
                ENDCASE.

******************************************************************************
            sort lt_slab ASCENDING BY Slabno.
            lv_count = lines( lt_slab ).

            loop at lt_slab ASSIGNING FIELD-SYMBOL(<ls_slab>).
                if <ls_slab> is ASSIGNED.

                    if <ls_slab>-Slabno is INITIAL.

                            MODIFY ENTITIES OF zqm_i_head IN LOCAL MODE
                            ENTITY QMSlab
                            UPDATE
                            FIELDS ( Slabno Poqtyuom Fromuom Touom Currency Minusplus Debitcreditindicator )
                            WITH VALUE #( for key in keys
                                        ( %tky = <ls_slab>-%tky
                                        Slabno = lv_count
                                        Poqtyuom = ls_head-Baseunit
                                        Fromuom = ls_mic-Inspunit
                                        Touom = ls_mic-Inspunit
                                        Currency = ls_head-Documentcurrency
                                        Minusplus = lv_res
                                        Debitcreditindicator = 'D'
                                        %control-Slabno = if_abap_behv=>mk-on
                                        %control-Poqtyuom = if_abap_behv=>mk-on
                                        %control-Fromuom = if_abap_behv=>mk-on
                                        %control-Touom = if_abap_behv=>mk-on
                                        %control-Currency = if_abap_behv=>mk-on
                                        %control-Minusplus = if_abap_behv=>mk-on
                                        %control-Debitcreditindicator = if_abap_behv=>mk-on
                                        ) ).
                    endif.

                endIF.
            endloop.
  ENDMETHOD.

  METHOD AmtCal.
******************************************************************************
            data: lv_fromslabamt TYPE zqm_slab_db-fromslabamt,
                  lv_toslabamt TYPE zqm_slab_db-toslabamt.
******************************************************************************
            READ ENTITIES OF zqm_i_head IN LOCAL MODE
            ENTITY QMHeader
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT data(lt_head)
            ENTITY QMHeader BY \_ItemMIC
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_mic)
            ENTITY QMMic by \_ItemSlab
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_slab)
            FAILED DATA(lt_failed).
******************************************************************************
            data(ls_head) = value #( lt_head[ 1 ] OPTIONAL ).
******************************************************************************
            DATA: lv_text TYPE string,
                lv_num  TYPE string.

            sort lt_mic ASCENDING BY Boocharacteristic.

            LOOP AT lt_slab ASSIGNING FIELD-SYMBOL(<ls_slab>).
            if <ls_slab> is ASSIGNED.

              ASSIGN lt_mic[ key entity
                            Uuid = <ls_slab>-Uuid
                            Boocharacteristic = <ls_slab>-Boocharacteristic ]
                            TO FIELD-SYMBOL(<ls_mic>).
              IF <ls_mic> IS ASSIGNED.
                data(lv_spamt) = <ls_mic>-Specification.
                REPLACE ALL OCCURRENCES OF PCRE '[^0-9.]' IN lv_spamt WITH ''.
                CONDENSE lv_spamt.
              ENDIF.

              if <ls_slab>-Fromslab is not INITIAL.
                data(lv_slabfrom) = <ls_slab>-Fromslab.
                REPLACE ALL OCCURRENCES OF PCRE '[^0-9.]' IN lv_slabfrom WITH ''.
                CONDENSE lv_slabfrom.
              endif.

              if <ls_slab>-Toslab is not INITIAL.
                data(lv_slabto) = <ls_slab>-Toslab.
                REPLACE ALL OCCURRENCES OF PCRE '[^0-9.]' IN lv_slabto WITH ''.
                CONDENSE lv_slabto.
              endif.

            if ( <ls_slab>-Minusplus = 'Minus' and ( lv_slabfrom is not INITIAL or lv_slabto is not INITIAL ) ) .
                lv_fromslabamt = lv_spamt - lv_slabfrom.
                lv_toslabamt =  lv_spamt - lv_slabto.

            ENDIF.

            if ( <ls_slab>-Minusplus = 'Plus' and ( lv_slabfrom is not INITIAL or lv_slabto is not INITIAL ) ) .
                lv_fromslabamt = lv_spamt + lv_slabfrom.
                lv_toslabamt =  lv_spamt + lv_slabto.

            ENDIF.


            if <ls_slab>-Fromslab is NOT INITIAL and <ls_slab>-Toslab is NOT INITIAL.

*                    if ( lv_fromslabamt is NOT INITIAL or lv_toslabamt is not INITIAL ).


*                    <ls_slab>-Fromslabamt = lv_fromslabamt.
*                    <ls_slab>-Toslabamt = lv_toslabamt.
                            MODIFY ENTITIES OF zqm_i_head IN LOCAL MODE
                            ENTITY QMSlab UPDATE

                            FIELDS ( Fromslabamt Toslabamt )
                            WITH VALUE #(
                                        ( %tky = <ls_slab>-%tky
                                        Fromslabamt = lv_fromslabamt
                                        Toslabamt = lv_toslabamt
                                        %control-Fromslabamt = if_abap_behv=>mk-on
                                        %control-Toslabamt = if_abap_behv=>mk-on
                                        ) ).

                    endif.
            ENDIF.
            ENDLOOP.

            data(lv_test) = lt_slab[].

  ENDMETHOD.

ENDCLASS.
