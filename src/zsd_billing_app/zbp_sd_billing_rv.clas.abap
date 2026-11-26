CLASS zbp_sd_billing_rv DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zsd_billing_rv.
  PUBLIC SECTION.

    CLASS-DATA gt_hdrdata
      TYPE STANDARD TABLE OF zsd_billing_tb.

    CLASS-DATA gt_lindata
      TYPE STANDARD TABLE OF zsd_billing_itb.

ENDCLASS.

CLASS zbp_sd_billing_rv IMPLEMENTATION.
ENDCLASS.
