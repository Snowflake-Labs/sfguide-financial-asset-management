/*
Hands-on-lab
https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab


*/


use schema finservam.public;
use role accountadmin;
use warehouse hol_junior;

-----------------------------------------------------------------------------------------------------------
--Scale Up or Down Compute - even query mid-flight

/* XSMALL SMALL MEDIUM LARGE XLARGE X2LARGE X3LARGE X4LARGE  */
alter warehouse hol_junior set warehouse_size = 'medium';


-----------------------------------------------------
--Caching

    --disable global cache (not recommended since "free") but good to see benefit
    alter account set use_cached_result=false;  

    --reenable cache
    alter account set use_cached_result=true;


-----------------------------------------------------
--Multi-Clustering (for unlimited concurrency)

    --disable to see pain of wasted employee and customer cost via queuing
    alter warehouse hol_junior set max_cluster_count = 1;

    --re-enable to see benefit
    alter warehouse hol_junior set max_cluster_count = 10;

-----------------------------------------------------
--Flow
/*
Customer pick a free Share; then we all query from it
Create Resource Monitor for both warehouses
Show Account Usage

*/
