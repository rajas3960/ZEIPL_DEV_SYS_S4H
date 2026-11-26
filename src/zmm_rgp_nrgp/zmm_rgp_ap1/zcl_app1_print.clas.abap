CLASS zcl_app1_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_APP1_PRINT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ) = abap_false.
      RETURN.
    ENDIF.

    DATA lt_result TYPE STANDARD TABLE OF zmm_app1_ce1.
    DATA lt_range  TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA lv_uuid   TYPE zmm_app1_rv-uuid.

    DATA(lo_filter) = io_request->get_filter( ).

    TRY.
        lt_range = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.

    IF NOT line_exists( lt_range[ name = 'UUID' ] ).
      io_response->set_data( lt_result ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    LOOP AT lt_range[ name = 'UUID' ]-range
      ASSIGNING FIELD-SYMBOL(<ls_range>).

      lv_uuid = <ls_range>-low.

      IF lv_uuid IS INITIAL.
        CONTINUE.
      ENDIF.

      SELECT SINGLE *
        FROM zmm_app1_rv WITH PRIVILEGED ACCESS
        WHERE uuid = @lv_uuid
        INTO @DATA(ls_hdr).

        "Fetch supplier details from I_Supplier
      SELECT SINGLE
             Supplier,
             SupplierName,
             StreetName,
             BPAddrStreetName,
             CityName,
             PostalCode,
             PAN,
             taxnumber3,
             Phone,
             EmailAddress,
             region,
             ADDRESS1,
             cipin
        FROM ZFI_SUPPLIER_ADDRESS
        WHERE Supplier = @ls_hdr-vendnum
        INTO @DATA(ls_supplier).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      "Add your mapping code here
      DATA ls_result TYPE zmm_app1_ce1.

      CLEAR ls_result.

      ls_result-uuid          = ls_hdr-uuid.
      ls_result-cmpname       = ls_hdr-plant.
      ls_result-typ           = ls_hdr-gptype.
      ls_result-rgpno         = ls_hdr-gpnum.
      ls_result-gatepassdt    = ls_hdr-gitdat.
      ls_result-gatepassno    = ls_hdr-rgpnrpactualno.
      ls_result-tdname        = ls_hdr-transportername.
      ls_result-vehicleno     = ls_hdr-vehicleno.
      ls_result-fregts        = ls_hdr-frghtscope.
      ls_result-grosswgt      = ls_hdr-grosswgt.
      ls_result-tarewgt       = ls_hdr-tarewgt.
      ls_result-netwgt        = ls_hdr-netwgt.
      ls_result-ewaybill_no   = ls_hdr-ewabillno.
      ls_result-lrno          = ls_hdr-lrnumber.
      ls_result-lrdate        = ls_hdr-lrdate.
      ls_result-formplace     = ls_hdr-fromplace.
      ls_result-placeofsupply = ls_hdr-toplace.
      ls_result-remark        = ls_hdr-remarks.
      ls_result-createdby     = ls_hdr-createdby.
      LS_RESULT-exp_retu_d    = LS_HDR-Plnrtndate.
      LS_RESULT-issuedate     = LS_HDR-Issuedate.
      ls_result-sp_name       = ls_supplier-SupplierName.
      ls_result-sp_email      = ls_supplier-EmailAddress.
      ls_result-sp_add1     = ls_supplier-StreetName.
      ls_result-sp_add2     = ls_supplier-BPAddrStreetName.
      ls_result-sp_city     = ls_supplier-CityName.
      ls_result-sp_pcode    = ls_supplier-PostalCode.
      ls_result-Contpr      = ls_hdr-Contpr.
      ls_result-particular  = ls_hdr-particular.

  CONCATENATE ls_supplier-BPAddrStreetName ls_supplier-CityName ls_supplier-PostalCode
    INTO ls_result-supaddress .
*    SEPARATED BY ', '.

*        ls_result-sp_cin      = ls_supplier-UK_CompanyRegistrationNumber.
        ls_result-sp_pan      = ls_supplier-pan.
        ls_result-sp_gstin    = ls_supplier-TaxNumber3.
        ls_result-sp_pno       = ls_supplier-Phone.
        ls_result-sp_statename  = ls_supplier-Region.

      APPEND ls_result TO lt_result.

    ENDLOOP.

    io_response->set_data( lt_result ).

    io_response->set_total_number_of_records(
      lines( lt_result )
    ).

  ENDMETHOD.
ENDCLASS.
