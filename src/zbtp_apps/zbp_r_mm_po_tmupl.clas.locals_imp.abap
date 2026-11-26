CLASS lhc_upload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Upload RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Upload RESULT result.

    METHODS ExcelUpload FOR MODIFY
      IMPORTING keys FOR ACTION Upload~ExcelUpload RESULT result.

    METHODS long_msg
      IMPORTING severity      TYPE if_abap_behv_message=>t_severity
                text          TYPE string
      RETURNING VALUE(result) TYPE REF TO if_abap_behv_message.
ENDCLASS.


CLASS lhc_upload IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.


  METHOD get_instance_features.
    READ ENTITIES OF zr_mm_po_tmupl IN LOCAL MODE
      ENTITY Upload
        FIELDS ( Status FileName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_upl).

    result = VALUE #( FOR u IN lt_upl
      ( %tky = u-%tky
        " uploaded records are final
        %update      = COND #( WHEN u-Status = 'S' THEN if_abap_behv=>fc-o-disabled
                               ELSE if_abap_behv=>fc-o-enabled )
        %action-Edit = COND #( WHEN u-Status = 'S' THEN if_abap_behv=>fc-o-disabled
                               ELSE if_abap_behv=>fc-o-enabled )
        " upload only from the saved record, once
        %action-ExcelUpload = COND #( WHEN u-%is_draft = if_abap_behv=>mk-on
                                        OR u-Status = 'S'
                                        OR u-FileName IS INITIAL
                                      THEN if_abap_behv=>fc-o-disabled
                                      ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.


  METHOD ExcelUpload.
    READ ENTITIES OF zr_mm_po_tmupl IN LOCAL MODE
      ENTITY Upload
        FIELDS ( Attachment )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_upl).

    LOOP AT lt_upl INTO DATA(ls_upl).
      DATA(ls_res) = zcl_mm_po_tm_upload=>prepare( ls_upl-Attachment ).

      " any error: report all, change nothing
      IF ls_res-errors IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_upl-%tky ) TO failed-upload.
        LOOP AT ls_res-errors INTO DATA(lv_err).
          APPEND VALUE #( %tky = ls_upl-%tky
                          %msg = long_msg( severity = if_abap_behv_message=>severity-error
                                                        text     = lv_err ) )
                 TO reported-upload.
        ENDLOOP.
        CONTINUE.
      ENDIF.

      " carriers and freight orders in one call; their checks run again at save
      MODIFY ENTITIES OF zr_mm_po_tmcar
        ENTITY Carrier
          CREATE FIELDS ( PurchaseOrder PurchaseOrderItem Carrier ) WITH ls_res-car_c
          CREATE BY \_FreightOrder FIELDS ( FreightOrder ValidFrom ValidTo ) WITH ls_res-fo_c
        ENTITY FreightOrder
          UPDATE FIELDS ( ValidFrom ValidTo ) WITH ls_res-fo_u
        FAILED   DATA(lt_failed)
        REPORTED DATA(lt_reported).

      IF lt_failed IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_upl-%tky ) TO failed-upload.
        LOOP AT lt_reported-carrier INTO DATA(ls_rc) WHERE %msg IS BOUND.
          APPEND VALUE #( %tky = ls_upl-%tky %msg = ls_rc-%msg ) TO reported-upload.
        ENDLOOP.
        LOOP AT lt_reported-freightorder INTO DATA(ls_rf) WHERE %msg IS BOUND.
          APPEND VALUE #( %tky = ls_upl-%tky %msg = ls_rf-%msg ) TO reported-upload.
        ENDLOOP.
        APPEND VALUE #( %tky = ls_upl-%tky
                        %msg = long_msg( severity = if_abap_behv_message=>severity-error
                                                      text     = `Upload not done. An allocation in the file may be open in edit mode.` ) )
               TO reported-upload.
        CONTINUE.
      ENDIF.

      " result on the upload record
      DATA(lv_msg) = zcl_mm_po_tm_upload=>summary( ls_res ).

      MODIFY ENTITIES OF zr_mm_po_tmupl IN LOCAL MODE
        ENTITY Upload
          UPDATE FIELDS ( Status RowsRead CarCreated CarUpdated FoCreated FoUpdated Message )
          WITH VALUE #( ( %tky       = ls_upl-%tky
                          Status     = 'S'
                          RowsRead   = ls_res-rows
                          CarCreated = lines( ls_res-car_c )
                          CarUpdated = lines( ls_res-car_u )
                          FoCreated  = ls_res-focount
                          FoUpdated  = lines( ls_res-fo_u )
                          Message    = lv_msg ) ).

      APPEND VALUE #( %tky = ls_upl-%tky
                      %msg = long_msg( severity = if_abap_behv_message=>severity-success
                                                    text     = lv_msg ) )
             TO reported-upload.
    ENDLOOP.

    READ ENTITIES OF zr_mm_po_tmupl IN LOCAL MODE
      ENTITY Upload
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD long_msg.
    " new_message_with_text cuts after 50 characters: split the text
    " over the 4 variables of ZMM_PO_TM_MSG 001 (&1&2&3&4)
    DATA lt_v TYPE STANDARD TABLE OF symsgv WITH EMPTY KEY.
    DATA(lv_rest) = text.
    WHILE lv_rest IS NOT INITIAL AND lines( lt_v ) < 4.
      DATA(lv_len) = nmin( val1 = 50 val2 = strlen( lv_rest ) ).
      " a blank at the end of a variable is lost: move it to the next one
      WHILE lv_len > 1 AND substring( val = lv_rest off = lv_len - 1 len = 1 ) = ` `.
        lv_len = lv_len - 1.
      ENDWHILE.
      APPEND substring( val = lv_rest len = lv_len ) TO lt_v.
      lv_rest = substring( val = lv_rest off = lv_len ).
    ENDWHILE.
    result = new_message( id       = 'ZMM_PO_TM_MSG'
                          number   = '001'
                          severity = severity
                          v1       = VALUE #( lt_v[ 1 ] OPTIONAL )
                          v2       = VALUE #( lt_v[ 2 ] OPTIONAL )
                          v3       = VALUE #( lt_v[ 3 ] OPTIONAL )
                          v4       = VALUE #( lt_v[ 4 ] OPTIONAL ) ).
  ENDMETHOD.

ENDCLASS.
