CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    "!
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR Line RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS fill_hdata FOR DETERMINE ON SAVE
      IMPORTING keys FOR Header~fill_hdata.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

*  METHOD get_instance_features.
*
*  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD fill_hdata.
**********************************************************************
    DATA: lt_hdrdata TYPE TABLE OF zlc_app01_tb1,
          ls_hdrdata TYPE zlc_app01_tb1.
**********************************************************************

    READ ENTITIES OF zlc_app01_rv IN LOCAL MODE
    ENTITY Header
    ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_hdr).
    DATA(ls_hdr) = lt_hdr[ 1 ].
    MOVE-CORRESPONDING ls_hdr TO ls_hdrdata.
    ls_hdrdata-applicant = ls_hdr-Applicant.
    ls_hdrdata-bankbranch = ls_hdr-BankBranch.
    ls_hdrdata-banknam = ls_hdr-Banknam.
    ls_hdrdata-lccurr = 'INR'.
    ls_hdrdata-ldd = ls_hdr-Ldd.
    ls_hdrdata-lnum = ls_hdr-Lnum.
    ls_hdrdata-stp = ls_hdr-Stp.
    ls_hdrdata-stpname = ls_hdr-StpName.
    ls_hdrdata-project = ls_hdr-Project.
    ls_hdrdata-valfrm = ls_hdr-Valfrm.
    ls_hdrdata-stpname = ls_hdr-StpName.
    ls_hdrdata-totalqty = ls_hdr-Totalqty.
    ls_hdrdata-unit = ls_hdr-Unit.
    ls_hdrdata-incoterm = ls_hdr-Incoterm.
    ls_hdrdata-popi = ls_hdr-Popi.
    ls_hdrdata-remark = ls_hdr-Remark.
    ls_hdrdata-beneficiary = ls_hdr-Beneficiary.
    ls_hdrdata-createdby = ls_hdr-Createdby.
    ls_hdrdata-createdon = ls_hdr-Createdon.
    ls_hdrdata-relstastu = ''.

*    TRY.
*        ls_hdrdata-createdby = cl_abap_context_info=>get_user_description(  ).
*      CATCH cx_ro INTO cx.
*        DATA(ls) = 1.
*    ENDTRY.


    APPEND ls_hdrdata TO lt_hdrdata.
    zbp_lc_app01_rv=>gt_hdrdata = lt_hdrdata.


  ENDMETHOD.



ENDCLASS.

CLASS lhc_Line DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS fill_ldata FOR DETERMINE ON SAVE
      IMPORTING keys FOR Line~fill_ldata.

    METHODS updt_ldata FOR DETERMINE ON SAVE
      IMPORTING keys FOR Line~updt_ldata.

ENDCLASS.

CLASS lhc_Line IMPLEMENTATION.

  METHOD fill_ldata.
**********************************************************************
    DATA: lt_linedata TYPE TABLE OF zlc_app01_tb2,
          lt_line2    TYPE TABLE OF zlc_app01_tb2,
          ls_linedata TYPE zlc_app01_tb2,
          lt_hdrupd   TYPE TABLE OF zlc_app01_tb1,
          ls_hdrupd   TYPE zlc_app01_tb1.
**********************************************************************

    READ ENTITIES OF zlc_app01_rv IN LOCAL MODE
    ENTITY Header
    ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_hdr)
    ENTITY Header BY \_Line
    ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_line).
    DATA(ls_hdr) = lt_hdr[ 1 ].
    DATA(ls_line) = lt_line[ 1 ].

