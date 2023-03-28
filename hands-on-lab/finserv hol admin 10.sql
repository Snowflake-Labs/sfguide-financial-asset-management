/*
Hands-on-lab
https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab

Optional
set isResetFull to 1 to reset Labs 4-30 which takes about five additional minutes

Time
set isResetFull to 0 for reset of only accounts 1-3 which takes about one minute


*/
use schema finservam.public;
use role accountadmin;

-----------------------------------------------------------------------------------------------------------
--Compute
    create warehouse if not exists fs_hol_power with warehouse_size = 'large' auto_suspend = 120 initially_suspended = true max_cluster_count = 4;
    grant ownership on warehouse fs_hol_power to role finservam_admin;

    create warehouse if not exists fs_hol_junior with warehouse_size = 'small' auto_suspend = 180 initially_suspended = true max_cluster_count = 6;
    grant ownership on warehouse fs_hol_junior to role finservam_admin;


----------------------------------------------------------------------------------------------------------
--We set the password to a random 3 letter string
--We can retrieve it by either running select $pwd or looking at the query history

set pwd = (select randstr(3, random()) from table(generator(rowcount => 1)));
select $pwd;



----------------------------------------------------------------------------------------------------------
---Setup
    //Create role
    create role if not exists fs_hol_rl comment = 'FinServ Hands On Lab';
    grant role fs_hol_rl to role finservam_admin;

    -----------------------------------------------------
    --clone
    create or replace database fs_hol_uat clone finservam;
    grant all privileges on database fs_hol_uat to role public;
    
    grant usage on schema fs_hol_uat.public to role public;
    grant usage on schema fs_hol_uat.transform to role public;
    
    grant select on all tables in schema fs_hol_uat.public to role public;
    grant select on all views in schema fs_hol_uat.public to role public;
    grant select on all views in schema fs_hol_uat.transform to role public;





----------------------------------------------------------------------------------------------------------
--Zero Copy Clone fs_hol1 only
create database fs_hol1 clone finservam;
create database fs_hol2 clone finservam;
create database fs_hol3 clone finservam;

-----------------------------------------------------
--role
create role fs_hol_rl1; grant role fs_hol_rl1 to role finservam_admin;
create role fs_hol_rl2; grant role fs_hol_rl2 to role finservam_admin;
create role fs_hol_rl3; grant role fs_hol_rl3 to role finservam_admin;

-----------------------------------------------------
--user
create user fs_hol_user1 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl1;
create user fs_hol_user2 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl2;
create user fs_hol_user3 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl3;

-----------------------------------------------------
--grant role to user
grant role fs_hol_rl1 to user fs_hol_user1;
grant role fs_hol_rl2 to user fs_hol_user2;
grant role fs_hol_rl3 to user fs_hol_user3;



-----------------------------------------------------
--granular privilege model
grant all privileges on database fs_hol1 to role fs_hol_rl1; grant ownership on schema fs_hol1.public to role fs_hol_rl1; grant ownership on schema fs_hol1.transform to role fs_hol_rl1; grant ownership on all tables in schema fs_hol1.public to role fs_hol_rl1; grant ownership on all views in schema fs_hol1.public to role fs_hol_rl1; grant ownership on all views in schema fs_hol1.transform to role fs_hol_rl1; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl1; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl1;
grant all privileges on database fs_hol2 to role fs_hol_rl2; grant ownership on schema fs_hol2.public to role fs_hol_rl2; grant ownership on schema fs_hol2.transform to role fs_hol_rl2; grant ownership on all tables in schema fs_hol2.public to role fs_hol_rl2; grant ownership on all views in schema fs_hol2.public to role fs_hol_rl2; grant ownership on all views in schema fs_hol2.transform to role fs_hol_rl2; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl2; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl2;
grant all privileges on database fs_hol3 to role fs_hol_rl3; grant ownership on schema fs_hol3.public to role fs_hol_rl3; grant ownership on schema fs_hol3.transform to role fs_hol_rl3; grant ownership on all tables in schema fs_hol3.public to role fs_hol_rl3; grant ownership on all views in schema fs_hol3.public to role fs_hol_rl3; grant ownership on all views in schema fs_hol3.transform to role fs_hol_rl3; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl3; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl3;

