CLASS lhc_ZSD_LC_APP03_RV DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zsd_lc_app03_rv RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zsd_lc_app03_rv RESULT result.

    METHODS getapp FOR MODIFY
       keys FOR ACTION zsd_lc_app03_rv~getapp RESULT result.

    METHODS getrej FOR MODIFY
       keys FOR ACTION zsd_lc_app03_rv~getrej RESULT result.

ENDCLASS.

CLASS lhc_ZSD_LC_APP03_RV IMPLEMENTATION.

  METHOD get_instance_features.
**********************************************************************
    READ ENTITIES OF zsd_lc_app03_rv IN LOCAL MODE
    ENTITY zsd_lc_app03_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).
**********************************************************************
    result =  VALUE #( FOR ls_data IN Lt_hdr
          (   %tky =  ls_data-%tky
          %action-getapp = COND #( WHEN  ls_data-relstastu IS NOT INITIAL

                                                      THEN if_abap_behv=>fc-o-disabled

                                                      ELSE if_abap_behv=>fc-o-enabled )
          %action-getrej =  COND #( WHEN  ls_data-relstastu IS NOT INITIAL

                                                      THEN if_abap_behv=>fc-o-disabled

                                                      ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD getapp.
**********************************************************************
    DATA : gs_hdr TYPE zlc_app01_tb1.
**********************************************************************
    READ ENTITIES OF zsd_lc_app03_rv IN LOCAL MODE
    ENTITY zsd_lc_app03_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).
    DATA(ls_hdr) = lt_hdr[ 1 ].
**********************************************************************
    IF lt_hdr IS NOT INITIAL.
**********************************************************************


      MOVE-CORRESPONDING  ls_hdr TO gs_hdr.
      gs_hdr-relstastu = 'A'.
      TRY.
          DATA(ls_user) = ''.
          DATA(ls_apdt) = ''.
        CATCH   cx_abap_context_info_error .
          DATA(lv) = 1.
      ENDTRY.
      gs_hdr-approveby = ls_user.
      gs_hdr-approveon = ls_apdt.

      APPEND gs_hdr TO zbp_sd_lc_app03_rv=>gt_hdr.
**********************************************************************

      result = VALUE #(
           FOR ls1 IN lt_hdr (
             %tky   = ls1-%tky
             %param = ls1
           )
         ).

    ENDIF.

  ENDMETHOD.

  METHOD getrej.
**********************************************************************
    DATA : gs_hd TYPE zlc_app01_tb1.
**********************************************************************
    READ ENTITIES OF zsd_lc_app03_rv IN LOCAL MODE
    ENTITY zsd_lc_app03_rv
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).
    DATA(ls_hdr) = lt_hdr[ 1 ].
**********************************************************************
    IF lt_hdr IS NOT INITIAL.
**********************************************************************


      MOVE-CORRESPONDING  ls_hdr TO gs_hd.
      gs_hd-relstastu = 'R'.
      TRY.
          DATA(ls_user) =  cl_abap_context_info=>get_user_business_partner_id(  ).
          DATA(ls_apdt) = cl_abap_context_info=>get_system_date(  ).
        CATCH   cx_abap_context_info_error .
          DATA(lv) = 1.
      ENDTRY.
      gs_hd-approveby = ls_user.
      gs_hd-approveon = ls_apdt.

      APPEND gs_hd TO zbp_sd_lc_app03_rv=>gt_hdr.
**********************************************************************

      result = VALUE #(
           FOR ls1 IN lt_hdr (
             %tky   = ls1-%tky
             %param = ls1
           )
         ).

    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZSD_LC_APP03_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSD_LC_APP03_RV IMPLEMENTATION.

  METHOD save_modified.
  IF zbp_sd_lc_app03_rv=>gt_hdr IS NOT INITIAL.
      MODIFY ZLC_APP01_TB1 FROM TABLE @zbp_sd_lc_app03_rv=>gt_hdr.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
