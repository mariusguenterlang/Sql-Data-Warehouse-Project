# Data Dictionary for Gold Layer
---

## Overview
The gold layer is the business level data representation, structured to support analytical and reporting use-cases. it consists of **dimension tables** and **fact tables** for specific business metrics.

---

### 1. gold.dim_customers
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name | Data Type | Description |
| --- | --- | --- |
| customer_key | INT | Surrogate key uniquely identifying each customer and record in the dimension table |
| customer_id | INT | Unique numerical identifier assigned to each customer |
| customer_number | VARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and referencing |
| first_name | VARCHAR(50) | The customer's first name, as recorded in the system |
| last_name | VARCHAR(50) | The customer's last name or family name |
| country | VARCHAR(50) | The country of residence for the customer (e.g. Australia) |
| marital_status | VARCHAR(50) | The marital status of the customer (e.g. Married, Single) |
| gender | VARCHAR(50) | The gender of the customer (e.g. Male, Female, n/a) |
