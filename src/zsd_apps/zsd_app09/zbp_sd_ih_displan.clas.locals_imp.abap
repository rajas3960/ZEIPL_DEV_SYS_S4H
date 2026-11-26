CLASS lhc_DispHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR DispHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR DispHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR DispHead RESULT result.

    METHODS ExcelUpload FOR MODIFY
       keys FOR ACTION DispHead~ExcelUpload RESULT result.
    METHODS attach FOR DETERMINE ON MODIFY
      keys FOR DispHead~attach.

ENDCLASS.

CLASS lhc_DispHead IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ExcelUpload.
***********************************************************************
    TYPES : BEGIN OF ty_excel_i,
              slno           type c LENGTH 2,
              dispatchdate   TYPE string,
              customer       TYPE string,
              plant          TYPE string,
              transmode      type string,
              salesorder     TYPE string,
              salesorderitem TYPE string,
              material       TYPE string,
              baseunit       TYPE string,
              totalorderqty  TYPE string,
              dispplantqty   TYPE string,
              Vehicleno     TYPE string,
              numseq         TYPE n LENGTH 15,
            END OF ty_excel_i.
***********************************************************************
   DATA :  lt_excel_i       TYPE STANDARD TABLE OF ty_excel_i,
           lt_itd         TYPE TABLE OF ZSD_APP09_IDB,
           ls_itd         TYPE  ZSD_APP09_IDB,
           lo_table_desc_h  TYPE REF TO cl_abap_tabledescr,
           lo_struc_descr_h TYPE REF TO cl_abap_structdescr,
           lo_table_desc_i  TYPE REF TO cl_abap_tabledescr,
           lo_struc_descr_i TYPE REF TO cl_abap_structdescr,
           lv_index       TYPE sy-index.
***********************************************************************
            FIELD-SYMBOLS : <lfs_col_header> TYPE any.

***********************************************************************
            READ ENTITIES OF zsd_ih_displan IN LOCAL MODE
            ENTITY DispHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_attach)
            FAILED DATA(lt_failed).
***********************************************************************
            DATA(ls_hdr) = VALUE #( lt_attach[ 1 ] OPTIONAL ).
            DATA(lv_suid) = VALUE #( lt_attach[ 1 ]-uuid OPTIONAL ).
            DATA(lv_attach) = VALUE #( lt_attach[ 1 ]-attachment OPTIONAL ).
***********************************************************************
            if lv_attach is NOT INITIAL.

                DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attach )->read_access(  ).
                DATA(lo_worksheet_i) = lo_xlsx->get_workbook(  )->worksheet->at_position( 1 ).
                DATA(lo_select_patrn_i) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(  )->get_pattern(  ).
                DATA(lo_execute_i) = lo_worksheet_i->select( lo_select_patrn_i )->row_stream(  )->operation->write_to( REF #( lt_excel_i  ) ).
                lo_execute_i->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value  )->if_xco_xlsx_ra_operation~execute(  ).

                DATA(lo_select_patrn_h) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(  )->get_pattern(  ).

            ENDIF.
***********************************************************************
    TRY .
        lo_table_desc_i ?= cl_abap_tabledescr=>describe_by_data( p_data = lt_excel_i ).
        lo_struc_descr_i ?= lo_table_desc_i->get_table_line_type(  ).
        DATA(lv_no_of_cols_i) = lines( lo_struc_descr_i->components ).

      CATCH cx_sy_move_cast_error.

    ENDTRY.

        DELETE lt_excel_i INDEX 1.
***********************************************************************
        if lt_excel_i is NOT INITIAL.

                SELECT * FROM ZSD_APP09_IDB WITH PRIVILEGED ACCESS
                WHERE uuid is NOT INITIAL
                INTO TABLE @DATA(lt_seq).

                SELECT SINGLE max( numseq  ) FROM ZSD_APP09_IDB WITH PRIVILEGED ACCESS
                WHERE uuid is NOT INITIAL
                into @DATA(ls_max).

                DATA(lv_count) = lines( lt_seq  ).

