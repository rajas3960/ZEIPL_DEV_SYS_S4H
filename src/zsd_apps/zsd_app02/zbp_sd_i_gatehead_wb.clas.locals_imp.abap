CLASS lhc_ZSD_I_GATEHEAD_WB DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsd_i_gatehead_wb RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zsd_i_gatehead_wb RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zsd_i_gatehead_wb RESULT result.
    METHODS captureimg FOR MODIFY
      IMPORTING keys FOR ACTION zsd_i_gatehead_wb~captureimg RESULT result.

ENDCLASS.

CLASS lhc_ZSD_I_GATEHEAD_WB IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD CaptureIMG.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEHEAD_WB DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsd_i_sgatehead_wb RESULT result.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEHEAD_WB IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEITEM_WB DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsd_i_sgateitem_wb RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zsd_i_sgateitem_wb RESULT result.

    METHODS firstweight FOR MODIFY
      IMPORTING keys FOR ACTION zsd_i_sgateitem_wb~firstweight RESULT result.

    METHODS secoundweight FOR MODIFY
      IMPORTING keys FOR ACTION zsd_i_sgateitem_wb~secoundweight RESULT result.

ENDCLASS.

CLASS lhc_ZSD_I_SGATEITEM_WB IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD FirstWeight.
  ENDMETHOD.

  METHOD SecoundWeight.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZSD_I_GATEHEAD_WB DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSD_I_GATEHEAD_WB IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
