CLASS zres_formprint_item_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZRES_FORMPRINT_ITEM_CLASS IMPLEMENTATION.


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
    DATA rt_item TYPE table of zres_item_ce.

**********************************************************************
    LOOP AT lt_range[ name = 'RESERVATION' ]-range ASSIGNING FIELD-SYMBOL(<ls_range>).

      DATA(lv_requi) = <ls_range>-low.

*      SELECT SINGLE *
*  FROM zreservation_hdr
*  WITH PRIVILEGED ACCESS
*  WHERE Requino = @lv_requi
*  INTO @DATA(wa_res).
********************************************************************
    SELECT *
  FROM zreservation_item
  WITH PRIVILEGED ACCESS
  WHERE Reservation = @lv_requi
  into table @data(wa_reqitem).

  if wa_reqitem is NOT INITIAL.
    SORT wa_reqitem ASCENDING by ReservationItem.
    LOOP AT wa_reqitem ASSIGNING FIELD-SYMBOL(<ls_item>).
    if  <ls_item> is ASSIGNED.
    INSERT value zres_item_ce( Reservation = <ls_item>-Reservation
                               Reservationitem = <ls_item>-Reservationitem
                               MaterialDocument = <ls_item>-MaterialDocument
                               MaterialDocumentItem = <ls_item>-MaterialDocumentItem
                              productcode = <ls_item>-productcode
                              itemdetails = <ls_item>-itemdetails
                              um = <ls_item>-um
                              reqqty = <ls_item>-reqqty
                              issueqty = <ls_item>-issueqty
                              Currency = <ls_item>-Currency
                              rate = <ls_item>-rate
                              provamt = <ls_item>-provamt
                              ProductWithDescription = <ls_item>-ProductWithDescription
                              StorageLocation = <ls_item>-StorageLocation
                              Storagelocationname = <ls_item>-Storagelocationname
                              Remark = <ls_item>-Remark )
                              INTO TABLE rt_item.

              endif.
              ENDLOOP.

    io_response->set_data( rt_item ).
        io_response->set_total_number_of_records( lines( rt_item ) ).

      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
