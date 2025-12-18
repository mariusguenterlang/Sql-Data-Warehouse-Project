/*
DDL-Script: Create Bronze Tables
================================

Script Purpose:
  This script creates tables in the 'bronze' schema, if they
  do not already exist. Since we use PgAdmin, we load the 
  tables manually, skipping stored procedures, a try-catch 
  architecture, or ETL duration tracking.
*/

CREATE TABLE IF NOT EXISTS bronze.crm_cust_info(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(50),
cst_gndr VARCHAR(50),
cst_create_date DATE
);

CREATE TABLE IF NOT EXISTS bronze.crm_prd_info(
prd_id INT,
prd_key VARCHAR(50),
prd_nm VARCHAR(50),
prd_cost INT,
prd_line VARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);

CREATE TABLE IF NOT EXISTS bronze.crm_sales_details(
sls_ord_num VARCHAR(50),
sls_prd_key VARCHAR(50),
sls_cust_id INT,
sls_order_dt TEXT,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
prd_price INT
);

CREATE TABLE IF NOT EXISTS bronze.erp_CUST_AZ12(
cid VARCHAR(50),
bdate DATE,
gen VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS bronze.erp_LOC_A101(
cid VARCHAR(50),
cntry VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS bronze.erp_PX_CAT_G1V2(
id VARCHAR(50),
cat VARCHAR(50),
subcat VARCHAR(50), 
maintenance VARCHAR(50)
);
