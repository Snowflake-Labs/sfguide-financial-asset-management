/*
Run these scripts to setup DDL

*/

use role finserv_admin; use warehouse finserv_datascience_wh; use schema finserv.public;

--size up since we are generating many trades 
alter warehouse finserv_datascience_wh set warehouse_size = 'xxlarge';

-----------------------------------------------------
--OPTION: Set number of traders to be used


    set limit_trader = 1000;        //on xxlarge - 2.1B trades; this build takes 1m45s; script 35 stress script takes 1m10s
//    set limit_trader = 2000;        //on xxlarge - 4.2B trades; this build takes 3m; script 35 stress script takes 2m10s
//    set limit_trader = 3000;        //on xxlarge - 6.4B trades; this build takes 4m40s ; script 35 stress script takes 3m20s






----------------------------------------------------------------------------------------------------------
--Control the number of rows generated in trade: 
      //Create traders for big data volume stress testing 
      create or replace temp table middleware.temp_trader as
      select distinct *
      from
      (
          select
              upper(randstr(3, random()))::varchar(50) trader,
              upper(randstr(2, random()))::varchar(50) PM,
              uniform(4000, 8000, random()) buying_power
          from table (generator(rowcount => 60000))
      ) c
      where rlike(trader,'[A-Z][A-Z][A-Z]') = 'TRUE' and rlike(PM,'[A-Z][A-Z]') = 'TRUE';

      --with dupes removed
      create or replace transient table finserv.public.trader comment = 'Trader with their PM and authorized buying power'
      as
      with cte as
      (
          select *,
          row_number() over (partition by trader order by buying_power, PM) num
          from middleware.temp_trader
      )
      select trader, PM, buying_power
      from cte
      where num = 1
      order by 2,1
      //1 of 2 RAISE THE LIMIT FOR MORE STRESS TESTING
            limit $limit_trader;
//            limit 5000;     //stress test
//            limit 100;     //use for fast tests
      
      comment on column public.trader.PM is 'Portfolio Manager (PM) manages traders';
      comment on column public.trader.buying_power is 'Trader is authorized this buying power in each transaction';
      


        --remove authorization of trades that have a close <1 or >4500
        create or replace temp table middleware.temp_watchlist 
            comment = 'ensure stock is still traded and has a close price within our buying power'
        as
            select c.*, 'all_authorized' Trader
            from finserv.public.company_profile c
            inner join finserv.public.stock_latest l on c.symbol = l.symbol     --ensure stock still traded 
            where mktcap is not null
            and exchange like 'N%'
            and c.symbol not in 
            (
                select distinct symbol
                from finserv.public.stock_history
                where close < 1 or close > 4500
            )
            order by mktcap desc
            //Option: raise the limit for more stress testing
            limit 1000;      









----------------------------------------------------------------------------------------------------------
--Asset Management Firm Objects


        -----------------------------------------------------
            create or replace transient table finserv.public.watchlist
                comment = 'what assets we are interested in owning'
            as
            select *, 'charles'::varchar(50) Trader
            from finserv.public.company_profile
            where symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
                union all
            select * from middleware.temp_watchlist
            order by trader, symbol, exchange;
            
