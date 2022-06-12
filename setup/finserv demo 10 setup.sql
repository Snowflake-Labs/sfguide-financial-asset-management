/*
Purpose:
    We create the objects needed for Financial Services Asset Management Demo
    
What we will see
    Setup the objects needed:
        roles (Role Based Access Control RBAC)
        warehouses (isolated and instant compute)
        database finservam
        all objects owned by finservam_admin role

    Optional:
        Schemas for Sigma and Zepl writeback to Snowflake


*/
//Create role
    use role accountadmin;
    create role if not exists finservam_admin comment = 'Ownership of finservam database and demo';

    //Create compute
    create warehouse if not exists finservam_devops_wh
        with warehouse_size = 'xsmall' auto_suspend = 120 initially_suspended = true comment = 'Financial Services DevOps Compute';
    create warehouse if not exists finservam_datascience_wh
        with warehouse_size = 'xsmall' auto_suspend = 60 initially_suspended = true comment = 'DataScience will often scale to extremes';
    create warehouse if not exists xsmall_const_wh
        with warehouse_size = 'xsmall' auto_suspend = 60 initially_suspended = true comment = 'Constant so should always be XS and not resized';
        
        
        
    
//Optional: Create a finservam user to connect to Snowflake with
//REPLACE PASSWORD WITH YOUR OWN
/*
    CREATE USER finservam
        PASSWORD = --ReplaceMe 
        FIRST_NAME = 'finservam' LAST_NAME = 'demo' DEFAULT_ROLE = finservam_admin MUST_CHANGE_PASSWORD = TRUE;
    alter user finservam set DEFAULT_WAREHOUSE = finservam_devops_wh, DEFAULT_NAMESPACE = finservam.public;

    GRANT ROLE finservam_admin TO USER finservam;
*/




//Permissions can be as granular as you'd like
    use role accountadmin;
    create database if not exists finservam comment = 'Financial Service Asset Management';
    
    grant ownership on database finservam to role finservam_admin;
    grant ownership on schema finservam.public to role finservam_admin;
    
    grant ownership on warehouse finservam_devops_wh to role finservam_admin;
    grant ownership on warehouse finservam_datascience_wh to role finservam_admin;
    
    grant ownership on warehouse xsmall_const_wh to role sysadmin;
    grant monitor, operate, usage on warehouse xsmall_const_wh to role finservam_admin;
    
    grant role finservam_admin to role sysadmin;

    use role finservam_admin;
    use schema finservam.public;
    create schema if not exists middleware comment = 'for interim objects that are not really meant for end users';
        
        //Optional: Allow Sigma Computing to write data to Snowflake 
        create schema if not exists sigma_writeback comment = 'Optional: For Sigma BI tool writeback';

        //Optional: Allow Zepl to write data to Snowflake
        create schema if not exists zepl_writeback comment = 'Optional: For Zepl - Zeppelin Data Science Notebook - writeback';

    use schema finservam.public;


