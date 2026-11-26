CLASS lhc__item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS fill_ldata FOR DETERMINE ON SAVE
      IMPORTING keys FOR _item~fill_ldata.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR _item RESULT result.

ENDCLASS.

CLASS lhc__item IMPLEMENTATION.

  METHOD fill_ldata.

    DATA: lt_linedata TYPE TABLE OF zsd_apps08_idb,
          ls_linedata TYPE zsd_apps08_idb.

    READ ENTITIES OF zsd_apps08_rv IN LOCAL MODE
      ENTITY hdr
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr)

      ENTITY hdr BY \_item
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_line).

    READ TABLE lt_hdr INTO DATA(ls_hdr) INDEX 1.
    READ TABLE lt_line INTO DATA(ls_line) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE brokerid,
                  MAX( srno ) AS srno
      FROM zsd_apps08_idb
      WHERE brokerid = @ls_hdr-brokerid
      GROUP BY brokerid
      INTO @DATA(ls_tab).

    IF ls_tab IS INITIAL.
      ls_linedata-srno = 1.
    ELSE.
      ls_linedata-srno = ls_tab-srno + 1.
    ENDIF.

    ls_linedata-brokerid  = ls_hdr-brokerid.
    ls_linedata-partnerid = ls_line-partnerid.
    ls_linedata-netamt    = ls_line-netamt.
    ls_linedata-bkcurr    = 'INR'.
    ls_linedata-createdby = ls_line-createdby.
    ls_linedata-createdon = ls_line-createdon.

    APPEND ls_linedata TO lt_linedata.

    zbp_sd_apps08_rv=>gt_lindata = lt_linedata.


  ENDMETHOD.


  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zsd_apps08_rv DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zsd_apps08_rv IMPLEMENTATION.

  METHOD save_modified.

    "Create Header
    IF create-hdr IS NOT INITIAL.

      IF zbp_sd_apps08_rv=>gt_hdrdata IS NOT INITIAL.
        MODIFY zsd_apps08_db
          FROM TABLE @zbp_sd_apps08_rv=>gt_hdrdata.
      ENDIF.

    ENDIF.

*
*    "Create Line Item
*    IF create-_item IS NOT INITIAL.
*
*      IF zbp_sd_apps08_rv=>gt_lindata IS NOT INITIAL.
*        MODIFY zsd_apps08_idb
*          FROM TABLE @zbp_sd_apps08_rv=>gt_lindata.
*      ENDIF.
*
*    ENDIF.
*
*    "Update Line Item
*    IF update-_item IS NOT INITIAL.
*
*      IF zbp_sd_apps08_rv=>gt_lindata IS NOT INITIAL.
*        UPDATE zsd_apps08_idb
*          FROM TABLE @zbp_sd_apps08_rv=>gt_lindata.
*      ENDIF.
*
*    ENDIF.


    "Create Line Item
    IF create-_item IS NOT INITIAL.

      IF zbp_sd_apps08_rv=>gt_lindata IS NOT INITIAL.
        MODIFY zsd_apps08_idb
          FROM TABLE @zbp_sd_apps08_rv=>gt_lindata.
      ENDIF.

    ENDIF.

    "Update Line Item
    IF update-_item IS NOT INITIAL.

      LOOP AT update-_item ASSIGNING FIELD-SYMBOL(<ls_update>).

        UPDATE zsd_apps08_idb
          SET netamt = @<ls_update>-netamt
          WHERE brokerid = @<ls_update>-brokerid
            AND srno     = @<ls_update>-srno.

      ENDLOOP.

    ENDIF.


    "Delete Header
    IF delete-hdr IS NOT INITIAL.

      LOOP AT delete-hdr INTO DATA(ls_hdr_delete).

        DELETE FROM zsd_apps08_db
          WHERE brokerid = @ls_hdr_delete-brokerid.

        DELETE FROM zsd_apps08_idb
          WHERE brokerid = @ls_hdr_delete-brokerid.

      ENDLOOP.

    ENDIF.


    "Delete Line Item
    IF delete-_item IS NOT INITIAL.

      LOOP AT delete-_item ASSIGNING FIELD-SYMBOL(<ls_delete>).

        DELETE FROM zsd_apps08_idb
          WHERE srno     = @<ls_delete>-srno
            AND brokerid = @<ls_delete>-brokerid.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_hdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR hdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR hdr RESULT result.
    METHODS fill_hdata FOR DETERMINE ON SAVE
      IMPORTING keys FOR hdr~fill_hdata.

ENDCLASS.

CLASS lhc_hdr IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD fill_hdata.

    DATA: lt_hdrdata TYPE TABLE OF zsd_apps08_db,
          ls_hdrdata TYPE zsd_apps08_db.

    READ ENTITIES OF zsd_apps08_rv IN LOCAL MODE
      ENTITY hdr
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    READ TABLE lt_hdr INTO DATA(ls_hdr) INDEX 1.

    IF sy-subrc = 0.

      ls_hdrdata-brokerid  = ls_hdr-brokerid.
      ls_hdrdata-brokername = ls_hdr-brokername.
      ls_hdrdata-fromdt    = ls_hdr-fromdt.
      ls_hdrdata-todate    = ls_hdr-todate.
      ls_hdrdata-netamt    = ls_hdr-netamt.
      ls_hdrdata-bkcurr    = 'INR'.
      ls_hdrdata-createdon = ls_hdr-createdon.
      ls_hdrdata-createdby = ls_hdr-createdby.

      APPEND ls_hdrdata TO lt_hdrdata.

      zbp_sd_apps08_rv=>gt_hdrdata = lt_hdrdata.

    ENDIF.

  ENDMETHOD.


ENDCLASS.
