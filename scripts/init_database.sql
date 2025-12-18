/*
Create database and schemas
===========================

Script purpose:
  This script creates a new database named "DataWarehouse" after
  checking if one with this name already exists. Additionally,
  the script sets up the schemas 'bronze', 'silver', and 'gold'.

Note:
  When working in PgAdmin, remember to manually select the db
  and run the parts independently.
*/

-- 1. drop DataWarehouse database
DO
$$
BEGIN
   IF EXISTS (
      SELECT 1 FROM pg_database WHERE datname = 'datawarehouse'
   ) THEN
      PERFORM pg_terminate_backend(pid)
      FROM pg_stat_activity
      WHERE datname = 'datawarehouse';

      EXECUTE 'DROP DATABASE "DataWarehouse"';
   END IF;
END;
$$;

-- 2. Create DataWarehouse database
CREATE DATABASE "DataWarehouse";

-- 3. Select DataWarehouse

-- 4. Create Schemas
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
