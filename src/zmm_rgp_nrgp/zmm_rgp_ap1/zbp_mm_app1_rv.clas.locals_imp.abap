CLASS lhc__HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR _hdr RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR _hdr RESULT result.

 METHODS getdata1 FOR DETERMINE ON SAVE
      IMPORTING keys FOR _hdr~getdata1.
    METHODS updhdr FOR DETERMINE ON SAVE
      IMPORTING keys FOR _hdr~updhdr.
    METHODS issueout FOR MODIFY
      IMPORTING keys FOR ACTION _hdr~issueout RESULT result.
    METHODS checked FOR MODIFY
      IMPORTING keys FOR ACTION _hdr~checked RESULT result.
    METHODS printout FOR MODIFY
      IMPORTING keys FOR ACTION _hdr~printout RESULT result.
    METHODS rgp_nrgp_number FOR MODIFY
      keys FOR ACTION _hdr~rgp_nrgp_number RESULT result.

ENDCLASS.

CLASS lhc__HDR IMPLEMENTATION.

  METHOD get_instance_features.
*  READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
*    ENTITY _hdr
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_status).
*    DATA(ls_hdr) = lt_status[ 1 ].
*
*    TRY.
*        DATA(lv_user2) = cl_abap_context_info=>get_user_business_partner_id(  ).
*      CATCH cx_abap_context_info_error INTO DATA(lv_error).
*        DATA(lv_1) = 1.
*    ENDTRY.
*
*
*    result = VALUE #( FOR ls_key IN keys
*    ( %tky =  ls_key-%tky
*      %delete = COND #(  WHEN ls_hdr-delmark = 'O' OR ls_hdr-delmark IS INITIAL OR ls_hdr-delmark = 'C' AND lv_user2 = '9980000000'
*                                     THEN if_abap_behv=>fc-o-enabled
*                                     ELSE if_abap_behv=>fc-o-disabled )
*      %update = COND #(  WHEN  ( ls_hdr-delmark = 'O' OR ls_hdr-delmark IS INITIAL ) OR ( ls_hdr-delmark = 'C' AND lv_user2 = '9980000000' )
*                                     THEN if_abap_behv=>fc-o-enabled
*                                     ELSE if_abap_behv=>fc-o-disabled )
*      %action = VALUE #( checked = COND #(  WHEN  ls_hdr-delmark = 'O' OR ls_hdr-delmark IS INITIAL
*                                     THEN if_abap_behv=>fc-o-enabled
*                                     ELSE if_abap_behv=>fc-o-disabled )
**                         edit =   COND #(  WHEN  ls_hdr-delmark = 'O' OR ls_hdr-delmark IS INITIAL and lv_user2 = '9980000000'
*                         edit =   COND #(  WHEN  ( ls_hdr-delmark = 'O' OR ls_hdr-delmark IS INITIAL ) OR ( ls_hdr-delmark = 'C' AND lv_user2 = '9980000000' )
*                                     THEN if_abap_behv=>fc-o-enabled
*                                     ELSE if_abap_behv=>fc-o-disabled )
*
*                                      ) ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

METHOD getdata1.
    DATA : lt_gphentry TYPE TABLE OF zmm_app1_tb1,
           ls_gphentry TYPE zmm_app1_tb1.
**********************************************************************
    READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
    ENTITY _hdr
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).
    DATA(ls_header)  = lt_header[ 1 ].

            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).


     SELECT SINGLE Supplier,SupplierFullName FROM I_Supplier WITH PRIVILEGED ACCESS
     WHERE Supplier = @ls_header-vendnum
     INTO @DATA(ls_suppname).
*    SELECT sum( totvalue ) FROM zmm_app1_tb2 WHERE uuid = @ls_header-Uuid into @data(totamt).

    ls_gphentry-uuid = ls_header-uuid.
    ls_gphentry-createdat = ls_header-createdat.
    ls_gphentry-createdby = ls_header-createdby.
    ls_gphentry-curky = ls_header-curky.
    ls_gphentry-dispby = ls_header-dispby.
    ls_gphentry-frghtscope = ls_header-frghtscope.
    ls_gphentry-gptype = ls_header-gptype.
    ls_gphentry-vendnum = ls_header-vendnum.
    ls_gphentry-vendname = ls_suppname-SupplierFullName.
    ls_gphentry-vehicleno = ls_header-vehicleno.
    ls_gphentry-vehicletype = ls_header-Vehicletype.
    ls_gphentry-transporter = ls_header-transporter.
    ls_gphentry-rsngp = ls_header-rsngp.
    ls_gphentry-remarks = ls_header-remarks.
    ls_gphentry-plnrtndate = ls_header-plnrtndate.
    ls_gphentry-pcklist = ls_header-pcklist.
