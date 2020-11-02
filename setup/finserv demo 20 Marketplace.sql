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
    use schema finserv.public;
    
    alter warehouse finserv_devops_wh set warehouse_size = 'medium';

    //no need to maintain - real-time updates
    select top 300 * from "ZEPL_US_STOCKS_DAILY"."PUBLIC"."STOCK_HISTORY" order by date desc;
    


----------------------------------------------------------------------------------------------------------
--Market Data Objects
        create or replace transient table finserv.public.stock_history
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

//                select top 10 * from finserv.public.stock_history;



      -----------------------------------------------------
        create or replace transient table finserv.public.stock_latest
            comment = 'latest available stock prices; We use latest date Starbucks (SBUX) is available since NYSE seems to come in at a later time; 
            remove duplicates via row_number'
        as
        with cte as
        (
          select *,
          row_number() over (partition by symbol order by symbol) num
          from finserv.public.stock_history
          where date = (select max(date) from zepl_us_stocks_daily.public.stock_history where symbol = 'SBUX')
        )
        select symbol, date, open, high, low, close, volume, adjclose
        from cte
        where num = 1
        order by symbol;//remove if a view

//                select top 10 * from finserv.public.stock_latest where symbol = 'SBUX';



      -----------------------------------------------------
        create or replace view finserv.public.company_profile
            comment = 'company profile; Note: Beta and Market Cap (mktcap) change daily but we will use these static numbers as a proxy for now; 
            we exclude columns that change with the date'
        as
        select symbol, exchange, companyname, industry, website, description, ceo, sector, beta, mktcap::number mktcap
        from zepl_us_stocks_daily.public.company_profile;
        

        //        select top 300 * from finserv.public.company_profile;
/*        
select top 300 * from zepl_us_stocks_daily.public.stock_history where symbol = 'AMZN' order by date desc;
 
select top 300 * from finserv.public.stock_latest order by close desc;
*/