/*
Problem Statement
    Business Intelligence (BI) Tools require separate licenses, can be costly, and hard to share and learn

Why SnowSight: Your benefits
    Complimentary with Snowflake
    Business Analyst (BA) experience to dashboard, share, write queries, and scale compute
    Unlimited Concurrency for your SVOT

What we will see
    Dashboard for a Trader and Symbol over time
    Deep Dive into Trades, Cash, PnL, and Position
    Share with Executives and Authorized User

    
*/

-----------------------------------------------------
--context
    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
    
    //if desired, resize compute - we start low to save money
    alter warehouse finservam_devops_wh set warehouse_size = 'small';

-----------------------------------------------------
--Position Over Time
--Line Chart: cash_used, market_value, pnl, num_shares_cumulative, close
    select
        symbol, date, trader, round(cash_cumulative) * -1 cash_used, num_shares_cumulative, round(close,2) close, 
        round(market_value) market_value, round(PnL) PnL
    from position where date = :daterange and symbol = :fssymbol and trader = :trader
    order by date;
    
-----------------------------------------------------
--Symbol Closing Price
--Line Chart: open, high, low, close
    select date, round(open,2) open, round(high,2) high, round(low,2) low, round(close,2) close
    from stock_history
    where symbol = :fssymbol and date = :daterange
    order by date;

-----------------------------------------------------
--Trader's Current PnL for Symbol
--ScoreCard Chart
    select round(PnL) PnL
    from public.position_now where symbol = :fssymbol and trader = :trader;

-----------------------------------------------------
--Symbol Position Details
    select
        symbol, date, trader, round(cash_cumulative) cash_cumulative, num_shares_cumulative, round(close,2) close, 
        round(market_value) market_value, round(PnL) PnL
    from position where date = :daterange and symbol = :fssymbol and trader = :trader
    order by date;

-----------------------------------------------------
--Trader's Current Portfolio PnL
--ScoreCard Chart
    select round(sum(PnL)) PnL
    from public.position_now where trader = :trader;

-----------------------------------------------------
--Trader's Current Portfolio Positions
    select symbol, exchange, trader, PM, num_share_now, round(cash_now) cash_now, round(close,2) close, date, round(market_value) market_value, round(PnL) PnL
    from public.position_now where trader = :trader
    order by symbol, exchange;



