/*
We want to use the Data Marketplace to get a free Data Share from Zepl 

Use role AccountAdmin on Snowflake level
Data Marketplace | Explore the Data Marketplace | Search for Zepl
US Stock Market for Data Science | Get Data
Change Database name to: ZEPL_US_STOCKS_DAILY
Add finserv_admin as role that can access
Accept legal terms
Create Database | Done
On Database Objects to your left, Click "Refresh Now" and see the Zepl share

*/

-----------------------------------------------------
--smoke test
    use role finserv_admin;
    use warehouse finserv_devops_wh;

    select top 300 * from "ZEPL_US_STOCKS_DAILY"."PUBLIC"."STOCK_HISTORY";
