/*
Financial Services Hand-On-Labs (HOL) for User

1. Find & Replace in Snowsight for:
    Mac: cmd-shift-h
    Windows: ctrl-shift-h
2. Replace all occurrences of database fs_hol3 with fs_hol and the UserID you were assigned, ie. if you're user 14 then fs_hol14


*/
    


-----------------------------------------------------
--ANSI standard data dictionary

    select table_type object_type, table_name object_name, comment /* JSON */
    from fs_hol3.information_schema.tables
    where table_schema = 'PUBLIC' and comment is not null
        union all
    select 'COLUMN' object_type, table_name || '.' || column_name object_type, comment
    from fs_hol3.information_schema.columns
    where table_schema = 'PUBLIC' and comment is not null
    order by 1,2;
        
        

    //what is my position and PnL as-of a date?  
        //notice 24 hour global cache on 2nd execution
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from fs_hol3.public.position where date >= '2019-01-02' and symbol = 'AMZN' and trader = 'charles'
        order by date;
        

          //view using window functions on 2.6B+ trade table
              select get_ddl('view','fs_hol_uat.public.position');   
              
            //let's see the metadata cache in the query profile
              select count(1) from trade;
              


    //see ranked PnL for a random trader
        set trader = (select top 1 trader from fs_hol_uat.public.trader sample(10) where trader is not null);

        select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL
        from fs_hol3.public.position_now
        where trader = $trader
        order by PnL desc;



    //trade-level granularity
        select * 
        from fs_hol3.public.trade 
        where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by symbol, date;          
        
            //ANSI SQL
                select get_ddl('table','fs_hol3.public.trade');   
        




//Cross-Database Joins 
    select sl.symbol, sl.date, sl.close, cp.exchange, cp.website, cp.description
    from fs_hol3.public.stock_latest sl
    inner join zepl_us_stocks_daily.public.company_profile cp on sl.symbol = cp.symbol
    where sl.symbol = 'AMZN';





//A Share is a pointer to another Snowflake account
        select * 
        from zepl_us_stocks_daily.public.stock_history
        where symbol = 'SBUX'
        order by date desc;

        //Origin means it's a read-only share
        show databases;

        //Shares are read-only pointers - uncomment this command and watch it fail
        -- delete from zepl_us_stocks_daily.public.stock_history;







----------------------------------------------------------------------------------------------------------
--Zero Copy Clone for instant dev,qa,sandboxes

//this is uat
  select *
  from fs_hol_uat.public.trade 
  where trader = 'charles' and symbol = 'AMZN';

//we want to change our dev clone
  select *
  from fs_hol3.public.trade 
  where trader = 'charles' and symbol = 'AMZN';
    
    
  --delete then record that queryID  
              delete
              from fs_hol3.public.trade 
              where trader = 'charles' and symbol = 'AMZN';

              set queryID = last_query_id(); 

  select $queryID;
  
  //verify the records are gone
  select *
  from fs_hol3.public.trade 
  where trader = 'charles' and symbol = 'AMZN';
  
                  //we can also see and set the queryID via: Home | Activity | Query History
                      -- set queryID = '01a72441-0604-d996-0000-7335022ae48e';


  //Use Time Travel to see before the (DML) delete
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
          select 'prod' env, count(*) cnt from fs_hol_uat.public.trade where trader = 'charles' and symbol = 'AMZN'
              union all
          select 'dev', count(*) from fs_hol3.public.trade where trader = 'charles' and symbol = 'AMZN';



//we can also clone at database, schema, or table level
  create transient table fs_hol3.public.trade_clone clone fs_hol3.public.trade;
  
    select *
    from fs_hol3.public.trade_clone
    where trader = 'charles' and symbol = 'AMZN';

              //let's test updates against our clone
                update fs_hol3.public.trade_clone set num_shares = num_shares * 10, cash = cash * 10
                where trader = 'charles' and symbol = 'AMZN';

                set queryID_update = last_query_id(); 
    
    select *
    from fs_hol3.public.trade 
    before (statement => $queryID_update)
    where trader = 'charles' and symbol = 'AMZN';



