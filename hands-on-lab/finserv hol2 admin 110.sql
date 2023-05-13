/*
Financial Services Hand-On-Labs (HOL) for User

1. Find & Replace in Snowsight for:
    Mac: cmd-shift-h
    Windows: ctrl-shift-h
2. Replace all occurrences of schema hol_schemaName with your current_schema (which is the same as your username)

*/

select current_schema();

/*
--Core Lab
    --Part 1: Time Travel: 0-90 days Undo
    --Part 2: Zero Copy Clone: "Game Changer"
    --Part 3: Undrop Object (Database, Schema, Table)

--Extra Credit on Wide Tables
    --Part 4: Size up or Switch Compute Instantly; CTAS CreateTableAS on a wide table
    --Part 5: Data Discovery and Charting (for SnowSight Dashboards)
    --Part 6: DML (Data Manipulation Language) on a Wide Table
    --Part 7: Rollback and Transaction
    
*/

use role hol_rl;
use warehouse hol_junior;
use schema hol_uat.hol_schemaName;



----------------------------------------------------------------------------------------------------------
--Part 1: Time Travel: 0-90 days Undo
    --What did user know at time x, Lower DevOps Risk

--we are now in our cloned sandbox which won't affect any other environment
    select count(*) from hol_uat.hol_schemaName.trade;

--notice data is same between uat
  select *
  from hol_uat.public.trade 
  where trader = 'charles' and symbol = 'AMZN'
  order by date;

--DevOps: we want to change our sandbox (schema)
  select *
  from hol_uat.hol_schemaName.trade 
  where trader = 'charles' and symbol = 'AMZN';
    
    
  --delete then record that queryID  
              delete
              from hol_uat.hol_schemaName.trade 
              where trader = 'charles' and symbol = 'AMZN';

              --another way: Home | Activity | Query History
              set queryID = last_query_id(); 

  select $queryID;
  
  --verify the records are gone
  select *
  from hol_uat.hol_schemaName.trade 
  where trader = 'charles' and symbol = 'AMZN';
  
  --Use Time Travel to see before the (DML) delete
  select *
  from hol_uat.hol_schemaName.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';
  
  
  -----------------------------------------------------
  --UNDO our delete
  insert into hol_uat.hol_schemaName.trade 
  select *
  from hol_uat.hol_schemaName.trade 
  before (statement => $queryid)
  where trader = 'charles' and symbol = 'AMZN';

--verify same as before
          select 'uat' env, count(*) cnt from hol_uat.hol_schemaName.trade where trader = 'charles' and symbol = 'AMZN'
              union all
          select 'dev', count(*) from hol_uat.hol_schemaName.trade where trader = 'charles' and symbol = 'AMZN';









----------------------------------------------------------------------------------------------------------
--Part 2: Zero Copy Clone: "Game Changer"
    --Instant Isolated Environments - in seconds - at no additional storage cost
    --Retire cost and maintenance of seperate Dev, QA, and UAT environments (Keep a small "Lab" environment for one-off risky testing)
    --Save signifcant time and cost by doing DevOps on Production
    --Much easier environment regression tests / lower operational risk
    --Zero Copy Clone plus Time Travel for backups





--we can also clone at database, schema, or table level
  create transient table hol_uat.hol_schemaName.trade_clone clone hol_uat.hol_schemaName.trade;
  
    select *
    from hol_uat.hol_schemaName.trade_clone
    where trader = 'charles' and symbol = 'AMZN';

              --let's test updates against our clone
                update hol_uat.hol_schemaName.trade_clone set num_shares = num_shares * 10, cash = cash * 10
                where trader = 'charles' and symbol = 'AMZN';

                --another way: Home | Activity | Query History
                set queryID_update = last_query_id(); 

    --Use Time Travel to see before the (DML) update
    select *
    from hol_uat.hol_schemaName.trade 
    before (statement => $queryID_update)
    where trader = 'charles' and symbol = 'AMZN';


    
  --ALTER TABLE... SWAP WITH: DevOps / present refreshed data to the business transparently
    alter table hol_uat.hol_schemaName.trade swap with hol_uat.hol_schemaName.trade_clone;
    
    --verify
      alter table hol_uat.hol_schemaName.trade_clone rename to hol_uat.hol_schemaName.trade_previous;









