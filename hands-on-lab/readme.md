# Snowflake Financial Services Hands-On-Lab

## Youtube 
1. [Youtube of this Hands-On-Lab](https://www.youtube.com/watch?v=Rr-QrbsUsYM)
2. Prerequisite is to [Build the Financial Services Asset Management Demo](https://www.youtube.com/playlist?list=PLyKI7j42vSkbryDXuB7kEhzk66lmdNJ3Z)

## Instructions
1. Run [finserv hol admin 90 reset](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol%20admin%2090%20reset.sql) to rebuild lab (this is an idempotent script)
2. Run [finserv hol admin 10](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol%20admin%2010.sql) to build the lab
3. Download the [Excel](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/Snowflake%20Financial%20Services%20Hands-on-lab.xlsx) and update with your account, users, and randomly generated password.
4. Walk users through [finserv hol user 10](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol%20user%2010.sql)

## Highly Recommended
1. Add a [Resource Monitor](https://docs.snowflake.com/en/sql-reference/sql/create-resource-monitor.html) for the Account and/or the two Virtual Warehouses (fs_hol_power and fs_hol_junior) created by the aforementioned scripts.

## Remove All Objects
1. Run [finserv hol admin 90 reset](https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/hands-on-lab/finserv%20hol%20admin%2090%20reset.sql)
