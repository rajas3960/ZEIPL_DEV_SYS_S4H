CLASS lhc_ExitHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ExitHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ExitHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ExitHead RESULT result.

    METHODS GateExit FOR MODIFY
      IMPORTING keys FOR ACTION ExitHead~GateExit RESULT result.

    METHODS ImageVald FOR MODIFY
      IMPORTING keys FOR ACTION ExitHead~ImageVald RESULT result.

ENDCLASS.

CLASS lhc_ExitHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zsd_ih_gexit IN LOCAL MODE
            ENTITY ExitHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

******************************************************************
            result = VALUE #( for ls_key in keys
                     ( %tky = ls_key-%tky

                     %action = VALUE #( GateExit = COND #( WHEN ls_head-Exitindic  = 'X'
                                            then if_abap_behv=>fc-o-disabled
                                            WHEN  ls_head-Imagevalid = 'X'
                                            THEN if_abap_behv=>fc-o-enabled
                                            ELSE if_abap_behv=>fc-o-disabled
                                            )
                                        ImageVald = COND #( WHEN ls_head-Imagevalid = 'X'
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
            READ ENTITIES OF zsd_ih_gexit IN LOCAL MODE
            ENTITY ExitHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_gatehd)
            FAILED FINAL(lt_failed).
***********************************************************************
    GET TIME STAMP FIELD Data(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
            LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
            IF <ls_hd> is ASSIGNED.

                    MODIFY ENTITIES OF zsd_ih_gexit IN LOCAL MODE
                    ENTITY ExitHead
                    UPDATE
                    FIELDS ( Gateexitdate Gateexittime Exitindic )
                        WITH VALUE #( for key in keys
                                   (   %tky = <ls_hd>-%tky
                                    Exitindic = 'X'
                                    Gateexitdate = lv_date
                                    Gateexittime = lv_time

                                    %control-Exitindic = if_abap_behv=>mk-on
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
            READ ENTITIES OF zsd_ih_gexit IN LOCAL MODE
            ENTITY ExitHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_gatehd)
            FAILED FINAL(lt_failed).
***********************************************************************
            LOOP AT lt_gatehd ASSIGNING FIELD-SYMBOL(<ls_hd>).
            IF <ls_hd> is ASSIGNED.

                    MODIFY ENTITIES OF zsd_ih_gexit IN LOCAL MODE
                    ENTITY ExitHead
                    UPDATE
                    FIELDS ( Imagevalid )
                        WITH VALUE #( for key in keys
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

ENDCLASS.

CLASS lhc_ExitItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ExitItem RESULT result.

ENDCLASS.

CLASS lhc_ExitItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
