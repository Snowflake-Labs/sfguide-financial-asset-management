/*
Run "script 30" to setup DDL

size up to a xxlarge so this script can complete in 5 minutes with 1000 traders; then turn off compute
create traders table using limit_trader parameter defaulted at 1000 traders
create watchlist table which authorizes which stocks are eligible for trading
populate 2.5 billion synthentic trades
create window-function views for position


*/

-----------------------------------------------------
--set context and size up compute
    use role finservam_admin; use warehouse finservam_datascience_wh; use schema finservam.public;

    --size up since we are generating many trades 
    --wait_for_completion can be a best practice for larger size warehouses
    alter warehouse finservam_datascience_wh set warehouse_size = 'xxlarge' wait_for_completion = TRUE;

-----------------------------------------------------
--OPTION: Set number of traders to be used

    set limit_trader = 1000;        //on xxlarge - 2.1B trades; this build takes 1m45s
//    set limit_trader = 2000;        //on xxlarge - 4.2B trades; this build takes 3m
//    set limit_trader = 3000;        //on xxlarge - 6.4B trades; this build takes 4m40s

    set limit_pm = $limit_trader / 10;   //Every Portfolio Manager (PM) will have 10 traders reporting to her.






----------------------------------------------------------------------------------------------------------
--we use a ACID-compliant transaction here because we want the sequence to restart from 1 each time trader is built 
--since our randon function needs a range from 1 to limit_pm

begin transaction;
    //must recreate sequence each time we use it so that it will start at 1
        create or replace sequence pm_id;
        
        set limit_trader = $limit_trader - 1;       //we remove one trader since we will manually add trader charles later

    //we get names from the TPC-DS data instantly available to each Snowflake account
        create or replace transient table trader 
            comment = 'Trader with their Portfolio Manager (PM) and trader authorized buying power' as
        with trader as
        (
          select distinct c_first_name trader
          from snowflake_sample_data.tpcds_sf10tcl.customer
          where c_first_name is not null
          limit $limit_trader
        ), PM as
        (
          select distinct c_last_name PM, pm_id.nextval id
          from snowflake_sample_data.tpcds_sf10tcl.customer
          where c_last_name is not null
        ), trader2 as
        (
          select
              trader, 
              uniform(1, $limit_pm, random()) PM_id,                //random function to assign a PM to a trader
              uniform(4000, 8000, random())::number buying_power
          from trader t
        )
        select
            t.trader, 
            p.pm, 
            t.buying_power
        from trader2 t
        inner join pm p on t.pm_id = p.id
        order by 2,1;
      
      comment on column public.trader.PM is 'Portfolio Manager (PM) manages traders';
      comment on column public.trader.buying_power is 'Trader is authorized this buying power in each transaction';

commit;



-----------------------------------------------------
--we update a trader's name to "lab" and their PM to "warren" for a Data Governance demo
--last_query_id and result_scan lets us manipulate the resultset of a previous query
    
    select pm, count(*) cnt
    from trader
    group by pm
    having count(*) > 2
    order by 2, 1
    limit 1;

    set q = last_query_id(); 

    update trader set trader = 'lab', PM = 'warren' where trader in
    (
        select trader
        from trader t
        inner join (
          select pm from table(result_scan($q))
        ) pm on t.pm = pm.pm
        order by trader
        limit 1
    );

      
----------------------------------------------------------------------------------------------------------
--remove authorization of trades that have a close price of <1 or >4500
        create or replace transient table public.watchlist
            comment = 'what assets we are interested in owning'
        as
            select c.*, 'all_authorized' Trader
            from public.company_profile c
            inner join public.stock_latest l on c.symbol = l.symbol     --ensure stock still traded 
            where mktcap is not null
            and exchange like 'N%'
            and c.symbol not in 
            (
                select distinct symbol
                from public.stock_history
                where close < 1 or close > 4500
            )
            and c.symbol not in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')  //we will add these in later
            order by mktcap desc
            //Option: raise the limit for more stress testing by authoring more stocks to be traded per day
            //we set the limit at 1000-12 which is 988
            limit 988; 

        //we add these 12 symbols specifically because we've highlighted trader charles trading these symbols later in the demo. This 998 + 12 = 1000 trades daily           
        insert into public.watchlist
            select *, 'all_authorized'::varchar(50) Trader
            from company_profile
            where symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
            order by mktcap desc;
            
        //and now we should have 1000 total trades made per day per trader
            






