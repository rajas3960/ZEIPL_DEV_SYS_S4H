CLASS lhc_upload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Upload RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Upload RESULT result.

    METHODS ExcelUpload FOR MODIFY
      IMPORTING keys FOR ACTION Upload~ExcelUpload RESULT result.
ENDCLASS.


CLASS lhc_upload IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.


  METHOD get_instance_features.
    READ ENTITIES OF zr_sd_so_tmupl IN LOCAL MODE
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
    READ ENTITIES OF zr_sd_so_tmupl IN LOCAL MODE
      ENTITY Upload
        FIELDS ( Attachment )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_upl).

    LOOP AT lt_upl INTO DATA(ls_upl).
      DATA(ls_res) = zcl_sd_so_tm_upload=>prepare( ls_upl-Attachment ).

      " any error: report all, change nothing
      IF ls_res-errors IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_upl-%tky ) TO failed-upload.
        LOOP AT ls_res-errors INTO DATA(lv_err).
          APPEND VALUE #( %tky = ls_upl-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = lv_err ) )
                 TO reported-upload.
        ENDLOOP.
        CONTINUE.
      ENDIF.

      " carriers and freight orders in one call; their checks run again at save
      IF ls_res-car_c IS NOT INITIAL OR ls_res-fo_c IS NOT INITIAL.
        MODIFY ENTITIES OF zr_sd_so_tmcar
          ENTITY Carrier
            CREATE FIELDS ( SalesOrder SalesOrderItem Carrier ) WITH ls_res-car_c
            CREATE BY \_FreightOrder FIELDS ( FreightOrder ) WITH ls_res-fo_c
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
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = `Not uploaded: an entry may be in edit mode` ) )
                 TO reported-upload.
          CONTINUE.
        ENDIF.
      ENDIF.

      " result on the upload record
      DATA(lv_msg) = zcl_sd_so_tm_upload=>summary( ls_res ).

      MODIFY ENTITIES OF zr_sd_so_tmupl IN LOCAL MODE
        ENTITY Upload
          UPDATE FIELDS ( Status RowsRead CarCreated CarUpdated FoCreated FoUpdated Message )
          WITH VALUE #( ( %tky       = ls_upl-%tky
                          Status     = 'S'
                          RowsRead   = ls_res-rows
                          CarCreated = lines( ls_res-car_c )
                          CarUpdated = ls_res-carextended
                          FoCreated  = ls_res-focount
                          FoUpdated  = 0
                          Message    = lv_msg ) ).

      APPEND VALUE #( %tky = ls_upl-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = lv_msg ) )
             TO reported-upload.
    ENDLOOP.

    READ ENTITIES OF zr_sd_so_tmupl IN LOCAL MODE
      ENTITY Upload
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.
