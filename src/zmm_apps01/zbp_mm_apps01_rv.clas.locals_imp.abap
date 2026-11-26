*CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
*
*  PRIVATE SECTION.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      keys REQUEST requested_features FOR item RESULT result.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      keys REQUEST requested_authorizations FOR item RESULT result.
*
*    METHODS Award FOR MODIFY
*       keys FOR ACTION item~Award RESULT result.
*
*ENDCLASS.
*
*CLASS lhc_item IMPLEMENTATION.
*
*  METHOD get_instance_features.
*  ENDMETHOD.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*  METHOD Award.
***********************************************************************
***********************************************************************
**    READ ENTITIES OF zmm_apps01_rv IN LOCAL MODE ENTITY item
**    ALL FIELDS WITH CORRESPONDING #( keys )
**    RESULT DATA(lt_item).
*    READ ENTITIES OF zmm_apps01_rv IN LOCAL MODE
*       ENTITY _hdr
*       ALL FIELDS WITH CORRESPONDING #( keys )
*       RESULT DATA(lt_hdr).
*       DATA(LS_HDR) = lt_hdr[ 1 ].
*       SELECT  FROM ZMM_APPS01_IRV FIELDS
*       SupplierQuotation
*       WHERE RequestForQuotation = @ls_hdr-RequestForQuotation
*       AND Compare = '01'
*       INTO TABLE @DATA(lt_item).
*
*          DELETE  DUPLICATES FROM lt_item COMPARING SupplierQuotation .
*
***********************************************************************
*    DATA(ls_item) = lt_item[ 1 ].
**    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
*
*      SELECT SINGLE
*      FROM I_SupplierQuotation_API01
*      FIELDS QTNLifecycleStatus
*      WHERE SupplierQuotation = @ls_item-SupplierQuotation
*      INTO @DATA(lv_status).
*
*      IF lv_status <> '06'.
*
*        MODIFY ENTITIES OF I_SupplierQuotationTP PRIVILEGED ENTITY SupplierQuotation
*        EXECUTE SubmitSuplrQtnForApproval FROM VALUE #( ( SupplierQuotation = ls_item-SupplierQuotation ) )
*        REPORTED DATA(lt_repot)
*        FAILED DATA(lt_faild).
*
*      ENDIF.
*
*
**    ENDLOOP.
*
*    result = VALUE #(
*    (
*      %tky = ls_item-SupplierQuotation
*    )
*  ).
*
*
*
***********************************************************************
*
*
*
*
*
*
*
***********************************************************************
***********************************************************************
*  ENDMETHOD.
*
*ENDCLASS.

CLASS lhc__HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR _hdr RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR _hdr RESULT result.

    METHODS compare FOR MODIFY
       keys FOR ACTION _hdr~compare RESULT result.
    METHODS award FOR MODIFY
       keys FOR ACTION _hdr~award RESULT result.



ENDCLASS.

CLASS lhc__HDR IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.


  METHOD Compare.
    READ ENTITIES OF zmm_apps01_rv IN LOCAL MODE
      ENTITY _hdr
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    IF lt_header IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE lt_header INTO DATA(ls_header) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lv_rfq) = ls_header-RequestForQuotation.


    "---------------------------------------------------------
    " Get quotation totals
    "---------------------------------------------------------
    SELECT FROM I_SupplierQuotationItem_Api01 AS sqi

      INNER JOIN I_SupplierQuotation_Api01 AS sq
        ON sq~SupplierQuotation = sqi~SupplierQuotation

      FIELDS
        sq~RequestForQuotation,
        sq~SupplierQuotation,
        sq~Supplier,
        SUM( sqi~NetPriceAmount ) AS TotalAmount

      WHERE sq~RequestForQuotation = @lv_rfq

      GROUP BY
        sq~RequestForQuotation,
        sq~SupplierQuotation,
        sq~Supplier

      INTO TABLE @DATA(lt_total).


    IF lt_total IS INITIAL.
      RETURN.
    ENDIF.
    "---------------------------------------------------------
    SORT lt_total BY TotalAmount ASCENDING.

    READ TABLE lt_total INTO DATA(ls_winner) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.


    CLEAR zbp_mm_apps01_rv=>gt_compare.

    APPEND VALUE #(
      supplierquotation   = ls_winner-SupplierQuotation
      requestforquotation = ls_winner-RequestForQuotation
      supplier            = ls_winner-Supplier
      compare             = '01'
    ) TO zbp_mm_apps01_rv=>gt_compare.


    "---------------------------------------------------------
    " Return selected header
    "---------------------------------------------------------
    READ ENTITIES OF zmm_apps01_rv IN LOCAL MODE
      ENTITY _hdr
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky = ls_result-%tky
        %param = ls_result
      )
    ).
  ENDMETHOD.


  METHOD Award.
    READ ENTITIES OF zmm_apps01_rv IN LOCAL MODE
        ENTITY _hdr
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_hdr).
    DATA(ls_hdr) = lt_hdr[ 1 ].
    SELECT  FROM zmm_apps01_irv FIELDS
    SupplierQuotation
    WHERE RequestForQuotation = @ls_hdr-RequestForQuotation
    AND Compare = '01'
    INTO TABLE @DATA(lt_item).

    DELETE  DUPLICATES FROM lt_item COMPARING SupplierQuotation .

