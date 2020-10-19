/*
DEMO
    Fundamentals of asset managers: trade, cash, and positions
    
Problem Statement
    Asset managers have spent hundreds of millions on systems to accurately give a Single Version of Truth (SVOT) in real-time
    Historically, all of this data has been siloed because one system couldn't handle all of the data and all of the users with high performance

Why Snowflake
    Significantly less cost of maintaining one high performance SVOT    
    SVOT makes trading, risk management, and regulatory reporting significantly easier
    Unlimited Compute and Concurrency enable quick data-driven decisions

Scope of this demo
    Show how to build trade, cash, and positions on Snowflake
    Use Data Marketplace zepl_us_stocks_daily to get stock history
    Use Window Functions to automate cash and position reporting
    This shows Snowflake's industry capabilities; Then use Citibike demo for technical audience
    
*/

-----------------------------------------------------
--Object comments for a data dictionary
    select table_name, comment
    from finserv.information_schema.tables
    where table_schema = 'PUBLIC' order by table_name;

    //context
    use role finserv_admin; use warehouse finserv_devops_wh; use schema finserv.public;
    
    //if desired, resize compute
    alter warehouse finserv_devops_wh set warehouse_size = 'small';
    
    
-----------------------------------------------------
--target objects for use case: asset manager - sharing position level data with investor
//PREREQUISITES
    //Zepl Marketplace share created as zepl_us_stocks_daily


//ASSET MANAGEMENT FIRM

    //trade - date and quantity of buy, sell, or hold action on assets
        select top 1000 * 
        from trade where trader = 'charles' 
        order by symbol, date;          
        
        //ansi sql; comments for queryable metadata and data catalog
            select get_ddl('table','trade');   

    //what is my position as-of a date?
        select top 1000 p.*
        from position p
        where p.symbol = 'SBUX' and date > '2019-01-01'
        order by date, trader;

        //dynamic view using window functions
            select get_ddl('table','position');   

//MARKET DATA
    //stock_history - free, daily-updated Zepl stock_history but with duplicates removed
        //Zepl is a Snowflake partner founded by the creators of Zeppelin notebook
        select * from stock_history where symbol = 'SBUX' order by date desc limit 100;
        
    //stock_latest - latest available stock prices
        select * from stock_latest limit 100;           
        
            //view on a share - notice CTE and comment for data dictionary
            select get_ddl('view','stock_latest');

    //company_profile - remove dated columns in Zepl's version (Please note beta and mktcap are inaccurately static as this is just an example)
        select * from company_profile limit 100;        
        
        //what is our current position?
        select top 300 * from position_now where symbol = 'SBUX' order by trader;

    //BI demo
    