//            select * from watchlist;






        -----------------------------------------------------
        create or replace transient table finserv.public.trade
            comment = 'trades made and cash used; unique_key: symbol, exchange, date'
        as
        --buy for all traders except Charles
         select
              c.*,
              round(buying_power/close,0) num_shares, 
              close * round(buying_power/close,0) * -1 cash,
              t.trader, t.PM
         from
         (
            select
                date, h.symbol, w.exchange, 'buy'::varchar(25) action, close
            from finserv.public.stock_history h
            inner join finserv.public.watchlist w on h.symbol = w.symbol and w.trader = 'all_authorized'
            where h.close <> 0 and year(date) between 2010 and 2019
         ) c
         full outer join public.trader t
       union all
        --hold for all traders except Charles
         select
              c.*,
              0 num_shares, 
              0 cash,
              t.trader, t.PM
         from
         (
            select
                date, h.symbol, w.exchange, 'hold'::varchar(25) action, close
            from finserv.public.stock_history h
            inner join finserv.public.watchlist w on h.symbol = w.symbol and w.trader = 'all_authorized'
            where h.close <> 0 and year(date) >= 2020
         ) c
         full outer join public.trader t
       union all
          --for charles buy $100K in value for each ticker in Jan 2019
          select
              date, h.symbol, w.exchange, 'buy'::varchar(25) action, close, round(1000000/close,0) num_shares, 
              close * round(1000000/close,0) * -1 cash,
              'charles' Trader, 'warren' PM
          from finserv.public.stock_history h
          inner join finserv.public.watchlist w on h.symbol = w.symbol and w.trader = 'charles'
          where h.close <> 0 and year(date) = 2019 and month(date) = 1
        union all
          --for charles sell $10K in value for each ticker in Mar 2019
            select
                date, h.symbol, w.exchange, 'sell' action, close, round(10000/close,0) * -1 num_shares, 
                close * round(10000/close,0) cash,
                'charles' Trader, 'warren' PM
            from finserv.public.stock_history h
            inner join finserv.public.watchlist w on h.symbol = w.symbol and w.trader = 'charles'
            where h.close <> 0 and year(date) = 2019 and month(date) = 3
        union all
          --for charles hold action so shares and cash don't change
          select
              date, h.symbol, w.exchange, 'hold' action, close, 0, 0 cash,
              'charles' Trader, 'warren' PM
          from finserv.public.stock_history h
          inner join finserv.public.watchlist w on h.symbol = w.symbol and w.trader = 'charles'
          where (h.close <> 0 and year(date) = 2019 and month(date) not in (1,3)) or (h.close <> 0 and year(date) >= 2020)
        order by 8,2,1;--Trader, symbol, date
        
        
//        select count(*) from trade;
//        select top 300 * from trade where date >= '2018-01-03' and symbol = 'SBUX' order by date;
//        select * from trade order by date, symbol;


        -----------------------------------------------------
          create or replace view finserv.public.position 
            comment = 'what assets owned; demo Window Function running sum'
          as
          with cte as
          (
              select 
                  t.symbol, exchange, t.date, trader, pm,
                  Sum(num_shares) OVER(partition BY t.symbol, exchange, trader ORDER BY t.date rows UNBOUNDED PRECEDING ) num_shares_cumulative,
                  Sum(cash) OVER(partition BY t.symbol, exchange, trader ORDER BY t.date rows UNBOUNDED PRECEDING ) cash_cumulative,
                  s.close
              from finserv.public.trade t
              inner join finserv.public.stock_history s on t.symbol = s.symbol and s.date = t.date
          )
          select 
            *,
            num_shares_cumulative * close as market_value, 
            (num_shares_cumulative * close) + cash_cumulative as PnL
          from cte;
          
//          select top 300 * 
//          from position where date between '2019-01-01' and  '2019-01-31' and symbol = 'SBUX' and trader = 'charles'
//          order by date;
          

//select top 300 * from stock_history;



        -----------------------------------------------------
          create or replace view finserv.middleware.share_now 
            comment = 'current position, shares, and cash we have now; demo last_value ranking; 
            placed in middleware schema since not really for end user consumption'
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
        create or replace view position_now 
            comment = 'current market price to show value now'
        as
        select p.*, l.close, l.date,
            num_share_now * close as market_value,
            (num_share_now * close) + cash_now as PnL
        from finserv.middleware.share_now p
        left outer join stock_latest l on p.symbol = l.symbol;
        
//                select top 300 * from position_now where symbol = 'SBUX';

        --size down to save money
        alter warehouse finserv_datascience_wh set warehouse_size = 'small';
        
        //option to shutdown
        alter warehouse finserv_datascience_wh suspend;