**********************************************************************

    SELECT SINGLE lnum, MAX( lcline ) AS lcline FROM zlc_app01_tb2
    WHERE lnum = @ls_hdr-Lnum
    GROUP BY lnum
    INTO @DATA(ls_tab).
    IF ls_tab IS INITIAL.
      ls_linedata-lcline = 1.
    ELSE.
      ls_linedata-lcline = ls_tab-lcline + 1.
    ENDIF.
    ls_linedata-lnum = ls_hdr-Lnum.
    ls_linedata-accbstus = ls_line-Accbstus.
    ls_linedata-boeamt = ls_line-Boeamt.
    ls_linedata-instdebt = ls_line-Instdebt.
    ls_linedata-fright = ls_line-Fright.
    ls_linedata-tboeamt = ls_linedata-boeamt + ls_linedata-fright + ls_linedata-instdebt.
    ls_linedata-boeqty = ls_line-Boeqty.
    ls_linedata-unit  =  ls_line-Unit.
    ls_linedata-boecurr = ls_line-Boecurr.
    ls_linedata-boedt = ls_line-Boedt.
    ls_linedata-boeno = ls_line-Boeno.
    ls_linedata-dudt = ls_line-Dudt.
    ls_linedata-lcamt = ls_line-LcAmt.
    ls_linedata-lccurr = 'INR'.
    ls_linedata-noofdays = ls_line-Noofdays.
    ls_linedata-remark = ls_line-Remark.
    ls_linedata-valfrm = cl_abap_context_info=>get_system_date(  ).
    ls_linedata-valto = ls_line-Valto.
    ls_linedata-createdby = ls_line-Createdby.
    ls_linedata-createdon = ls_line-Createdon.
    ls_linedata-inst = ls_line-Inst.
    IF ls_line-Torlce IS NOT INITIAL AND ls_line-LcAmt IS NOT INITIAL.
      ls_linedata-torlce = ls_line-Torlce.
      ls_linedata-tlcamt = ls_line-lcamt + ( ls_line-lcamt * ls_line-torlce / 100 ).
    ELSEIF ls_line-LcAmt IS NOT INITIAL AND ls_line-Torlce IS INITIAL.
      ls_linedata-tlcamt = ls_line-LcAmt.
    ENDIF.
**********************************************************************





    APPEND ls_linedata TO lt_linedata.

* CLEAR ls_hdrupd.
    MOVE-CORRESPONDING ls_hdr TO ls_hdrupd.
    IF ls_hdrupd-valto < ls_line-valto.
      ls_hdrupd-valto = ls_line-valto.
    ENDIF.
    CLEAR ls_hdrupd-tlcamt.
    ls_hdrupd-tlcamt += ls_linedata-tlcamt.
    ls_hdrupd-planlcamt = ls_hdrupd-tlcamt - ls_hdrupd-aclcamt.  "

    " Step 1: Filter entries where Torlce is not initial
    lt_line2 = VALUE #(
      FOR ls IN lt_line
      WHERE ( torlce IS NOT INITIAL )
      ( CORRESPONDING #( ls ) )
    ).

    " Step 2: Sort by lcnumber and lcline in descending order (latest first)
    SORT lt_line2 BY lnum DESCENDING createdon DESCENDING.

    " Step 3: Read the first entry (latest)
    IF lt_line2 IS NOT INITIAL.
      DATA(ls_line2) = lt_line2[ 1 ].

      " Step 4: Assign torlce value
      IF ls_line2-torlce IS NOT INITIAL.
        ls_hdrupd-torlce = ls_line2-torlce.
      ELSE.
        ls_hdrupd-torlce = 0.
      ENDIF.
    ELSE.
      ls_hdrupd-torlce = 0.
    ENDIF.
    ls_hdrupd-relstastu = ''.


    APPEND ls_hdrupd TO lt_hdrupd.
    zbp_lc_app01_rv=>gt_hdrupd = lt_hdrupd.


    zbp_lc_app01_rv=>gt_lindata = lt_linedata.
**********************************************************************
  ENDMETHOD.

  METHOD updt_ldata.
  ENDMETHOD.

ENDCLASS.

