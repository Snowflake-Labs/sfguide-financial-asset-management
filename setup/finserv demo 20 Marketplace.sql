/*
Summary:
    verify economy_data_atlas share
    remove duplicates

    Python Faker function
    https://medium.com/snowflake/flaker-2-0-fake-snowflake-data-the-easy-way-dc5e65225a13


*/

-----------------------------------------------------
--setup
    use role finservam_admin;
    use warehouse finservam_devops_wh;
    use schema finservam.public;

--Verify Data Marketplace Share
    select top 1 *
    from economy_data_atlas.economy.usindssp2020;

    
--exclude_symbol - we will exclude these as they have the same symbol in NASDAQ and NYSE
    create or replace table transform.exclude_symbol as
    select distinct "Company" symbol
    from
    (
        select "Company", "Date"
        from economy_data_atlas.economy.usindssp2020
        where "Indicator Name" = 'Close'
        and "Scale" = 1
        and "Frequency" = 'D'
        and "Stock Exchange Name" in ('NASDAQ','NYSE')
        group by "Company", "Date"
        having count(*) > 1
    )
    order by 1;

--close price = 0 we will exclude
    insert into transform.exclude_symbol (symbol)
    with cte as
    (
        select distinct "Company" symbol
        from economy_data_atlas.economy.usindssp2020
        where "Indicator Name" = 'Close'
        and "Scale" = 1
        and "Frequency" = 'D'
        and "Stock Exchange Name" in ('NASDAQ','NYSE')
        and "Value" = 0
    )
    select c.symbol
    from cte c
    left outer join transform.exclude_symbol q on c.symbol = q.symbol 
    where q.symbol is null
    order by 1;


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
    from economy_data_atlas.economy.usindssp2020 k
    left outer join transform.exclude_symbol e on e.symbol = k."Company"
    where "Indicator Name" = 'Close'
    and "Scale" = 1
    and "Frequency" = 'D'
    and "Stock Exchange Name" in ('NASDAQ','NYSE')
    and e.symbol is null
    and "Company" not in ('FERG','BRKa')    --these are greater than $5000 per sharp
    order by "Company", "Date";
    
    comment on column stock_history.close is 'security price at the end of the financial market business day';


-----------------------------------------------------
--Python FAKE
    create or replace function FAKE(locale varchar,provider varchar,parameters variant)
    returns variant
    language python
    volatile
    runtime_version = '3.8'
    packages = ('faker','simplejson')
    handler = 'fake'
    as
    $$
    import simplejson as json
    from faker import Faker
    def fake(locale,provider,parameters):
      if type(parameters).__name__=='sqlNullWrapper':
        parameters = {}
      fake = Faker(locale=locale)
      return json.loads(json.dumps(fake.format(formatter=provider,**parameters), default=str))
    $$;

/*
--test
select FAKE('en_US','name',null)::varchar as FAKE_NAME
from table(generator(rowcount => 10));

*/
