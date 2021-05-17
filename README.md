# Financial Services Asset Management on Snowflake Demo

## Why this Demo
### Problem Statement
Asset managers have spent hundreds of millions on systems to accurately give a Single Version of Truth (SVOT) in real-time.  What would such a system look like on Snowflake?

### Why Snowflake: Your benefits
    Significantly less cost of maintaining one high performance SVOT    
    SVOT makes trading, risk management, and regulatory reporting significantly easier
    Unlimited Compute and Concurrency enable quick data-driven decisions

### What we will see
    Use Data Marketplace to instantly get stock history so the business doesn't have to wait for IT.
    Populate only the trade table and use window functions to generate cash, positions, and Profit-and-Loss (PnL) so that you can have real-time updates.
    Use SnowSight - Snowflake's complimentary User Interface (UI) - to generate dashboards that can be shared with the business so that you don't need licenses for an additional Business Intelligence (BI) tool.

## Demo and Technical Deep-Dive
[Youtube Playlist](https://www.youtube.com/playlist?list=PLyKI7j42vSkbryDXuB7kEhzk66lmdNJ3Z)

[Medium Blog](https://allenwongtech.medium.com/what-would-snowflake-for-an-asset-manager-look-like-part-1-a0583c0e5822)

## How to Install (Only takes about 5 minutes to execute)
    Run Script 10: Sets up the environment
    Run Script 20: Connects to the Data Marketplace to get free stock history
    Run Script 30: Populates the trade table.  Creates Window Function Views for cash, positions, and PnL
    
### Optional Setting:
In the first few lines of script 30, you can set the variable *limit_trader = x*.

It's default is set to 1000 traders to populate in the trader table which when multplied by ten years of daily trades will create 2.1 billion trades.  So you can create 6 billion or more trades for stress-testing and this is the relationship:
    
limit_trader  | Trades generated | Script 30 Run-time with xxlarge compute
--------------|------------------|------------------------------
1000 (default)| 2.1 billion      | 1:45 (1 minute  : 45 seconds)
2000          | 4.2 billion      | 3:00 (3 minutes)
3000          | 6.4 billion      | 4:40 (4 minutes : 40 seconds)
    
## How to Demo
    Run script 40: Show the use case, benefits, and sample queries 

## How to Demo SnowSight
    In snowsight subfolder:
        Add filters in script "33 filter SnowSight"
        Build SnowSight dashboard using script "35 SnowSight".
    
## Optional Demo
    Run script 50: Stress-test queries via Window Functions on all data (shows scaling up to XLarge compute)
    
## Partner Demos on top of this demo

[Data Build Tool (DBT)](https://github.com/ruwhite11/AssetManagement): Open-Sourced by a hedge fund prospect.  DBT gives you software engineering best practices on big data with concepts like Don't Repeat Yourself and Analytics Engineer.

[Sigma Computing](https://sigmacomputing.wistia.com/medias/w7ck8dugdp): Excel-like analysis over 2 billion rows powered with only Snowflake Small compute power.

[Zepl](https://www.youtube.com/watch?v=PuY7LpklunM&feature=youtu.be): Founded by the creators of the Zeppelin notebook, Zepl provides a serverless way for you to easily secure, scale, and share your data science workloads (Python, SQL, R, or Scala) against Snowflake.
  
## To remove Demo
    Run "optional\finserv option reset.sql".
    If you implemented SnowSight, delete Filters and Dashboard in snowsight subfolder: scripts 33 and 35.
