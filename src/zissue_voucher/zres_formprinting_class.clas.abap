CLASS zres_formprinting_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZRES_FORMPRINTING_CLASS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF NOT io_request->is_data_requested(  ).
      RETURN.
    ENDIF.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        DATA(lo_error) = 1.
    ENDTRY.
**********************************************************************
    IF NOT line_exists( lt_range[ name = 'RESERVATION' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
**********************************************************************
    DATA rt_table TYPE TABLE OF zres_hdr_ce.

**********************************************************************
    LOOP AT lt_range[ name = 'RESERVATION' ]-range ASSIGNING FIELD-SYMBOL(<ls_range>).

      DATA(lv_requi) = <ls_range>-low.

*      SELECT SINGLE * FROM zreservation_hdr WITH PRIVILEGED ACCESS
*      WHERE Requino = @lv_requi
*      INTO @DATA(wa_REQUI).
***********************************************************************
*       select single * from I_MaterialDocumentItem_2  WITH PRIVILEGED ACCESS
*       where Reservation = @wa_requi-Requino
*       into @data(wa_issue).
*
*
*
*
***********************************************************************
*      IF wa_REQUI IS NOT INITIAL.
*
*        INSERT VALUE zres_hdr_ce(     Reservation   = wa_REQUI-Requino
*                                      RequiDt  =   wa_REQUI-RequiDt
*                                      Batchno = wa_REQUI-batchno
*                                      Plant          = wa_REQUI-Div
*                                      Preparedby  = wa_REQUI-Preparedby
*                                      Stocktype           = wa_REQUI-Stocktype
*                                      cost            = wa_REQUI-cost
*                                     issueto      = wa_REQUI-issueto
*                                      issueno      = wa_issue-MaterialDocument
*                                      issuedt      = wa_issue-PostingDate
*                                      Username   = wa_requi-PersonFullName
*                                      plantName = wa_requi-PlantName
*                                      Costcentername = wa_requi-CostCenterDescription
*                                      movementtypename = |{ wa_requi-Stocktype }-{ wa_requi-GoodsMovementTypeName }|
*
      SELECT SINGLE *
        FROM zreservation_hdr
        WITH PRIVILEGED ACCESS
        WHERE Requino = @lv_requi
        INTO @DATA(wa_requi).

*---------------------------------------------------------------------*
* Get all material documents for the reservation
*---------------------------------------------------------------------*
*      DATA: lt_issue1 TYPE TABLE OF I_MaterialDocumentItem_2,
*            ls_issue1 TYPE I_MaterialDocumentItem_2.

*---------------------------------------------------------------------*
* 1. Get all material documents for the reservation
*---------------------------------------------------------------------*
      SELECT  MaterialDocument, MaterialDocumentItem ,MaterialDocumentYear, PostingDate
        FROM I_MaterialDocumentItem_2
        WITH PRIVILEGED ACCESS
        WHERE Reservation = @wa_requi-Requino
        INTO TABLE @data(lt_issue).

*---------------------------------------------------------------------*
* 2. Sort all material documents by latest transaction
*---------------------------------------------------------------------*
      SORT lt_issue BY MaterialDocumentYear DESCENDING
                      MaterialDocument     DESCENDING
                      MaterialDocumentItem DESCENDING.

*---------------------------------------------------------------------*
* 3. Get the latest material document
*---------------------------------------------------------------------*
      DATA:
            lv_issuedt TYPE zres_hdr_ce-issuedt.

**********************************************************************
**********************************************************************
      CLEAR:
             lv_issuedt.


*      READ TABLE lt_issue INTO ls_issue INDEX 1.
      DATA(ls_issue) = VALUE #( lt_issue[ 1 ] OPTIONAL ).

      IF sy-subrc = 0.

        DATA(lv_issueno) = ls_issue-MaterialDocument.
        IF sy-subrc = 0  AND ls_issue-PostingDate IS NOT INITIAL.
          lv_issuedt = ls_issue-PostingDate.
        ENDIF.
*  CLEAR: lv_issueno,
*         lv_issuedt.

      ENDIF.

***********************************************************************
" added for Custom Fields
      SELECT SINGLE Reservation, YY1_Chgable_Nchgable1_RES,yy1_po_sup_dtls1p_res,
                    yy1_po_sup_dtls1pd_res,yy1_po_sup_dtls1s_res,yy1_po_sup_dtls1sn_res
       FROM I_ReservationDocumentItemTP
       WITH PRIVILEGED ACCESS
       WHERE Reservation = @wa_requi-Requino
       INTO  @DATA(ls_reservation_item).
**********************************************************************

**********************************************************************
* 2. Get Business User details based on UserID
*---------------------------------------------------------------------*
"added for issuedBy 28-10-26
    DATA :  lv_issuedby TYPE I_MaterialDocumentHeader_2-CreatedByUser.
    CLEAR: lv_issuedby.

    SELECT SINGLE CreatedByUser
    FROM I_MaterialDocumentHeader_2
    WITH PRIVILEGED ACCESS
    WHERE MaterialDocument     = @ls_issue-MaterialDocument
      AND MaterialDocumentYear = @ls_issue-MaterialDocumentYear
    INTO @lv_issuedby.
**********************************************************************
DATA lv_issuebyname TYPE I_BusinessUserBasic-PersonFullName.
CLEAR lv_issuebyname.

IF lv_issuedby IS NOT INITIAL.

  SELECT SINGLE PersonFullName
    FROM I_BusinessUserBasic
    WITH PRIVILEGED ACCESS
    WHERE UserID = @lv_issuedby
    INTO @lv_issuebyname.

ENDIF.

*---------------------------------------------------------------------*
* Create header data
*---------------------------------------------------------------------*
      IF wa_requi IS NOT INITIAL.

        INSERT VALUE zres_hdr_ce(
            Reservation       = wa_requi-Requino
            RequiDt           = wa_requi-RequiDt
            Batchno           = wa_requi-Batchno
            Plant             = wa_requi-Div
            Preparedby        = wa_requi-Preparedby
            Stocktype         = wa_requi-Stocktype
            cost              = wa_requi-cost
            issueto           = wa_requi-issueto
            issuedby          = wa_requi-IssuedBy
            issueno           = lv_issueno
            issuedt           = lv_issuedt
            Username          = wa_requi-PersonFullName
            plantName         = wa_requi-PlantName
            Costcentername    = wa_requi-CostCenterDescription
            movementtypename  = |{ wa_requi-Stocktype }-{ wa_requi-GoodsMovementTypeName }|
" added for Custom Fields
            Chargable         = ls_reservation_item-YY1_Chgable_Nchgable1_RES
            PurchaseOrder     = ls_reservation_item-yy1_po_sup_dtls1p_res
            PurchaseOrderDate = ls_reservation_item-yy1_po_sup_dtls1pd_res
            Supplier          = ls_reservation_item-yy1_po_sup_dtls1s_res
            SupplierName      = ls_reservation_item-yy1_po_sup_dtls1sn_res
" added for IssuedBy
            issuebyfinal      = lv_issuedby
            issuebyname       = lv_issuebyname


        )

        INTO TABLE rt_table.
        io_response->set_data( rt_table ).
        io_response->set_total_number_of_records( lines( rt_table ) ).

      ENDIF.


    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
