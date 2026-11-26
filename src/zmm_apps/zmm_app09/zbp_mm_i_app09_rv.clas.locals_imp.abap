CLASS lhc_ZMM_I_APP09_RV DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zmm_i_app09_rv RESULT result.

    METHODS gt_getmail FOR MODIFY
      IMPORTING keys FOR ACTION zmm_i_app09_rv~gt_getmail .
    METHODS gt_related FOR MODIFY
      IMPORTING keys FOR ACTION zmm_i_app09_rv~gt_related.

ENDCLASS.

CLASS lhc_ZMM_I_APP09_RV IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD gt_getmail.

    DATA: lv_passcode TYPE string,
          lv_random   TYPE i.
    DATA: lv_sender   TYPE c LENGTH 512,
          lv_reciever TYPE c LENGTH 512.
    DATA : wa_hdr  type  zmm_a_app09_htb .
    READ ENTITIES OF zmm_i_app09_rv IN LOCAL MODE
ENTITY zmm_i_app09_rv
  ALL FIELDS
  WITH CORRESPONDING #( keys )
RESULT DATA(lt_request).

data(ls_hdr) = lt_request[ 1 ].

    TRY.
        cl_abap_random_int=>create(
          seed = cl_abap_random=>seed( )
          min  = 100000
          max  = 999999
        )->get_next(
        RECEIVING
          value = lv_random ).
      CATCH cx_abap_random  .
        lv_random = 100000.
    ENDTRY.
    lv_passcode = lv_random.
**********************************************************************
    IF lt_request[ 1 ]-EmailAddress IS NOT INITIAL.
      lv_reciever = ls_hdr-EmailAddress.
      DATA(lv_date) = cl_abap_context_info=>get_system_date( ).

      DATA(lv_content) = |  | &&
      |<p>Dear { ls_hdr-OrganizationName1 },</p>| &&

      |<p>Your one-time passcode for accessing the Supplier Portal is:</p>| &&

      |<h2>{ lv_passcode }</h2>| &&

      |<p>Please enter this passcode on the Supplier Portal to continue.</p> | &&

      | <p>If you did not request this passcode, please ignore this email.</p> | &&

      | <p>Regards,<br> | &&
      | EPIL Team</p> |
      .

      lv_sender = 'sap.head@envirocareinfra.in'.

      TRY.
          DATA(lo_mail) = cl_bcs_mail_message=>create_instance(  ).
          lo_mail->set_sender( lv_sender ).
          lo_mail->set_subject( 'Supplier Portal PassCode' ) .
          lo_mail->add_recipient( lv_reciever ).
          lo_mail->set_main(
             cl_bcs_mail_textpart=>create_instance(
                 iv_content      = lv_content
                 iv_content_type = 'text/html'
             )
         ).
          lo_mail->send(
            IMPORTING et_status = DATA(lt_status)
        ).

          DATA(wa_em) = lt_status[ 1 ].
          IF wa_em-status = 'S'.
          MOVE-CORRESPONDING ls_hdr to wa_hdr.
          wa_hdr-status = 'Passcode is Geneated'.
          wa_hdr-passcode = lv_passcode.
          wa_hdr-emaiaddress = ls_hdr-EmailAddress.
          apPEND wa_hdr to zbp_mm_i_app09_rv=>gt_hdr.
          APPEND VALUE #( %tky = ls_hdr-%tky
      %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                              text = 'PassCode is Generated' )
                               ) TO reported-zmm_i_app09_rv.
          ENDIF.
        CATCH cx_bcs_mail INTO DATA(lx_mail1).
          DATA(lv_cxemail) = 1.
          " TODO: log failure
      ENDTRY.

    ELSE.
      APPEND VALUE #( %tky = lt_request[ 1 ]-%tky ) TO failed-zmm_i_app09_rv.
      APPEND VALUE #( %tky = lt_request[ 1 ]-%tky
      %msg =  new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = 'Maintain the Email in Customer Master Level' )
                               ) TO reported-zmm_i_app09_rv.

    ENDIF.




  ENDMETHOD.

  METHOD gt_related.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZMM_I_APP09_RV DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZMM_I_APP09_RV IMPLEMENTATION.

  METHOD save_modified.
  if zbp_mm_i_app09_rv=>gt_hdr is not inITIAL.
  modify zmm_a_app09_htb from table @zbp_mm_i_app09_rv=>gt_hdr.
  endif.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