*    ls_gphentry-plant = ls_header-plant.
*    ls_gphentry-plantname = ls_header-plantname.
    ls_gphentry-lastchangedby = ls_header-lastchangedby.
    ls_gphentry-lastchangedat = ls_header-lastchangedat.
    ls_gphentry-issuedby = ls_header-issuedby.
    ls_gphentry-issuedate  = ls_header-issuedate.
    ls_gphentry-zattachment = ls_header-zattachment.
    ls_gphentry-filename = ls_header-filename.
    ls_gphentry-minetype = ls_header-minetype.

    ls_gphentry-ebeln = ls_header-ebeln.
    ls_gphentry-grosswgt = ls_header-grosswgt.
    ls_gphentry-netwgt = ls_header-netwgt.
    ls_gphentry-tarewgt = ls_header-tarewgt.
    ls_gphentry-insurno = ls_header-insurno.
    ls_gphentry-ewabillno = ls_header-ewabillno.
    ls_gphentry-contpr = ls_header-contpr.
    ls_gphentry-reqby =  ls_header-reqby.
    ls_gphentry-reqdpt =  ls_header-reqdpt.
    ls_gphentry-transporterid = ls_header-Transporterid.
    ls_gphentry-gitdat = lv_date.
***********************************************************************
*    SELECT * FROM zmm_app1_tb1 WHERE uuid IS NOT INITIAL AND delmark <> 'X'
*      AND gptype = @ls_header-gptype
*    INTO TABLE @DATA(lt_gpentry).
*    IF lt_gpentry IS INITIAL.
*      IF ls_header-gptype = 'RGP'.
*        ls_gphentry-gpnum = '8000000000'.
*      ELSE.
*        ls_gphentry-gpnum = '9000000000'.
*      ENDIF.
*    ELSE.
*      SORT lt_gpentry BY gpnum DESCENDING.
*      DATA(ls_gpentry)  = lt_gpentry[ 1 ].
*      ls_gphentry-gpnum = ls_gpentry-gpnum + 1.
*    ENDIF.
*
****************************************************************
**********************************************************************
    APPEND ls_gphentry TO lt_gphentry.
    zbp_mm_app1_rv=>gt_gphdr = lt_gphentry.

 ENDMETHOD.

 METHOD updhdr.
    DATA : lt_uphdr TYPE TABLE OF zmm_app1_tb1,
           ls_uphrd TYPE zmm_app1_tb1.
   READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
    ENTITY _hdr
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).
    DATA(ls_hdr) = lt_hdr[ 1 ].

*   if lt_hdr is not INITIAL.
*   loop at lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).

    MOVE-CORRESPONDING ls_hdr TO ls_uphrd.
*       SELECT * FROM zmm_app1_tb1 WHERE uuid IS NOT INITIAL
*    AND gptype = @ls_hdr-gptype
*    INTO TABLE @DATA(lt_gpentry).
*    IF lt_gpentry IS INITIAL.
*      IF ls_hdr-gptype = 'RGP'.
*        ls_uphrd-gpnum = '8000000000'.
*      ELSE.
*        ls_uphrd-gpnum = '9000000000'.
*      ENDIF.
*    ELSE.
*      SORT lt_gpentry BY gpnum DESCENDING.
*      DATA(ls_gpentry)  = lt_gpentry[ 1 ].
*      ls_uphrd-gpnum = ls_gpentry-gpnum + 1.
*    ENDIF.
    ls_uphrd-delmark = 'O'.

    APPEND ls_uphrd TO lt_uphdr.



    zbp_mm_app1_rv=>gt_uphdr = lt_uphdr.

  ENDMETHOD.


  METHOD issueout.

  ENDMETHOD.

  METHOD checked.
    DATA : lt_gphentry TYPE TABLE OF zmm_app1_tb1,
           ls_gphentry TYPE zmm_app1_tb1.
    READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
    ENTITY _hdr
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_hdr).
    DATA(ls_hdr) = it_hdr[ 1 ].

    MOVE-CORRESPONDING ls_hdr TO ls_gphentry.
    ls_gphentry-delmark = 'C'.
*    ls_gphentry-statustext = 'Checked ✅'.
    APPEND ls_gphentry TO lt_gphentry.
    zbp_mm_app1_rv=>gt_checkd = lt_gphentry.

    result = VALUE #( FOR ls_ord IN it_hdr
                 ( %tky   = ls_ord-%tky
                   %param = ls_ord ) ).

  ENDMETHOD.

METHOD printout.
**********************************************************************
    DATA: lv_system_date TYPE d,
*          gs_htb         TYPE zmm_app1_chtb,
*          gt_hdt         TYPE TABLE OF zmm_app1_chtb.

          gs_htb         TYPE zmm_app1_chtb1,
          gt_hdt         TYPE TABLE OF zmm_app1_chtb1.

    lv_system_date = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
    ENTITY _hdr
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(lt_data)
    ENTITY _hdr BY \_item1
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(lt_item).
**********************************************************************
    DATA(ls_data) = lt_data[ 1 ]. "Header structure
    DATA(ls_data1) = lt_data[ 1 ].
    DATA(lt_items) = lt_item[].   " Item structure
    SORT lt_items BY itemno ASCENDING. "Shorting By Line Item
**********************************************************************
*****************************Plant details*****************************************
    SELECT SINGLE organizationname1 FROM zmm_app1_plantv1 WHERE plant = @ls_data-plant INTO @DATA(wa_plant).

    DATA: lv_request_string TYPE string,
          lo_hhtp_response  TYPE REF TO if_web_http_response.
    DATA: lo_http_destination TYPE REF TO if_http_destination,
          lo_http_client      TYPE REF TO if_web_http_client,
          lv_response1        TYPE string.
