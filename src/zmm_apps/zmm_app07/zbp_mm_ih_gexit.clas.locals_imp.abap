CLASS lhc_GateExitHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateExitHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateExitHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR GateExitHead RESULT result.

    METHODS GateExit FOR MODIFY
      IMPORTING keys FOR ACTION GateExitHead~GateExit RESULT result.
    METHODS ImageVald FOR MODIFY
      IMPORTING keys FOR ACTION GateExitHead~ImageVald RESULT result.

ENDCLASS.

CLASS lhc_GateExitHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zmm_ih_gexit IN LOCAL MODE
            ENTITY GateExitHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

******************************************************************
            result = VALUE #( for ls_key in keys
                     ( %tky = ls_key-%tky

                     %action = VALUE #( GateExit = COND #(
                                            WHEN ls_head-Gateexitindicator  = 'X'
                                            then if_abap_behv=>fc-o-disabled
                                            WHEN  ls_head-Exitindicator = 'X'
                                            THEN if_abap_behv=>fc-o-enabled
                                            ELSE if_abap_behv=>fc-o-disabled
                                            )
                                        ImageVald = COND #( WHEN ls_head-Exitindicator = 'X'
                                                     then if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled )
                                             ) ) ).
******************************************************************
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GateExit.
***********************************************************************
            READ ENTITIES OF zmm_ih_gexit IN LOCAL MODE
            ENTITY GateExitHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_gatehd)
            FAILED FINAL(lt_failed).
***********************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
            LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
            IF <ls_hd> is ASSIGNED.

                    MODIFY ENTITIES OF zmm_ih_gexit IN LOCAL MODE
                    ENTITY GateExitHead
                    UPDATE
                    FIELDS ( Gateexitdate Gateexittime Gateexitindicator )
                        WITH VALUE #( for key in keys
                                   (   %tky = <ls_hd>-%tky
                                    Gateexitindicator = 'X'
                                    Gateexitdate = lv_date
                                    Gateexittime = lv_time

                                    %control-Gateexitindicator = if_abap_behv=>mk-on
                                    %control-Gateexitdate = if_abap_behv=>mk-on
                                    %control-Gateexittime = if_abap_behv=>mk-on
                                    )  ).
            ENDIF.
            ENDLOOP.
************************************************************************
    result = VALUE #( FOR ls_ord IN lt_gatehd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD ImageVald.
***********************************************************************
            READ ENTITIES OF zmm_ih_gexit IN LOCAL MODE
            ENTITY GateExitHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_gatehd)
            FAILED FINAL(lt_failed).

***********************************************************************
            LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
            IF <ls_hd> is ASSIGNED.

                    MODIFY ENTITIES OF zmm_ih_gexit IN LOCAL MODE
                    ENTITY GateExitHead
                    UPDATE
                    FIELDS ( Exitindicator )
                        WITH VALUE #( for key in keys
                                   (   %tky = <ls_hd>-%tky
                                    Exitindicator = 'X'

                                    %control-Exitindicator = if_abap_behv=>mk-on

                                    )  ).
            ENDIF.
            ENDLOOP.
************************************************************************
    result = VALUE #( FOR ls_ord IN lt_gatehd
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateExitItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateExitItem RESULT result.

ENDCLASS.

CLASS lhc_GateExitItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
