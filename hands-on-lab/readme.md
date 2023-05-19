# Snowflake Financial Services Hands-On-Lab

## Youtube 
1. [Youtube of this Hands-On-Lab (note this is a previous version of the HOL](https://www.youtube.com/watch?v=Rr-QrbsUsYM)

## Instructions
1. Prerequisite is to [Build the Financial Services Asset Management Demo](https://www.youtube.com/playlist?list=PLyKI7j42vSkbryDXuB7kEhzk66lmdNJ3Z)
2. Make a copy of this [Google Sheet](https://docs.google.com/spreadsheets/d/16iX6s8R1rd87X7aCvZA54tUkWD9k9wFoj0LTRs0xvpk/edit#gid=0) then replace the emails in the Email column (column B) with the emails of your HOL participants.
3. Copy and Paste the contents of the DDL column (column C) into the next script at the location "Temp Space for User Creation DML Begin"
4. Run [finserv hol2 admin 10](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol2%20admin%2010.sql) to build the lab
5. Have users log into your Snowflake account with their emails.
6. Walk users through [finserv hol user 10](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol2%20user%20100.sql)

## Highly Recommended
1. Add a [Resource Monitor](https://docs.snowflake.com/en/sql-reference/sql/create-resource-monitor.html) for the Account and/or the two Virtual Warehouses (fs_hol_power and fs_hol_junior) created by the aforementioned scripts.

## Remove All Objects
1. Run [finserv hol2 admin 90 reset](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol2%20admin%2090%20reset.sql) to optionally reset lab if it has been built before (this is an idempotent script).