**********************************************************************
    lv_request_string = |https://my418555-api.s4hana.cloud.sap/sap/opu/odata/sap/YY1_PLANTADDRESS_CDS/YY1_PLANTADDRESS| .
**********************************************************************
    TRY.
        " Create HTTP destination via URL
        lo_http_destination = cl_http_destination_provider=>create_by_url( lv_request_string ).
        " Create HTTP client by HTTP destination
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        " adding Header fields
        DATA : lv_password1 TYPE string,
               lv_userpwd   TYPE string.

        lo_http_client->get_http_request(  )->set_header_fields( VALUE #( ( name = if_web_http_header=>authorization value = 'Basic Q1BNX0NPTV9VU0VSUzoze3ZcXER4MjhbaFotUVZdbX4kbVdjbVlAcW1rOFE0LytvTTJSRFBS' )
                                                                           ( name = if_web_http_header=>accept      value = if_web_http_header=>accept_application_json  ) ) ).

        " execute HTTP POST-request and store response


        lo_hhtp_response = lo_http_client->execute( if_web_http_client=>get ).

        DATA(ls_status1) = lo_hhtp_response->get_status(  ).

        lv_response1 = lo_hhtp_response->get_text(  ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error1).
        DATA(lv_2) = 2.
    ENDTRY.


* Define the nested types to match the JSON structure
    TYPES: BEGIN OF ty_plant,
             plant_address                  TYPE string,
             plant_gst                      TYPE string,
             plant_pan                      TYPE string,
             plant_tan                      TYPE string,
             email                          TYPE string,
             cin_number                     TYPE string,
             sap_uuid                       TYPE sysuuid_c32,
             plant                          TYPE string,
             sap_createddatetime            TYPE timestamp,
             sap_createdbyuser              TYPE string,
             sap_lastchangeddatetime        TYPE timestamp,
             sap_lastchangedbyuser          TYPE string,
             sap_lifecyclestatus            TYPE string,
             sap_lifecyclestatus_text       TYPE string,
             field013                       TYPE string,
             field014                       TYPE string,
             field015                       TYPE string,
             sap_createdbyuser_text         TYPE string,
             sap_lastchangedbyuser_text     TYPE string,
             to_ilm_status_text             TYPE REF TO data, " Using REF TO DATA for nested objects
             to_sapsysadmindata_change_user TYPE REF TO data,
             to_sapsysadmindata_create_user TYPE REF TO data,
           END OF ty_plant.

* The "results" key in the JSON is an array, so it must be an internal table in ABAP
    TYPES: tt_plant TYPE STANDARD TABLE OF ty_plant WITH EMPTY KEY.

* Define the intermediate structure for the "d" key
    TYPES: BEGIN OF ty_results,
             results TYPE tt_plant, " This must be a table type
           END OF ty_results.

* Define the root structure for the entire JSON payload
    TYPES: BEGIN OF ty_root,
             d TYPE ty_results,
           END OF ty_root.

* Declare variables
    DATA: lv_json TYPE string,
          ls_root TYPE ty_root.

* Assign your JSON string here
    lv_json = lv_response1.

* Deserialize the JSON into the root structure
    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json         = lv_json
            pretty_name  = /ui2/cl_json=>pretty_mode-camel_case " Auto-converts names
            assoc_arrays = abap_true
          CHANGING
            data         = ls_root
        ).
        " You can now access the internal table via ls_root-d-results
        DATA(lt_plants) = ls_root-d-results.


      CATCH cx_root INTO DATA(lx).
        DATA(lv_err1) = 1.

    ENDTRY.

    IF ls_data-plant IS NOT INITIAL.
      READ TABLE lt_plants INTO DATA(wa) WITH KEY plant = ls_data-plant.
    ENDIF.

*********************************VENDOR*************************************

    SELECT SINGLE businesspartnername1,taxnumber3,address1,cipin,phone,regionname FROM zi_customer_view WHERE   supplier = @ls_data-vendnum INTO @DATA(wa_vendor).

*********************************ENDVENDOR*************************************
    TRY.
        DATA(lv_user) = cl_abap_context_info=>get_user_description(  ).
      CATCH cx_abap_context_info_error INTO DATA(lv_error).
        DATA(lv_1) = 1.
    ENDTRY.

**********************************************************************

gs_htb-uuid         = ls_data-uuid.
gs_htb-cmpname         = wa_plant.
gs_htb-addrs           = wa-plant_address.
gs_htb-gstin           = wa-plant_gst.
gs_htb-pan             = wa-plant_pan.
gs_htb-email           = wa-email.
gs_htb-statecode       = wa-plant_gst.
gs_htb-typ             = ls_data-gptype.
gs_htb-rgpno           = ls_data-Rgpnrpactualno.
*GS_HTB-gatepassno      = ls_data-Gpnum.
gs_htb-gatepassdt      = ls_data-Gitdat.
gs_htb-tdname          = ls_data-TransporterName.
gs_htb-vehicleno       = ls_data-vehicleno.
gs_htb-exp_retu_d      = ls_data-plnrtndate.
gs_htb-fregts          = ls_data-Frghtscope.
gs_htb-grosswgt           = ls_data-grosswgt.
gs_htb-tarewgt            = ls_data-tarewgt.
gs_htb-netwgt           = ls_data-netwgt.
gs_htb-bi_add1         = wa_vendor-address1.
gs_htb-bi_gstin        = wa_vendor-taxnumber3.
gs_htb-bi_phone        = wa_vendor-phone.
gs_htb-bi_statename    = wa_vendor-regionname.
gs_htb-ewaybill_no      = ls_data-ewabillno.
gs_htb-lrno             = ls_data-LRnumber.
gs_htb-lrdate           = ls_data-LRdate.
gs_htb-exp_retu_d       = ls_data-Gitdat.
gs_htb-formplace        = ls_data-Fromplace.
gs_htb-placeofsupply    = ls_data-Toplace.
gs_htb-remark           = ls_data-Remarks.
gs_htb-createdby        = ls_data-Createdby.


