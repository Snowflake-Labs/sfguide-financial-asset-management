/*
Hands-on-lab
https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab


*/
----------------------------------------------------------------------------------------------------------
--setup
    use role accountadmin;

    //Create role
    create role if not exists fs_hol_rl comment = 'FinServ Hands On Lab';
    grant role fs_hol_rl to role finservam_admin;

    -----------------------------------------------------
    --clone
    create or replace database fs_hol_prod clone finservam;
    grant all privileges on database fs_hol_prod to role fs_hol_rl;
    
    grant usage on schema fs_hol_prod.public to role fs_hol_rl;
    grant usage on schema fs_hol_prod.middleware to role fs_hol_rl;
    
    grant select on all tables in schema fs_hol_prod.public to role fs_hol_rl;
    grant select on all views in schema fs_hol_prod.public to role fs_hol_rl;
    grant select on all views in schema fs_hol_prod.middleware to role fs_hol_rl;


    //Create compute
    create warehouse if not exists fs_hol_xsmall with warehouse_size = 'xsmall' auto_suspend = 60 initially_suspended = true comment = 'Hands On Lab';
    create warehouse if not exists fs_hol_medium with warehouse_size = 'medium' auto_suspend = 60 initially_suspended = true comment = 'Hands On Lab';

    grant ownership on warehouse fs_hol_xsmall to role finservam_admin;
    grant ownership on warehouse fs_hol_medium to role finservam_admin;


----------------------------------------------------------------------------------------------------------
--Zero Copy Clone sandboxes
create or replace database fs_hol1 clone finservam;
create or replace database fs_hol2 clone finservam;


    -----------------------------------------------------
    --grand read on prod
//    grant usage on database 


    -----------------------------------------------------
    --grant ownership on 
    grant ownership on database fs_hol1 to role fs_hol_rl;
    grant all privileges on database fs_hol1 to role fs_hol_rl;

    grant ownership on schema fs_hol1.public to role fs_hol_rl;
    grant ownership on schema fs_hol1.middleware to role fs_hol_rl;
    
    grant ownership on all tables in schema fs_hol1.public to role fs_hol_rl copy current grants;
    grant ownership on all views in schema fs_hol1.public to role fs_hol_rl copy current grants;
    grant ownership on all views in schema fs_hol1.middleware to role fs_hol_rl copy current grants;

    grant monitor, operate, usage on warehouse fs_hol_xsmall to role fs_hol_rl;
    

-----------------------------------------------------
--create user
//    drop user if exists fs_hol_user1;
//    create user fs_hol_user1 password = 'replaceme' default_role = fs_hol_rl default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public must_change_password = true;

    GRANT ROLE fs_hol_rl TO USER fs_hol_user1;
//    show grants to user fs_hol_user1;

