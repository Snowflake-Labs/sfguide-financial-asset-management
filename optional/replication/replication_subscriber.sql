/*
https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/optional/replication/replication_subscriber.sql

*/


use role accountadmin;
create database finservam_replication as replica of sfsenorthamerica.demo171.finservam_replication;

--refresh replication ~3m45s
alter database finservam_replication refresh;

-- can see progress [on another tab as well] on replication history
select * from table(finservam_replication.information_schema.database_refresh_progress(finservam_replication));

--grant ownership to lower roles as needed
use role accountadmin;
grant ownership on database finservam_replication to role finservam_admin;
grant ownership on all schemas in database finservam_replication to role finservam_admin;
grant ownership on all tables in schema finservam_replication.public to role finservam_admin;
grant ownership on all views in schema finservam_replication.public to role finservam_admin;



-- show the database master(s) that we can replicate
show replication databases;



/*--------------------------------------------------------------------------------
  Check out the replica
--------------------------------------------------------------------------------*/

use schema finservam_replication.public;


    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
    alter warehouse finservam_devops_wh set warehouse_size = 'small';

-----------------------------------------------------
--verify replication and performance

    select table_type object_type, table_name object_name, comment
    from information_schema.tables
    where table_schema = 'PUBLIC' and comment is not null
        union all
    select 'COLUMN' object_type, table_name || '.' || column_name object_type, comment
    from information_schema.columns
    where table_schema = 'PUBLIC' and comment is not null
    order by 1,2;







    //what is the current PnL for trader charles? - view on trade table so always updated as trade populated
        //notice it is a non-materialized window function view on 2 billion rows
        select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL
        from position_now where trader = 'charles'
        order by PnL desc;
        
        select get_ddl('view','position_now');
        
        
       

    //trade - date and quantity of buy, sell, or hold action on assets: This controls the position view
        select * 
        from trade 
        where date >= '2019-01-01' and symbol = 'MSFT' and trader = 'charles'
        order by symbol, date;          
        
            //ansi sql; comments for queryable metadata and data catalog
                select get_ddl('table','trade');   










/*--------------------------------------------------------------------------------
  Add some more data to the master copy
--------------------------------------------------------------------------------*/

-- sync the DBs to show the newly loaded data  ~10s
alter database finservam_replication refresh;


-- show replication history
select * from table(finservam_replication.information_schema.database_refresh_progress(finservam_replication));


/*--------------------------------------------------------------------------------
  Automate the process of keeping things in sync
--------------------------------------------------------------------------------*/
use role accountadmin;

--to enable serverless tasks
grant execute task, execute managed task on account to role sysadmin;


--util database to hold utilities 
use role sysadmin;
create database if not exists util;




-- using serverless task: replicate on the hour, every hour, Mon-Fri
create task if not exists util.public.refresh_finservam_replication_task
  SCHEDULE = 'USING CRON 0 9-17 * * 1-5 America/New_York'
as
  alter database finservam_replication refresh;




-- start the task
alter task util.public.refresh_finservam_replication_task resume;

-- monitor the task
show tasks in database util;

--see next task execution
select timestampdiff(second, current_timestamp, scheduled_time) as next_run,
       scheduled_time, current_timestamp, name, state
  from table(information_schema.task_history()) order by completed_time desc;






/*--------------------------------------------------------------------------------
  Clean up replication - drop subscriber so that publisher can be dropped
--------------------------------------------------------------------------------*/

drop task if exists util.public.refresh_finservam_replication_task;
drop database finservam_replication;
