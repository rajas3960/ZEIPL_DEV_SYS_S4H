CLASS lhc_GateSecEntry DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateSecEntry RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateSecEntry RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR GateSecEntry RESULT result.

    METHODS head_modify FOR DETERMINE ON SAVE
      IMPORTING keys FOR GateSecEntry~head_modify.
    METHODS PRINT FOR MODIFY
      IMPORTING keys FOR ACTION GateSecEntry~PRINT RESULT result.
    METHODS gatenocheck FOR VALIDATE ON SAVE
      IMPORTING keys FOR GateSecEntry~gatenocheck.

ENDCLASS.

CLASS lhc_GateSecEntry IMPLEMENTATION.

  METHOD get_instance_features.
**********************************************************************
            READ ENTITIES OF zmm_i_gentry IN LOCAL MODE
            ENTITY GateSecEntry
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_gatehd)
            FAILED DATA(lt_failed).
**********************************************************************
            DATA(ls_gatehd) = VALUE #( lt_gatehd[ 1 ] OPTIONAL ).

            result = VALUE #( FOR gs_header IN lt_gatehd
                            ( %tky   = gs_header-%tky

                       %field-Minepassno =  COND #( WHEN gs_header-Gateentryseries = 'G1'
                                                                  THEN if_abap_behv=>fc-f-unrestricted
                                                                  ELSE if_abap_behv=>fc-f-read_only )

                       %field-Forestpassno =  COND #( WHEN gs_header-Gateentryseries = 'G1'
                                                                  THEN if_abap_behv=>fc-f-unrestricted
                                                                  ELSE if_abap_behv=>fc-f-read_only )
                        ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD head_modify.
************************************************************************
            data: gateid type zmm_gate_htb-gateentryid,
                  securityremark type zmm_gate_htb-securityremarks,
                  transportid TYPE n LENGTH 10.
***********************************************************************
            READ ENTITIES OF zmm_i_gentry IN LOCAL MODE
            ENTITY GateSecEntry
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head).
***********************************************************************
            data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
