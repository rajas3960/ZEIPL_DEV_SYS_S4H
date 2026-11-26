CLASS zbp_sd_ih_weight DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zsd_ih_weight.
  PUBLIC SECTION.
    CLASS-DATA: gt_head  TYPE TABLE OF ZSD_APP05_HDB,
                gt_Migohead  TYPE TABLE OF ZSD_APP05_HDB,
                gt_item TYPE TABLE OF ZSD_APP05_IDB,
                gt_upwtitem TYPE TABLE of ZSD_APP05_IDB.

    CLASS-DATA: cv_dlv_doc TYPE RESPONSE FOR MAPPED  I_OutboundDeliveryTP,
                cv_dlvitem_doc TYPE RESPONSE FOR MAPPED  I_OutboundDeliveryTP,
                cv_mat_doc TYPE RESPONSE FOR MAPPED I_MaterialDocumentTP.
ENDCLASS.



CLASS ZBP_SD_IH_WEIGHT IMPLEMENTATION.
ENDCLASS.
