/*
Hands-on-lab
https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab

Dashboard -- The Lab Admin will send you this
https://app.snowflake.com/us-west-2/mqa22344/#/finserv-hol-asset-mgmt-trader-dFNKfYCJA


*/


use schema finservam.public;
use role accountadmin;

-----------------------------------------------------------------------------------------------------------
--Compute
    create warehouse if not exists hol_power with warehouse_size = 'large' auto_suspend = 120 initially_suspended = true max_cluster_count = 10;
    grant ownership on warehouse hol_power to role finservam_admin;

    create warehouse if not exists hol_junior with warehouse_size = 'small' auto_suspend = 180 initially_suspended = true max_cluster_count = 10;
    grant ownership on warehouse hol_junior to role finservam_admin;



                            

----------------------------------------------------------------------------------------------------------
---Setup
    //Create role
    create role if not exists hol_rl comment = 'FinServ Hands On Lab';
    grant role hol_rl to role finservam_admin;


    -----------------------------------------------------
    --clone
    create or replace database hol_uat clone finservam;
    grant all privileges on database hol_uat to role hol_rl;
    
    grant usage on schema hol_uat.public to role hol_rl;
    grant usage on schema hol_uat.transform to role hol_rl;
    
    grant select on all tables in schema hol_uat.public to role hol_rl;
    grant select on all views in schema hol_uat.public to role hol_rl;
    grant select on all views in schema hol_uat.transform to role hol_rl;

    use role accountadmin;
    grant usage on warehouse hol_junior to role hol_rl;
    grant usage on warehouse hol_power to role hol_rl;

    -----------------------------------------------------
    --rbac to production (finservam)

    grant usage on database finservam to role hol_rl;
    grant usage on schema finservam.public to role hol_rl;

    use role accountadmin;
    grant select on all tables in schema finservam.public to role hol_rl;
    grant select on all views in schema finservam.public to role hol_rl;



-----------------------------------------------------
--HR Human Resources Schema
    create or replace schema hol_uat.hr;
    grant usage on schema hol_uat.hr to role finservam_admin;
  
-----------------------------------------------------
--Users
create or replace table hol_uat.hr.login (
    username varchar,
    schemaname varchar as                     --notice computed column
        regexp_replace(                       
            left(username,                    --username without email domain
                position('@',username)-1),    --find @
        '([^A-Za-z0-9_$])','')                --remove non-valid identifier (also less confusing)
);

use warehouse hol_junior;

select * from hr.login;

----------------------------------------------------------------------------------------------------------Temp Space for User Creation DML Begin











----------------------------------------------------------------------------------------------------------Temp Space for User Creation DML End










select * from hr.login;

create or replace view hr.login_vw as
select
    l.username,
    'hol_' || l.schemaname as schemaname
from hr.login l;

select * from hr.login_vw;


-----------------------------------------------------
--Generate DDL to run

select
    -- ddl_schema
    'create or replace schema hol_uat.' ||
        l.schemaname || ' clone hol_uat.public;' ||

    -- ddl_user
    '        create or replace user ' || l.schemaname || ' login_name = ''' || l.username || ''' password = ''' || l.username || 
        ''', default_warehouse = hol_junior, default_namespace = hol_uat.' || l.schemaname ||
        ', default_role = hol_rl; ' ||

    -- ddl_role
        '        grant role hol_rl to user ' || l.schemaname || ';' ||
        
    -- ddl_ownership
        '        grant ownership on schema hol_uat.' || l.schemaname || ' to role hol_rl;' ||
        '        grant ownership on table hol_uat.' || l.schemaname || '.trade to role hol_rl revoke current grants;'
        
        as ddl_to_run,
    l.*
from hr.login_vw l;


--------------------------------------------------------------------------------------------------------
--Temp Space for User Creation DDL Execution

