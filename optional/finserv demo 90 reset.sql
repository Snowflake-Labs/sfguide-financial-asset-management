/*
Optional Script to remove all objects created during this demo
*/
use role finservam_admin;
drop database if exists finservam;
drop database if exists finservam_qa1;
drop warehouse if exists finservam_datascience_wh;
drop warehouse if exists finservam_devops_wh;

use role accountadmin;
drop role if exists finservam_admin;

--optional
-- drop database if exists economy_data_atlas;
-- drop warehouse if exists xsmall_const_wh;
-----------------------------------------------------
--deprecated objects
-- drop database if exists zepl_us_stocks_daily;