*    gs_htb-uuid = ls_data-Uuid.
*    gs_htb-rnr = wa-cin_number.
*    gs_htb-ruler = wa-field015.
*    gs_htb-cmpname = wa_plant.
*    gs_htb-addrs = wa-plant_address.
*    gs_htb-gstin = wa-plant_gst.
*    gs_htb-pan = wa-plant_pan.
*    gs_htb-email = wa-email.
*    gs_htb-statecode = wa-plant_gst.
*    gs_htb-typ = ls_data-gptype.
*    gs_htb-rgpno = ls_data-gpnum.
*    gs_htb-despdt = ls_data-createdat.
*    gs_htb-rgpdt = ls_data-createdat.
*    gs_htb-dispthr = ls_data-dispby.
*    gs_htb-retndt = ls_data-plnrtndate.
*    gs_htb-transna = ls_data-transporter.
*    gs_htb-fregts = ls_data-frghtscope.
*    gs_htb-vehno = ls_data-vehicleno.
*    gs_htb-insurncsc = ls_data-insurno.
*    gs_htb-contno = ls_data-contpr.
*    gs_htb-reqdept = ls_data-reqdpt.
*    gs_htb-requestedby = ls_data-reqby.
*    gs_htb-gateenty = ls_data-gateno.
*    gs_htb-gatetime = ls_data-gittim.
*    gs_htb-gross = ls_data-grosswgt.
*    gs_htb-tare = ls_data-tarewgt.
*    gs_htb-netw = ls_data-netwgt.
*    gs_htb-dt = ls_data-crea tedat.
*    gs_htb-ddt = ls_data-gitdat.
*    gs_htb-cmp = wa_vendor-businesspartnername1.
*    gs_htb-add1 = wa_vendor-address1.
*    gs_htb-add2 = wa_vendor-cipin.
*    gs_htb-gstno = wa_vendor-taxnumber3.
*    gs_htb-sc = wa_vendor-taxnumber3.
*    gs_htb-pos = wa_vendor-regionname.
*    gs_htb-ewbno = ls_data-ewabillno.
*    gs_htb-conctno = wa_vendor-phone.
*    gs_htb-valueinwords = ls_data-Remarks.
*********************************************************************
    APPEND gs_htb TO gt_hdt.
**********************************************************************
**********************************************************************
    IF gt_hdt IS NOT INITIAL.

*      MODIFY zmm_app1_chtb FROM TABLE @gt_hdt.

      MODIFY zmm_app1_chtb1 FROM TABLE @gt_hdt.


    ENDIF.

**********************************************************************
**********************************************************************
    IF ls_data-uuid IS NOT INITIAL.

      TRY.
          "Initialize Template Store Client
          DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
           iv_name                  = 'ZADS_CS'
           iv_service_instance_name = 'ZADS_OUT_REST'
          ).

          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZMM_APP1_CE'
                                                                iv_root_node = 'ZMM_APP1_CE1'
                                                                ) .
**********************************************************************
          DATA: printque TYPE c LENGTH 32.

          printque = 'ADOBE_DEFAULT'.
**********************************************************************
*DATA: lv_form_name     TYPE string,
*      lv_template_name TYPE string.
*
*IF ls_data-gptype = 'RGP'.
*
*  lv_form_name     = 'ZRGP_DELIVERYCHALAN'.
*  lv_template_name = 'ZRGP_DELIVERYCHALAN'.
*
*ELSEIF ls_data-gptype = 'NRGP'.
*
*  lv_form_name     = 'ZNRGP_DELIVERYCHALAN'.
*  lv_template_name = 'ZNRGP_DELIVERYCHALAN'.
*
*ENDIF.

DATA: lv_form_name     TYPE string,
      lv_template_name TYPE string.

IF ls_data-gptype = 'RGP'.

  lv_form_name     = 'ZRGP_DELIVERYCHALAN'.
  lv_template_name = 'ZRGP_DELIVERYCHALAN'.

ELSEIF ls_data-gptype = 'NRGP'.

  lv_form_name     = 'ZNRGP_DELIVERYCHALAN'.
  lv_template_name = 'ZNRGP_DELIVERYCHALAN'.

ELSE.

  RETURN.

ENDIF.



          TRY.

*              lo_store->get_schema_by_name( iv_form_name = 'ZRGP_DELIVERYCHALAN' ).
               lo_store->get_schema_by_name(  iv_form_name = lv_form_name ).

              "   out->write( 'Schema found in form' ).
            CATCH zcx_fp_tmpl_store_error INTO DATA(lo_tmpl_error).
              "  out->write( 'No schema in form found' ).
              IF lo_tmpl_error->mv_http_status_code = 404 OR lo_tmpl_error->mv_http_status_code = 403 .
                "Upload service definition
