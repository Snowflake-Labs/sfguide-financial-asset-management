/*
reset the Financial Services Hand-on-lab by dropping objects created in the HOL

https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab


*/
----------------------------------------------------------------------------------------------------------

use role accountadmin;

//role
drop role if exists fs_hol_rl;

//warehouse
drop warehouse if exists fs_hol_xsmall;
drop warehouse if exists fs_hol_medium;

//database
drop database if exists fs_prod;

drop database if exists fs_hol1;
drop database if exists fs_hol2;
drop database if exists fs_hol3;
drop database if exists fs_hol4;
drop database if exists fs_hol5;

//user
drop user if exists fs_hol_user1;
drop user if exists fs_hol_user2;
drop user if exists fs_hol_user3;
drop user if exists fs_hol_user4;
drop user if exists fs_hol_user5;