----------------------------------------------------------------------------------------------------------
--Part 3: Undrop Object (Database, Schema, Table)
    --Inherits Time Travel Setting of 0-90 days



--Uncomment this section to test undrop table and schema

    --table
    drop table hol_uat.hol_schemaName.trade;
    
    --this will fail
    select count(*) from hol_uat.hol_schemaName.trade;

    --until you undrop table
    undrop table hol_uat.hol_schemaName.trade;
    
    --verify undrop
    select count(*) from hol_uat.hol_schemaName.trade;
    

/*    
    --schema
    drop schema hol_schemaName;
    
    --this will fail
    select count(*) from hol_uat.hol_schemaName.trade;

    --until you undrop schema
    undrop schema hol_schemaName;
    
    -- verify
    select count(*) from hol_uat.hol_schemaName.trade;
*/








----------------------------------------------------------------------------------------------------------
--Half-Time Recap
--Core Lab
    --Part 1: Time Travel: 0-90 days Undo
    --Part 2: Zero Copy Clone: "Game Changer"
    --Part 3: Undrop Object (Database, Schema, Table)

--Continue on to Extra Credit on Wide Tables?






----------------------------------------------------------------------------------------------------------
--Part 4: Size up or Switch Compute Instantly; CTAS CreateTableAS on a wide table



    --https:--www.snowflake.com/blog/tpc-ds-now-available-snowflake-samples/
    /*
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.store_sales;--29b
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.item;--402k
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.store;--1.5k
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.customer;--65m
                select top 300 * from snowflake_sample_data.tpcds_sf10tcl.date_dim;--73k
                select top 300 * from date_dim where year(d_date) = 2000 and month(d_date) = 6;
    */


    -----------------------------------------------------
    --best practice: scale up compute then back down
        use warehouse hol_power;

                    --Best Practice: Create every table with an Order By column for faster & efficient querying
                    --when only one user: medium 2m19s; large 1m1s; xlarge 50s
                    create or replace transient table hol_uat.hol_schemaName.sales_denorm1 as 
                    select *
                    from snowflake_sample_data.tpcds_sf10tcl.store_sales ss
                    inner join snowflake_sample_data.tpcds_sf10tcl.item i on i.i_item_sk = ss.ss_item_sk
                    inner join snowflake_sample_data.tpcds_sf10tcl.store s on s.s_store_sk = ss.ss_store_sk
                    inner join snowflake_sample_data.tpcds_sf10tcl.customer c on c.c_customer_sk = ss.ss_customer_sk
                    inner join snowflake_sample_data.tpcds_sf10tcl.date_dim d on ss.ss_sold_date_sk = d.d_date_sk
                    where d_date between '2000-06-01' and '2000-06-07'
                    order by ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk;

        use warehouse hol_junior;

        --you just created a table with 58 million rows
        select count(*) from hol_uat.hol_schemaName.sales_denorm1;

        --and 120 columns
        select *
        from information_schema.columns
        where table_schema = upper('hol_schemaName') and table_name = 'SALES_DENORM1'
        order by ordinal_position desc;



        

        --Best Practice for business-facing tables: cluster key for auto-clustering (instant as it's a metadata operation)
        alter table hol_schemaName.sales_denorm1 cluster by (ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk);

            --change schema
            use schema hol_schemaName;
        
            --notice cluster_by and automatic_clustering
            show tables like 'SALES_DENORM1%';









----------------------------------------------------------------------------------------------------------
--Part 5: Data Discovery and Charting (for SnowSight Dashboards)



    
    --In Stats Pane on right, click a few objects
    select top 300 *
    from hol_uat.hol_schemaName.sales_denorm1;

    
    --Which managers had the most sales?
    select s_manager, count(*) cnt
    from hol_uat.hol_schemaName.sales_denorm1
    where s_manager is not null
    group by 1
    order by 2 desc, 1;

    --Let's make a Chart (You can use this for Dashboards later):
        --Chart | Bar (Chart Type)
        --Appearance | Orientation | "Horizontal Icon"
        --CNT(SUM), S_MANAGER Y-Axis; Orientation Horizontal







----------------------------------------------------------------------------------------------------------
--Part 6: DML (Data Manipulation Language) on a Wide Table



    --notice pruning though not on cluster key (ss_sold_date_sk, ss_item_sk, ss_store_sk, ss_customer_sk)
    --Ellipsis | View Query Profile
    select top 300 *
    from hol_uat.hol_schemaName.sales_denorm1
    where s_manager = 'Robert Reyes';



    -----------------------------------------------------
    --changes to our wide table
    
    --clone
    drop table if exists hol_uat.hol_schemaName.sales_denorm1_sandbox;
    create transient table hol_uat.hol_schemaName.sales_denorm1_sandbox clone hol_uat.hol_schemaName.sales_denorm1;

    --notice looks the same but zero additional storage cost
    show tables like 'sales_denorm1%';


    

    -----------------------------------------------------
    --add 'New and Improved: ' to multiple attributes in a wide table

    --update 2 columns in 309 records
    select i_item_desc, i_brand, count(*) cnt
    from hol_uat.hol_schemaName.sales_denorm1_sandbox
    where i_item_sk = 376283
    group by 1,2;

    --micro-partition filtering, committed to two AZs
    --small 7s
    update hol_uat.hol_schemaName.sales_denorm1_sandbox set
        i_item_desc = 'New and Improved: ' || i_item_desc,
        i_brand = 'New and Improved: ' || i_brand
    where i_item_sk = 376283;

    --verify
    select i_item_desc, i_brand, count(*) cnt
    from hol_uat.hol_schemaName.sales_denorm1_sandbox
    where i_item_sk = 376283
    group by 1,2;
    








----------------------------------------------------------------------------------------------------------
--Part 7: Rollback and Transaction


    --let's delete all records about GA (Georgia)
    select s_state, count(*) cnt
    from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037
    group by 1
    order by 2 desc;

    --we also want to have 15% margins (notice how price is higher than wholesale cost)
    select i_current_price, i_wholesale_cost, i_brand
    from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037;
    
    --verify but rollback since not ready to release yet
    begin transaction;
            delete from hol_uat.hol_schemaName.sales_denorm1_sandbox 
            where i_item_sk = 319037 and s_state = 'GA';--105
        
            --we are like Costco and want 15% margins
            update hol_uat.hol_schemaName.sales_denorm1_sandbox set
                i_current_price = i_wholesale_cost * 1.15 
            where i_item_sk = 319037;
    
            --notice GA is gone
            select s_state, count(*) cnt
            from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037
            group by 1
            order by 2 desc;
            
            --15% margins
            select i_current_price, i_wholesale_cost, i_brand
            from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037;
    
            --a value means you're in a transaction
            select current_transaction();
    
    rollback;

        --Verify rollback
    
            -- null means no transaction
            select current_transaction();
        
            --verify rollback (notice price is back to original being lower than wholesale)
            select i_current_price, i_wholesale_cost, i_brand
            from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037;
    
            --Georgia (GA) has returned
            select s_state, count(*) cnt
            from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037
            group by 1
            order by 2 desc;
    

    --we are ready to commit: let's select all 4 statements to run them as a batch
            begin transaction;
                    --we are like Costco and want 15% margins
                    update hol_uat.hol_schemaName.sales_denorm1_sandbox set
                        i_current_price = i_wholesale_cost * 1.15 
                    where i_item_sk = 319037;

                    delete from hol_uat.hol_schemaName.sales_denorm1_sandbox 
                    where i_item_sk = 319037 and s_state = 'GA';

            commit;

            --verify commit
            select i_current_price, i_wholesale_cost, i_brand
            from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037;
            
            select s_state, count(*) cnt
            from hol_uat.hol_schemaName.sales_denorm1_sandbox where i_item_sk = 319037
            group by 1
            order by 2 desc;








--Recap
--Core Lab
    --Part 1: Time Travel: 0-90 days Undo
    --Part 2: Zero Copy Clone: "Game Changer"
    --Part 3: Undrop Object (Database, Schema, Table)

--Extra Credit on Wide Tables
    --Part 4: Size up or Switch Compute Instantly; CTAS CreateTableAS on a wide table
    --Part 5: Data Discovery and Charting (for SnowSight Dashboards)
    --Part 6: DML (Data Manipulation Language) on a Wide Table
    --Part 7: Rollback and Transaction
