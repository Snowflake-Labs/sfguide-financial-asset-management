/*
reset the Financial Services Hand-on-lab by dropping objects created in the HOL

https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab


*/
----------------------------------------------------------------------------------------------------------
use schema finservam.public;
use role accountadmin;

//role
drop role if exists fs_hol_rl;

//warehouse
drop warehouse if exists fs_hol_xsmall;
drop warehouse if exists fs_hol_power;

//database
drop database if exists fs_hol_uat;

drop database if exists fs_hol1;
drop database if exists fs_hol2;
drop database if exists fs_hol3;
drop database if exists fs_hol4;
drop database if exists fs_hol5;
drop database if exists fs_hol6;
drop database if exists fs_hol7;
drop database if exists fs_hol8;
drop database if exists fs_hol9;
drop database if exists fs_hol10;
drop database if exists fs_hol11;
drop database if exists fs_hol12;
drop database if exists fs_hol13;
drop database if exists fs_hol14;
drop database if exists fs_hol15;
drop database if exists fs_hol16;
drop database if exists fs_hol17;
drop database if exists fs_hol18;
drop database if exists fs_hol19;
drop database if exists fs_hol20;
drop database if exists fs_hol21;
drop database if exists fs_hol22;
drop database if exists fs_hol23;
drop database if exists fs_hol24;
drop database if exists fs_hol25;
drop database if exists fs_hol26;
drop database if exists fs_hol27;
drop database if exists fs_hol28;
drop database if exists fs_hol29;
drop database if exists fs_hol30;

//user
drop user if exists fs_hol_user1;
drop user if exists fs_hol_user2;
drop user if exists fs_hol_user3;
drop user if exists fs_hol_user4;
drop user if exists fs_hol_user5;
drop user if exists fs_hol_user6;
drop user if exists fs_hol_user7;
drop user if exists fs_hol_user8;
drop user if exists fs_hol_user9;
drop user if exists fs_hol_user10;
drop user if exists fs_hol_user11;
drop user if exists fs_hol_user12;
drop user if exists fs_hol_user13;
drop user if exists fs_hol_user14;
drop user if exists fs_hol_user15;
drop user if exists fs_hol_user16;
drop user if exists fs_hol_user17;
drop user if exists fs_hol_user18;
drop user if exists fs_hol_user19;
drop user if exists fs_hol_user20;
drop user if exists fs_hol_user21;
drop user if exists fs_hol_user22;
drop user if exists fs_hol_user23;
drop user if exists fs_hol_user24;
drop user if exists fs_hol_user25;
drop user if exists fs_hol_user26;
drop user if exists fs_hol_user27;
drop user if exists fs_hol_user28;
drop user if exists fs_hol_user29;
drop user if exists fs_hol_user30;

//role

drop role if exists fs_hol_rl1;
drop role if exists fs_hol_rl2;
drop role if exists fs_hol_rl3;
drop role if exists fs_hol_rl4;
drop role if exists fs_hol_rl5;
drop role if exists fs_hol_rl6;
drop role if exists fs_hol_rl7;
drop role if exists fs_hol_rl8;
drop role if exists fs_hol_rl9;
drop role if exists fs_hol_rl10;
drop role if exists fs_hol_rl11;
drop role if exists fs_hol_rl12;
drop role if exists fs_hol_rl13;
drop role if exists fs_hol_rl14;
drop role if exists fs_hol_rl15;
drop role if exists fs_hol_rl16;
drop role if exists fs_hol_rl17;
drop role if exists fs_hol_rl18;
drop role if exists fs_hol_rl19;
drop role if exists fs_hol_rl20;
drop role if exists fs_hol_rl21;
drop role if exists fs_hol_rl22;
drop role if exists fs_hol_rl23;
drop role if exists fs_hol_rl24;
drop role if exists fs_hol_rl25;
drop role if exists fs_hol_rl26;
drop role if exists fs_hol_rl27;
drop role if exists fs_hol_rl28;
drop role if exists fs_hol_rl29;
drop role if exists fs_hol_rl30;
