/*
Financial Services Hand-On-Labs (HOL) for User

To run query:
    Blue button on top right
    Keyboard Shortcut:
        Mac: ⌘ + Enter
        Windows: Ctrl + Enter


*/

use role hol_rl;
use warehouse hol_junior;




-----------------------------------------------------
--ANSI standard data dictionary

    select table_type object_type, table_name object_name, comment /* JSON */
    from hol_uat.information_schema.tables
    where table_schema = 'PUBLIC' and comment is not null
        union all
    select 'COLUMN' object_type, table_name || '.' || column_name object_type, comment
    from hol_uat.information_schema.columns
    where table_schema = 'PUBLIC' and comment is not null
    order by 1,2;
        
        

    //what is my position and PnL as-of a date?  
        //notice 24 hour global cache on 2nd execution
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from hol_uat.public.position where date >= '2019-01-02' and symbol = 'AMZN' and trader = 'charles'
        order by date;
        

          //view using window functions on 3B+ trade table
              select get_ddl('view','hol_uat.public.position');   
              
            //let's see the metadata cache in the query profile
              select count(*) cnt, min(date) min_date, max(date) max_date from hol_uat.public.trade;
              


    //see ranked PnL for a random trader
        set trader = (select top 1 trader from hol_uat.public.trader sample(10) where trader is not null);

        select *
        from hol_uat.public.position_now
        where trader = $trader
        order by PnL desc;



    //trade-level granularity
        select * 
        from hol_uat.public.trade 
        where date >= '2019-01-01' and symbol = 'AMZN' and trader = 'charles'
        order by symbol, date;          
        
            //ANSI SQL
                select get_ddl('table','hol_uat.public.trade');   
        




//Cross-Database Joins 
    set dt = '2019-01-02';

    select k.*
    from hol_uat.public.stock_history s
    inner join economy_data_atlas.economy.usindssp2020 k on s.symbol = k."Company" and s.date = k."Date"
    where k."Company" = 'AMZN' and s.date = $dt
    order by k."Indicator Name";





//A Share is a pointer to another Snowflake account
        select top 100 * 
        from economy_data_atlas.economy.usindssp2020
        where "Company" = 'SBUX'
        order by "Date" desc;

        //Origin means it's a read-only share
        show databases;

        //Shares are read-only pointers - uncomment this command and watch it fail
        -- delete from economy_data_atlas.economy.usindssp2020;






