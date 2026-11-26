CLASS lhc__hdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _hdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR _hdr RESULT result.

ENDCLASS.

CLASS lhc__hdr IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lhc__litem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _litem RESULT result.

    METHODS Gtdata1 FOR DETERMINE ON SAVE
      IMPORTING keys FOR _litem~Gtdata1.

    METHODS Gtdata2 FOR DETERMINE ON SAVE
      IMPORTING keys FOR _litem~Gtdata2.
    METHODS validateLcAmount FOR VALIDATE ON SAVE
       keys FOR _litem~validateLcAmount.

ENDCLASS.

CLASS lhc__litem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD Gtdata1.
    DATA : lt_crtdata TYPE TABLE OF zlc_app02_idb,
           ls_crtdata TYPE zlc_app02_idb.

    READ ENTITIES OF zlc_app02_rv IN LOCAL MODE
     ENTITY _hdr
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_hdr)
     ENTITY _hdr BY \_litem
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_lcdata).

    DATA(ls_hdr) = lt_hdr[ 1 ].
    DATA(ls_lcdata) = lt_lcdata[ 1 ].

    ls_crtdata-Salesdocument = ls_hdr-SalesDocument.
    SELECT SINGLE MAX( srno ) FROM zlc_app02_idb  WHERE salesdocument = @ls_lcdata-Salesdocument INTO @DATA(wa_line).
    IF wa_line IS NOT INITIAL.
      ls_crtdata-srno = wa_line + 1.
    ELSE.
      ls_crtdata-srno = 1.
    ENDIF.
    ls_crtdata-lcnum = ls_lcdata-Lcnum.
    ls_crtdata-lcamount = ls_lcdata-Lcamount.
    ls_crtdata-lcurr = 'INR'.
    ls_crtdata-createdby = ls_lcdata-Createdby.
    ls_crtdata-createdon = ls_lcdata-Createdon.
    ls_crtdata-lastchangedbyuser = ls_lcdata-Lastchangedbyuser.
    ls_crtdata-lastchangedatetime = ls_lcdata-Lastchangedatetime.

    APPEND ls_crtdata TO lt_crtdata.

    zbp_lc_app02_rv=>gt_crtdata = lt_crtdata.

  ENDMETHOD.

  METHOD Gtdata2.
  ENDMETHOD.

  METHOD validateLcAmount.
**********************************************************************
    READ ENTITIES OF zlc_app02_rv IN LOCAL MODE
      ENTITY _litem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_lcdata).

    LOOP AT lt_lcdata ASSIGNING FIELD-SYMBOL(<ls_lcdata>).

      SELECT SINGLE
        FROM zlc_app02_f4 WITH PRIVILEGED ACCESS
        FIELDS lnum,
               lccurr,
               lcamt
        WHERE lnum = @<ls_lcdata>-lcnum
        INTO @DATA(ls_f4).
*
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.

      IF <ls_lcdata>-lcamount > ls_f4-lcamt.

        "Block SAVE
        APPEND VALUE #(
          %tky = <ls_lcdata>-%tky
        ) TO failed-_litem.

        "Display ERROR message
        APPEND VALUE #(
          %tky = <ls_lcdata>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |LC Amount cannot be greater than available amount.|
          )
        ) TO reported-_litem.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZLC_APP02_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZLC_APP02_RV IMPLEMENTATION.

  METHOD save_modified.
    IF create-_litem IS NOT INITIAL.
      IF zbp_lc_app02_rv=>gt_crtdata IS NOT INITIAL.
        MODIFY zlc_app02_idb FROM TABLE @zbp_lc_app02_rv=>gt_crtdata.
      ENDIF.
    ENDIF.



*    IF update-_litem IS NOT INITIAL.
*      IF zbp_lc_app02_rv=>gt_uptdata IS NOT INITIAL.
*        MODIFY zlc_app02_idb FROM TABLE @zbp_lc_app02_rv=>gt_uptdata.
*      ENDIF.
*    ENDIF.
    IF update-_litem IS NOT INITIAL.

      LOOP AT update-_litem INTO DATA(ls_update).

        DATA(ls_db) = VALUE zlc_app02_idb( ).

        "Read existing database record using key
        SELECT SINGLE *
          FROM zlc_app02_idb
          WHERE salesdocument = @ls_update-salesdocument
            AND srno          = @ls_update-srno
          INTO @ls_db.

        IF sy-subrc = 0.

          "Copy changed values from RAP update structure
          MOVE-CORRESPONDING ls_update TO ls_db.

          "Update database
          MODIFY zlc_app02_idb FROM @ls_db.

        ENDIF.

      ENDLOOP.

    ENDIF.



    IF delete-_litem IS NOT INITIAL.
      LOOP AT delete-_litem INTO DATA(ls_gipentry).
        DELETE FROM zlc_app02_idb WHERE salesdocument = @ls_gipentry-Salesdocument AND srno = @ls_gipentry-Srno.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
