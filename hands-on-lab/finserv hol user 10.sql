/*
Financial Services Hand-On-Labs (HOL) for User


*/



-----------------------------------------------------
--context
    use role fs_hol_rl; use warehouse fs_hol_xsmall; use schema fs_hol_prod.public;
    


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




    //what is the current PnL for trader charles? - view on trade table so always updated as trade populated
        //notice it is a non-materialized window function view on 2 billion rows
        select *
        from position_now where trader = 'charles'
        order by PnL desc;
        
                
        
    //see ranked PnL for a random trader - no indexes, statistics, vacuuming, maintenance
        set trader = (select top 1 trader from trader sample(10) where trader is not null);

        select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL
        from position_now
        where trader = $trader
        order by PnL desc;
        
        

    //what is my position and PnL as-of a date?  
        //notice 24 hour global cache on 2nd execution
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by date;
        

          //dynamic view using window functions so only pay storage for trade table; trade table drives all
              select get_ddl('view','position');   
              




    //trade - date and quantity of buy, sell, or hold action on assets: This controls the position view
        select * 
        from trade 
        where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by symbol, date;          
        
            //ansi sql; comments for queryable metadata and data catalog
                select get_ddl('table','trade');   



//Cross-Database Joins 
    select sl.symbol, sl.date, sl.close, cp.exchange, cp.website, cp.description
    from fs_hol_prod.public.stock_latest sl
    inner join zepl_us_stocks_daily.public.company_profile cp on sl.symbol = cp.symbol
    where sl.symbol = 'AMZN';





//Instant Real-Time Market Data with neither copying nor FTP
        //Query terabytes immediately
        select * 
        from zepl_us_stocks_daily.public.stock_history
        where symbol = 'SBUX'
        order by date desc;
        






----------------------------------------------------------------------------------------------------------
--Zero Copy Clone for instant dev,qa,sandboxes


  select *
  from fs_hol_prod.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

//we want to change this
  select *
  from fs_hol1.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  delete
  from fs_hol1.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

//we use Time Travel for DevOps & Rollbacks [configurable from 0-90 days]

  //set a parameter
  set queryID = last_query_id(); 
  
  select $queryID;
  
  //verify the records are gone
  select *
  from fs_hol1.public.trade 
  where trader = 'charles' and symbol = 'AMZN';
  
  
                  //we can also see and set the queryID via: Home | Activity | Query History
                      //set queryID = '01a61bc3-0504-9531-0000-7335021bd556';



  //but we can use Time Travel to see before the (DML) delete
  select *
  from fs_hol1.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';
  
  
  -----------------------------------------------------
  --UNDO our delete
  insert into fs_hol1.public.trade 
  select *
  from fs_hol1.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';

//verify same as before
          select 'prod' env, count(*) cnt from fs_hol_prod.public.trade where trader = 'charles' and symbol = 'AMZN'
              union all
          select 'dev', count(*) from fs_hol1.public.trade where trader = 'charles' and symbol = 'AMZN';

          select *
          from fs_hol1.public.trade 
          where trader = 'charles' and symbol = 'AMZN';

  -----------------------------------------------------
  --Undrop is also up to 90 days of Time Travel; DBAs and Release Managers sleep much better than backup & restore
  drop table fs_hol1.public.trade;
  select count(*) from fs_hol1.public.trade;
  undrop table fs_hol1.public.trade;
  
  //verify undrop
  select top 10 *
  from fs_hol1.public.trade;



