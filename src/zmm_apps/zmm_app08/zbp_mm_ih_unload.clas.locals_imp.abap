CLASS lhc_UnloadHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR UnloadHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR UnloadHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR UnloadHead RESULT result.

    METHODS UnloadEnd FOR MODIFY
      IMPORTING keys FOR ACTION UnloadHead~UnloadEnd RESULT result.

    METHODS Unloadst FOR MODIFY
      IMPORTING keys FOR ACTION UnloadHead~Unloadst RESULT result.

ENDCLASS.

CLASS lhc_UnloadHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
            READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
            ENTITY UnloadHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY UnloadHead BY \_Item
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).

******************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
******************************************************************
                result = VALUE #( for ls_key in lt_item
                     ( %tky = ls_head-%tky

                     %action = VALUE #( Unloadst = COND #( when ls_head-Unloadstindi = 'X'
                                            then if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )

                                       UnloadEnd = COND #( WHEN ls_head-Unloadendindi = 'X'
                                                then if_abap_behv=>fc-o-disabled
                                                when ls_head-Unloadstindi = 'X'
                                                    AND ls_key-Unloadind = abap_true
                                                then if_abap_behv=>fc-o-enabled
                                                ELSE if_abap_behv=>fc-o-disabled )
                                         ) ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD UnloadEnd.
**********************************************************************
        READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
        ENTITY UnloadHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
        FAILED DATA(lt_failed).
**************************************************************************
            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**************************************************************************
            LOOP at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
            if <ls_head> is ASSIGNED.

                MODIFY ENTITIES OF zmm_ih_unload IN LOCAL MODE
                ENTITY UnloadHead
                UPDATE
                FIELDS ( Unloadenddate Unloadendtime Unloadendindi )
                WITH VALUE #(  for key in keys
                               ( %tky = <ls_head>-%tky
                                 Unloadenddate = lv_date
                                 Unloadendtime = lv_time
                                 Unloadendindi = 'X'

                                %control-Unloadenddate = if_abap_behv=>mk-on
                                %control-Unloadendtime = if_abap_behv=>mk-on
                                %control-Unloadendindi = if_abap_behv=>mk-on
                                 ) ).

            ENDIF.
            ENDLOOP.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

  METHOD Unloadst.
**********************************************************************
        READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
        ENTITY UnloadHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
        FAILED DATA(lt_failed).
**************************************************************************
            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**************************************************************************
            LOOP at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
            if <ls_head> is ASSIGNED.

                MODIFY ENTITIES OF zmm_ih_unload IN LOCAL MODE
                ENTITY UnloadHead
                UPDATE
                FIELDS ( Unloadstdate Unloadstindi Unloadsttime )
                WITH VALUE #(  for key in keys
                               ( %tky = <ls_head>-%tky
                                 Unloadstdate = lv_date
                                 Unloadsttime = lv_time
                                 Unloadstindi = 'X'

                                %control-Unloadstdate = if_abap_behv=>mk-on
                                %control-Unloadsttime = if_abap_behv=>mk-on
                                %control-Unloadstindi = if_abap_behv=>mk-on
                                 ) ).

            ENDIF.
            ENDLOOP.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************

  ENDMETHOD.

ENDCLASS.

CLASS lhc_UnloadItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR UnloadItem RESULT result.
    METHODS imagecount FOR DETERMINE ON MODIFY
      keys FOR unloaditem~imagecount.

ENDCLASS.

CLASS lhc_UnloadItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD imagecount.
***********************************************************************
            READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
            ENTITY UnloadHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY UnloadItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
***********************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA: lv_count TYPE zmm_app04_idb-lineimagecount.
***********************************************************************
            LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
            if <ls_item> IS ASSIGNED.

            if <ls_item>-Unloadind = 'X'.
                lv_count = '01'.
            ELSE.
                lv_count = '00'.
            ENDIF.
            MODIFY ENTITIES OF zmm_ih_unload IN LOCAL MODE
            ENTITY UnloadItem
            UPDATE
            FIELDS ( Lineimagecount )
            WITH VALUE #(  FOR key IN keys
                       ( %tky = <ls_item>-%tky
                         Lineimagecount = lv_count
                        %control-Lineimagecount = if_abap_behv=>mk-on
                         ) ).
            ENDIF.
            ENDLOOP.
***********************************************************************

  ENDMETHOD.

ENDCLASS.