----------------------------------------------------------------------------------------------------------
--create trade table showing buy, sell, hold actions; this is the longest running part of the script

        -----------------------------------------------------
        create or replace transient table trade
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
            from stock_history h
            inner join watchlist w on h.symbol = w.symbol and w.trader = 'all_authorized'
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
            from stock_history h
            inner join watchlist w on h.symbol = w.symbol and w.trader = 'all_authorized'
            where h.close <> 0 and year(date) >= 2020
         ) c
         full outer join public.trader t
       union all
          --for charles buy $100K in value for each ticker in Jan 2019
          select
              date, h.symbol, w.exchange, 'buy'::varchar(25) action, close, round(1000000/close,0) num_shares, 
              close * round(1000000/close,0) * -1 cash,
              'charles' Trader, 'warren' PM
          from stock_history h
          inner join watchlist w on h.symbol = w.symbol and w.symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
          where h.close <> 0 and year(date) = 2019 and month(date) = 1
        union all
          --for charles sell $10K in value for each ticker in Mar 2019
            select
                date, h.symbol, w.exchange, 'sell' action, close, round(10000/close,0) * -1 num_shares, 
                close * round(10000/close,0) cash,
                'charles' Trader, 'warren' PM
            from stock_history h
            inner join watchlist w on h.symbol = w.symbol and w.symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
            where h.close <> 0 and year(date) = 2019 and month(date) = 3
        union all
          --for charles hold action so shares and cash don't change
          select
              date, h.symbol, w.exchange, 'hold' action, close, 0, 0 cash,
              'charles' Trader, 'warren' PM
          from public.stock_history h
          inner join public.watchlist w on h.symbol = w.symbol and w.symbol in ('AMZN','CAT','COF','GE','GOOG','MCK','MSFT','NFLX','SBUX','TSLA','VOO','XOM')
          where (h.close <> 0 and year(date) = 2019 and month(date) not in (1,3)) or (h.close <> 0 and year(date) >= 2020)
        order by 8,2,1;--Trader, symbol, date
        
        

      //we focus on trader charles during our demo so we specifically add him in
      begin transaction;
            delete from trader where trader = 'charles';

            insert into trader
            select 'charles' trader, 'warren' PM, 2000000 buying_power;
      commit;

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
                  t.symbol, exchange, t.date, trader, pm,
                  Sum(num_shares) OVER(partition BY t.symbol, exchange, trader ORDER BY t.date rows UNBOUNDED PRECEDING ) num_shares_cumulative,
                  Sum(cash) OVER(partition BY t.symbol, exchange, trader ORDER BY t.date rows UNBOUNDED PRECEDING ) cash_cumulative,
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
          create or replace view middleware.share_now 
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
            from public.position
          )
          select symbol, exchange, trader, pm, num_share_now, cash_now
          from cte
          where is_current = 1;
          

          
        -----------------------------------------------------
        --position_now
        create or replace view position_now        
        (
        symbol, exchange, trader, pm, num_share_now, cash_now, close, date, market_value,
        PnL comment 'Profit and Loss: Demonstrate comment on view column'
        )
            comment = 'current market price to show value now'
        as
        select p.*, l.close, l.date,
            num_share_now * close as market_value,
            (num_share_now * close) + cash_now as PnL
        from middleware.share_now p
        left outer join stock_latest l on p.symbol = l.symbol;

----------------------------------------------------------------------------------------------------------
--size down to save money
  
        alter warehouse finservam_datascience_wh set warehouse_size = 'xsmall';
        
        //option to shutdown
        alter warehouse finservam_datascience_wh suspend;

