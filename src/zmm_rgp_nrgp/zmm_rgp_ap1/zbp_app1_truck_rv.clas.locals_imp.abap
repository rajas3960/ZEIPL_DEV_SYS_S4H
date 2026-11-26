CLASS lhc_ZAPP1_TRUCK_RV DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zapp1_truck_rv RESULT result.

ENDCLASS.

CLASS lhc_ZAPP1_TRUCK_RV IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