*CLASS lhc__Lineboi DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR _Lineboi RESULT result.
*
*    METHODS boeamt FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR _Lineboi~boeamt.
*
*    METHODS fill_ldata1 FOR DETERMINE ON SAVE
*      IMPORTING keys FOR _Lineboi~fill_ldata1.
*
*    METHODS gt_updt FOR DETERMINE ON SAVE
*      IMPORTING keys FOR _Lineboi~gt_updt.
*
*    METHODS V1_boeamt FOR VALIDATE ON SAVE
*      IMPORTING keys FOR _Lineboi~V1_boeamt.
*
*ENDCLASS.
*
*CLASS lhc__Lineboi IMPLEMENTATION.
*
*  METHOD get_instance_features.
*
*  ENDMETHOD.
*
*  METHOD boeamt.
*    READ ENTITIES OF zlc_app01_rv IN LOCAL MODE
*      ENTITY Header
*      ALL FIELDS WITH CORRESPONDING #( keys )
*              RESULT FINAL(lt_hdr)
*      ENTITY Header BY \_Lineboi
*      ALL FIELDS WITH CORRESPONDING #( keys )
*              RESULT FINAL(lt_line).
*    DATA(ls_hdr) = lt_hdr[ 1 ].
*    DATA(ls_line) = lt_line[ 1 ].
*
*  ENDMETHOD.
*
*  METHOD fill_ldata1.
***********************************************************************
*    DATA: lt_linedata TYPE TABLE OF zlc_app01_tb3,
*          ls_linedata TYPE zlc_app01_tb3,
*          lt_hdrupd   TYPE TABLE OF zlc_app01_tb1,
*          ls_hdrupd   TYPE zlc_app01_tb1.
***********************************************************************
*
*    READ ENTITIES OF zlc_app01_rv IN LOCAL MODE
*       ENTITY Header
*       ALL FIELDS WITH CORRESPONDING #( keys )
*               RESULT FINAL(lt_hdr)
*       ENTITY Header BY \_Lineboi
*       ALL FIELDS WITH CORRESPONDING #( keys )
*               RESULT FINAL(lt_line).
*    DATA(ls_hdr) = lt_hdr[ 1 ].
*    DATA(ls_line) = lt_line[ 1 ].
***********************************************************************
*    "Check duplicate Sales Order
*    SELECT SINGLE vbeln
*      FROM zlc_app01_tb3
*      WHERE lnum  = @ls_hdr-lnum
*        AND vbeln = @ls_line-vbeln
*      INTO @DATA(lv_vbeln).
*
*    IF sy-subrc = 0.
*
*      APPEND VALUE #(
*        %tky = keys[ 1 ]-%tky
*        %msg = new_message(
*                 id       = 'ZLC_MSG'
*                 number   = '001'
*                 severity = if_abap_behv_message=>severity-error
*                 v1       = |Sales Order { ls_line-vbeln } already exists|
*               )
*      ) TO reported-header.
*
*      RETURN.
*    ENDIF.
***********************************************************************
*
*    SELECT SINGLE lnum, MAX( lcline ) AS lcline FROM zlc_app01_tb3
*    WHERE lnum = @ls_hdr-Lnum
*    GROUP BY lnum
*    INTO @DATA(ls_tab).
*    IF ls_tab IS INITIAL.
*      ls_linedata-lcline = 1.
*    ELSE.
*      ls_linedata-lcline = ls_tab-lcline + 1.
*    ENDIF.
***********************************************************************
*    ls_linedata-lnum = ls_hdr-Lnum.
*    ls_linedata-vbeln = ls_line-vbeln.
*    ls_linedata-boeamt = ls_line-Boeamt.
*    ls_linedata-instdebt = ls_line-Instdebt.
*    ls_linedata-fright = ls_line-Fright.
*    ls_linedata-tboeamt = ls_linedata-boeamt + ls_linedata-fright + ls_linedata-instdebt.
*    ls_linedata-boeqty = ls_line-Boeqty.
*    ls_linedata-unit  =  ls_line-Unit.
*    ls_linedata-boecurr = ls_line-Boecurr.
*    ls_linedata-boedt = ls_line-Boedt.
*    ls_linedata-boeno = ls_line-Boeno.
*    ls_linedata-dudt = ls_line-Dudt.
*    ls_linedata-createdby = ls_line-Createdby.
*    ls_linedata-createdon = ls_line-Createdon.
*
***********************************************************************
*    MOVE-CORRESPONDING ls_hdr TO ls_hdrupd.
*    IF ls_linedata-Tboeamt IS NOT INITIAL.
*      ls_hdrupd-aclcamt += ls_linedata-tboeamt.
*      ls_hdrupd-totboeamt += ls_linedata-tboeamt.
*      ls_hdrupd-planlcamt = ls_hdrupd-tlcamt - ls_hdrupd-aclcamt.
**ls_hdrupd-totbalance = ls_hdrupd-totboeamt - ls_hdrupd-tlcutilz.
*
*      "aclcamt is
*    ENDIF.
***********************************************************************
*    APPEND ls_linedata TO lt_linedata.
*    zbp_lc_app01_rv=>gt_line2data = lt_linedata.
*    APPEND ls_hdrupd TO lt_hdrupd.
*    zbp_lc_app01_rv=>gt_hdrupd =  lt_hdrupd.
*
*
*  ENDMETHOD.
*
*  METHOD gt_updt.
***********************************************************************
*    DATA : gs_item TYPE  zlc_app01_tb3.
*    READ ENTITIES OF zlc_app01_rv IN LOCAL MODE
*  ENTITY Header
*  ALL FIELDS WITH CORRESPONDING #( keys )
*          RESULT FINAL(lt_hdr)
*  ENTITY Header BY \_Lineboi
*  ALL FIELDS WITH CORRESPONDING #( keys )
*          RESULT FINAL(lt_line).
*
*    DATA(ls_item) = lt_line[ 1 ].
*
*    SELECT SINGLE * FROM zlc_app01_tb3 WHERE lnum = @ls_item-Lnum AND lcline = @ls_item-Lcline INTO @DATA(ls_item2).
*
*    MOVE-CORRESPONDING ls_item2 TO gs_item.
*    gs_item-dudt  = ls_item-Dudt.
*
*    APPEND gs_item TO zbp_lc_app01_rv=>gt_line2data.
*
*  ENDMETHOD.
*
*  METHOD V1_boeamt.
***********************************************************************
*    READ ENTITIES OF zlc_app01_rv IN LOCAL MODE
*   ENTITY Header
*   ALL FIELDS WITH CORRESPONDING #( keys )
*           RESULT FINAL(lt_hdr)
*   ENTITY Header BY \_Lineboi
*   ALL FIELDS WITH CORRESPONDING #( keys )
*           RESULT FINAL(lt_line).
*    DATA : lv_totv TYPE p DECIMALS 2.
*
*    DATA(ls_hdr) = lt_hdr[ 1 ].
**    DATA(ls_line) = lt_line[ 1 ].
*    LOOP AT lt_line INTO DATA(ls_line) .
*      ls_line-Tboeamt = ls_line-Boeamt + ls_line-Fright + ls_line-Instdebt.
*      lv_totv += ls_line-Tboeamt.
*
*    ENDLOOP.
*
*    IF lv_totv > ls_hdr-TlcAmt.
*      APPEND VALUE #( %tky = ls_line-%tky  ) TO failed-_Lineboi.
*      APPEND VALUE #( %tky = keys[ 1 ]-%tky
*      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*  text = |Total LC Amt: { ls_hdr-TlcAmt }, BOE Exceeded: { lv_totv }|
*      ) ) TO reported-_Lineboi.
*    ENDIF.
***********************************************************************
*
*  ENDMETHOD.
*
*ENDCLASS.

