/*
Story Intro:
    We create the Trade, Cash, and Positions Views for Equity Trading
    
Scenario: 
    We make Trades.  Then we want to dynamically determine the cash and positions both as-of a date and now.

This script will setup the objects roles, warehouses, and databases.

*/
//Create role
    use role accountadmin;
    create role if not exists finserv_admin comment = 'Ownership of finserv database and demo';
    create warehouse if not exists finserv_devops_wh  with warehouse_size = 'xsmall' auto_suspend = 300 initially_suspended = true;
    
//Optional: Create a finserv user to connect with
//REPLACE PASSWORD WITH YOUR OWN
/*
    CREATE USER finserv
        PASSWORD = --ReplaceMe 
        FIRST_NAME = 'finserv' LAST_NAME = 'demo' DEFAULT_ROLE = finserv_admin MUST_CHANGE_PASSWORD = TRUE;
    alter user finserv set DEFAULT_WAREHOUSE = finserv_devops_wh, DEFAULT_NAMESPACE = finserv.public;

    GRANT ROLE finserv_admin TO USER finserv;
*/




//Permissions can be as granular as you'd like
    use role accountadmin;
    create database if not exists finserv;
    grant ownership on database finserv to role finserv_admin;
    grant ownership on schema finserv.public to role finserv_admin;
    grant ownership on warehouse finserv_devops_wh to role finserv_admin;
    grant role finserv_admin to role sysadmin;

    use role finserv_admin;
    use schema finserv.public;
    create schema if not exists middleware comment = 'for interim objects that are not really meant for end users';
        //Optional --https://help.sigmacomputing.com/hc/en-us/articles/360037430473-Set-Up-Write-Access
        create schema if not exists sigma_writeback comment = 'Optional: For Sigma BI tool writeback';
    use schema finserv.public;
    
