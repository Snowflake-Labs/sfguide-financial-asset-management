/*
Hands-on-lab


*/
-----------------------------------------------------
--setup
    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
    alter warehouse finservam_devops_wh set warehouse_size = 'xsmall';

    create or replace database fs_hol_prod clone finservam;

    //Create compute
    create warehouse if not exists hol_xs
        with warehouse_size = 'xsmall' auto_suspend = 60 initially_suspended = true comment = 'Hands On Lab';
    grant ownership on warehouse hol_xs to role finservam_admin;


----------------------------------------------------------------------------------------------------------
--Zero Copy Clone sandboxes
use role accountadmin;

drop database if exists fs_hol1;
drop database if exists fs_hol2;

create or replace database fs_hol1 clone finservam;
create or replace database fs_hol2 clone finservam;

-----------------------------------------------------
--RBAC

//Create role
    use role accountadmin;
    create role if not exists fs_hol_rl comment = 'FinServ Hands On Lab';
    GRANT ROLE fs_hol_rl TO role finservam_admin;

    grant ownership on database fs_hol1 to role fs_hol_rl;
    grant all privileges on database fs_hol1 to role fs_hol_rl;

    grant ownership on schema fs_hol1.public to role fs_hol_rl;
    grant ownership on schema fs_hol1.middleware to role fs_hol_rl;
    
    grant ownership on all tables in schema fs_hol1.public to role fs_hol_rl copy current grants;
    grant ownership on all views in schema fs_hol1.public to role fs_hol_rl copy current grants;
    grant ownership on all views in schema fs_hol1.middleware to role fs_hol_rl copy current grants;

    grant monitor, operate, usage on warehouse hol_xs to role fs_hol_rl;
    

-----------------------------------------------------
--create user
//    drop user if exists hol_user1;
//    CREATE USER hol_user1 PASSWORD = 'replaceMe' DEFAULT_ROLE = fs_hol_rl DEFAULT_WAREHOUSE = hol_xs, DEFAULT_NAMESPACE = fs_hol_prod.public;

    GRANT ROLE fs_hol_rl TO USER hol_user1;
    show grants to user hol_user1;


