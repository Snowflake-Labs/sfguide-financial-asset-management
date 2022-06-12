/*
What we will do in "script 20":
    Use a free share from the Data Marketplace to get stock price history
    Data Governance via RBAC by adding finservam_admin as role that can access data
    Data Quality Check by ensuring no duplicates


Use role AccountAdmin on Snowflake level
Data Marketplace | Explore the Data Marketplace | Search for "Zepl"
US Stock Market for Data Science | Get Data

Change Database name to: ZEPL_US_STOCKS_DAILY
Add finservam_admin as role that can access
Accept legal terms

Create Database | Done
On Database Objects to your left, Click "Refresh Now" and see the Zepl share

*/

-----------------------------------------------------
--setup
    use role accountadmin;
    use warehouse finservam_devops_wh;

/*
--create database from marketplace share
    set acct_name = 'ZEPL';
    set share_name = 'US_STOCKS_DAILY';
    set share = $acct_name || '.' || $share_name;

    create or replace database ZEPL_US_STOCKS_DAILY from share identifier($share);
    grant imported privileges on database ZEPL_US_STOCKS_DAILY to role finservam_admin;
*/

--Test Driven Development: Verify Data Marketplace Share; Instructions are in topmost comments
    select top 1 *
    from zepl_us_stocks_daily.public.stock_history;


--Test Driven Development: Verify snowflake_sample_data share; Instructions are here:
--https://github.com/Snowflake-Labs/sfguide-financial-asset-management#how-to-install-takes-under-7-minutes-each-script-is-idempotent
    select top 1 *
    from snowflake_sample_data.tpcds_sf10tcl.customer;


--Size up compute
    alter warehouse finservam_devops_wh set warehouse_size = 'medium';
    use role finservam_admin;
    use schema finservam.public;

----------------------------------------------------------------------------------------------------------
--Market Data Objects
        create or replace transient table finservam.public.stock_history
            comment = 'zepl_us_stocks_daily stock_history but with duplicates removed'
        as
        with cte as
        (
          select *,
          row_number() over (partition by symbol,date order by date) num
          from zepl_us_stocks_daily.public.stock_history
        )
        select symbol, date, open, high, low, close, volume, adjclose
        from cte
        where num = 1
        order by date, symbol;//remove if a view
        
        comment on column stock_history.close is 'closing price used for all transactions';





      -----------------------------------------------------
        create or replace transient table finservam.public.stock_latest
            comment = 'latest available stock prices; We use latest date Starbucks (SBUX) is available since NYSE seems to come in at a later time; 
            remove duplicates via row_number'
        as
        with cte as
        (
          select *,
          row_number() over (partition by symbol order by symbol) num
          from stock_history
          where date = (select max(date) from zepl_us_stocks_daily.public.stock_history where symbol = 'SBUX')
        )
        select symbol, date, open, high, low, close, volume, adjclose
        from cte
        where num = 1
        order by symbol;//remove if a view





      -----------------------------------------------------
        create or replace view finservam.public.company_profile
            comment = 'company profile; Note: Beta and Market Cap (mktcap) change daily but we will use these static numbers as a proxy for now; 
            we exclude columns that change with the date'
        as
        select symbol, exchange, companyname, industry, website, description, ceo, sector, beta, mktcap::number mktcap
        from zepl_us_stocks_daily.public.company_profile;
        

-----------------------------------------------------
--suspend Virtual Warehouse to save credits
    alter warehouse finservam_devops_wh set warehouse_size = 'xsmall';
    alter warehouse finservam_devops_wh suspend;

