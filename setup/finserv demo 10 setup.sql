/*    
Setup the objects needed:
    Role Based Access Control RBAC
    Virtual Warehouses (compute)
    Database
    Objects


*/
//Create role
    use role accountadmin;
    create role if not exists finservam_admin comment = 'Ownership of finservam database and demo';

    //Create compute
    create warehouse if not exists finservam_devops_wh
        with warehouse_size = 'small' auto_suspend = 120 initially_suspended = true comment = 'Financial Services DevOps Compute';
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
    create database if not exists finservam comment = 'Financial Service Asset Management';
    
    grant ownership on database finservam to role finservam_admin;
    grant ownership on schema finservam.public to role finservam_admin;
    
    grant ownership on warehouse finservam_devops_wh to role finservam_admin;
    
    grant ownership on warehouse xsmall_const_wh to role sysadmin;
    grant monitor, operate, usage on warehouse xsmall_const_wh to role finservam_admin;
    
    grant role finservam_admin to role sysadmin;

    use schema finservam.public;

    create schema if not exists transform comment = 'for interim objects that are not really meant for end users';
    grant ownership on schema transform to role finservam_admin;

    use schema finservam.public;
    use warehouse finservam_devops_wh;
