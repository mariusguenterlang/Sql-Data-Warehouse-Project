
-- Check Customer-ID counts on the aggregated customer info table
SELECT cst_id, COUNT(*) FROM
(SELECT
  ci.cst_id,
  ci.cst_key,
  ci.cst_firstname,
  ci.cst_lastname,
  ci.cst_marital_status,
  ci.cst_gndr,
  ci.cst_create_date,
  ca.bdate,
  ca.gen,
  la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
) GROUP BY cst_id HAVING COUNT(*) > 1;
