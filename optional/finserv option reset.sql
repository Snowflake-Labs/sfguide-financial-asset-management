/*
Optional Script to remove all objects created during this demo
*/
use role finservam_admin;
drop database if exists finservam;
drop warehouse if exists finservam_datascience_wh;
drop warehouse if exists finservam_devops_wh;

use role accountadmin;
drop database if exists zepl_us_stocks_daily;
drop role if exists finservam_admin;

