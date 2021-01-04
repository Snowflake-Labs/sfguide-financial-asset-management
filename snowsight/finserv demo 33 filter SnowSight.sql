/*
Custom filters are special keywords that resolve as a subquery or list of values.
    https://docs.snowflake.com/en/user-guide/ui-snowsight-worksheets.html#custom-filters
    
The benefit of filters is:
    * it's a Single Version of the Truth (SVOT) for your business definitions
    * users don't need to write additional SQL
    * when you change a filter, all queries that use it have the latest definition
    
Recommended Setup:
    * Create a Virtual Warehouse such as XSMALL_CONST_WH so it's an XS Constant Warehouse that no one will resize. 
    * Set it was auto-suspend of 1 minute to save costs
    
Note:
    * These filters are used by the "finserv demo 35 SnowSight" script.

*/

-- :trader
select distinct trader from finservam.public.trader order by 1;

-- :fsdate
select distinct date from finservam.public.trade order by 1;

-- :fssymbol
select distinct symbol from finservam.public.trade order by 1;

