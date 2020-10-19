/*
Run these scripts

*/

use role finserv_admin; use warehouse finserv_devops_wh; use schema finserv.public;
alter warehouse finserv_devops_wh set warehouse_size = 'medium';










----------------------------------------------------------------------------------------------------------
--Market Data Objects
        create or replace view finserv.public.stock_history
            comment = 'zepl_us_stocks_daily stock_history but with duplicates removed'
        as
        with cte as
        (
          select *,
          row_number() over (partition by symbol,date order by date) num
          from zepl_us_stocks_daily.public.stock_history
        )
        select symbol, date, open, high, low, close, volume, adjclose
        from cte
        where num = 1
        order by symbol;
        
//        select top 10 * from finserv.public.stock_history;

      -----------------------------------------------------
        create or replace view finserv.public.stock_latest
            comment = 'latest available stock prices; We use SBUX since NYSE seems to come in at a later time; remove duplicates via row_number'
        as
        with cte as
        (
          select *,
          row_number() over (partition by symbol order by symbol) num
          from finserv.public.stock_history
          where date = (select max(date) from zepl_us_stocks_daily.public.stock_history where symbol = 'SBUX')
        )
        select symbol, date, open, high, low, close, volume, adjclose
        from cte
        where num = 1
        order by symbol;

//        select top 10 * from finserv.public.stock_latest where symbol = 'SBUX';

      -----------------------------------------------------
        create or replace view finserv.public.company_profile
            comment = 'company profile; Note: Beta and mktcap change daily but we will use these static numbers as a proxy for now; we exclude columns that change with the date'
        as
        select symbol, exchange, companyname, industry, website, description, ceo, sector, beta, mktcap::number mktcap
        from zepl_us_stocks_daily.public.company_profile;

//        select top 300 * from finserv.public.company_profile;










----------------------------------------------------------------------------------------------------------
--Asset Management Firm Objects

        -----------------------------------------------------
            create or replace table finserv.public.watchlist
                comment = 'what assets we are interested in owning'
            as
            select *
            from finserv.public.company_profile
            where symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','VOO','XOM')
            order by symbol, exchange;
            
//            select top 300 * from watchlist;

        -----------------------------------------------------
        create or replace transient table finserv.public.trade
            comment = 'trades made and cash used; unique_key: symbol, exchange, date'
        as
        --for DailyTrader buy $100K in value per day when year <> 2019
            select
                date, h.symbol, w.exchange, 'buy'::varchar(25) action, close, round(100000/close,0) num_shares, close * round(100000/close,0) * -1 cash,
                'DailyTrader'::varchar(50) Trader, 'DailyTraderPM'::varchar(50) PM
            from finserv.public.stock_history h
            inner join finserv.public.company_profile w on h.symbol = w.symbol
            where h.close <> 0 and year(date) <> 2019
        --for DailyTrader sell $5K in value per day when year = 2019
        union all
            select
                date, h.symbol, w.exchange, 'sell' action, close, round(50000/close,0) * -1 num_shares, close * round(50000/close,0) cash,
                'DailyTrader' Trader, 'DailyTraderPM' PM
            from finserv.public.stock_history h
            inner join finserv.public.company_profile w on h.symbol = w.symbol 
            where h.close <> 0 and year(date) = 2019
        union all
          --for charles buy $100K in value for each ticker in Jan 2019
          select
              date, h.symbol, w.exchange, 'buy'::varchar(25) action, close, round(1000000/close,0) num_shares, close * round(1000000/close,0) * -1 cash,
              'charles' Trader, 'warren' PM
          from finserv.public.stock_history h
          inner join finserv.public.watchlist w on h.symbol = w.symbol 
          where h.close <> 0 and year(date) = 2019 and month(date) = 1
        union all
          --for charles hold action so shares and cash don't change
          select
              date, h.symbol, w.exchange, 'hold' action, close, 0, 0 cash,
              'charles' Trader, 'warren' PM
          from finserv.public.stock_history h
          inner join finserv.public.watchlist w on h.symbol = w.symbol 
          where (h.close <> 0 and year(date) = 2019 and month(date) <> 1) or (h.close <> 0 and year(date) = 2020) 
        order by 3,1;
        
//        select top 300 * from trade where date = '2019-01-03' and symbol = 'SBUX';

        -----------------------------------------------------
          create or replace view finserv.public.position comment = 'what assets owned; demo window function running sum'
          as
          select 
              symbol, exchange, date, trader, pm,
              Sum(num_shares) OVER(partition BY symbol, exchange, trader ORDER BY date rows UNBOUNDED PRECEDING ) num_shares_cumulative,
              Sum(cash) OVER(partition BY symbol, exchange, trader ORDER BY date rows UNBOUNDED PRECEDING ) cash_cumulative
          from finserv.public.trade
          order by 1,2,3;
          
          select top 300 * from position where date = '2019-01-03' and symbol = 'SBUX'
          union
                    select top 300 * from position where date = '2019-01-07' and symbol = 'SBUX';

        -----------------------------------------------------
          create or replace view finserv.middleware.share_now comment = 'current position, shares, and cash we have now; demo last_value ranking; placed in middleware schema since not really for end user consumption'
          as
          with cte as
          (
            select
                symbol, exchange, trader, pm,
                last_value(num_shares_cumulative) over (partition by symbol, exchange, trader order by date) as num_share_now,
                last_value(cash_cumulative) over (partition by symbol, exchange, trader order by date) as cash_now,
                case when last_value(date) over (partition by symbol, exchange, trader order by date) = date then 1 else 0 end is_current
            from finserv.public.position
          )
          select symbol, exchange, trader, pm, num_share_now, cash_now
          from cte
          where is_current = 1;
          
//        select top 300 * from middleware.share_now where symbol = 'SBUX';
          
        -----------------------------------------------------
        --position_now
        create or replace view position_now comment = 'current market price to show value now'
        as
        select p.*, l.close, l.date,
            num_share_now * close market_value
        from finserv.middleware.share_now p
        left outer join stock_latest l on p.symbol = l.symbol
        order by 1;
        
//                select top 300 * from position_now where symbol = 'SBUX';
