/*

WHY
    Use Snowflake scripting aka SQL Stored Procs to simulate writing trades into a table while reading from another

REFERENCE
    https://github.com/Snowflake-Labs/sfguide-financial-asset-management/new/master/optional/finserv-demo-60-clone-scripting.sql
    https://docs.snowflake.com/en/developer-guide/snowflake-scripting/index.html
    https://www.intricity.com/learningcenter/snowflake-protalk-stored-procedures

*/

-----------------------------------------------------
--setup
    use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam.public;
 
    alter warehouse finservam_devops_wh set warehouse_size = 'xsmall';



-----------------------------------------------------
--Zero Copy Clone to create finservam_stress test environment
    use role accountadmin;
    create or replace database finservam_stress clone finservam;

    grant ownership on database finservam_stress to role finservam_admin;
    grant ownership on schema finservam_stress.public to role finservam_admin;

    use role finservam_admin;
    
    


-----------------------------------------------------
--create trade2
    use schema finservam_stress.public;
    create or replace table trade2 like trade;
    
    
    

-----------------------------------------------------
--Scripting to simulate adding new records by day
  truncate table trade2;

  execute immediate $$
  declare
    res RESULTSET default (
        select distinct date::varchar d
        from trade
        where trader = 'charles'
        order by 1);
    vw_cursor CURSOR for res;
    vw_table RESULTSET ;
    stmt varchar;
  begin
    for vw in vw_cursor do
        stmt := 'insert into trade2 select * from trade where trader = ''charles'' and date = ''' || vw.d || '''';
        vw_table := (execute immediate :stmt);
    end for;
  end;
  $$;




----------------------------------------------------------------------------------------------------------
--test scripting in other window

    -----------------------------------------------------
    --setup
        use role finservam_admin; use warehouse finservam_devops_wh; use schema finservam_stress.public;
        alter warehouse finservam_devops_wh set warehouse_size = 'xsmall';


    --readers don't block writers
      select date, count(*) cnt
      from trade2
      group by 1
      order by 1 desc;

      select top 300 * 
      from trade2 order by 1 desc;
