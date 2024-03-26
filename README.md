# Snowflake Financial Services Asset Management Demo Version 3

## Releases
    v3.0    Use Cybersyn share
    v2.0    Use Knoema instead of deprecated Zepl Share; Added Python Faker for synthetic trader creation; Rewrote Snowsight Tiles
            Removed: company_profile, stock_latest, finservam_datascience_wh, snowflake_sample_data, share_now, middleware
    v1.0    Use Zepl Marketplace share

### Problem
What would a big data Financial Services Asset Manager look like on Snowflake?

### What we will see
    Instant access to start market prices with neither copying nor FTP.
    Use window functions real-time trades, cash, positions, and Profit-and-Loss (PnL)
    Use SnowSight - Snowflake's complimentary User Interface (UI) - to generate dashboards that can be shared with the business.


## Demo and Technical Deep-Dive of Version 1.0
[Youtube Demo and build-from-scratch](https://www.youtube.com/watch?v=HkrRXMHDd-E)

[Quickstart Step-by-Step Guide](https://quickstarts.snowflake.com/guide/financial-services-asset-management-snowflake/#0)

[Medium Blog](https://medium.com/snowflake/open-sourcing-a-snowflake-financial-services-asset-management-system-3-billion-trades-with-1a2a0e04671a)

## How to Install (each script is idempotent; takes 7 minutes)

    Find a share named [Cybersyn Financial & Economic Essentials](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/cybersyn-financial-economic-essentials) and mount the share as a database named Financial_Economic_Essentials (Notice 1 underscore between each word)
    
    Run Script 10: Sets up the environment
    Run Script 20: Connects to the Data Marketplace to get free stock history
    Run Script 30: Populates the trade table.  Creates Window Function Views for cash, positions, and PnL
    Run Script 40: This is the smoke test and what the business queries
    
### Optional Setting:
In [line 27 of script 30](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/setup/finserv%20demo%2030%20DDL.sql#L27), you can set the variable *limit_trader = x*.

It's default is set to 100 traders to populate in the trader table which when multplied by 40+ years of daily trades will create 3-billion-plus trades. 
    
limit_trader  | Trades generated | Script 30 Run-time with xxlarge compute
--------------|------------------|------------------------------
100 (default) | 3 billion        | under 4 minutes
200           | 6 billion        | 
300           | 9 billion        | 
    
## Partner Demos on top of this demo

[Data Build Tool (DBT)](https://github.com/ruwhite11/AssetManagement): Open-Sourced by a hedge fund prospect.  DBT gives you software engineering best practices on big data with concepts like Don't Repeat Yourself and Analytics Engineer.

[Sigma Computing](https://sigmacomputing.wistia.com/medias/w7ck8dugdp): Excel-like analysis over 2 billion rows powered with only Snowflake Small compute power.
  
## To remove Demo
    Run "optional\finserv 90 reset.sql".
