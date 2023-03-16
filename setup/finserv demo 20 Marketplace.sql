/*
Summary:
    Data Governance via RBAC by adding finservam_admin as role that can access data
    Data Quality Check by ensuring no duplicates

*/

-----------------------------------------------------
--setup
    use role finservam_admin;
    use warehouse finservam_devops_wh;
    use schema finservam.public;

--Verify Data Marketplace Share
    select top 1 *
    from economy_data_atlas.economy.usindssp2020;


--Verify snowflake_sample_data share
    select top 1 *
    from snowflake_sample_data.tpcds_sf10tcl.customer;


----------------------------------------------------------------------------------------------------------
--stock_history

create or replace transient table finservam.public.stock_history
    comment = 'knoema economy_data_atlas.economy.usindssp2020 daily closing prices for NASDAQ & NYSE'
as
select
    "Company" symbol,
    "Date" date,
    "Company Name" company,
    "Stock Exchange Name" exchange,
    "Value" close
from economy_data_atlas.economy.usindssp2020
where "Indicator Name" = 'Close'
and "Scale" = 1
and "Frequency" = 'D'
and "Stock Exchange Name" in ('NASDAQ','NYSE')
order by "Company", "Date";

comment on column stock_history.close is 'security price at the end of the financial market business day';


--optional: if we don't want to wait for auto-suspend:
    alter warehouse finservam_devops_wh suspend;
