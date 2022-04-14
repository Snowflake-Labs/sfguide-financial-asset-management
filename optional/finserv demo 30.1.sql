/*
Run "finserv demo 30.1" to setup 'SNOWFLAKE_SAMPLE_DATA' if it does not exist

If running the script: finserv demo 30 DDL
produces a missing database error like: 
"Database 'SNOWFLAKE_SAMPLE_DATA' does not exist"

You will need to run this script:"finserv demo 30.1.sql" as described in: https://docs.snowflake.com/en/user-guide/sample-data-using.html

*/

-----------------------------------------------------
--set context 


-- Execute this worksheet as AccountAdmin

use role ACCOUNTADMIN;
-- Create a database from the share
-- 
-- If the database already exists you'll see the following error: 
-- "SQL compilation error: Object 'SNOWFLAKE_SAMPLE_DATA' already exists."
create database snowflake_sample_data from share sfc_samples.sample_data;

-- Grant the PUBLIC role access to the database.
-- Optionally change the role name to restrict access to a subset of users.
grant imported privileges on database snowflake_sample_data to role public;

-- To show this worked, there should be a 'name': 'SNOWFLAKE_SAMPLE_DATA'
show databases like '%sample%';

use role finservam_admin;
-- To show this worked for finservam_admin, there should be a 'name': 'SNOWFLAKE_SAMPLE_DATA'
show databases like '%sample%';