************************************************************************
*""""" Gate Master Validation process--*********************************
*
*            select single * from ZMMGATE_NOVH WITH PRIVILEGED ACCESS
*            WHERE Userid = @ls_head-Createdby
*            and Gateno = @ls_head-Gateno
*            into @DATA(gs_gatenouser).
*
*       if gs_gatenouser is NOT INITIAL.
*
************************************************************************

            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
            TRY.
                DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
              CATCH cx_abap_context_info_error.
                DATA(ls_x1) = 1.
            ENDTRY.

            DATA(lv_cbuser) = 'CB' && lv_user.

            select single PersonFullName,UserID from I_BusinessUserBasic WITH PRIVILEGED ACCESS
            where UserID = @lv_cbuser
            into @DATA(lv_username).

            securityremark = |{ lv_cbuser }-{ lv_username-PersonFullName }|.
***********************************************************************

            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
                if <ls_head> is ASSIGNED.

                select single value_low,text from  ZMMGATE_SERIES_VH with PRIVILEGED ACCESS
                where value_low = @<ls_head>-Gateentryseries
                into @DATA(gs_gateentryseries).

                select single Gateno,Gatenodes from  ZMMGATE_NOVH with PRIVILEGED ACCESS
                where Gateno = @<ls_head>-Gateno
                into @DATA(gs_gateenno).

                if <ls_head>-Trasporterid is not INITIAL.
                    transportid = <ls_head>-Trasporterid.
                    SELECT SINGLE * FROM ZMM_BP_ZTRP_VH WITH PRIVILEGED ACCESS
                    WHERE Transporterid = @transportid
                    INTO @DATA(ls_traname).
                ENDIF.

***********************************************************************
                SELECT SINGLE MAX( gateentryid ) AS gateentryid
                FROM ZMM_APP04_HDB
                INTO @DATA(gs_id).

                if gs_id is not INITIAL.
                gateid = gs_id + 1.
                 else.
                gateid = '2000000001'.
                endif.

************************************************************************
                MODIFY ENTITIES OF zmm_i_gentry IN LOCAL MODE
                ENTITY GateSecEntry
                UPDATE
                FIELDS ( Gateentryid Gateentryiddate  Gateentryseriesdes
                         Gatenodes Securityremarks Createdname Trasportername )
                WITH VALUE #(  for key in keys
                               ( %tky = <ls_head>-%tky
                                 Gateentryid = gateid
                                 Gateentryiddate = lv_date
                                 Gateentryseriesdes = gs_gateentryseries-text
                                 Gatenodes = gs_gateenno-Gatenodes
                                 Securityremarks = securityremark
                                 Createdname = lv_username-PersonFullName
                                 Trasportername = ls_traname-Transportername

                                %control-Gateentryid = if_abap_behv=>mk-on
                                %control-Gateentryiddate = if_abap_behv=>mk-on
                                %control-Gateentryseriesdes = if_abap_behv=>mk-on
                                %control-Gatenodes = if_abap_behv=>mk-on
                                %control-Securityremarks = if_abap_behv=>mk-on
                                %control-Createdname = if_abap_behv=>mk-on
                                %control-Trasportername = if_abap_behv=>mk-on
                                 ) ).
************************************************************************
                endif.
            ENDLOOP.
************************************************************************

*        ELSE.
*
*          APPEND VALUE #( %tky = ls_head-%tky ) to failed-gatesecentry..
*          APPEND VALUE #( %tky = ls_head-%tky
*          %state_area    = 'Validate_Header'
*          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                        text = 'Gate No User Auth not Maintained' )
*                                        ) to reported-gatesecentry.
*        ENDIF.
*************************************************************************
  ENDMETHOD.

  METHOD PRINT.
  ENDMETHOD.

  METHOD gatenocheck.
*************************************************************************
                READ ENTITIES OF zmm_i_gentry IN LOCAL MODE
                ENTITY GateSecEntry
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(lt_head)
                FAILED DATA(lt_failed).
***********************************************************************
            data(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
************************************************************************
*""""" Gate Master Validation process--*********************************

            select single * from ZMMGATE_NOVH WITH PRIVILEGED ACCESS
            WHERE Userid = @ls_head-Createdby
            and Gateno = @ls_head-Gateno
            into @DATA(gs_gatenouser).

       if gs_gatenouser is INITIAL.

        DATA(lv_msgs) = |Gate No User Auth not Maintained|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgs ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Vehicleno is INITIAL.

        DATA(lv_msgvn) = |Vehicle Number is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgvn ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
*       ELSEIF ls_head-Vehicleno is not INITIAL.
*                SELECT SINGLE uuid,vehicleno,Gateexitindicator FROM zmm_app04_hdb WITH PRIVILEGED ACCESS
*                WHERE vehicleno = @ls_head-Vehicleno
*                AND gateexitindicator is INITIAL
*                INTO @DATA(ls_vehicle).
*              if ls_vehicle-gateexitindicator is INITIAL.
*
*                DATA(lv_msgvs) = |Vehicle Still in the Plant|.
*                APPEND VALUE #( %tky        = ls_head-%tky
*                        %state_area = 'Validate_Head'
*                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                             text     = lv_msgvs ) )
*                 TO reported-gatesecentry.
*
*                APPEND VALUE #( %tky = ls_head-%tky )
*                TO failed-gatesecentry.

*              ENDIF.
       ENDIF.
************************************************************************
       if ls_head-Vehicletype is INITIAL.

        DATA(lv_msgVt) = |Vehicle Type is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgVt ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Trasporterid is INITIAL.

        DATA(lv_msgTid) = |Transport ID is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgTid ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Licenseno is INITIAL.

        DATA(lv_msgTli) = |License No is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgTli ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Engineno is INITIAL.

        DATA(lv_msgTEgn) = |Engine Number is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgTEgn ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************

  ENDMETHOD.


ENDCLASS.
