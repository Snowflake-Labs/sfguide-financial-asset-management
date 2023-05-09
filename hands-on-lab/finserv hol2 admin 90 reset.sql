/*
reset the Financial Services Hand-on-lab by dropping objects created in the HOL

https://github.com/Snowflake-Labs/sfguide-financial-asset-management/tree/master/hands-on-lab


*/
----------------------------------------------------------------------------------------------------------
use schema finservam.public;
use role accountadmin;

-----------------------------------------------------
--never changes
    //role
    drop role if exists hol_rl;
    
    //warehouse
    drop warehouse if exists hol_power;
    drop warehouse if exists hol_junior;
    
    //database
    drop database if exists hol_uat;
    


-----------------------------------------------------
--take output and run

//drop all users returned from this query
    show users like 'HOL_%';
    set q = last_query_id(); 
    
    select
        'drop user if exists ' || "name" || ';' ddl
        ,*
    from table(result_scan($q));


    
//copy and paste the output above and execute here to drop users;


