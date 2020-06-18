CLASS zcl_appl_job_email_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_appl_job_email_client IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.

    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'RECIPTS'     kind = if_apj_dt_exec_object=>select_option     datatype = 'C' length = 80     param_text = 'Recipients'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'SENDER'      kind = if_apj_dt_exec_object=>parameter         datatype = 'C' length = 80     param_text = 'Sender'       lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'MAILSUBJ'    kind = if_apj_dt_exec_object=>parameter         datatype = 'C' length = 256    param_text = 'Mail Subject'                           changeable_ind = abap_true )
      ( selname = 'MAILBODY'    kind = if_apj_dt_exec_object=>parameter         datatype = 'C' length = 1024   param_text = 'Mail content'                           changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'RECIPTS'         kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = 'recipient@example.com' )
      ( selname = 'SENDER'          kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'sender@example.com' )
      ( selname = 'MAILSUBJ'        kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Test Mail Subject' )
      ( selname = 'MAILBODY'        kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '<p>Dear Mail recipient</p> <p>This is the mail body.</p> <p> Best Regards, Sender</p>' )
    ).

  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.

    TYPES ty_id TYPE c LENGTH 10.



    TRY.
        " Implement the job execution
        " Create a mail message instance
        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

        " Fetch details from the job parameters
        LOOP AT it_parameters INTO DATA(ls_parameter).
          CASE ls_parameter-selname.
            WHEN 'RECIPTS'.
              " Set the recipients of the mail
              lo_mail->add_recipient( CONV cl_bcs_mail_message=>ty_address( ls_parameter-low )  ).
            WHEN 'SENDER'.
              " Set the sender of the mail
              lo_mail->set_sender( CONV cl_bcs_mail_message=>ty_address( ls_parameter-low ) ).
            WHEN 'MAILSUBJ'.
              " Set the subject line for the mail
              lo_mail->set_subject( CONV cl_bcs_mail_message=>ty_subject( ls_parameter-low ) ).
            WHEN 'MAILBODY'.
              " Create the mail body
              DATA: mail_content TYPE string.  " Mail content.

              IF ls_parameter-low IS NOT INITIAL.
                mail_content = CONV string( ls_parameter-low ).
              ELSE.
                mail_content      = |<p>Hi Recipient</p>| &
                                    |<p> Job executed with ZCL_APPL_JOB_EMAIL_CLIENT in X08 on { cl_abap_context_info=>get_system_date( ) } at { cl_abap_context_info=>get_system_time( ) } using { cl_abap_context_info=>get_user_technical_name( ) } </p>| &
                                    |<p> Regards, Sender  </p>|.
              ENDIF.

              lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
                iv_content       = mail_content
                iv_content_type  = 'text/html'
              ) ).
          ENDCASE.

        ENDLOOP.

        " Send the mail
        lo_mail->send( IMPORTING et_status = DATA(lt_status) ).
      CATCH cx_bcs_mail INTO DATA(lx_mailer).
        DATA(lx_mailer_data) = lx_mailer->get_longtext( ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
