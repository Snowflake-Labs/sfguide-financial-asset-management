/*
Problem Statement
    Big Data Analysis has been painful because:
        inability to scale compute instantly up and down
        fast querying has required expert and expensive tuning
        ad-hoc queries take a long time

Why Snowflake: Your benefits
    Scale compute instantly so you get the performance you pay for
    Then instantly lower or suspend compute to save money for when you will need it again
    No more cubes and less need for optimization

What we will see
    What is the most profitable position of all-time now?  Window function over billions of trades
    What is ranked PnL for a random as-of date?  Window function up to any given date

    
*/

-----------------------------------------------------
--context
    use role finservam_admin; use warehouse finservam_datascience_wh; use schema finservam.public;
    





----------------------------------------------------------------------------------------------------------
--//Big Data Analysis - size up compute instantly
    alter warehouse finservam_datascience_wh set warehouse_size = 'xxlarge';
    
        
    
    
    
    //what is most profitable position of all-time now?  Window function over billions of trades [float over trade]
    //We could persist but want to show stress-test and history cache
    //1000 traders: xxlarge takes 37 seconds; 1M rows returned
        select symbol, date, trader, cash_now, num_share_now, close, market_value, PnL
        from position_now
        order by PnL desc;




        //select get_ddl('view','position_now');




    //what is ranked PnL for a random as-of date?  Window function up to any given date
    //1000 traders: xxlarge takes 30 seconds
        set date = (select top 1 date from trade sample(1));
        
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position
        where date = $date
        order by PnL desc;







    //To see history query results:
        //Open History (In far right of results pane) | SQL






    //we are done, resize compute down 
        alter warehouse finservam_datascience_wh set warehouse_size = 'small';
        
    //option to shutdown
        alter warehouse finservam_datascience_wh suspend;






/*Recap what we saw & benefits
    What is the most profitable position of all-time now?
    What is ranked PnL for a random as-of date?

    Scale compute instantly so you get the performance you pay for
    Then instantly lower or suspend compute to save money for when you will need it again
    No more cubes and less need for optimization
*/