*                  lo_store->set_schema(
*                    iv_form_name = 'GATEFORM'
*                    is_data      = VALUE #( note = '' schema_name = 'schema' xsd_schema = lo_fdp_util->get_xsd( ) )
*                  ).
              ELSE.

              ENDIF.
          ENDTRY.
**********************************************************************
          TYPES: BEGIN OF ty_schema_body,
                   xsd_schema  TYPE xstring,
                   schema_name TYPE c LENGTH 30,
                   note        TYPE c LENGTH 280,
                 END OF ty_schema_body.
          " TODO: variable is assigned but never used (ABAP cleaner)
          DATA lv_xdp TYPE ty_schema_body.
          lv_xdp = VALUE #( note        = ''
                            schema_name = 'schema'
                            xsd_schema  = lo_fdp_util->get_xsd( ) ).
**********************************************************************

          DATA(lt_keys)     = lo_fdp_util->get_keys( ).

          lt_keys[ name = 'UUID' ]-value = lt_data[ 1 ]-uuid.

          DATA(lt_xsd) = lo_fdp_util->get_xsd( ).
*            lt_xsd[ name = 'BILLINGDOCUMENT' ]-value = header[ 1 ]-BillingDocument.

          DATA(lv_text) = cl_web_http_utility=>decode_utf8( encoded = lt_xsd ).

          TRY.
              DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
              "out->write( 'Service data retrieved' ).
              DATA(lv_text2) = cl_web_http_utility=>decode_utf8( encoded = lv_xml ).
            CATCH cx_fp_fdp_error INTO DATA(lo_exception).
              DATA(lo_error3) = 3.
          ENDTRY..

*****************************************************************************

DATA(ls_template) = lo_store->get_template_by_name(
  iv_get_binary    = abap_true
  iv_form_name     = lv_form_name
  iv_template_name = lv_template_name
).



******************************************************************
*          DATA(ls_template) = lo_store->get_template_by_name(
*            iv_get_binary    = abap_true
*            iv_form_name     = 'ZNRGP_DELIVERYCHALAN'
*            iv_template_name = 'ZNRGP_DELIVERYCHALAN'
*          ).

          cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                     "  iv_pq_name      = CONV zde_pqname( ls_queue-printque )"'YYRESV' "'PRINT_QUEUE'
                                               iv_xml_data     = lv_xml
                                               iv_xdp_layout   = ls_template-xdp_template
                                               is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                     IMPORTING
                                     " TODO: variable is assigned but never used (ABAP cleaner)
                                               ev_trace_string = DATA(lv_trace)
                                               ev_pdf          = DATA(lv_pdf) ).


          DATA: lv_name TYPE c LENGTH 120.
          lv_name = |Invoice { lt_data[ 1 ]-gpnum }|.

          DATA(lv_gno) = VALUE #( lt_data[ 1 ]-gpnum OPTIONAL ).

**********************************************************************
          cl_print_queue_utils=>create_queue_item_by_data(
            iv_qname            = printque
            iv_print_data       = lv_pdf
            iv_name_of_main_doc = lv_name
            iv_itemid           = cl_print_queue_utils=>create_queue_itemid( )
          ).

        CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
          " out->write( 'Exception occurred.' ).
          DATA(lo_error) = 2.
      ENDTRY.

      IF lv_pdf IS NOT INITIAL.


      gs_htb-zattachment =  lv_pdf.
        gs_htb-filename = | { gs_htb-typ  } - { gs_htb-rgpno } |.
        gs_htb-minetype =  'application/pdf'.


      APPEND gs_htb to zbp_mm_app1_rv=>gt_att.





      ENDIF.



    ENDIF.


    result = VALUE #( FOR ls_output IN lt_data ( %tky = ls_output-%tky
                                                              %param = ls_output ) ).


**********************************************************************
  ENDMETHOD.


  METHOD RGP_NRGP_number.
**********************************************************************
            DATA: lv_seq TYPE zmm_app1_tb1-seqnum,
                  lv_gatenumber TYPE zmm_app1_tb1-rgpnrpactualno.

            DATA: lt_uphead TYPE TABLE of zmm_app1_tb1,
                  ls_uphead TYPE zmm_app1_tb1,
                  lt_upitem TYPE TABLE of zmm_app1_tb2,
                  ls_upitem TYPE zmm_app1_tb2.

            READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
            ENTITY _hdr
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_header)
            ENTITY _hdr BY \_Item1
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).

            DATA(ls_header) = VALUE #( lt_header[ 1 ] OPTIONAL ).

            if ls_header-Gptype is NOT INITIAL.

