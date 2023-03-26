/*
This demo answers the question:
    What would a Single Version of the Truth (SVOT) on Snowflake for Asset Managers look like?

Why Snowflake: Your benefits
    Significantly less cost of maintaining one high performance SVOT    
    SVOT makes trading, risk management, regulatory reporting, and all use cases significantly easier
    Unlimited Compute and Concurrency enable quick data-driven decisions

What we will see
    Use Data Marketplace to instantly get stock history
    Query trade, cash, positions, and PnL on 2 billion or more rows on Snowflake
    Use Window Functions to automate cash, position, and PnL reporting
    
*/


-----------------------------------------------------
--context
    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
    
    //if desired, resize compute - we start low to save money
    alter warehouse finservam_devops_wh set warehouse_size = 'small';

    /*. XSMALL SMALL MEDIUM LARGE XLARGE X2LARGE X3LARGE X4LARGE  */



-----------------------------------------------------
--View, table, and column comments for a data dictionary

    select table_type object_type, table_name object_name, comment /* JSON */
    from information_schema.tables
    where table_schema = 'PUBLIC' and comment is not null
        union all
    select 'COLUMN' object_type, table_name || '.' || column_name object_type, comment
    from information_schema.columns
    where table_schema = 'PUBLIC' and comment is not null
    order by 1,2;


    set date = (select max(date) from trade);

    //what is the current PnL for trader charles? - view on trade table so always updated as trade populated
        select *
        from position where trader = 'charles'
        and date = $date
        order by PnL desc;

                
        
    //see ranked PnL for a random trader - no indexes, statistics, vacuuming, maintenance
        set trader = (select top 1 trader from trader sample(10) where trader is not null);

        select *
        from position
        where trader = $trader
        and date = $date
        order by PnL desc;
        
        

    //option to disable cache
//        alter user set use_cached_result=false;  
//        alter user set use_cached_result=true; 

    //time-series: what is my position as-of a date?  
        //notice 24 hour global cache on 2nd execution

        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position where date >= '2019-01-01' and symbol = 'TSLA' and trader = 'charles'
        order by date;

        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position where date >= '1980-01-01' and symbol = 'AAPL' and trader = $trader
        order by date;

        
        select top 300 * from trade;


        -- alter user set use_cached_result=false;  
        -- alter user set use_cached_result=true; 

        --metadata cache
        select count(*) from trade;
        

          //dynamic view using window functions so only pay storage for trade table; trade table drives all
              select get_ddl('view','position');   

              --see the rowcount and metadata
              show tables like 'trade';

              






    //trade - date and quantity of buy, sell, or hold action on assets: This controls the position view
        select * 
        from trade 
        where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by symbol, date;          
        
            //ansi sql; comments for queryable metadata and data catalog
                select get_ddl('table','trade');   



select * 
from trade 
where date >= '2019-12-31' and trader = 'charles'
order by date, symbol;

//Python Functions
    select
        FAKE('en_US','name',null)::varchar as trader
    from table(generator(rowcount => 10));



//Cross-Database Joins 
    set dt = '2019-01-02';

    select k.*
    from finservam.public.stock_history s
    inner join economy_data_atlas.economy.usindssp2020 k on s.symbol = k."Company" and s.date = k."Date"
    where k."Company" = 'AMZN' and s.date = $dt
    order by k."Indicator Name";





//Instant Real-Time Market Data with neither copying nor FTP
        //Query terabytes immediately
        select * 
        from economy_data_atlas.economy.usindssp2020
        where "Company" = 'SBUX'
        and "Indicator Name" = 'Close'
        order by "Date" desc;
        






----------------------------------------------------------------------------------------------------------
--Zero Copy Clone for instant dev,qa,sandboxes
use role accountadmin;
drop database if exists finservam_qa1;


create database finservam_qa1 clone finservam;



//Clones are zero additional storage cost; storage cost is only on deltas; 
//ie 1 TB in prod; change .1 TB in clone only pay for 1.1 automatically compressed TB
  select *
  from finservam.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  //we can change clones without impacting production
  select *
  from finservam_qa1.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  
  update finservam_qa1.public.trade set symbol = 'GE'
  where trader = 'charles' and symbol = 'AMZN';


  //we use Time Travel for DevOps & Rollbacks [configurable from 0-90 days]
    set queryID = last_query_id(); 
  
  
  //optional: we can also set the queryID by looking at Query History
      //      set queryID = '01a66082-0604-ab79-0000-7335021ce9ce';



  //we Time Travel to see before the (DML) delete
  select *
  from finservam_qa1.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';
  
  
  -----------------------------------------------------
  --UNDO our delete
  insert into finservam_qa1.public.trade 
  select *
  from finservam_qa1.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';
  
  
  -----------------------------------------------------
  --Undrop is also up to 90 days of Time Travel; DBAs and Release Managers sleep much better than backup & restore
  drop table finservam_qa1.public.trade;
  -- select count(*) from finservam_qa1.public.trade;
  undrop table finservam_qa1.public.trade;
  
  drop database finservam_qa1;
  -- select count(*) from finservam_qa1.public.trade;
  undrop database finservam_qa1;
  
  drop database finservam_qa1;


  //if we don't want to wait for auto-suspend
    alter warehouse finservam_devops_wh suspend;

    use schema finservam.public;
