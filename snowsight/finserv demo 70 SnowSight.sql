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
    Share with Executives and Authorized Users

    
*/

-----------------------------------------------------
--context
    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
    
    //if desired, resize compute - we start low to save money
    alter warehouse finservam_devops_wh set warehouse_size = 'small';

----------------------------------------------------------------------------------------------------------
--Row 1

--Symbol Position Over Time Line Chart
--Line Chart: cash_used, market_value, pnl, num_shares_cumulative, close
    --X-Axis: Date (Year)
    select
        symbol, date, trader, round(cash_cumulative) * -1 cash_used, num_shares_cumulative, round(close,2) close, 
        round(market_value) market_value, round(PnL) PnL
    from position where date = :daterange and symbol = :fssymbol and trader = :fstrader
    order by date;
    
 --Symbol Position Over Time Table
    select
        symbol, date, trader, round(cash_cumulative) cash_cumulative, num_shares_cumulative, round(close,2) close, 
        round(market_value) market_value, round(PnL) PnL
    from position where date = :daterange and symbol = :fssymbol and trader = :fstrader
    order by date desc;
    
 --Symbol Trade Action Table
    select * 
    from trade 
    where date = :daterange and symbol = :fssymbol and trader = :fstrader
    order by symbol, date desc;     
    
----------------------------------------------------------------------------------------------------------
--Row 2

--Portfolio PnL Top 10 Bar Chart
    select top 10 symbol, round(PnL) PnL
    from public.position_now where trader = :fstrader
    order by PnL desc;

--Portfolio PnL Bottom 10 Bar Chart
    select top 10 symbol, round(PnL) PnL
    from public.position_now where trader = :fstrader
    order by PnL asc;


----------------------------------------------------------------------------------------------------------
--Row 3

--Portfolio Position Current Table
    select
        symbol, date, trader, round(cash_cumulative) cash_cumulative, num_shares_cumulative, round(close,2) close,
        round(market_value) market_value, round(PnL) PnL
    from public.position_now where trader = :fstrader
    order by pnl desc;