***********************************************************************
*        SELECT SINGLE MAX( gateentryid ) AS gateentryid
*            FROM ZSD_APP05_HDB
*            INTO @DATA(gs_id).
*
*        if gs_id is not INITIAL.
*            gateid = gs_id + 1.
*         else.
*            gateid = '1000000001'.
*        endif.

************************************************************************
            sort lt_excel_i ASCENDING BY salesorder salesorderitem.
            DATA(count) = 1.
            LOOP AT lt_excel_i ASSIGNING FIELD-SYMBOL(<fs_excel>).
                if <fs_excel> is ASSIGNED.
                        if ls_max is NOT INITIAL.
                        <fs_excel>-numseq = ls_max + count.
                            ELSE.
                        <fs_excel>-numseq =  count.
                        ENDIF.
                ENDIF.
                count += 1.

            ENDLOOP.

                MODIFY ENTITIES OF zsd_ih_displan IN LOCAL MODE
                ENTITY DispHead
                CREATE BY \_SalesItem
                AUTO FILL CID
                FIELDS ( Salesorder Salesorderitem Slno Numseq Dispatchdate Customer
                        Plant Transmode Material Baseunit Totalorderqty Dispplantqty Vehicleno )
                WITH VALUE #( for ls_attach in lt_attach
                                (  %is_draft = ls_attach-%is_draft
                                    %key =  CORRESPONDING #( ls_attach )
                                   %target = VALUE #( for ls_att in lt_excel_i
                                    ( %cid = |CID{ ls_att-numseq }|

                                       Salesorder = ls_att-salesorder
                                       Salesorderitem = ls_att-salesorderitem
                                       Slno = ls_att-slno
                                       Numseq = ls_att-numseq
                                       Dispatchdate = ls_att-dispatchdate
                                       Customer = ls_att-customer
                                       Plant = ls_att-plant
                                       Transmode = ls_att-transmode
                                       Material = ls_att-material
                                       baseunit = ls_att-BaseUnit
                                       Totalorderqty = ls_att-totalorderqty
                                       Dispplantqty = ls_att-dispplantqty
                                       Vehicleno = ls_att-Vehicleno
                                        ) )
                                    ) )
                          REPORTED reported
                          fAILED failed
                          MAPPED mapped.

***********************************************************************
        if mapped-salesorder is not INITIAL.

                MODIFY ENTITIES OF zsd_ih_displan IN LOCAL MODE
                ENTITY DispHead
                UPDATE
                FIELDS ( Status )
                WITH VALUE #( for key IN keys
                            ( %tky = ls_hdr-%tky
                         Status = 'X'
                         %control-Status = if_abap_behv=>mk-on
                         ) ).

        ENDIF.
***********************************************************************
        ENDIF.
***********************************************************************

    result = VALUE #( FOR ls_attach IN lt_attach
                         ( %tky   = ls_attach-%tky
                           %param = ls_attach ) ).
***********************************************************************
  ENDMETHOD.
***********************************************************************

  METHOD attach.
***********************************************************************
            READ ENTITIES OF zsd_ih_displan IN LOCAL MODE
            ENTITY DispHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_attach)
            FAILED DATA(lt_failed).
***********************************************************************
        DATA(ls_hdr) = VALUE #( lt_attach[ 1 ] OPTIONAL ).
***********************************************************************
            if ls_hdr-Attachment is not INITIAL.

            data(lv_fileName) = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
            data(FILENAME)    = 'DispatchPlan.xlsx'.

                MODIFY ENTITIES OF zsd_ih_displan IN LOCAL MODE
                ENTITY DispHead
                UPDATE
                FIELDS ( Filename Minetype )
                WITH VALUE #( for key IN keys
                            ( %tky = ls_hdr-%tky
                         Filename = FILENAME
                         Minetype = lv_fileName
                         %control-Filename = if_abap_behv=>mk-on
                         %control-Minetype = if_abap_behv=>mk-on
                         ) ).
            ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_SalesOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR SalesOrder RESULT result.

ENDCLASS.

CLASS lhc_SalesOrder IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZSD_IH_DISPLAN DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSD_IH_DISPLAN IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
