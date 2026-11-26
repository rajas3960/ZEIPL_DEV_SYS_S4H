CLASS zbp_mm_apps01_rv DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zmm_apps01_rv.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_compare,
        supplierquotation   TYPE zmm_apps01_itb-supplierquotation,
        requestforquotation TYPE zmm_apps01_itb-requestforquotation,
        supplier            TYPE zmm_apps01_itb-supplier,
        compare             TYPE zmm_apps01_itb-compare,
      END OF ty_compare.
    TYPES: BEGIN OF ty_award,
             rfq TYPE zmm_apps01_tb-rfq,
             sq  TYPE zmm_apps01_tb-sq,
           END OF ty_award.

    CLASS-DATA gt_award TYPE STANDARD TABLE OF ty_award.

    CLASS-DATA gt_compare TYPE STANDARD TABLE OF ty_compare.
ENDCLASS.



CLASS ZBP_MM_APPS01_RV IMPLEMENTATION.
ENDCLASS.
