/*
Financial Services Hand-On-Labs (HOL) for User

INSTRUCTIONS

1. Find & Replace in Snowsight or the text editor of your choice:
    for mac cmd-shift-h
    for windows ctrl-shift-h
2. Replace all occurences of fs_hol3 with "fs_hol" and the UserID you were assigned ie 1-30.
3. Change the fs_hol_rl3 to your UserID ie fs_hol_rl" and your UserID 


*/



-----------------------------------------------------
--context
    -- use role fs_hol_rl;
    -- use secondary roles all;
    use role fs_hol_rl3; use warehouse fs_hol_xsmall; use schema fs_hol_prod.public;
    


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
  from fs_hol3.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  delete
  from fs_hol3.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

  //we use Time Travel for DevOps & Rollbacks [configurable from 0-90 days]
  set queryID = last_query_id(); 
  
  select $queryID;
  
  //verify the records are gone
  select *
  from fs_hol3.public.trade 
  where trader = 'charles' and symbol = 'AMZN';
  
  
  
  
                  //we can also see and set the queryID via: Home | Activity | Query History
                      //set queryID = 'changeMe';



  //but we can use Time Travel to see before the (DML) delete
  select *
  from fs_hol3.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';
  
  
  -----------------------------------------------------
  --UNDO our delete
  insert into fs_hol3.public.trade 
  select *
  from fs_hol3.public.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';

//verify same as before
          select 'prod' env, count(*) cnt from fs_hol_prod.public.trade where trader = 'charles' and symbol = 'AMZN'
              union all
          select 'dev', count(*) from fs_hol3.public.trade where trader = 'charles' and symbol = 'AMZN';

          select *
          from fs_hol3.public.trade 
          where trader = 'charles' and symbol = 'AMZN';

//we can also clone
  create transient table fs_hol3.public.trade_clone clone fs_hol3.public.trade;
  
  //let's test updates against our clone
    select *
    from fs_hol3.public.trade_clone
    where trader = 'charles' and symbol = 'AMZN';

    update fs_hol3.public.trade_clone set num_shares = num_shares * 10, cash = cash * 10
    where trader = 'charles' and symbol = 'AMZN';
    
    set queryID_update = last_query_id(); 
    
    select *
    from fs_hol3.public.trade 
    before (statement => $queryID_update)
    where trader = 'charles' and symbol = 'AMZN';

  //let's test deletes against our clone
    select *
    from fs_hol3.public.trade_clone
    where trader = 'charles' and symbol = 'TSLA';

    delete from fs_hol3.public.trade_clone
    where trader = 'charles' and symbol = 'TSLA';
    
    set queryID_delete = last_query_id(); 
    
    select *
    from fs_hol3.public.trade 
    before (statement => $queryID_delete)
    where trader = 'charles' and symbol = 'TSLA';
    
  //let's swap our UAT table with our clone then rename the previous UAT
    alter table fs_hol3.public.trade swap with fs_hol3.public.trade_clone;
    
    //verify
      alter table fs_hol3.public.trade_clone rename to fs_hol3.public.trade_previous;
  
      //TSLA is gone  
      select * 
      from fs_hol3.public.position_now 
      where trader = 'charles'
      order by pnl desc;

      //AMZN has been recalculated
      select 'prod' env, * from fs_hol_prod.public.position_now where trader = 'charles' and symbol = 'AMZN'
          union all
      select 'uat' env,  * from fs_hol3.public.position_now where trader = 'charles' and symbol = 'AMZN';





/*
--Uncomment this section to test undrop table

  -----------------------------------------------------
  --Undrop is also up to 90 days of Time Travel; DBAs and Release Managers sleep much better than backup & restore
  drop table fs_hol3.public.trade;

  //this will fail until you undrop the table
  select count(*) from fs_hol3.public.trade;
  undrop table fs_hol3.public.trade;
  
  //verify undrop
  select count(*) from fs_hol3.public.trade;
  
  select top 10 *
  from fs_hol3.public.trade;
*/