**********************************************************************
    DATA(ls_item) = lt_item[ 1 ].
*    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).

    SELECT SINGLE
    FROM I_SupplierQuotation_API01
    FIELDS QTNLifecycleStatus
    WHERE SupplierQuotation = @ls_item-SupplierQuotation
    INTO @DATA(lv_status).

    IF lv_status <> '06'.

      MODIFY ENTITIES OF I_SupplierQuotationTP PRIVILEGED ENTITY SupplierQuotation
      EXECUTE SubmitSuplrQtnForApproval FROM VALUE #( ( SupplierQuotation = ls_item-SupplierQuotation ) )
      REPORTED DATA(lt_repot)
      FAILED DATA(lt_faild).

    ENDIF.

**********************************************************************
    APPEND VALUE #(
        rfq = ls_hdr-RequestForQuotation
        sq  = ls_item-SupplierQuotation
    ) TO zbp_mm_apps01_rv=>gt_award.


    result = VALUE #(
     FOR ls_result IN lt_hdr
     (
       %tky = ls_result-%tky
       %param = ls_result
     )
   ).


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_APPS01_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMM_APPS01_RV IMPLEMENTATION.

  METHOD save_modified.
    LOOP AT zbp_mm_apps01_rv=>gt_compare
        INTO DATA(ls_compare).

      "Clear previous winner for this RFQ
      UPDATE zmm_apps01_itb
         SET compare = ''
       WHERE requestforquotation =
             @ls_compare-requestforquotation.


      "Check whether winner already exists
      SELECT SINGLE
        FROM zmm_apps01_itb
        FIELDS supplierquotation,
               requestforquotation,
               supplier
        WHERE supplierquotation =
                @ls_compare-supplierquotation
          AND requestforquotation =
                @ls_compare-requestforquotation
          AND supplier =
                @ls_compare-supplier
        INTO @DATA(ls_existing).


      IF sy-subrc = 0.

        "Existing record → update
        UPDATE zmm_apps01_itb
           SET compare = '01'
         WHERE supplierquotation =
                 @ls_compare-supplierquotation
           AND requestforquotation =
                 @ls_compare-requestforquotation
           AND supplier =
                 @ls_compare-supplier.

      ELSE.

        "New record → insert
        DATA ls_itb TYPE zmm_apps01_itb.

        CLEAR ls_itb.

        ls_itb-client              = sy-mandt.
        ls_itb-supplierquotation   = ls_compare-supplierquotation.
        ls_itb-requestforquotation = ls_compare-requestforquotation.
        ls_itb-supplier            = ls_compare-supplier.
        ls_itb-compare             = '01'.

        INSERT zmm_apps01_itb FROM @ls_itb.

      ENDIF.

    ENDLOOP.
**********************************************************************

    LOOP AT zbp_mm_apps01_rv=>gt_award
    INTO DATA(ls_award).

      DATA:ls_tb TYPE zmm_apps01_tb.



      ls_tb-client = sy-mandt.
      ls_tb-rfq    = ls_award-rfq.
      ls_tb-sq     = ls_award-sq.
*  ls_tb-status = '01'.   "optional

      MODIFY zmm_apps01_tb FROM @ls_tb.

    ENDLOOP.

    CLEAR zbp_mm_apps01_rv=>gt_award.



  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
