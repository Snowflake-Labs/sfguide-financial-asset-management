/*
Overview
    We take Factsets SASB (Sustainability Accounting Standards Board) Data 
    to calculate (Environmental, Social, and Governance) ESG scores
    
    https://www.snowflake.com/datasets/factset-truvalue-labs-sasb-codified-datafeed/


SASB Materiality Metrics:

    materiality_adj_insight: company ESG performance, generating scores for lower-volume and zerovolume firms by blending company scores with industry medians
    materiality_ind_pctl: context on company Adjust Insight scores relative to peers in the same SICS Industry.
    materiality_esg_rank: Leader, Above Average, Average, Below Average, or a Laggard, directly mapping from the SASB Materiality map Industry Percentiles.

*/


-----------------------------------------------------
--set the context
    use role finservam_admin;
    use warehouse finservam_devops_wh;

-----------------------------------------------------
--instant access to Factset maintained ESG data

    use database factset_snowflake_esg_demo_share;
    select top 300 * from sym_v1.sym_coverage;
    select top 300 * from sym_v1.sym_ticker_region;
    select top 300 * from tv_v2.tv_esg_ranks order by tv_date desc;
    select top 300 * from tv_v2.tv_factset_id_map;


-----------------------------------------------------
--cross-database join Factset's data with our Portfolio data
    use schema finservam.public;

    create or replace view FACTSET_ESG_VW as
    SELECT cov.proper_name,
           split_part(tr.ticker_region,'-',1) as ticker,
           split_part(tr.ticker_region,'-',2) as region,
           ter.tv_date,
           ter.all_categories_adj_insight,
           ter.all_categories_ind_pctl,
           ter.all_categories_esg_rank,
           ter.materiality_adj_insight,
           ter.materiality_ind_pctl,
           ter.materiality_esg_rank
    FROM "FACTSET_SNOWFLAKE_ESG_DEMO_SHARE"."SYM_V1"."SYM_TICKER_REGION" AS tr
    JOIN "FACTSET_SNOWFLAKE_ESG_DEMO_SHARE"."SYM_V1"."SYM_COVERAGE" AS cov
      ON tr.fsym_id = cov.fsym_id
    JOIN "FACTSET_SNOWFLAKE_ESG_DEMO_SHARE"."TV_V2"."TV_FACTSET_ID_MAP" AS id
      ON id.factset_id = cov.fsym_security_id
    JOIN "FACTSET_SNOWFLAKE_ESG_DEMO_SHARE"."TV_V2"."TV_ESG_RANKS" AS ter
      ON ter.tv_instrument_id = id.provider_id
    WHERE 
    REGION = 'US'
    AND
    tv_date = '2021-02-28'
    order by ter.tv_date desc;

--Query Factset ESG Data - FAANG Stocks
    SELECT * 
    from factset_esg_vw where
    ticker in ('FB','AMZN','AAPL','NFLX','GOOG') and region = 'US';


--What is the ESG risk in my portfolio?
    --notice: querying live data from Factset
    select symbol, date, trader, PM, cash_now, num_share_now, close, market_value, PnL, e.all_categories_adj_insight, e.all_categories_esg_rank
    from position_now p
    inner join factset_esg_vw e on e.ticker = p.symbol
    where p.trader = 'charles'
    order by all_categories_adj_insight desc;



--Create View for ESG + Company Profile
    create or replace view COMPANY_PROFILE_ESG as
    select * from COMPANY_PROFILE as co
    inner join FACTSET_ESG_VW as esg
    on co.symbol = esg.ticker;

    --what is the ESG for a certain ticker?
    select top 300 * 
    from COMPANY_PROFILE_ESG
    where symbol = 'YUM';


--ESG by Industry ordered by sector
    select SECTOR, avg(ALL_CATEGORIES_ADJ_INSIGHT) as ESG_AVG 
    from COMPANY_PROFILE_ESG
    where SECTOR is not null and sector <> ''
    group by SECTOR
    order by 2 desc, 1;


--ESG for Financial Services ordered by ESG descending
    select COMPANYNAME, SYMBOL, SECTOR, BETA, MKTCAP, ALL_CATEGORIES_ADJ_INSIGHT, ALL_CATEGORIES_IND_PCTL, ALL_CATEGORIES_ESG_RANK, MATERIALITY_ADJ_INSIGHT, MATERIALITY_IND_PCTL, MATERIALITY_ESG_RANK
    from COMPANY_PROFILE_ESG
    where SECTOR = 'Financial Services' --'Technology'
    and ALL_CATEGORIES_ESG_RANK in ('Leader','Above Average')
    and ALL_CATEGORIES_ESG_RANK is not null
    order by ALL_CATEGORIES_ESG_RANK desc;

/*
Recap
    We take Factsets SASB (Sustainability Accounting Standards Board) Data 
    to calculate (Environmental, Social, and Governance) ESG scores
    
    https://www.snowflake.com/datasets/factset-truvalue-labs-sasb-codified-datafeed/


*/
