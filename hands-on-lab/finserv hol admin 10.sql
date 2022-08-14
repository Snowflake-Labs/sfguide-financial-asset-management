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
    grant all privileges on database fs_hol_prod to role public;
    
    grant usage on schema fs_hol_prod.public to role public;
    grant usage on schema fs_hol_prod.middleware to role public;
    
    grant select on all tables in schema fs_hol_prod.public to role public;
    grant select on all views in schema fs_hol_prod.public to role public;
    grant select on all views in schema fs_hol_prod.middleware to role public;



    //Create compute
    create warehouse if not exists fs_hol_xsmall with warehouse_size = 'xsmall' auto_suspend = 60 initially_suspended = true max_cluster_count = 6;
//    create warehouse if not exists fs_hol_xlarge with warehouse_size = 'xlarge' auto_suspend = 60 initially_suspended = true max_cluster_count = 4;

    grant ownership on warehouse fs_hol_xsmall to role finservam_admin;
//    grant ownership on warehouse fs_hol_xlarge to role finservam_admin;


----------------------------------------------------------------------------------------------------------
--Zero Copy Clone fs_hol1 only

create database fs_hol1 clone finservam;
create database fs_hol2 clone finservam;
create database fs_hol3 clone finservam;
create database fs_hol4 clone finservam;
create database fs_hol5 clone finservam;



-----------------------------------------------------
--role
create role fs_hol_rl1; grant role fs_hol_rl1 to role finservam_admin;
create role fs_hol_rl2; grant role fs_hol_rl2 to role finservam_admin;
create role fs_hol_rl3; grant role fs_hol_rl3 to role finservam_admin;
create role fs_hol_rl4; grant role fs_hol_rl4 to role finservam_admin;
create role fs_hol_rl5; grant role fs_hol_rl5 to role finservam_admin;



-----------------------------------------------------
--user
create user fs_hol_user1 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl1;
create user fs_hol_user2 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl2;
create user fs_hol_user3 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl3;
create user fs_hol_user4 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl4;
create user fs_hol_user5 password = 'replaceme', default_warehouse = fs_hol_xsmall, default_namespace = fs_hol_prod.public, default_role = fs_hol_rl5;

-----------------------------------------------------
--grant role to user
grant role fs_hol_rl1 to user fs_hol_user1;
grant role fs_hol_rl2 to user fs_hol_user2;
grant role fs_hol_rl3 to user fs_hol_user3;
grant role fs_hol_rl4 to user fs_hol_user4;
grant role fs_hol_rl5 to user fs_hol_user5;


//show grants to role fs_hol_rl;
//show grants to user fs_hol_user2;

-----------------------------------------------------
--
//create database fs_hol2 clone fs_hol1;
//grant usage on database fs_hol2 to role fs_hol_rl;


-----------------------------------------------------
--

-----------------------------------------------------
--

grant all privileges on database fs_hol2 to role fs_hol_rl2; grant ownership on schema fs_hol2.public to role fs_hol_rl2; grant ownership on schema fs_hol2.middleware to role fs_hol_rl2; grant ownership on all tables in schema fs_hol2.public to role fs_hol_rl2; grant ownership on all views in schema fs_hol2.public to role fs_hol_rl2; grant ownership on all views in schema fs_hol2.middleware to role fs_hol_rl2; grant monitor, operate, usage on warehouse fs_hol_xsmall to role fs_hol_rl2;

grant all privileges on database fs_hol5 to role fs_hol_rl5; grant ownership on schema fs_hol5.public to role fs_hol_rl5; grant ownership on schema fs_hol5.middleware to role fs_hol_rl5; grant ownership on all tables in schema fs_hol5.public to role fs_hol_rl5; grant ownership on all views in schema fs_hol5.public to role fs_hol_rl5; grant ownership on all views in schema fs_hol5.middleware to role fs_hol_rl5; grant monitor, operate, usage on warehouse fs_hol_xsmall to role fs_hol_rl5;
