"! <p class="shorttext synchronized" lang="en">Template Generator class for application jobs</p>
"! Application Job template factory can be used to define application job catalog and job templates
CLASS zcl_appl_job_template_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.      " Needed to create an executable class with output in ABAP Console.
  PROTECTED SECTION.
  PRIVATE SECTION.
    "!  Design time instance of application job, handle for creating and deleting application job catalog and template
    DATA mo_application_job_dt TYPE REF TO cl_apj_dt_create_content.

    "! <p class="shorttext synchronized" lang="EN">Creates application job catalog entry</p>
    "! @parameter is_catalog_creation_successful | Indicator denoting successful creation of application job catalog,
    "!                                 <ol>
    "!                                  <li>
    "!                                    <em> <strong>ABAP_TRUE</strong> </em> - If catalog creation was successful <br/>
    "!                                  </li>
    "!                                  <li>
    "!                                    <em> <strong>ABAP_FALSE</strong> </em> - If catalog creation failed <br/>
    "!                                  </li>
    "!                                 </ol>
    METHODS create_job_catalog
      RETURNING
                VALUE(is_catalog_creation_successful) TYPE abap_bool
      RAISING   cx_apj_dt_content .

    "! <p class="shorttext synchronized" lang="EN">Creates application job template entry</p>
    "! @parameter is_template_create_successful | Indicator denoting successful creation of application job template
    "!                                 <ol>
    "!                                  <li>
    "!                                    <em> <strong>ABAP_TRUE</strong> </em> - If job template creation was successful <br/>
    "!                                  </li>
    "!                                  <li>
    "!                                    <em> <strong>ABAP_FALSE</strong> </em> - If job template creation failed <br/>
    "!                                  </li>
    "!                                 </ol>
    METHODS create_job_template
      RETURNING
                VALUE(is_template_create_successful) TYPE abap_bool
      RAISING   cx_apj_dt_content .


    CONSTANTS catalog_name             TYPE cl_apj_dt_create_content=>ty_catalog_name       VALUE 'ZTEST_APJ_CATALOG'.                   " Name of the application job catalog
    CONSTANTS catalog_description      TYPE cl_apj_dt_create_content=>ty_text               VALUE 'Test Catalog for Application Jobs'.   " Description of the application job catalog


    CONSTANTS template_name            TYPE cl_apj_dt_create_content=>ty_template_name      VALUE 'ZTEST_APJ_TEMPLATE'.                  " Name of the application job template
    CONSTANTS template_description     TYPE cl_apj_dt_create_content=>ty_text               VALUE 'Test Template: Email Trigger'.        " Description of the application job template

    CONSTANTS handler_class_name       TYPE cl_apj_dt_create_content=>ty_class_name         VALUE 'ZCL_APPL_JOB_EMAIL_CLIENT'.           " Handler class of the job

    CONSTANTS transport_request        TYPE cl_apj_dt_create_content=>ty_transport_request  VALUE 'X08K900084'.                          " TR containing the application job catalog and job template entry
    CONSTANTS package                  TYPE cl_apj_dt_create_content=>ty_package            VALUE 'Z_TEST_APPLICATION_JOBS'.             " Package containing relevant entries
ENDCLASS.



CLASS zcl_appl_job_template_factory IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Get an instance of the application job design time, provides a handle to create and delete application job catalog and template.
    mo_application_job_dt = cl_apj_dt_create_content=>get_instance( ).

    TRY.
        DATA(lv_cat_creation_status) = create_job_catalog(  ).
      CATCH cx_apj_dt_content INTO DATA(lx_apj_dt_content).
        out->write( |Creation of job catalog entry failed: { lx_apj_dt_content->get_text( ) }| ).
    ENDTRY.

    IF lv_cat_creation_status EQ abap_true.
      out->write( |Job catalog created| ).
    ELSE.       " Needed for handling cases where cx_apj_dt_content was not raised during failure of job catalog creation
      IF lx_apj_dt_content IS INITIAL.
        out->write( |Job catalog was not created| ).
      ENDIF.
    ENDIF.

    CLEAR : lx_apj_dt_content.
    TRY.
        DATA(lv_templ_creation_status) = create_job_template(  ).
      CATCH cx_apj_dt_content INTO lx_apj_dt_content.
        out->write( |Creation of job template failed: { lx_apj_dt_content->get_text( ) }| ).
    ENDTRY.

    IF lv_templ_creation_status EQ abap_true.
      out->write( |Job template created| ).
    ELSE.        " Needed for handling cases where cx_apj_dt_content was not raised during failure of job template creation
      IF lx_apj_dt_content IS INITIAL.
        out->write( |Job template was not created| ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD create_job_catalog.
    is_catalog_creation_successful = abap_false.    " Set the indicator flag to ABAP_FALSE as default.
    " Create a job catalog entry.
    is_catalog_creation_successful  =  mo_application_job_dt->create_job_cat_entry(
        iv_catalog_name       = catalog_name
        iv_class_name         = handler_class_name
        iv_text               = catalog_description
        iv_catalog_entry_type = cl_apj_dt_create_content=>class_based
        iv_transport_request  = transport_request
        iv_package            = package
    ).
  ENDMETHOD.

  METHOD create_job_template.
    DATA lt_parameters TYPE if_apj_dt_exec_object=>tt_templ_val.

    is_template_create_successful = abap_false.      " Set the indicator flag to ABAP_FALSE as default.

    " Fetch the parameters needed for the job
    NEW zcl_appl_job_email_client( )->if_apj_dt_exec_object~get_parameters(
      IMPORTING
        et_parameter_val = lt_parameters
    ).

    " Create a job template based on the parameters for the catalog
    is_template_create_successful = mo_application_job_dt->create_job_template_entry(
         iv_template_name     = template_name
         iv_catalog_name      = catalog_name
         iv_text              = template_description
         it_parameters        = lt_parameters
         iv_transport_request = transport_request
         iv_package           = package
     ).

  ENDMETHOD.

ENDCLASS.
