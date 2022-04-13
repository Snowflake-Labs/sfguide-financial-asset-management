/*
Run "finserv demo 30.1" to setup 'SNOWFLAKE_SAMPLE_DATA' if it does not exist

If running the script: finserv demo 30 DDL
the error is produced: "Database 'SNOWFLAKE_SAMPLE_DATA' does not exist"

You will need to run this script as described in: https://docs.google.com/document/d/1zy5J5PfjJ82vcX0exFEnaq5FN_hs0G8e64zB5BpFC3I/edit

*/

-----------------------------------------------------
--set context and size up compute


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
