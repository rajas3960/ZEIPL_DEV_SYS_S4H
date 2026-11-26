CLASS zbp_mm_ih_inventry DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zmm_ih_inventry.
    CLASS-DATA: cv_migo_doc  TYPE RESPONSE FOR MAPPED  i_materialdocumenttp.
    PUBLIC SECTION.
        CLASS-DATA : gt_migoup TYPE TABLE OF ZMM_APP04_HDB,
                     gt_item TYPE TABLE OF ZMM_APP04_IDB,
                     gt_upitem TYPE TABLE OF ZMM_APP04_IDB.

        CLASS-DATA: cv_Indlv_doc TYPE RESPONSE FOR MAPPED  I_InboundDeliveryTp.
ENDCLASS.



CLASS ZBP_MM_IH_INVENTRY IMPLEMENTATION.
ENDCLASS.
