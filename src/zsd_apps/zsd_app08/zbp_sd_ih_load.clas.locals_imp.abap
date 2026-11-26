CLASS lhc_LoadHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR LoadHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR LoadHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR LoadHead RESULT result.

    METHODS Loadend FOR MODIFY
       keys FOR ACTION LoadHead~Loadend RESULT result.

    METHODS LoadSt FOR MODIFY
       keys FOR ACTION LoadHead~LoadSt RESULT result.

ENDCLASS.

CLASS lhc_LoadHead IMPLEMENTATION.

  METHOD get_instance_features.
******************************************************************
    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
    ENTITY LoadHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    FAILED DATA(lt_failed).

******************************************************************
    DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
******************************************************************
    result = VALUE #( FOR ls_key IN keys
         ( %tky = ls_head-%tky

         %action = VALUE #( loadst = COND #( WHEN ls_head-loadstindi = 'X'
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )

                           loadEnd = COND #( WHEN ls_head-loadendindi = ' ' AND
                                         ls_head-loadstindi = 'X'
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled )
                             ) ) ) .
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD Loadend.
**********************************************************************
    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
    ENTITY LoadHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    FAILED DATA(lt_failed).
**************************************************************************
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**************************************************************************
    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
      IF <ls_head> IS ASSIGNED.

        MODIFY ENTITIES OF zsd_ih_load IN LOCAL MODE
        ENTITY LoadHead
        UPDATE
        FIELDS ( Loadenddate Loadendindi Loadendtime )
        WITH VALUE #(  FOR key IN keys
                       ( %tky = <ls_head>-%tky
                         Loadenddate = lv_date
                         Loadendtime = lv_time
                         Loadendindi = 'X'

                        %control-Loadenddate = if_abap_behv=>mk-on
                        %control-Loadendtime = if_abap_behv=>mk-on
                        %control-Loadendindi = if_abap_behv=>mk-on
                         ) ).

      ENDIF.
    ENDLOOP.
***********************************************************************
    result = VALUE #( FOR ls_ord IN lt_head
                         ( %tky   = ls_ord-%tky
                           %param = ls_ord ) ).
***********************************************************************
  ENDMETHOD.

  METHOD LoadSt.
**********************************************************************
    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
    ENTITY LoadHead
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_head)
    FAILED DATA(lt_failed).
**************************************************************************
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
**************************************************************************
    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
      IF <ls_head> IS ASSIGNED.

        MODIFY ENTITIES OF zsd_ih_load IN LOCAL MODE
        ENTITY LoadHead
        UPDATE
        FIELDS ( loadstdate loadstindi loadsttime Loadendindi )
        WITH VALUE #(  FOR key IN keys
                       ( %tky = <ls_head>-%tky
                         loadstdate = lv_date
                         loadsttime = lv_time
                         loadstindi = 'X'
                         Loadendindi = ' '
                        %control-loadstdate = if_abap_behv=>mk-on
                        %control-loadsttime = if_abap_behv=>mk-on
                        %control-loadstindi = if_abap_behv=>mk-on
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

CLASS lhc_LoadItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR LoadItem RESULT result.
    METHODS imagecount FOR DETERMINE ON MODIFY
      keys FOR loaditem~imagecount.

ENDCLASS.

CLASS lhc_LoadItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD imagecount.

***********************************************************************
            READ ENTITIES OF zsd_ih_load IN LOCAL MODE
            ENTITY LoadHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY LoadItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
***********************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            DATA: lv_count TYPE zsd_app05_idb-itemimagecount.
***********************************************************************
            LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
            if <ls_item> IS ASSIGNED.

            if <ls_item>-Loadcheck = 'X'.
                lv_count = '01'.
            ELSE.
                lv_count = '00'.
            ENDIF.
            MODIFY ENTITIES OF zsd_ih_load IN LOCAL MODE
            ENTITY LoadItem
            UPDATE
            FIELDS ( Itemimagecount )
            WITH VALUE #(  FOR key IN keys
                       ( %tky = <ls_item>-%tky
                         Itemimagecount = lv_count
                        %control-Itemimagecount = if_abap_behv=>mk-on
                         ) ).
            ENDIF.
            ENDLOOP.
***********************************************************************
  ENDMETHOD.

ENDCLASS.