-----------------------------------------------------
--deletes
    select *
    from fs_hol3.public.trade_clone
    where trader = 'charles' and symbol = 'TSLA';

              //let's test deletes against our clone
                delete from fs_hol3.public.trade_clone
                where trader = 'charles' and symbol = 'TSLA';

                set queryID_delete = last_query_id(); 
    
    select *
    from fs_hol3.public.trade 
    before (statement => $queryID_delete)
    where trader = 'charles' and symbol = 'TSLA';
    
  //let's swap our dev table with our changed clone then rename the original table to previous
    alter table fs_hol3.public.trade swap with fs_hol3.public.trade_clone;
    
    //verify
      alter table fs_hol3.public.trade_clone rename to fs_hol3.public.trade_previous;
  
      //TSLA is gone even from the window function view
      select * 
      from fs_hol3.public.position_now 
      where trader = 'charles'
      order by pnl desc;

      //AMZN has been recalculated as well
      select 'uat' env, * from fs_hol_uat.public.position_now where trader = 'charles' and symbol = 'AMZN'
          union all
      select 'dev' env,  * from fs_hol3.public.position_now where trader = 'charles' and symbol = 'AMZN';





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

    --https://www.snowflake.com/blog/tpc-ds-now-available-snowflake-samples/
                select top 300 * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.store_sales;--29B
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.item;--402K
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.store;--1.5K
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.customer;--65M
                select top 300 * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.date_dim;--73K
                select top 300 * from date_dim where year(d_date) = 2000 and month(d_date) = 6;



    -----------------------------------------------------
    --scale up then back down - let's run the next 4 code blocks as a batch - recommended for automated ELT
                use warehouse fs_hol_power;

                drop table if exists fs_hol3.tpcds_sf10tcl.sales_denorm1;

                --medium 2m19s; large 1m41s; xlarge 50s
                create transient table fs_hol3.tpcds_sf10tcl.sales_denorm1 as 
                select *
                from snowflake_sample_data.tpcds_sf10tcl.store_sales ss
                inner join snowflake_sample_data.tpcds_sf10tcl.item i on i.i_item_sk = ss.ss_item_sk
                inner join snowflake_sample_data.tpcds_sf10tcl.store s on s.s_store_sk = ss.ss_store_sk
                inner join snowflake_sample_data.tpcds_sf10tcl.customer c on c.c_customer_sk = ss.ss_customer_sk
                inner join snowflake_sample_data.tpcds_sf10tcl.date_dim d on ss.ss_sold_date_sk = d.d_date_sk
                where d_date between '2000-06-01' and '2000-06-07'
                order by ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk;

                use warehouse fs_hol_junior;

        --cluster key for future auto-clustering as changes are made
        alter table sales_denorm1 cluster by (ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk);
        
        --notice automatic_clustering
        show tables like 'sales_denorm1%';

-----------------------------------------------------
--data discovery

    //see query profile - metadata cache
    select count(*) from fs_hol3.tpcds_sf10tcl.sales_denorm1; --58M

    //see stats pane on right
    select top 300 *
    from fs_hol3.tpcds_sf10tcl.sales_denorm1;

    //which managers had the most sales?
    select s_manager, count(*) cnt
    from fs_hol3.tpcds_sf10tcl.sales_denorm1
    where s_manager is not null
    group by 1
    order by 2 desc, 1;



    //notice pruning though not on cluster key
    select top 300 *
    from fs_hol3.tpcds_sf10tcl.sales_denorm1
    where s_manager = 'Robert Reyes';

    //120 columns
    select * 
    from information_schema.columns c 
    where c.table_name = 'SALES_DENORM1'
    order by c.ordinal_position desc;

-----------------------------------------------------
--changes to a clone
    use schema fs_hol3.tpcds_sf10tcl;

    --clone
    drop table if exists fs_hol3.tpcds_sf10tcl.sales_denorm1_clone;
    create transient table fs_hol3.tpcds_sf10tcl.sales_denorm1_clone clone fs_hol3.tpcds_sf10tcl.sales_denorm1;
    
    show tables like 'sales_denorm1%';

    select i_item_sk, count(*) cnt
    from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone
    group by 1
    order by 2 desc;

    -----------------------------------------------------
    --add 'New and Improved: ' to multiple attributes in a wide table
        --
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
    
    
----------------------------------------------------------------------------------------------------------
--TRANSACTION DEMO

    --all the records from GA (Georgia) are incorrect so we delete them
    select s_state, count(*) cnt
    from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037
    group by 1
    order by 2 desc;

    --we want to have 15% margins
    select i_current_price, i_wholesale_cost, i_brand
    from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037;
    
    --verify but rollback since not ready to release yet
    begin transaction;
        delete from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone 
        where i_item_sk = 319037 and s_state = 'GA';
    
        --we are like Costco and want 15% margins
        update fs_hol3.tpcds_sf10tcl.sales_denorm1_clone set
            i_current_price = i_wholesale_cost * 1.15 
        where i_item_sk = 319037;

        --notice GA is gone
        select s_state, count(*) cnt
        from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037
        group by 1
        order by 2 desc;
        
        --15% margins
        select i_current_price, i_wholesale_cost, i_brand
        from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037;

        --null means no transaction
        select current_transaction();
    
            --replace with your current_transaction()
            -- describe transaction 1662471136171000000;

    rollback;

        --verify rollback
        select i_current_price, i_wholesale_cost, i_brand
        from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037;
        
        select s_state, count(*) cnt
        from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037
        group by 1
        order by 2 desc;

    --it's good let's commit it for real

    --let's run the next 4 statements as a batch
                begin transaction;
                    --we are like Costco and want 15% margins
                    update fs_hol3.tpcds_sf10tcl.sales_denorm1_clone set
                        i_current_price = i_wholesale_cost * 1.15 
                    where i_item_sk = 319037;

                    delete from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone 
                    where i_item_sk = 319037 and s_state = 'GA';

                commit;

        --verify commit
        select i_current_price, i_wholesale_cost, i_brand
        from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037;
        
        select s_state, count(*) cnt
        from fs_hol3.tpcds_sf10tcl.sales_denorm1_clone where i_item_sk = 319037
        group by 1
        order by 2 desc;
    
    
--End of updates and transactions on a wide table