CLASS lsc_ZLC_APP01_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZLC_APP01_RV IMPLEMENTATION.

  METHOD save_modified.
**********************************************************************
*    IF create-header IS NOT INITIAL.
    IF zbp_lc_app01_rv=>gt_hdrdata IS NOT INITIAL.
      MODIFY zlc_app01_tb1 FROM TABLE @zbp_lc_app01_rv=>gt_hdrdata.
    ENDIF.
*    ENDIF.
**********************************************************************
    IF create-line IS NOT INITIAL.
      IF zbp_lc_app01_rv=>gt_lindata IS NOT INITIAL.
        MODIFY zlc_app01_tb2 FROM TABLE @zbp_lc_app01_rv=>gt_lindata.
      ENDIF.
    ENDIF.

    IF zbp_lc_app01_rv=>gt_hdrupd IS NOT INITIAL.
      MODIFY zlc_app01_tb1 FROM TABLE @zbp_lc_app01_rv=>gt_hdrupd.
    ENDIF.
**********************************************************************
*----------------------------------------------------------------------
* UPDATE LINE
*----------------------------------------------------------------------
    IF update-line IS NOT INITIAL.

      LOOP AT update-line INTO DATA(ls_upd_line).

        DATA(ls_line_db) = VALUE zlc_app01_tb2( ).

        SELECT SINGLE *
          FROM zlc_app01_tb2
          WHERE lnum   = @ls_upd_line-lnum
            AND lcline = @ls_upd_line-lcline
          INTO @ls_line_db.

        IF sy-subrc = 0.

          "Update only changed fields
          IF ls_upd_line-%control-LcAmt = if_abap_behv=>mk-on.
            ls_line_db-lcamt = ls_upd_line-LcAmt.
          ENDIF.

          IF ls_upd_line-%control-Torlce = if_abap_behv=>mk-on.
            ls_line_db-torlce = ls_upd_line-Torlce.
          ENDIF.

          IF ls_upd_line-%control-Valto = if_abap_behv=>mk-on.
            ls_line_db-valto = ls_upd_line-Valto.
          ENDIF.
          IF ls_upd_line-%control-Noofdays = if_abap_behv=>mk-on.
            ls_line_db-noofdays = ls_upd_line-Noofdays.
          ENDIF.

          "Calculate line total
          IF ls_line_db-lcamt IS NOT INITIAL
             AND ls_line_db-torlce IS NOT INITIAL.

            ls_line_db-tlcamt =
                ls_line_db-lcamt
              + ( ls_line_db-lcamt * ls_line_db-torlce / 100 ).

          ELSE.

            ls_line_db-tlcamt = ls_line_db-lcamt.

          ENDIF.

          "Save line
          MODIFY zlc_app01_tb2 FROM @ls_line_db.

        ENDIF.

      ENDLOOP.


      "============================================================
      " UPDATE HEADER
      "============================================================

      SELECT SINGLE *
        FROM zlc_app01_tb1
        WHERE lnum = @ls_upd_line-lnum
        INTO @DATA(ls_hdr_db).

      IF sy-subrc = 0.

        DATA(lv_total_lc) = CONV decfloat34( 0 ).

        "Read all lines after update
        SELECT
          FROM zlc_app01_tb2 FIELDS tlcamt,lnum,
           torlce
          WHERE lnum = @ls_upd_line-lnum
          INTO TABLE @DATA(lt_lines).

        "Calculate header total
        LOOP AT lt_lines INTO DATA(ls_line).

          lv_total_lc += ls_line-tlcamt.

        ENDLOOP.
        CLEAR ls_hdr_db-tlcamt.
        "Update header
        ls_hdr_db-tlcamt = lv_total_lc.

        ls_hdr_db-planlcamt =
            ls_hdr_db-tlcamt
          - ls_hdr_db-aclcamt.
        ls_hdr_db-relstastu = ''.


        "Update tolerance if required
        READ TABLE lt_lines INTO DATA(ls_first_line) INDEX 1.

        IF sy-subrc = 0.
          ls_hdr_db-torlce = ls_first_line-torlce.
        ENDIF.

        "Save header
        MODIFY zlc_app01_tb1 FROM @ls_hdr_db.

      ENDIF.

    ENDIF.