select $pwd;


----------------------------------------------------------------------------------------------------------
--set isResetFull to 1 to reset user 4-30 as well

-- execute immediate $$  --only needed if in classic UI
begin
  let isResetFull := 1;
  if (isResetFull = 1) then

create database fs_hol4 clone finservam;
create database fs_hol5 clone finservam;
create database fs_hol6 clone finservam;
create database fs_hol7 clone finservam;
create database fs_hol8 clone finservam;
create database fs_hol9 clone finservam;
create database fs_hol10 clone finservam;
create database fs_hol11 clone finservam;
create database fs_hol12 clone finservam;
create database fs_hol13 clone finservam;
create database fs_hol14 clone finservam;
create database fs_hol15 clone finservam;
create database fs_hol16 clone finservam;
create database fs_hol17 clone finservam;
create database fs_hol18 clone finservam;
create database fs_hol19 clone finservam;
create database fs_hol20 clone finservam;
create database fs_hol21 clone finservam;
create database fs_hol22 clone finservam;
create database fs_hol23 clone finservam;
create database fs_hol24 clone finservam;
create database fs_hol25 clone finservam;
create database fs_hol26 clone finservam;
create database fs_hol27 clone finservam;
create database fs_hol28 clone finservam;
create database fs_hol29 clone finservam;
create database fs_hol30 clone finservam;

create role fs_hol_rl4; grant role fs_hol_rl4 to role finservam_admin;
create role fs_hol_rl5; grant role fs_hol_rl5 to role finservam_admin;
create role fs_hol_rl6; grant role fs_hol_rl6 to role finservam_admin;
create role fs_hol_rl7; grant role fs_hol_rl7 to role finservam_admin;
create role fs_hol_rl8; grant role fs_hol_rl8 to role finservam_admin;
create role fs_hol_rl9; grant role fs_hol_rl9 to role finservam_admin;
create role fs_hol_rl10; grant role fs_hol_rl10 to role finservam_admin;
create role fs_hol_rl11; grant role fs_hol_rl11 to role finservam_admin;
create role fs_hol_rl12; grant role fs_hol_rl12 to role finservam_admin;
create role fs_hol_rl13; grant role fs_hol_rl13 to role finservam_admin;
create role fs_hol_rl14; grant role fs_hol_rl14 to role finservam_admin;
create role fs_hol_rl15; grant role fs_hol_rl15 to role finservam_admin;
create role fs_hol_rl16; grant role fs_hol_rl16 to role finservam_admin;
create role fs_hol_rl17; grant role fs_hol_rl17 to role finservam_admin;
create role fs_hol_rl18; grant role fs_hol_rl18 to role finservam_admin;
create role fs_hol_rl19; grant role fs_hol_rl19 to role finservam_admin;
create role fs_hol_rl20; grant role fs_hol_rl20 to role finservam_admin;
create role fs_hol_rl21; grant role fs_hol_rl21 to role finservam_admin;
create role fs_hol_rl22; grant role fs_hol_rl22 to role finservam_admin;
create role fs_hol_rl23; grant role fs_hol_rl23 to role finservam_admin;
create role fs_hol_rl24; grant role fs_hol_rl24 to role finservam_admin;
create role fs_hol_rl25; grant role fs_hol_rl25 to role finservam_admin;
create role fs_hol_rl26; grant role fs_hol_rl26 to role finservam_admin;
create role fs_hol_rl27; grant role fs_hol_rl27 to role finservam_admin;
create role fs_hol_rl28; grant role fs_hol_rl28 to role finservam_admin;
create role fs_hol_rl29; grant role fs_hol_rl29 to role finservam_admin;
create role fs_hol_rl30; grant role fs_hol_rl30 to role finservam_admin;

