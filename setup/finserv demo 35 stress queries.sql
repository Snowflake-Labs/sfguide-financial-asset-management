/*
Why
    We demo running these first in the background since the stress-tests takes a few minutes
    Run-time depending on our number of traders (trading 1000 trades a day since 2010)

What we will see
    What is the most profitable position of all-time now?  Window function over 10 billion rows (10 years of data)
    What is ranked PnL for a random as-of date?  Window function up to any given date

    
*/

-----------------------------------------------------
--context
    use role finserv_admin; use warehouse finserv_datascience_wh; use schema finserv.public;
    





----------------------------------------------------------------------------------------------------------
--//Big Data Analysis - size up compute instantly
    alter warehouse finserv_datascience_wh set warehouse_size = 'xxlarge';
    
        
    
    
    
    //what is most profitable position of all-time now?  Window function over 10 billion rows (10 years of data)
    //We could persist but want to show stress-test and history cache
        select symbol, date, trader, cash_now, num_share_now, close, market_value, PnL
        from position_now
        order by PnL desc;



    //float over trade table to see the row count
        //select get_ddl('view','position_now');




    //what is ranked PnL for a random as-of date?  Window function up to any given date
        set date = (select top 1 date from trade sample(10));
        
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position
        where date = $date
        order by PnL desc;






    //You can persist these to tables for significantly faster reporting





    //To see history query results:
        //Open History (In far right of results pane) | SQL






    //we are done, resize compute down 
        alter warehouse finserv_datascience_wh set warehouse_size = 'small';
        
    //option to shutdown
        alter warehouse finserv_datascience_wh suspend;






//Recap and benefits of what we showed:
    //    What is the most profitable position of all-time now?  Window function over 10 billion rows (10 years of data)
    //    What is ranked PnL for a random as-of date?  Window function up to any given date



//BI demo

