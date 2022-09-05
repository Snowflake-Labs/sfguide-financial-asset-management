/*
Financial Services Hand-On-Labs (HOL) for User

INSTRUCTIONS

1. Find & Replace in Snowsight or the text editor of your choice:
    for mac cmd-shift-h
    for windows ctrl-shift-h
2. Replace all occurences of fs_hol999 with "fs_hol" and the UserID you were assigned ie 1-30.
3. Change the fs_hol_rl999 to your UserID ie fs_hol_rl" and your UserID 


*/



-----------------------------------------------------
--context
    -- use role fs_hol_rl;
    -- use secondary roles all;
    use role fs_hol_rl999; use warehouse fs_hol_xsmall; use schema fs_hol_prod.public;
    


-----------------------------------------------------
--View, table, and column comments for a data dictionary

    select table_type object_type, table_name object_name, comment /* JSON */
    from fs_hol_prod.information_schema.tables
    where table_schema = 'PUBLIC' and comment is not null
        union all
    select 'COLUMN' object_type, table_name || '.' || column_name object_type, comment
    from fs_hol_prod.information_schema.columns
    where table_schema = 'PUBLIC' and comment is not null
    order by 1,2;
        
        

    //what is my position and PnL as-of a date?  
        //notice 24 hour global cache on 2nd execution
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from fs_hol_prod.public.position where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by date;
        

          //dynamic view using window functions so only pay storage for trade table; trade table drives all
              select get_ddl('view','fs_hol_prod.public.position');   
              
          //how many rows is in the trade table that we just queried?
            //let's see the metadata cache in the query profile
              select count(*) from trade;
              


    //see ranked PnL for a random trader - no indexes, statistics, vacuuming, maintenance
        set trader = (select top 1 trader from fs_hol_prod.public.trader sample(10) where trader is not null);

        select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL
        from fs_hol_prod.public.position_now
        where trader = $trader
        order by PnL desc;



    //trade - date and quantity of buy, sell, or hold action on assets: This controls the position view
        select * 
        from fs_hol_prod.public.trade 
        where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by symbol, date;          
        
            //ansi sql; comments for queryable metadata and data catalog
                select get_ddl('table','fs_hol_prod.public.trade');   
        




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

        //Shares are read-only pointers - uncomment this command and watch it fail
        -- delete from zepl_us_stocks_daily.public.stock_history;







----------------------------------------------------------------------------------------------------------
--Zero Copy Clone for instant dev,qa,sandboxes

//this is prod
  select *
  from fs_hol_prod.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

//we want to change our test / clone
  select *
  from fs_hol999.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  delete
  from fs_hol999.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  //we use Time Travel for DevOps & Rollbacks [configurable from 0-90 days]
  set queryID = last_query_id(); 
  
  select $queryID;
  
  //verify the records are gone
  select *
  from fs_hol999.public.trade 
  where trader = 'charles' and symbol = 'AMZN';
  
  
  
  
                  //we can also see and set the queryID via: Home | Activity | Query History
                      //set queryID = 'changeMe';



  //but we can use Time Travel to see before the (DML) delete
  select *
  from fs_hol999.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';
  
  
  -----------------------------------------------------
  --UNDO our delete
  insert into fs_hol999.public.trade 
  select *
  from fs_hol999.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';

//verify same as before
          select 'prod' env, count(*) cnt from fs_hol_prod.public.trade where trader = 'charles' and symbol = 'AMZN'
              union all
          select 'dev', count(*) from fs_hol999.public.trade where trader = 'charles' and symbol = 'AMZN';

          select *
          from fs_hol999.public.trade 
          where trader = 'charles' and symbol = 'AMZN';

//we can also clone
  create transient table fs_hol999.public.trade_clone clone fs_hol999.public.trade;
  
  //let's test updates against our clone
    select *
    from fs_hol999.public.trade_clone
    where trader = 'charles' and symbol = 'AMZN';

    update fs_hol999.public.trade_clone set num_shares = num_shares * 10, cash = cash * 10
    where trader = 'charles' and symbol = 'AMZN';
    
    set queryID_update = last_query_id(); 
    
    select *
    from fs_hol999.public.trade 
    before (statement => $queryID_update)
    where trader = 'charles' and symbol = 'AMZN';

  //let's test deletes against our clone
    select *
    from fs_hol999.public.trade_clone
    where trader = 'charles' and symbol = 'TSLA';

    delete from fs_hol999.public.trade_clone
    where trader = 'charles' and symbol = 'TSLA';
    
    set queryID_delete = last_query_id(); 
    
    select *
    from fs_hol999.public.trade 
    before (statement => $queryID_delete)
    where trader = 'charles' and symbol = 'TSLA';
    
  //let's swap our UAT table with our clone then rename the previous UAT
    alter table fs_hol999.public.trade swap with fs_hol999.public.trade_clone;
    
    //verify
      alter table fs_hol999.public.trade_clone rename to fs_hol999.public.trade_previous;
  
      //TSLA is gone  
      select * 
      from fs_hol999.public.position_now 
      where trader = 'charles'
      order by pnl desc;

      //AMZN has been recalculated
      select 'prod' env, * from fs_hol_prod.public.position_now where trader = 'charles' and symbol = 'AMZN'
          union all
      select 'uat' env,  * from fs_hol999.public.position_now where trader = 'charles' and symbol = 'AMZN';


/*
--Uncomment this section to test undrop table

  -----------------------------------------------------
  --Undrop is also up to 90 days of Time Travel; DBAs and Release Managers sleep much better than backup & restore
  drop table fs_hol999.public.trade;

  //this will fail until you undrop the table
  select count(*) from fs_hol999.public.trade;
  undrop table fs_hol999.public.trade;
  
  //verify undrop
  select count(*) from fs_hol999.public.trade;
  
  select top 10 *
  from fs_hol999.public.trade;
*/
