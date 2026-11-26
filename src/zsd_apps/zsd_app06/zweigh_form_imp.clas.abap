CLASS zweigh_form_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZWEIGH_FORM_IMP IMPLEMENTATION.


METHOD if_rap_query_provider~select.
********************************************************************************************************
  if not io_request->is_data_requested(  ).
        RETURN.
    endif.
******************************************************************************************************************

   DATA(lo_filter) = io_request->get_filter(  ).

    TRY.
        DATA(lt_range) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
*******************************************************************************************************************
        IF NOT line_exists( lt_range[  name = 'UUID' ] ).
      "Need select parameter!
      RETURN.
    ENDIF.
*****************************************************************************************************************
    DATA rt_table TYPE TABLE OF ZSD_CE_WEIGHT.
    DATA: lv_uuid TYPE ZSD_CE_WEIGHT-uuid.
    DATA: lv_tare TYPE zsd_app05_hdb-tarewt,
          lv_net TYPE zsd_app05_hdb-tarewt,
          lv_total TYPE zsd_app05_hdb-tarewt.

    data lvgateno type c length 10 .
    DATA: lv_accodoc TYPE ZFI_FORM_OUTPUT-AccountingDocument.
*****************************************************************************************************
     LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls_Acc>).
        lv_uuid = <ls_acc>-low.

************************************************************************************************************
        select SINGLE * from zsd_app05_hdb wiTH PRIVILEGED ACCESS
        whERE uuid = @lv_uuid
        into @data(ls_gate).
************************************************************************************************************
        SELECT * from zsd_app05_idb WITH PRIVILEGED ACCESS
        WHERE uuid = @lv_uuid
        INto TABLE @DATA(lt_item).

*        lv_net  = REDUCE #( INIT total = 0
*                                FOR ls_item IN lt_item
*                                NEXT total = total + ls_item-Netweight ).

        lv_total = REDUCE #(
                            INIT total1 = CONV #( 0 )
                            FOR ls_item IN lt_item
                            NEXT total1 = total1 + ls_item-Netweight ).
        lv_net = lv_total.

        lv_tare  = REDUCE #( INIT total = CONV #( 0 )
                                FOR ls_item IN lt_item
                                NEXT total = total + ls_item-tareweight ).
*******************************************************************************************************
        INSERT VALUE ZSD_CE_WEIGHT(
                         uuid = ls_gate-uuid
                         vehicleno = ls_gate-vehicleno
*                         grossweight  = lt_item-grossweight
                         grossweight   = VALUE #( lt_item[ 1 ]-grossweight OPTIONAL )
                         gateentrydate = ls_gate-gateentrydate
                         netweight = lv_net
                         tarewt = lv_tare

                        )
                        into table rt_table.
*******************************************************************************************************
      io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