**********************************************************************
*     if create-line2 is not INITIAL.
*    IF zbp_lc_app01_rv=>gt_line2data IS NOT INITIAL.
*
*      MODIFY zlc_app01_tb3 FROM TABLE @zbp_lc_app01_rv=>gt_line2data.
*    ENDIF.
    IF zbp_lc_app01_rv=>gt_hdrupd IS NOT INITIAL.
      MODIFY zlc_app01_tb1 FROM TABLE @zbp_lc_app01_rv=>gt_hdrupd.
    ENDIF.
*          endif.
**********************************************************************

    IF delete-header IS NOT INITIAL.
      LOOP AT delete-header INTO DATA(ls_gpentry).
        DELETE FROM zlc_app01_tb1 WHERE lnum = @ls_gpentry-Lnum.
        DELETE FROM zlc_app01_tb2 WHERE lnum = @ls_gpentry-Lnum.
*        DELETE FROM zlc_app01_tb3 WHERE lnum = @ls_gpentry-Lnum.
      ENDLOOP.
    ENDIF.

    IF delete-line IS NOT INITIAL.
      LOOP AT delete-line INTO DATA(ls_itm).
        DELETE FROM zlc_app01_tb2 WHERE lnum = @ls_itm-Lnum
                                  AND   lcline = @ls_itm-Lcline.

      ENDLOOP.
      ENDIF.
**********************************************************************
*    IF delete-_lineboi IS NOT INITIAL.
*      LOOP AT delete-_lineboi ASSIGNING FIELD-SYMBOL(<ls_delete>).
*        DELETE FROM zlc_app01_tb3 WHERE lcline = @<ls_delete>-Lcline.
*
*      ENDLOOP.
*    ENDIF.
**********************************************************************
*            LOOP AT update-_lineboi INTO DATA(ls_upd).
*
*              DATA(ls_db) = VALUE zlc_app01_tb3( ).
*
*              SELECT SINGLE *
*                FROM zlc_app01_tb3
*                WITH PRIVILEGED ACCESS
*                WHERE lcline = @ls_upd-lcline
*                INTO @ls_db.
*
*              IF sy-subrc = 0.
*
*                "Copy the NEW values from the RAP update structure
*                MOVE-CORRESPONDING ls_upd TO ls_db.
*
*                MODIFY zlc_app01_tb3 FROM @ls_db.
*
*              ENDIF.
*
*            ENDLOOP.

    ENDMETHOD.

    METHOD cleanup_finalize.
    ENDMETHOD.

ENDCLASS.
