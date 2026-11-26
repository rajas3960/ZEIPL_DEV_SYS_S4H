CLASS zsd_ewaybill_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_edoc_adaptor_cloud .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSD_EWAYBILL_CLASS IMPLEMENTATION.


  METHOD if_edoc_adaptor_cloud~change_edocument_type.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~change_form.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~change_invoice_type.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~get_variable_key.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~is_relevant.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~restrict_cancel.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~set_output_data.

    ASSIGN COMPONENT 'VTWEG' OF STRUCTURE is_source_data TO FIELD-SYMBOL(<fs_vtweg>).

    IF <fs_vtweg> IS ASSIGNED AND <fs_vtweg> = '60'.


      ASSIGN COMPONENT 'SUB_SUPPLY_TYPE' OF STRUCTURE cs_output_data TO FIELD-SYMBOL(<fs_sub_supply>).

      IF <fs_sub_supply> IS ASSIGNED.
        <fs_sub_supply> = '4'.
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
