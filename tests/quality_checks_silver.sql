/*
Quality Checks
==============

Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardisation across the 'silver' schemas. It includes checks for:
  - Null or duplicate primary keys
  - Unwanted spaces in string fields
  - Data standardisation and consistency
  - Invalid date ranges
  - Data consistency between related fields

Usage Notes:
  Run these scripts after loading the silver layer.
  Investigate and resolve any discrepancies between the checks.
*/

-----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No results

SELECT 
  cst_id,
COUNT (*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT (*) > 1 or cst_id IS NULL;
