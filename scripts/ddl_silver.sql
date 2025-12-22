/*
DDL-Script: Create Silver Tables
================================

Script Purpose:
	This script creates tables in the 'silver'-layer
	if they do not already exist.
	Run this script to re-define the DDL-structure
	of the bronze layer.
*/

CALL silver.load_silver();

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE SQL
AS $$
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE IF NOT EXISTS silver.crm_cust_info(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(50),
cst_gndr VARCHAR(50),
cst_create_date DATE,
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE IF NOT EXISTS silver.crm_prd_info(
prd_id INT,
cat_id VARCHAR(50),
prd_key VARCHAR(50),
prd_nm VARCHAR(50),
prd_cost INT,
prd_line VARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE IF NOT EXISTS silver.crm_sales_details(
sls_ord_num VARCHAR(50),
sls_prd_key VARCHAR(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
prd_price INT,
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_CUST_AZ12;
CREATE TABLE IF NOT EXISTS silver.erp_CUST_AZ12(
cid VARCHAR(50),
bdate DATE,
gen VARCHAR(50),
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_LOC_A101;
CREATE TABLE IF NOT EXISTS silver.erp_LOC_A101(
cid VARCHAR(50),
cntry VARCHAR(50),
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_PX_CAT_G1V2;
CREATE TABLE IF NOT EXISTS silver.erp_PX_CAT_G1V2(
id VARCHAR(50),
cat VARCHAR(50),
subcat VARCHAR(50), 
maintenance VARCHAR(50),
dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Data Transformations

SELECT *
FROM bronze.crm_cust_info;

-- Check for nulls and doubles in the primary key
-- Expectation: no result

SELECT cst_id, COUNT (*) FROM bronze.crm_cust_info
GROUP BY cst_id HAVING COUNT (*) > 1 OR cst_id IS NULL;

-- Data Cleansing

SELECT *, 
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info WHERE cst_id = 29466;

SELECT
*
FROM(
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
)WHERE flag_last = 1;

-- Insert into silver table

TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info(
  cst_id,
  cst_key,
  cst_firstname, 
  cst_lastname,
  cst_marital_status,
  cst_gndr,
  cst_create_date
)
SELECT
  cst_id,
  cst_key,
  TRIM(cst_firstname) AS cst_firstname,
  TRIM(cst_lastname) AS cst_lastname,
  CASE WHEN UPPER(TRIM(cst_gndr)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Married'
	ELSE 'n/a'
  END cst_marital_status,
  CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'n/a'
  END cst_gndr,
  cst_create_date
FROM (
  SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
  FROM bronze.crm_cust_info
  WHERE cst_id IS NOT NULL
) WHERE flag_last = 1;

-- Data Standardisation and Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- Check for the silver layer
SELECT cst_id, COUNT (*) FROM silver.crm_cust_info
GROUP BY cst_id HAVING COUNT (*) > 1 OR cst_id IS NULL;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT *
FROM silver.crm_cust_info;


-- Table: Product Product Info
SELECT *
FROM bronze.crm_prd_info;

TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info(
  prd_id,
  cat_id,
  prd_key,
  prd_nm,
  prd_cost,
  prd_line,
  prd_start_dt,
  prd_end_dt
)
SELECT
  prd_id,
  REPLACE(SUBSTRING(prd_key FROM 1 FOR 5), '-', '_') AS cat_id,
  SUBSTRING(prd_key FROM 7 FOR LENGTH(prd_key)) AS prd_key,
  prd_nm,
  COALESCE(prd_cost, 0) AS prd_cost,
  CASE UPPER(TRIM(prd_line))
    WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'Other Sales'
	WHEN 'T' THEN 'Touring'
	ELSE 'n/a'
  END AS prd_line,
  CAST(prd_start_dt AS DATE) AS prd_start_dt,
  (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day')::date AS prd_end_dt
FROM bronze.crm_prd_info;

-- Table: Sales Orders

TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details(
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  prd_price
)
SELECT
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  CASE 
    WHEN LENGTH(sls_order_dt::text) != 8 OR sls_order_dt::text = '0' THEN NULL
    ELSE TO_DATE(sls_order_dt::text, 'YYYYMMDD')
  END AS sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(prd_price)
    THEN sls_quantity * ABS(prd_price)
	ELSE sls_sales
  END AS sls_sales,
  sls_quantity,
  CASE WHEN prd_price IS NULL OR prd_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE prd_price
  END AS prd_price
FROM bronze.crm_sales_details;

SELECT * FROM silver.crm_sales_details;

-- Clean and load the erp_cust_az12
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12(
  cid,
  bdate,
  gen
)
SELECT
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
  	ELSE cid
  END AS cid,
  CASE WHEN bdate > CURRENT_DATE THEN NULL
    ELSE bdate
  END AS bdate,
  CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'n/a'	
  END AS gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12;

-- Clean and load erp_loc_a101
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101(cid, cntry)
SELECT
  REPLACE(cid, '-', '') AS cid,
  CASE 
    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN NULLIF(TRIM(cntry), '') IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
  END AS cntry
FROM bronze.erp_loc_a101;

SELECT * FROM silver.erp_loc_a101;

-- Clean and load erp_px_cat_g1v2
TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
SELECT
  id,
  cat,
  subcat,
  maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2;
$$
