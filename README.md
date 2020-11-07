# Financial Services Asset Management on Snowflake Demo

## Why this Demo
### Problem Statement
    Asset managers have spent hundreds of millions on systems to accurately give a Single Version of Truth (SVOT) in real-time

### Why Snowflake: Your benefits
    Significantly less cost of maintaining one high performance SVOT    
    SVOT makes trading, risk management, and regulatory reporting significantly easier
    Unlimited Compute and Concurrency enable quick data-driven decisions

### What we will see
    Use Data Marketplace to instantly get stock history
    Query trade, cash, positions, and PnL on Snowflake
    Use Window Functions to automate cash, position, and PnL reporting

## How to Install
    Run Script 10: Sets up the environment
    Run Script 20: Connects to the Data Marketplace to get free stock history
    Run Script 30: Populates the trade table.  Creates Window Function Views for cash & PnL
    
### Optional Setting:
    Script 30: In the first few lines allows you to set *limit_trader = x*
    It's default is set to 1000 traders to populate in the trader table which when multplied by ten years of daily trades will create 2.1 billion trades.  So you can create billions of trades for stress-testing and this is the relationship:
    
limit_trader | Trades generated | Script 30 Run-time with xxlarge compute
-------------|------------------|------------------------------
1000         | 2.1 billion      | 1:45 (1 minute  : 45 seconds)
2000         | 4.2 billion      | 3:00 (3 minutes)
3000         | 6.4 billion      | 4:40 (4 minutes : 40 seconds)
    
## How to Demo
    Run script 40: Show the use case, benefits, sample queries
    
## Optional Demo
    Run script 50: Stress-test query via Window Functions on all data
    
  
