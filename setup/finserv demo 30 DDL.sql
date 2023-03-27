/*

size up so we complete quicker put pay the same cost
create traders table using limit_trader parameter defaulted at 1000 traders
create watchlist table which authorizes which stocks are eligible for trading
populate 3 billion synthentic trades
create window-function views for position


*/

-----------------------------------------------------
--set context and size up compute
    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
    
    --size up since we are generating many trades 
    alter warehouse finservam_devops_wh set warehouse_size = 'xxlarge' wait_for_completion = TRUE;

-----------------------------------------------------
--how many traders
/*
traders   trades    VWh        Duration
40        1.2B      xxlarge    1m25s
100       3B        xxlarge    3m25s


*/
    set limit_trader = 100;        //on xxlarge - 2.6B trades; this build takes under 3min
    set limit_pm = $limit_trader / 10;   //Every Portfolio Manager (PM) will have about 10 traders reporting to her.

    select count(*) from trade;    

-----------------------------------------------------
--PM
    create or replace sequence pm_id;        --unique number generator
    
    create or replace transient table pm
        comment = 'PM is the Portfolio Manager who manages the traders' as
    select
        FAKE('en_UK','name',null)::varchar as PM,
        pm_id.nextval id
    from table(generator(rowcount => $limit_pm));
    

-----------------------------------------------------
--trader
--we don't need a transaction but we demo it
begin transaction;
    create or replace transient table trader 
        comment = 'Trader with their Portfolio Manager (PM) and trader authorized buying power' as
    with cte as
    (
    select
        FAKE('en_US','name',null)::varchar as trader,
        uniform(1, $limit_pm, random()) PM_id,                //random function to assign a PM to a trader
        uniform(1000, 3000, random())::number buying_power    //how much a trader can buy per day
    from table(generator(rowcount => $limit_trader))
    )
    select
        t.trader,
        pm.pm,
        t.buying_power
    from cte t
    inner join pm on t.pm_id = pm.id
    order by 2,1;

    comment on column public.trader.PM is 'Portfolio Manager (PM) manages traders';
    comment on column public.trader.buying_power is 'Trader is authorized this buying power in each transaction';
commit;


select * from trader order by 1;




----------------------------------------------------------------------------------------------------------
--create trade table showing buy, sell, hold actions; this is the longest running part of the script

        -----------------------------------------------------
        create or replace transient table trade
            comment = 'trades made and cash used; unique_key: symbol, exchange, date'
        as
        --buy action
         select
              c.*,
              round(buying_power/close,0) num_shares, 
              close * round(buying_power/close,0) * -1 cash,
              t.trader, t.PM
         from
         (
            select
                date, h.symbol, h.exchange, 'buy'::varchar(25) action, close
            from stock_history h
            where year(date) between 1981 and 2010
         ) c
         full outer join public.trader t
       union all
        --hold action
         select
              c.*,
              0 num_shares, 
              0 cash,
              t.trader, t.PM
         from
         (
            select
                date, h.symbol, h.exchange, 'hold'::varchar(25) action, close
            from stock_history h
            where year(date) >= 2010
         ) c
         full outer join public.trader t
        order by 8,2,1;--Trader, symbol, date

-- select top 300 * from trade where trader = 'charles';

-----------------------------------------------------
--we add traders specifically to demo against
    insert into trader values ('charles', 'warren', 1000000);


    insert into trade
      --for charles buy $100K in value for each ticker in Jan 2019
      select
          date, h.symbol, h.exchange, 'buy'::varchar(25) action, close, round(1000000/close,0) num_shares, 
          close * round(1000000/close,0) * -1 cash,
          'charles' Trader, 'warren' PM
      from stock_history h
      where h.symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
      and year(date) = 2019 and month(date) = 1
    union all
      --for charles sell $10K in value for each ticker in Mar 2019
        select
            date, h.symbol, h.exchange, 'sell' action, close, round(10000/close,0) * -1 num_shares, 
            close * round(10000/close,0) cash,
            'charles' Trader, 'warren' PM
        from stock_history h
        where h.symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
        and year(date) = 2019 and month(date) = 3
    union all
      --for charles hold action so shares and cash don't change
      select
          date, h.symbol, h.exchange, 'hold' action, close, 0, 0 cash,
          'charles' Trader, 'warren' PM
      from public.stock_history h
      where h.symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
      and (
              (year(date) = 2019 and month(date) not in (1,3)) or
              (year(date) >= 2020)
          )
      order by 8,2,1;--Trader, symbol, date


    -----------------------------------------------------
    --clustering
    
    --create clustered key based on what we sorted
        alter table trade cluster by (trader, symbol, date);

    --cluster_by column
        show tables like 'trade';

    --we can enable / disable automatic clustering
    -- alter table trade suspend recluster;




    //we can create comments on view columns
    -----------------------------------------------------
      create or replace view public.position
      (
          symbol, exchange, date, trader, pm, num_shares_cumulative, cash_cumulative, close, market_value,
          PnL comment 'Profit and Loss: Demonstrate comment on view column'
      )
        comment = 'what assets owned; demo Window Function running sum'
      as
      with cte as
      (
          select 
              t.symbol, t.exchange, t.date, trader, pm,
              Sum(num_shares) OVER(partition BY t.symbol, t.exchange, trader ORDER BY t.date rows UNBOUNDED PRECEDING ) num_shares_cumulative,
              Sum(cash) OVER(partition BY t.symbol, t.exchange, trader ORDER BY t.date rows UNBOUNDED PRECEDING ) cash_cumulative,
              s.close
          from public.trade t
          inner join public.stock_history s on t.symbol = s.symbol and s.date = t.date
      )
      select 
        *,
        num_shares_cumulative * close as market_value, 
        (num_shares_cumulative * close) + cash_cumulative as PnL
      from cte;
      
-----------------------------------------------------
--position_now
        create or replace view public.position_now
        comment = 'what assets owned; demo Window Function running sum for the max date in the trade table'
        as
        with cte as
        (
            select max(date) dt from public.trade
        )        
        select p.*
        from cte
        inner join position p on p.date = cte.dt;
        

----------------------------------------------------------------------------------------------------------
--size down to save credits
    alter warehouse finservam_devops_wh set warehouse_size = 'small';

