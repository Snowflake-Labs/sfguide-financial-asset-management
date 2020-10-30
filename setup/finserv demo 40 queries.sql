/*
GITHUB
    https://github.com/allen-wong-tech/asset-management

DEMO
    Fundamentals of asset managers: trade, cash, positions, PnL
    
Problem Statement
    Asset managers have spent hundreds of millions on systems to accurately give a Single Version of Truth (SVOT) in real-time

Why Snowflake: Your benefits
    Significantly less cost of maintaining one high performance SVOT    
    SVOT makes trading, risk management, and regulatory reporting significantly easier
    Unlimited Compute and Concurrency enable quick data-driven decisions

Scope of this demo
    Show how to query trade, cash, positions, and PnL on Snowflake
    Use Data Marketplace to get stock history
    Use Window Functions to automate cash, position, and PnL reporting
    
*/

-----------------------------------------------------
--context
    use role finserv_admin; use warehouse finserv_devops_wh; use schema finserv.public;
    
    //if desired, resize compute - we start low to save money
    alter warehouse finserv_devops_wh set warehouse_size = 'small';

-----------------------------------------------------
--Object comments for a data dictionary
    select table_type, table_name, comment
    from finserv.information_schema.tables
    where table_schema = 'PUBLIC'
    order by 1,2;
    
    --column comments
    select table_name, column_name, comment
    from finserv.information_schema.columns
    where table_schema = 'PUBLIC' and comment is not null
    order by table_name, ordinal_position;


    //what is the current PnL for trader charles? - view on trade table so always updated as trade populated
        select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL
        from position_now where trader = 'charles'
        order by PnL desc;
        
    //see ranked PnL for a random trader - no indexes, statistics, vacuuming, maintenance
        set trader = (select top 1 trader from trader sample(10));

        select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL
        from position_now
        where trader = $trader
        order by PnL desc;
        

    //what is my position and PnL as-of a date?
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position where date >= '2019-01-01' and symbol = 'MSFT' and trader = 'charles'
        order by date;
        
          //dynamic view using window functions so only pay storage for trade table; trade table drives all
              select get_ddl('table','position');   

    //trade - date and quantity of buy, sell, or hold action on assets: This controls the position view
        select * 
        from trade 
        where date >= '2019-01-01' and symbol = 'MSFT' and trader = 'charles'
        order by symbol, date;          
        
            //ansi sql; comments for queryable metadata and data catalog
                select get_ddl('table','trade');   




//Instant Real-Time Market Data
        //stock_history from Data Marketplace
        //Factset / S&P: Instant access to entire catalog (Terabytes in seconds)
        select * 
        from stock_history
        where symbol = 'SBUX'
        order by date desc;
        
    //stock_latest - real-time stock quotes with zero maintenance
        select top 100 s.*
        from stock_latest s
        inner join watchlist w on s.symbol = w.symbol
        order by 1;


----------------------------------------------------------------------------------------------------------
--//Big Data Analysis - size up instantly
    alter warehouse finserv_devops_wh set warehouse_size = 'xlarge';
    
    //what is most profitable position now?
        select symbol, date, trader, cash_now, num_share_now, close, market_value, PnL
        from position_now
        order by PnL desc;

    //see ranked PnL for a random as-of date - unique micropartitions filter out
        set date = (select top 1 date from trade sample(10));
        
        select symbol, date, trader, cash_cumulative, num_shares_cumulative, close, market_value, PnL
        from position
        where date = $date
        order by PnL desc;

    //we are done, resize compute down
        alter warehouse finserv_devops_wh set warehouse_size = 'small';






//Recap
    //Showed Window Function view on position that give PnL, Cash, As-of-date PnL
    //Data Instantly from Data Marketplace with zero maintenance going forward
    //Trade table drives everything
    //FOSS so you can start building on this code


    //BI demo


