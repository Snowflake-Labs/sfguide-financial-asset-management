/*
What
    Run on publisher to replicate to another account in your Organization

Documentation
    https://docs.snowflake.com/en/user-guide/database-replication-failover.html

Open-Source
    https://github.com/Snowflake-Labs/sfguide-financial-asset-management/blob/master/optional/replication/replication_publisher.sql
    https://github.com/Snowflake-Labs/sfguide-financial-asset-management

Youtube Demo of this replication
    https://youtu.be/X2QhA4GSNAc

Benefits
    Serverless replication
    Near zero-maintenance: No need to worry about Distributors, Hardware, and Primary Keys
    Easy Setup via GUI or Script


*/




--Zero Copy Clone to create sandbox for replication
use role sysadmin;
create database if not exists finservam_replication clone finservam;
grant ownership on database finservam_replication to role finservam_admin;



-- show the organisation
use role accountadmin;
show global accounts;


-- Enable replication for each source and target account in your organization
  use role orgadmin;
  select system$global_account_set_parameter('demo171','ENABLE_ACCOUNT_DATABASE_REPLICATION', 'true');
  select system$global_account_set_parameter('sfsenorthamerica_vademo171','ENABLE_ACCOUNT_DATABASE_REPLICATION', 'true');


-- enable replication for database
use role accountadmin;
alter database finservam_replication enable replication to accounts sfsenorthamerica.sfsenorthamerica_vademo171;


-- what is replicated
show replication databases;




/*--------------------------------------------------------------------------------
  Clean up replication
--------------------------------------------------------------------------------*/
/*
drop database finservam_replication;
*/