***********************************************************************
            GET TIME STAMP FIELD Data(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************

            SELECT SINGLE MAX( seqnum ) AS Seqnum,
                  gitdat
            FROM zmm_app1_tb1
            WHERE gitdat = @lv_date
            GROUP BY gitdat
            INTO @DATA(gs_seqno).

***********************************************************************
            if sy-subrc = 0 and gs_seqno-seqnum is not INITIAL.
                lv_seq = gs_seqno-seqnum + 1.
                lv_gatenumber = |{ ls_header-Gptype }{ lv_date }-{ lv_seq }|.
            else.
                lv_seq = '001'.
                lv_gatenumber = |{ ls_header-Gptype }{ lv_date }-{ lv_seq }|.
            endif.
***********************************************************************

          "--Header update
            MOVE-CORRESPONDING ls_header to ls_uphead.
            ls_uphead-seqnum = lv_seq.
            ls_uphead-rgpnrpactualno = lv_gatenumber.

            APPEND ls_uphead to lt_uphead.

          "item Update
          LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
          if <ls_item> is ASSIGNED.

                MOVE-CORRESPONDING <ls_item> to ls_upitem.
                ls_upitem-rgpnrpactualno = lv_gatenumber.
                APPEND ls_upitem to lt_upitem.
          ENDIF.
          ENDLOOP.

            if lt_uphead is NOT INITIAL.
                zbp_mm_app1_rv=>gt_gatehead = lt_uphead.
            ENDIF.

            if lt_upitem is NOT INITIAL.
               zbp_mm_app1_rv=>gt_gateiteam = lt_upitem.
            ENDIF.

            ENDIF.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    result = VALUE #( FOR ls_output IN lt_header ( %tky = ls_output-%tky
                                                              %param = ls_output ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc__ITM1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR _itm1 RESULT result.

    METHODS CrtItem FOR DETERMINE ON SAVE
       keys FOR _itm1~CrtItem.

    METHODS upditm FOR DETERMINE ON SAVE
       keys FOR _itm1~upditm.

    METHODS quant FOR VALIDATE ON SAVE
       keys FOR _itm1~quant.

ENDCLASS.

CLASS lhc__ITM1 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD CrtItem.

   DATA : lt_gpientry TYPE TABLE OF zmm_app1_tb2,
           ls_gpientry TYPE zmm_app1_tb2.
**********************************************************************
    READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
    ENTITY _itm1
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item).
    DATA(ls_item)  = lt_item[ 1 ].
**********************************************************************Valuation area by material
    READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
     ENTITY _hdr
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_header).
    DATA(ls_header) = lt_header[ 1 ].


**********************************************************************
    SELECT SINGLE MAX( itemno ) FROM zmm_app1_tb2
          WHERE uuid = @ls_item-uuid
          INTO @DATA(ls_sno).
    IF sy-subrc = 0 AND NOT ls_sno IS INITIAL.
      ls_gpientry-itemno = ls_sno + 10.
    ELSE.
      ls_gpientry-itemno = 10.
    ENDIF.
    ls_gpientry-createdat = ls_item-createdat.
    ls_gpientry-createdby = ls_item-createdby.
    ls_gpientry-curky = ls_item-curky.
    ls_gpientry-hsncode = ls_item-hsncode.
    ls_gpientry-plant = ls_item-plant.
    ls_gpientry-plantname = ls_item-plantname.
    ls_gpientry-storagelocation = ls_item-Storagelocation.
    ls_gpientry-lastchangedat = ls_item-lastchangedat.
    ls_gpientry-lastchangedby = ls_item-lastchangedby.
    ls_gpientry-uuid = ls_item-uuid.
    ls_gpientry-uom = ls_item-uom.
    ls_gpientry-totvalue = ls_item-quantity * ls_item-netprice.
    ls_gpientry-quantity = ls_item-quantity.
    ls_gpientry-netprice = ls_item-netprice.
    ls_gpientry-matnr = ls_item-matnr.
    ls_gpientry-maktx = ls_item-maktx.
    ls_gpientry-rgpnrpactualno = ls_header-Rgpnrpactualno.
**********************************************************************
    IF ls_item-matnr IS NOT INITIAL.
      SELECT SINGLE p~product AS matnr,
                    p~baseunit AS uom,
                    d~productdescription AS maktx,
                    v~inventoryvaluationprocedure AS ivp
      ,CAST( v~standardprice AS CURR( 13,2 ) )  AS stdamt , v~movingaverageprice AS map, CAST( b~consumptiontaxctrlcode AS CHAR( 30 ) )  AS hsn  FROM i_product WITH PRIVILEGED ACCESS AS p
      INNER JOIN i_productdescription_2 WITH PRIVILEGED ACCESS AS d
      ON d~product = p~product AND d~language = 'E'
      INNER JOIN i_productvaluationbasic WITH PRIVILEGED ACCESS AS v  "for standard price of material
      ON v~product = p~product AND v~valuationarea = @ls_header-plant
      INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b " For hsn code
      ON b~product = p~product AND b~plant = @ls_header-plant
      WHERE p~product = @ls_item-matnr  INTO @DATA(ls_mat).
      IF ls_mat IS NOT INITIAL.
        IF ls_mat-ivp = 'S'.
          ls_gpientry-netprice = ls_mat-stdamt.
        ELSE.
          ls_gpientry-netprice = ls_mat-map.
        ENDIF.
        ls_gpientry-totvalue = ls_item-quantity * ls_gpientry-netprice.
      ENDIF.
    ENDIF.
