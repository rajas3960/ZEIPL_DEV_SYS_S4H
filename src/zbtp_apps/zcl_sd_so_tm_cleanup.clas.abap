CLASS zcl_sd_so_tm_cleanup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS ZCL_SD_SO_TM_CLEANUP IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " one-time: test rows saved before the ALPHA conversion (SO '1469'
    " instead of '0000001469') - active and draft tables
    DELETE FROM zsd_so_tmfo    WHERE salesorder = '1469'.
    out->write( |zsd_so_tmfo:    { sy-dbcnt } deleted| ).
    DELETE FROM zsd_so_tmcar   WHERE salesorder = '1469'.
    out->write( |zsd_so_tmcar:   { sy-dbcnt } deleted| ).
    DELETE FROM zsd_so_tmfo_d  WHERE salesorder = '1469'.
    out->write( |zsd_so_tmfo_d:  { sy-dbcnt } deleted| ).
    DELETE FROM zsd_so_tmcar_d WHERE salesorder = '1469'.
    out->write( |zsd_so_tmcar_d: { sy-dbcnt } deleted| ).
    COMMIT WORK.
  ENDMETHOD.
ENDCLASS.