----------------------------------------------------------------------------------------------------------
--updates on a wide table
create schema if not exists fs_hol3.tpcds_sf10tcl;

use schema snowflake_sample_data.tpcds_sf10tcl;

select top 300 * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.store_sales;--29B
select top 300 * from snowflake_sample_data.tpcds_sf10tcl.item;--402K
select top 300 * from snowflake_sample_data.tpcds_sf10tcl.store;--1.5K
select top 300 * from snowflake_sample_data.tpcds_sf10tcl.customer;--65M
select top 300 * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.date_dim;--73K

select top 300 * from date_dim where year(d_date) = 2000 and month(d_date) = 6;



-----------------------------------------------------
--scale up then back down
        use warehouse fs_hol_medium;
        
        drop table if exists fs_hol3.tpcds_sf10tcl.sales_denorm1;

        --medium 2m19s
        --7 days bytes spilled to local storage
        create transient table fs_hol3.tpcds_sf10tcl.sales_denorm1 as 
        select *
        from snowflake_sample_data.tpcds_sf10tcl.store_sales ss
        inner join snowflake_sample_data.tpcds_sf10tcl.item i on i.i_item_sk = ss.ss_item_sk
        inner join snowflake_sample_data.tpcds_sf10tcl.store s on s.s_store_sk = ss.ss_store_sk
        inner join snowflake_sample_data.tpcds_sf10tcl.customer c on c.c_customer_sk = ss.ss_customer_sk
        inner join snowflake_sample_data.tpcds_sf10tcl.date_dim d on ss.ss_sold_date_sk = d.d_date_sk
        where d_date between '2000-06-01' and '2000-06-07'
        order by ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk;

        use warehouse fs_hol_xsmall;

        --cluster key for documenation and future auto-clustering as changes are made
        alter table sales_denorm1_clone cluster by (ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk);

        show tables like 'sales_denorm1%';

-----------------------------------------------------
--data discovery

    //see query profile - metadata cache
    select count(*) from fs_hol3.tpcds_sf10tcl.sales_denorm1; --58M

    //see stats pane on right
    select top 300 *
    from fs_hol3.tpcds_sf10tcl.sales_denorm1;

    //which managers had most sales?
    select s_manager, count(*) cnt
    from fs_hol3.tpcds_sf10tcl.sales_denorm1
    where s_manager is not null
    group by 1
    order by 2 desc, 1;



    //view query profile
        //click most expensive operator: table scan
        //notice pruning because sorted on ss_store_sk
    select top 300 *
    from fs_hol3.tpcds_sf10tcl.sales_denorm1
    where s_manager = 'Robert Reyes';

    //120 columns
    select top 300 * 
    from information_schema.columns c 
    where c.table_name = 'SALES_DENORM1'
    order by c.ordinal_position desc;

-----------------------------------------------------
--changes to a clone
    use schema fs_hol3.tpcds_sf10tcl;

    --let's demo transactions while we're at it
    begin transaction;
        drop table if exists fs_hol3.tpcds_sf10tcl.sales_denorm1_clone;
        create transient table fs_hol3.tpcds_sf10tcl.sales_denorm1_clone clone fs_hol3.tpcds_sf10tcl.sales_denorm1;
    commit;
    
    show tables like 'sales_denorm1%';


    -----------------------------------------------------
    --update multiple attributes in a wide table
        --add 'New and Improved: '
    select i_item_desc, i_brand, *
    from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 376283;--402K

    --micro-partition filtering, committed to two AZs
    --xsmall 8s
    update fs_hol3.tpcds_sf10tcl.sales_denorm1_clone set
        i_item_desc = 'New and Improved: ' || i_item_desc,
        i_brand = 'New and Improved: ' || i_brand
    where i_item_sk = 376283;--402K

    --verify
    select i_item_desc, i_brand, *
    from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 376283;
    

    