**********************************************************************
    APPEND ls_gpientry TO lt_gpientry.
    zbp_mm_app1_rv=>gt_gpitm = lt_gpientry.

  ENDMETHOD.

  METHOD upditm.

  DATA : it_update TYPE TABLE OF zmm_app1_tb2,
           wa_update TYPE zmm_app1_tb2,
           it_header TYPE TABLE OF zmm_app1_tb1,
           wa_header TYPE zmm_app1_tb1.
    DATA : totamt TYPE p LENGTH 8 DECIMALS 2.
    totamt = 0.
    READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
        ENTITY _hdr
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header)
        ENTITY _hdr BY \_item1
         ALL FIELDS WITH  CORRESPONDING #( keys )
      RESULT DATA(it_item).
    DATA(ls_header) = lt_header[ 1 ].

*  READ ENTITIES OF zmm_app1_rv IN LOCAL MODE
*  ENTITY _itm1
*  ALL FIELDS WITH  CORRESPONDING #( keys )
*  RESULT data(it_item).


    LOOP AT it_item INTO DATA(ls_item).
      wa_update-createdat = ls_item-createdat.
      wa_update-createdby = ls_item-createdby.
      wa_update-curky = ls_item-curky.
      wa_update-hsncode = ls_item-hsncode.
      wa_update-plant   = LS_ITEM-plant.
      wa_update-plantname = LS_ITEM-plantname.
      wa_update-storagelocation = ls_item-Storagelocation.
      wa_update-lastchangedat = ls_item-lastchangedat.
      wa_update-lastchangedby = ls_item-lastchangedby.
      wa_update-uuid = ls_item-uuid.
      wa_update-itemno = ls_item-itemno.
      wa_update-uom = ls_item-uom.
      wa_update-totvalue = ls_item-quantity * ls_item-netprice.
      wa_update-quantity = ls_item-quantity.
      wa_update-netprice = ls_item-netprice.
      wa_update-matnr = ls_item-matnr.
      wa_update-maktx = ls_item-Maktx.

**************************************
*      wa_update-plant = ls_item-plant.
*      wa_update-plantname = ls_item-plantname.

**********************************************************************
      IF ls_item-matnr IS NOT INITIAL.
        SELECT SINGLE p~product AS matnr,
                      p~baseunit AS uom,
                      d~productdescription AS maktx,
*                      p~plant AS PLANT,
*                      d~plantname AS plantname,
                      v~inventoryvaluationprocedure AS ivp,
                      p~producttype AS prtype
        ,CAST( v~standardprice AS CURR( 13,2 ) )  AS stdamt , v~movingaverageprice AS map, CAST( b~consumptiontaxctrlcode AS CHAR( 30 ) )  AS hsn
          FROM i_product WITH PRIVILEGED ACCESS AS p
        INNER JOIN i_productdescription_2 WITH PRIVILEGED ACCESS AS d
        ON d~product = p~product AND d~language = 'E'
        INNER JOIN i_productvaluationbasic WITH PRIVILEGED ACCESS AS v  "for standard price of material
        ON v~product = p~product AND v~valuationarea = @ls_header-plant
        INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b " For hsn code
        ON b~product = p~product AND b~plant = @ls_header-plant
        WHERE p~product = @ls_item-matnr  INTO @DATA(ls_mat).

        IF ls_mat IS NOT INITIAL.
          IF ls_mat-ivp = 'S'.
            wa_update-netprice = ls_mat-stdamt.
          ELSE.
            wa_update-netprice = ls_mat-map.
          ENDIF.
          wa_update-totvalue = ls_item-quantity * wa_update-netprice.
        ENDIF.
      ENDIF.

**********************************************************************
      totamt = totamt + wa_update-totvalue.
      MOVE-CORRESPONDING ls_header TO wa_header.
      wa_header-gpvalue = totamt.
**********************************************************************
      APPEND wa_update TO it_update.

    ENDLOOP.
**********************************************************************
    APPEND wa_header TO it_header.
* SELECT sum( totvalue ) FROM zmm_app1_tb2 WHERE uuid = @ls_header-Uuid into @totamt.
*
* MOVE-CORRESPONDING ls_header TO wa_header.
* wa_header-gpvalue = totamt.



**********************************************************************
    zbp_mm_app1_rv=>gt_upitm = it_update.
**********************************************************************
    zbp_mm_app1_rv=>gt_uptot = it_header.

  ENDMETHOD.

  METHOD quant.

   READ ENTITIES OF zmm_app1_rv IN LOCAL MODE ENTITY _itm1
*  ALL FIELDS WITH CORRESPONDING #( keys )
  FIELDS ( quantity )  WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item).
    DATA(ls_item) = lt_item[ 1 ].
    IF ls_item-quantity <= 0 .
      APPEND VALUE #( %tky = ls_item-%tky  ) TO failed-_itm1.
      APPEND VALUE #( %tky = keys[ 1 ]-%tky
      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
  text = |Quantity should be more than { ls_item-quantity }|
      ) ) TO reported-_itm1.
    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_APP1_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.
CLASS lsc_zmm_app1_rv IMPLEMENTATION.

  METHOD save_modified.
**********************************************************************
    IF create-_hdr IS NOT INITIAL.
      IF zbp_mm_app1_rv=>gt_gphdr IS NOT INITIAL.
        DATA(lt_gpentry) = zbp_mm_app1_rv=>gt_gphdr.
        MODIFY zmm_app1_tb1 FROM TABLE @lt_gpentry.
      ENDIF.
    ENDIF.
    IF create-_itm1 IS NOT INITIAL.
      IF zbp_mm_app1_rv=>gt_gpitm IS NOT INITIAL.
        DATA(lt_gpitem) = zbp_mm_app1_rv=>gt_gpitm.
        MODIFY zmm_app1_tb2 FROM TABLE @lt_gpitem.
      ENDIF.
    ENDIF.
