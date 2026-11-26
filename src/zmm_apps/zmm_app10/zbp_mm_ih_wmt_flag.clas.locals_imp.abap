CLASS lhc_weighFlag DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR weighFlag RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR weighFlag RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR weighFlag RESULT result.
    METHODS update FOR DETERMINE ON SAVE
      keys FOR weighFlag~update.

ENDCLASS.

CLASS lhc_weighFlag IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD update.
***********************************************************************
        READ ENTITIES OF zmm_ih_wmt_flag IN LOCAL MODE
        ENTITY weighFlag
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
        FAILED DATA(lt_failed).
***********************************************************************
            loop at lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
                if <ls_head> is ASSIGNED.

                select single value_low,text from  ZMMGATE_SERIES_VH with PRIVILEGED ACCESS
                where value_low = @<ls_head>-Gateentryseries
                into @DATA(gs_gateentryseries).

                select single * from  ZMM_MATGROUP_VH with PRIVILEGED ACCESS
                where Materialgroup = @<ls_head>-Materialgroup
                into @DATA(gs_grouptext).

***********************************************************************
                MODIFY ENTITIES OF zmm_ih_wmt_flag IN LOCAL MODE
                ENTITY weighFlag
                UPDATE
                FIELDS ( Materialgroupdes Gateentryseriesdes )
                WITH VALUE #(  for key in keys
                               ( %tky = <ls_head>-%tky
                                 Materialgroupdes = gs_grouptext-MaterialGroupName
                                 Gateentryseriesdes = gs_gateentryseries-text

                                %control-Materialgroupdes = if_abap_behv=>mk-on
                                %control-Gateentryseriesdes = if_abap_behv=>mk-on

                                 ) ).
************************************************************************
                endif.
            ENDLOOP.
************************************************************************

  ENDMETHOD.

ENDCLASS.
