/*
Hands-on-lab
https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab


*/
----------------------------------------------------------------------------------------------------------
--setup
    use role accountadmin;

    //Create role
    create role fs_hol_rl comment = 'FinServ Hands On Lab';
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
    create warehouse if not exists fs_hol_xsmall with warehouse_size = 'xsmall' auto_suspend = 60 initially_suspended = true max_cluster_count = 6;
    create warehouse if not exists fs_hol_xlarge with warehouse_size = 'xlarge' auto_suspend = 60 initially_suspended = true max_cluster_count = 4;

    grant ownership on warehouse fs_hol_xsmall to role finservam_admin;
    grant ownership on warehouse fs_hol_xlarge to role finservam_admin;


----------------------------------------------------------------------------------------------------------
--Zero Copy Clone fs_hol1 only
create or replace database fs_hol1 clone finservam;




-----------------------------------------------------
--grant



    -----------------------------------------------------
    --grand read on prod
//    grant usage on database 


    -----------------------------------------------------
    --grant ownership on 
//    grant ownership on database fs_hol1 to role fs_hol_rl;
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

create user fs_hol_user1 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl1;
create user fs_hol_user2 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl2;


create role fs_hol_rl1; grant role fs_hol_rl1 to role finservam_admin;
create role fs_hol_rl2; grant role fs_hol_rl2 to role finservam_admin;

grant role fs_hol_rl1 to user fs_hol_user1;
grant role fs_hol_rl2 to user fs_hol_user2; grant role fs_hol_rl to user fs_hol_user2;

show grants to role fs_hol_rl;
show grants to user fs_hol_user2;

-----------------------------------------------------
--
create database fs_hol2 clone fs_hol1;
grant usage on database fs_hol2 to role fs_hol_rl;