**********************************************************************
    IF update-_hdr IS NOT INITIAL.
      IF zbp_mm_app1_rv=>gt_uphdr IS NOT INITIAL.
        DATA(it_uphdr) = zbp_mm_app1_rv=>gt_uphdr.
        MODIFY zmm_app1_tb1 FROM TABLE @it_uphdr.
      ENDIF.
    ENDIF.

    IF  zbp_mm_app1_rv=>gt_checkd IS NOT INITIAL.
      DATA(it_checkdt) = zbp_mm_app1_rv=>gt_checkd.
      MODIFY zmm_app1_tb1 FROM TABLE @it_checkdt.
    ENDIF.

    IF update-_itm1 IS NOT INITIAL.
      IF zbp_mm_app1_rv=>gt_upitm IS NOT INITIAL.
        DATA(lt_gipitem) = zbp_mm_app1_rv=>gt_upitm.
        MODIFY zmm_app1_tb2 FROM TABLE @lt_gipitem.
      ENDIF.
    ENDIF.
**********************************************************************
    IF delete-_hdr IS NOT INITIAL.
      LOOP AT delete-_hdr INTO DATA(ls_gpentry).
        DELETE FROM zmm_app1_tb2 WHERE uuid = @ls_gpentry-uuid.
        DELETE FROM zmm_app1_tb1 WHERE uuid =  @ls_gpentry-uuid.
*        SELECT SINGLE * FROM zmm_app1_tb1 WHERE uuid = @ls_gpentry-uuid INTO @DATA(ls_data).
*        ls_data-mark2 = 'X'.
*        MODIFY zmm_app1_tb1 FROM  @ls_data.

      ENDLOOP.

    ENDIF.

    IF delete-_itm1 IS NOT INITIAL.
      LOOP AT delete-_itm1 INTO DATA(ls_gipentry).
        DELETE FROM zmm_app1_tb2 WHERE uuid = @ls_gipentry-uuid AND itemno = @ls_gipentry-itemno.
      ENDLOOP.
    ENDIF.
**********************************************************************

*******************************print view***************************************
    IF zbp_mm_app1_rv=>gv_print_data IS NOT INITIAL.
      DATA(lv_print_data) = zbp_mm_app1_rv=>gv_print_data.
      DATA(lv_qitem_id) = zbp_mm_app1_rv=>gv_qitem_id.
      DATA(lv_docno) = zbp_mm_app1_rv=>gv_gpnum.
      DATA(lv_type) = zbp_mm_app1_rv=>gv_gptype.

      TRY.
          DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
        CATCH cx_abap_context_info_error INTO DATA(lv_error).
          DATA(lv_1) = 1.
      ENDTRY.
      IF lv_user = '9980000070' OR lv_user = '9980000182' OR lv_user = '9980000023' .
        cl_print_queue_utils=>create_queue_item_by_data(
          EXPORTING
            iv_qname            = 'ZDEVPRINT'
            iv_print_data       =  lv_print_data
            iv_name_of_main_doc = lv_type && lv_docno
            iv_itemid           = lv_qitem_id
*            iv_pages            =
*            iv_number_of_copies =
*            it_attachment_data  =
          IMPORTING
            ev_err_msg          = DATA(gs_error_msg1)
*          RECEIVING
*            rv_itemid           =
        ).
      ELSE.
        cl_print_queue_utils=>create_queue_item_by_data(
  EXPORTING
    iv_qname            = 'ZNRGP_DELIVERYCHALAN'
    iv_print_data       =  lv_print_data
    iv_name_of_main_doc = lv_type && lv_docno
    iv_itemid           = lv_qitem_id
*            iv_pages            =
*            iv_number_of_copies =
*            it_attachment_data  =
  IMPORTING
    ev_err_msg          = DATA(gs_error_msg)
*          RECEIVING
*            rv_itemid           =
).

      ENDIF.

    ENDIF.
**********************************************************************


    IF zbp_mm_app1_rv=>gt_uptot IS NOT INITIAL.
      DATA(lt_header) = zbp_mm_app1_rv=>gt_uptot.
      MODIFY zmm_app1_tb1 FROM TABLE @lt_header.
    ENDIF.

   if zbp_mm_app1_rv=>gt_att is not inITIAL.
*   modify zmm_app1_chtb from table @zbp_mm_app1_rv=>gt_att.

     modify zmm_app1_chtb1 from table @zbp_mm_app1_rv=>gt_att.

   endif.

""----RGP/NRGP Gate Entry Update
    if zbp_mm_app1_rv=>gt_gatehead is NOT INITIAL.
        MODIFY zmm_app1_tb1 FROM TABLE @zbp_mm_app1_rv=>gt_gatehead.
    ENDIF.

    if zbp_mm_app1_rv=>gt_gateiteam is NOT INITIAL.
        MODIFY zmm_app1_tb2 FROM TABLE @zbp_mm_app1_rv=>gt_gateiteam.
    ENDIF.
  ENDMETHOD.



  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