create user fs_hol_user4 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl4;
create user fs_hol_user5 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl5;
create user fs_hol_user6 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl6;
create user fs_hol_user7 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl7;
create user fs_hol_user8 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl8;
create user fs_hol_user9 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl9;
create user fs_hol_user10 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl10;
create user fs_hol_user11 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl11;
create user fs_hol_user12 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl12;
create user fs_hol_user13 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl13;
create user fs_hol_user14 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl14;
create user fs_hol_user15 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl15;
create user fs_hol_user16 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl16;
create user fs_hol_user17 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl17;
create user fs_hol_user18 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl18;
create user fs_hol_user19 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl19;
create user fs_hol_user20 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl20;
create user fs_hol_user21 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl21;
create user fs_hol_user22 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl22;
create user fs_hol_user23 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl23;
create user fs_hol_user24 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl24;
create user fs_hol_user25 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl25;
create user fs_hol_user26 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl26;
create user fs_hol_user27 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl27;
create user fs_hol_user28 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl28;
create user fs_hol_user29 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl29;
create user fs_hol_user30 password = $pwd, default_warehouse = fs_hol_junior, default_namespace = fs_hol_uat.public, default_role = fs_hol_rl30;

grant role fs_hol_rl4 to user fs_hol_user4;
grant role fs_hol_rl5 to user fs_hol_user5;
grant role fs_hol_rl6 to user fs_hol_user6;
grant role fs_hol_rl7 to user fs_hol_user7;
grant role fs_hol_rl8 to user fs_hol_user8;
grant role fs_hol_rl9 to user fs_hol_user9;
grant role fs_hol_rl10 to user fs_hol_user10;
grant role fs_hol_rl11 to user fs_hol_user11;
grant role fs_hol_rl12 to user fs_hol_user12;
grant role fs_hol_rl13 to user fs_hol_user13;
grant role fs_hol_rl14 to user fs_hol_user14;
grant role fs_hol_rl15 to user fs_hol_user15;
grant role fs_hol_rl16 to user fs_hol_user16;
grant role fs_hol_rl17 to user fs_hol_user17;
grant role fs_hol_rl18 to user fs_hol_user18;
grant role fs_hol_rl19 to user fs_hol_user19;
grant role fs_hol_rl20 to user fs_hol_user20;
grant role fs_hol_rl21 to user fs_hol_user21;
grant role fs_hol_rl22 to user fs_hol_user22;
grant role fs_hol_rl23 to user fs_hol_user23;
grant role fs_hol_rl24 to user fs_hol_user24;
grant role fs_hol_rl25 to user fs_hol_user25;
grant role fs_hol_rl26 to user fs_hol_user26;
grant role fs_hol_rl27 to user fs_hol_user27;
grant role fs_hol_rl28 to user fs_hol_user28;
grant role fs_hol_rl29 to user fs_hol_user29;
grant role fs_hol_rl30 to user fs_hol_user30;

grant all privileges on database fs_hol4 to role fs_hol_rl4; grant ownership on schema fs_hol4.public to role fs_hol_rl4; grant ownership on schema fs_hol4.transform to role fs_hol_rl4; grant ownership on all tables in schema fs_hol4.public to role fs_hol_rl4; grant ownership on all views in schema fs_hol4.public to role fs_hol_rl4; grant ownership on all views in schema fs_hol4.transform to role fs_hol_rl4; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl4; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl4;
grant all privileges on database fs_hol5 to role fs_hol_rl5; grant ownership on schema fs_hol5.public to role fs_hol_rl5; grant ownership on schema fs_hol5.transform to role fs_hol_rl5; grant ownership on all tables in schema fs_hol5.public to role fs_hol_rl5; grant ownership on all views in schema fs_hol5.public to role fs_hol_rl5; grant ownership on all views in schema fs_hol5.transform to role fs_hol_rl5; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl5; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl5;
grant all privileges on database fs_hol6 to role fs_hol_rl6; grant ownership on schema fs_hol6.public to role fs_hol_rl6; grant ownership on schema fs_hol6.transform to role fs_hol_rl6; grant ownership on all tables in schema fs_hol6.public to role fs_hol_rl6; grant ownership on all views in schema fs_hol6.public to role fs_hol_rl6; grant ownership on all views in schema fs_hol6.transform to role fs_hol_rl6; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl6; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl6;
grant all privileges on database fs_hol7 to role fs_hol_rl7; grant ownership on schema fs_hol7.public to role fs_hol_rl7; grant ownership on schema fs_hol7.transform to role fs_hol_rl7; grant ownership on all tables in schema fs_hol7.public to role fs_hol_rl7; grant ownership on all views in schema fs_hol7.public to role fs_hol_rl7; grant ownership on all views in schema fs_hol7.transform to role fs_hol_rl7; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl7; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl7;
grant all privileges on database fs_hol8 to role fs_hol_rl8; grant ownership on schema fs_hol8.public to role fs_hol_rl8; grant ownership on schema fs_hol8.transform to role fs_hol_rl8; grant ownership on all tables in schema fs_hol8.public to role fs_hol_rl8; grant ownership on all views in schema fs_hol8.public to role fs_hol_rl8; grant ownership on all views in schema fs_hol8.transform to role fs_hol_rl8; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl8; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl8;
grant all privileges on database fs_hol9 to role fs_hol_rl9; grant ownership on schema fs_hol9.public to role fs_hol_rl9; grant ownership on schema fs_hol9.transform to role fs_hol_rl9; grant ownership on all tables in schema fs_hol9.public to role fs_hol_rl9; grant ownership on all views in schema fs_hol9.public to role fs_hol_rl9; grant ownership on all views in schema fs_hol9.transform to role fs_hol_rl9; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl9; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl9;
grant all privileges on database fs_hol10 to role fs_hol_rl10; grant ownership on schema fs_hol10.public to role fs_hol_rl10; grant ownership on schema fs_hol10.transform to role fs_hol_rl10; grant ownership on all tables in schema fs_hol10.public to role fs_hol_rl10; grant ownership on all views in schema fs_hol10.public to role fs_hol_rl10; grant ownership on all views in schema fs_hol10.transform to role fs_hol_rl10; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl10; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl10;
grant all privileges on database fs_hol11 to role fs_hol_rl11; grant ownership on schema fs_hol11.public to role fs_hol_rl11; grant ownership on schema fs_hol11.transform to role fs_hol_rl11; grant ownership on all tables in schema fs_hol11.public to role fs_hol_rl11; grant ownership on all views in schema fs_hol11.public to role fs_hol_rl11; grant ownership on all views in schema fs_hol11.transform to role fs_hol_rl11; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl11; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl11;
grant all privileges on database fs_hol12 to role fs_hol_rl12; grant ownership on schema fs_hol12.public to role fs_hol_rl12; grant ownership on schema fs_hol12.transform to role fs_hol_rl12; grant ownership on all tables in schema fs_hol12.public to role fs_hol_rl12; grant ownership on all views in schema fs_hol12.public to role fs_hol_rl12; grant ownership on all views in schema fs_hol12.transform to role fs_hol_rl12; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl12; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl12;
grant all privileges on database fs_hol13 to role fs_hol_rl13; grant ownership on schema fs_hol13.public to role fs_hol_rl13; grant ownership on schema fs_hol13.transform to role fs_hol_rl13; grant ownership on all tables in schema fs_hol13.public to role fs_hol_rl13; grant ownership on all views in schema fs_hol13.public to role fs_hol_rl13; grant ownership on all views in schema fs_hol13.transform to role fs_hol_rl13; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl13; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl13;
grant all privileges on database fs_hol14 to role fs_hol_rl14; grant ownership on schema fs_hol14.public to role fs_hol_rl14; grant ownership on schema fs_hol14.transform to role fs_hol_rl14; grant ownership on all tables in schema fs_hol14.public to role fs_hol_rl14; grant ownership on all views in schema fs_hol14.public to role fs_hol_rl14; grant ownership on all views in schema fs_hol14.transform to role fs_hol_rl14; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl14; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl14;
grant all privileges on database fs_hol15 to role fs_hol_rl15; grant ownership on schema fs_hol15.public to role fs_hol_rl15; grant ownership on schema fs_hol15.transform to role fs_hol_rl15; grant ownership on all tables in schema fs_hol15.public to role fs_hol_rl15; grant ownership on all views in schema fs_hol15.public to role fs_hol_rl15; grant ownership on all views in schema fs_hol15.transform to role fs_hol_rl15; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl15; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl15;
grant all privileges on database fs_hol16 to role fs_hol_rl16; grant ownership on schema fs_hol16.public to role fs_hol_rl16; grant ownership on schema fs_hol16.transform to role fs_hol_rl16; grant ownership on all tables in schema fs_hol16.public to role fs_hol_rl16; grant ownership on all views in schema fs_hol16.public to role fs_hol_rl16; grant ownership on all views in schema fs_hol16.transform to role fs_hol_rl16; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl16; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl16;
grant all privileges on database fs_hol17 to role fs_hol_rl17; grant ownership on schema fs_hol17.public to role fs_hol_rl17; grant ownership on schema fs_hol17.transform to role fs_hol_rl17; grant ownership on all tables in schema fs_hol17.public to role fs_hol_rl17; grant ownership on all views in schema fs_hol17.public to role fs_hol_rl17; grant ownership on all views in schema fs_hol17.transform to role fs_hol_rl17; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl17; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl17;
grant all privileges on database fs_hol18 to role fs_hol_rl18; grant ownership on schema fs_hol18.public to role fs_hol_rl18; grant ownership on schema fs_hol18.transform to role fs_hol_rl18; grant ownership on all tables in schema fs_hol18.public to role fs_hol_rl18; grant ownership on all views in schema fs_hol18.public to role fs_hol_rl18; grant ownership on all views in schema fs_hol18.transform to role fs_hol_rl18; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl18; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl18;
grant all privileges on database fs_hol19 to role fs_hol_rl19; grant ownership on schema fs_hol19.public to role fs_hol_rl19; grant ownership on schema fs_hol19.transform to role fs_hol_rl19; grant ownership on all tables in schema fs_hol19.public to role fs_hol_rl19; grant ownership on all views in schema fs_hol19.public to role fs_hol_rl19; grant ownership on all views in schema fs_hol19.transform to role fs_hol_rl19; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl19; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl19;
grant all privileges on database fs_hol20 to role fs_hol_rl20; grant ownership on schema fs_hol20.public to role fs_hol_rl20; grant ownership on schema fs_hol20.transform to role fs_hol_rl20; grant ownership on all tables in schema fs_hol20.public to role fs_hol_rl20; grant ownership on all views in schema fs_hol20.public to role fs_hol_rl20; grant ownership on all views in schema fs_hol20.transform to role fs_hol_rl20; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl20; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl20;
grant all privileges on database fs_hol21 to role fs_hol_rl21; grant ownership on schema fs_hol21.public to role fs_hol_rl21; grant ownership on schema fs_hol21.transform to role fs_hol_rl21; grant ownership on all tables in schema fs_hol21.public to role fs_hol_rl21; grant ownership on all views in schema fs_hol21.public to role fs_hol_rl21; grant ownership on all views in schema fs_hol21.transform to role fs_hol_rl21; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl21; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl21;
grant all privileges on database fs_hol22 to role fs_hol_rl22; grant ownership on schema fs_hol22.public to role fs_hol_rl22; grant ownership on schema fs_hol22.transform to role fs_hol_rl22; grant ownership on all tables in schema fs_hol22.public to role fs_hol_rl22; grant ownership on all views in schema fs_hol22.public to role fs_hol_rl22; grant ownership on all views in schema fs_hol22.transform to role fs_hol_rl22; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl22; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl22;
grant all privileges on database fs_hol23 to role fs_hol_rl23; grant ownership on schema fs_hol23.public to role fs_hol_rl23; grant ownership on schema fs_hol23.transform to role fs_hol_rl23; grant ownership on all tables in schema fs_hol23.public to role fs_hol_rl23; grant ownership on all views in schema fs_hol23.public to role fs_hol_rl23; grant ownership on all views in schema fs_hol23.transform to role fs_hol_rl23; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl23; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl23;
grant all privileges on database fs_hol24 to role fs_hol_rl24; grant ownership on schema fs_hol24.public to role fs_hol_rl24; grant ownership on schema fs_hol24.transform to role fs_hol_rl24; grant ownership on all tables in schema fs_hol24.public to role fs_hol_rl24; grant ownership on all views in schema fs_hol24.public to role fs_hol_rl24; grant ownership on all views in schema fs_hol24.transform to role fs_hol_rl24; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl24; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl24;
grant all privileges on database fs_hol25 to role fs_hol_rl25; grant ownership on schema fs_hol25.public to role fs_hol_rl25; grant ownership on schema fs_hol25.transform to role fs_hol_rl25; grant ownership on all tables in schema fs_hol25.public to role fs_hol_rl25; grant ownership on all views in schema fs_hol25.public to role fs_hol_rl25; grant ownership on all views in schema fs_hol25.transform to role fs_hol_rl25; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl25; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl25;
grant all privileges on database fs_hol26 to role fs_hol_rl26; grant ownership on schema fs_hol26.public to role fs_hol_rl26; grant ownership on schema fs_hol26.transform to role fs_hol_rl26; grant ownership on all tables in schema fs_hol26.public to role fs_hol_rl26; grant ownership on all views in schema fs_hol26.public to role fs_hol_rl26; grant ownership on all views in schema fs_hol26.transform to role fs_hol_rl26; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl26; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl26;
grant all privileges on database fs_hol27 to role fs_hol_rl27; grant ownership on schema fs_hol27.public to role fs_hol_rl27; grant ownership on schema fs_hol27.transform to role fs_hol_rl27; grant ownership on all tables in schema fs_hol27.public to role fs_hol_rl27; grant ownership on all views in schema fs_hol27.public to role fs_hol_rl27; grant ownership on all views in schema fs_hol27.transform to role fs_hol_rl27; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl27; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl27;
grant all privileges on database fs_hol28 to role fs_hol_rl28; grant ownership on schema fs_hol28.public to role fs_hol_rl28; grant ownership on schema fs_hol28.transform to role fs_hol_rl28; grant ownership on all tables in schema fs_hol28.public to role fs_hol_rl28; grant ownership on all views in schema fs_hol28.public to role fs_hol_rl28; grant ownership on all views in schema fs_hol28.transform to role fs_hol_rl28; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl28; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl28;
grant all privileges on database fs_hol29 to role fs_hol_rl29; grant ownership on schema fs_hol29.public to role fs_hol_rl29; grant ownership on schema fs_hol29.transform to role fs_hol_rl29; grant ownership on all tables in schema fs_hol29.public to role fs_hol_rl29; grant ownership on all views in schema fs_hol29.public to role fs_hol_rl29; grant ownership on all views in schema fs_hol29.transform to role fs_hol_rl29; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl29; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl29;
grant all privileges on database fs_hol30 to role fs_hol_rl30; grant ownership on schema fs_hol30.public to role fs_hol_rl30; grant ownership on schema fs_hol30.transform to role fs_hol_rl30; grant ownership on all tables in schema fs_hol30.public to role fs_hol_rl30; grant ownership on all views in schema fs_hol30.public to role fs_hol_rl30; grant ownership on all views in schema fs_hol30.transform to role fs_hol_rl30; grant monitor, operate, usage on warehouse fs_hol_junior to role fs_hol_rl30; grant monitor, operate, usage on warehouse fs_hol_power to role fs_hol_rl30;
  end if;
end;
--$$;   --only needed for classic UI



--HP4
select $pwd;
