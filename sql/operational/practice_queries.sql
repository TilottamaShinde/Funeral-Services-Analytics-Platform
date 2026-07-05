-- ===================================================================
-- DELA SQL PRACTICE WORKBOOK
-- SQL Patterns for BI Developer Interview Preparation
-- ===================================================================

USE dela_services;

-- ===================================================================
-- LEVEL 1: BASIC QUERIES (Warm-up)
-- ===================================================================

-- Q1.1: Find the top 5 funeral homes by number of funerals in 2026
SELECT 
  fh.funeral_home_id,
  fh.name,
  fh.city,
  COUNT(f.funeral_id) as total_funerals,
  SUM(f.cost) as total_revenue
FROM funeral_homes fh
LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id
WHERE YEAR(f.funeral_date) = 2026
GROUP BY fh.funeral_home_id, fh.name, fh.city
ORDER BY total_funerals DESC
LIMIT 5;

-- Q1.2: List all active insurance policies
SELECT 
  p.policy_id,
  p.policy_number,
  CONCAT(c.first_name, ' ', c.last_name) as customer_name,
  p.policy_type,
  p.coverage_amount,
  p.annual_premium,
  p.started_at
FROM insurance_policies p
JOIN customers c ON p.customer_id = c.customer_id
WHERE p.active = TRUE
ORDER BY p.started_at DESC;

-- Q1.3: Count funerals by service type in Q1 2026
SELECT 
  service_type,
  COUNT(*) as funeral_count,
  AVG(cost) as avg_cost,
  MIN(cost) as min_cost,
  MAX(cost) as max_cost
FROM funerals
WHERE YEAR(funeral_date) = 2026
  AND MONTH(funeral_date) <= 3
GROUP BY service_type
ORDER BY funeral_count DESC;

-- Q1.4: Find all completed funerals with customer details
SELECT 
  f.funeral_id,
  f.deceased_name,
  f.funeral_date,
  CONCAT(c.first_name, ' ', c.last_name) as customer_name,
  fh.name as funeral_home,
  f.service_type,
  f.cost
FROM funerals f
JOIN customers c ON f.customer_id = c.customer_id
JOIN funeral_homes fh ON f.funeral_home_id = fh.funeral_home_id
WHERE f.status = 'COMPLETED'
ORDER BY f.funeral_date DESC;

-- ===================================================================
-- LEVEL 2: WINDOW FUNCTIONS & AGGREGATION (Important for BI)
-- ===================================================================

-- Q2.1: Running total of funerals per funeral home by month
SELECT 
  fh.name as funeral_home,
  DATE_TRUNC('month', f.funeral_date) as month,
  COUNT(*) as funerals_this_month,
  SUM(COUNT(*)) OVER (
    PARTITION BY fh.funeral_home_id 
    ORDER BY DATE_TRUNC('month', f.funeral_date)
  ) as running_total_funerals,
  SUM(f.cost) as monthly_revenue
FROM funeral_homes fh
LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id
WHERE YEAR(f.funeral_date) = 2026
GROUP BY fh.funeral_home_id, fh.name, DATE_TRUNC('month', f.funeral_date)
ORDER BY fh.name, month;

-- Q2.2: Month-over-month change in cremations
WITH monthly_cremations AS (
  SELECT 
    DATE_TRUNC('month', c.completed_date) as month,
    COUNT(*) as cremations
  FROM cremations c
  WHERE c.status = 'COMPLETED'
    AND YEAR(c.completed_date) = 2026
  GROUP BY DATE_TRUNC('month', c.completed_date)
)
SELECT 
  month,
  cremations,
  LAG(cremations) OVER (ORDER BY month) as prev_month_cremations,
  cremations - LAG(cremations) OVER (ORDER BY month) as mom_change,
  ROUND(
    ((cremations - LAG(cremations) OVER (ORDER BY month)) / 
     LAG(cremations) OVER (ORDER BY month) * 100), 2
  ) as mom_change_pct
FROM monthly_cremations
ORDER BY month;

-- Q2.3: Rank funeral homes by revenue (with dense rank)
SELECT 
  DENSE_RANK() OVER (ORDER BY SUM(f.cost) DESC) as revenue_rank,
  fh.name,
  fh.city,
  COUNT(f.funeral_id) as funeral_count,
  SUM(f.cost) as total_revenue,
  ROUND(AVG(f.cost), 2) as avg_funeral_cost
FROM funeral_homes fh
LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id
  AND YEAR(f.funeral_date) = 2026
GROUP BY fh.funeral_home_id, fh.name, fh.city
ORDER BY revenue_rank;

-- Q2.4: Customer funeral history with row number (to find repeat customers)
SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) as customer_name,
  f.deceased_name,
  f.funeral_date,
  ROW_NUMBER() OVER (
    PARTITION BY c.customer_id 
    ORDER BY f.funeral_date
  ) as funeral_sequence,
  LAG(f.funeral_date) OVER (
    PARTITION BY c.customer_id 
    ORDER BY f.funeral_date
  ) as previous_funeral_date,
  DATEDIFF(f.funeral_date, LAG(f.funeral_date) OVER (
    PARTITION BY c.customer_id 
    ORDER BY f.funeral_date
  )) as days_between_funerals
FROM customers c
LEFT JOIN funerals f ON c.customer_id = f.customer_id
WHERE f.funeral_id IS NOT NULL
ORDER BY c.customer_id, f.funeral_date;

-- Q2.5: Identify top 10% performers (funeral homes by cost)
WITH ranked_homes AS (
  SELECT 
    fh.funeral_home_id,
    fh.name,
    SUM(f.cost) as total_revenue,
    PERCENT_RANK() OVER (ORDER BY SUM(f.cost) DESC) as percentile_rank
  FROM funeral_homes fh
  LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id
    AND YEAR(f.funeral_date) = 2026
  GROUP BY fh.funeral_home_id, fh.name
)
SELECT *
FROM ranked_homes
WHERE percentile_rank <= 0.10
ORDER BY percentile_rank;

-- ===================================================================
-- LEVEL 3: COMPLEX LOGIC & DATA QUALITY (Messy Data Patterns)
-- ===================================================================

-- Q3.1: Identify duplicate repatriations (same customer, similar dates)
SELECT 
  r1.repatriation_id,
  r1.customer_id,
  r1.deceased_name,
  r1.date_of_death,
  r1.destination_country,
  COUNT(*) OVER (
    PARTITION BY r1.customer_id, r1.date_of_death, r1.destination_country
  ) as duplicate_count,
  ROW_NUMBER() OVER (
    PARTITION BY r1.customer_id, r1.date_of_death, r1.destination_country
    ORDER BY r1.created_at DESC
  ) as record_order
FROM repatriations r1
WHERE COUNT(*) OVER (
  PARTITION BY r1.customer_id, r1.date_of_death, r1.destination_country
) > 1
ORDER BY r1.customer_id, r1.date_of_death;

-- Q3.2: Consolidate data from "current" and "legacy" repatriation records
-- (Simulating a data migration scenario)
WITH consolidated_repatriations AS (
  SELECT 
    customer_id,
    deceased_name,
    date_of_death,
    destination_country,
    repatriation_cost,
    'current' as source,
    created_at
  FROM repatriations
  WHERE YEAR(created_at) >= 2025
  
  UNION ALL
  
  SELECT 
    customer_id,
    deceased_name,
    date_of_death,
    destination_country,
    repatriation_cost * 0.95 as repatriation_cost,  -- Assume legacy costs need adjustment
    'legacy' as source,
    created_at
  FROM repatriations
  WHERE YEAR(created_at) < 2025
)
SELECT 
  customer_id,
  deceased_name,
  date_of_death,
  destination_country,
  MIN(created_at) as first_request_date,
  COUNT(DISTINCT source) as sources_count,
  STRING_AGG(DISTINCT source, ', ') as all_sources,
  SUM(repatriation_cost) as total_cost,
  COUNT(*) as record_count
FROM consolidated_repatriations
GROUP BY customer_id, deceased_name, date_of_death, destination_country
ORDER BY customer_id;

-- Q3.3: Flag data quality issues in claims
SELECT 
  cl.claim_id,
  cl.policy_id,
  cl.customer_id,
  cl.claim_amount,
  cl.approved_amount,
  CASE 
    WHEN cl.approved_amount > p.coverage_amount THEN 'APPROVED_EXCEEDS_COVERAGE'
    WHEN cl.approved_amount IS NULL AND cl.status = 'APPROVED' THEN 'MISSING_APPROVED_AMOUNT'
    WHEN cl.claimed_at > f.funeral_date + INTERVAL 30 DAY THEN 'CLAIM_LATE'
    WHEN cl.approved_amount = 0 THEN 'ZERO_APPROVAL'
    ELSE 'OK'
  END as quality_flag,
  p.coverage_amount,
  f.funeral_date,
  cl.claimed_at
FROM insurance_claims cl
LEFT JOIN insurance_policies p ON cl.policy_id = p.policy_id
LEFT JOIN funerals f ON cl.funeral_id = f.funeral_id
WHERE cl.status IN ('APPROVED', 'PAID', 'SUBMITTED')
ORDER BY quality_flag;

-- Q3.4: Identify claims pending approval (aging report)
SELECT 
  cl.claim_id,
  CONCAT(c.first_name, ' ', c.last_name) as customer_name,
  cl.policy_id,
  cl.claim_amount,
  cl.claimed_at,
  DATEDIFF(CURDATE(), cl.claimed_at) as days_pending,
  CASE 
    WHEN DATEDIFF(CURDATE(), cl.claimed_at) > 30 THEN 'OVERDUE'
    WHEN DATEDIFF(CURDATE(), cl.claimed_at) > 14 THEN 'AT_RISK'
    ELSE 'ON_TRACK'
  END as aging_status,
  cl.notes
FROM insurance_claims cl
JOIN customers c ON cl.customer_id = c.customer_id
WHERE cl.status IN ('SUBMITTED', 'UNDER_REVIEW')
ORDER BY DATEDIFF(CURDATE(), cl.claimed_at) DESC;

-- Q3.5: Reconcile funerals vs. claims (find missing claims)
SELECT 
  f.funeral_id,
  f.deceased_name,
  f.funeral_date,
  CONCAT(c.first_name, ' ', c.last_name) as customer_name,
  f.cost as funeral_cost,
  COALESCE(cl.claim_amount, 0) as claimed_amount,
  CASE 
    WHEN cl.claim_id IS NULL THEN 'NO_CLAIM'
    WHEN cl.claim_id IS NOT NULL AND DATEDIFF(cl.claimed_at, f.funeral_date) > 30 THEN 'CLAIM_LATE'
    ELSE 'CLAIMED'
  END as claim_status
FROM funerals f
JOIN customers c ON f.customer_id = c.customer_id
LEFT JOIN insurance_claims cl ON f.funeral_id = cl.funeral_id
WHERE f.status = 'COMPLETED'
  AND YEAR(f.funeral_date) = 2026
ORDER BY claim_status;

-- ===================================================================
-- LEVEL 4: ADVANCED (If You Impress)
-- ===================================================================

-- Q4.1: Calculate KPIs for funeral home dashboard
WITH home_stats AS (
  SELECT 
    fh.funeral_home_id,
    fh.name,
    fh.city,
    fh.capacity_per_day,
    COUNT(DISTINCT f.funeral_id) as funerals_completed,
    COUNT(CASE WHEN f.status = 'SCHEDULED' THEN 1 END) as funerals_scheduled,
    COUNT(CASE WHEN f.status = 'PENDING' THEN 1 END) as funerals_pending,
    ROUND(AVG(f.attended_staff_count), 2) as avg_staff_per_funeral,
    SUM(f.cost) as total_revenue,
    ROUND(AVG(f.cost), 2) as avg_funeral_cost,
    COUNT(DISTINCT f.customer_id) as unique_customers
  FROM funeral_homes fh
  LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id
    AND YEAR(f.funeral_date) = 2026
  GROUP BY fh.funeral_home_id, fh.name, fh.city, fh.capacity_per_day
)
SELECT 
  *,
  ROUND((funerals_completed / capacity_per_day) / 
    (SELECT COUNT(DISTINCT DATE(funeral_date)) FROM funerals 
     WHERE YEAR(funeral_date) = 2026), 2) as utilization_rate
FROM home_stats
ORDER BY total_revenue DESC;

-- Q4.2: Customer lifetime value (CLV) analysis
WITH customer_funeral_history AS (
  SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.created_at,
    COUNT(f.funeral_id) as funerals_arranged,
    SUM(f.cost) as total_funeral_spend,
    COUNT(DISTINCT p.policy_id) as active_policies,
    SUM(p.annual_premium) as total_annual_premium,
    MIN(f.funeral_date) as first_funeral_date,
    MAX(f.funeral_date) as last_funeral_date,
    DATEDIFF(MAX(f.funeral_date), MIN(f.funeral_date)) as customer_lifecycle_days
  FROM customers c
  LEFT JOIN funerals f ON c.customer_id = f.customer_id
  LEFT JOIN insurance_policies p ON c.customer_id = p.customer_id AND p.active = TRUE
  GROUP BY c.customer_id, c.first_name, c.last_name, c.created_at
)
SELECT 
  *,
  ROUND((total_funeral_spend + (total_annual_premium * 10)) / NULLIF(customer_lifecycle_days, 0) * 365, 2) as clv_annual_value
FROM customer_funeral_history
WHERE funerals_arranged > 0
ORDER BY clv_annual_value DESC;

-- Q4.3: Repatriation performance SLA report (Are we completing on time?)
SELECT 
  r.destination_country,
  COUNT(*) as total_repatriations,
  COUNT(CASE WHEN r.status = 'COMPLETED' THEN 1 END) as completed,
  ROUND(DATEDIFF(r.arrival_date, r.departure_date), 2) as avg_transit_days,
  ROUND(
    DATEDIFF(r.arrival_date, r.departure_date) / COUNT(*) * 100, 2
  ) as avg_transit_time_pct,
  COUNT(CASE 
    WHEN r.status = 'COMPLETED' 
    AND DATEDIFF(r.arrival_date, r.departure_date) <= 3 THEN 1 
  END) as within_sla_3days,
  ROUND(
    COUNT(CASE 
      WHEN r.status = 'COMPLETED' 
      AND DATEDIFF(r.arrival_date, r.departure_date) <= 3 THEN 1 
    END) / COUNT(CASE WHEN r.status = 'COMPLETED' THEN 1 END) * 100, 2
  ) as sla_compliance_pct
FROM repatriations r
WHERE r.status IN ('COMPLETED', 'IN_TRANSIT')
GROUP BY r.destination_country
ORDER BY sla_compliance_pct DESC;

-- Q4.4: Correlation analysis: Does higher staff count correlate with higher cost?
SELECT 
  f.attended_staff_count,
  COUNT(*) as funeral_count,
  ROUND(AVG(f.cost), 2) as avg_cost,
  ROUND(STDDEV_POP(f.cost), 2) as cost_stddev,
  MIN(f.cost) as min_cost,
  MAX(f.cost) as max_cost
FROM funerals f
WHERE f.status = 'COMPLETED'
  AND f.attended_staff_count > 0
GROUP BY f.attended_staff_count
ORDER BY f.attended_staff_count;

-- Q4.5: Identify peak seasons and capacity planning needs
SELECT 
  MONTH(f.funeral_date) as month,
  MONTHNAME(f.funeral_date) as month_name,
  COUNT(f.funeral_id) as funeral_count,
  COUNT(DISTINCT f.funeral_home_id) as funeral_homes_active,
  ROUND(COUNT(f.funeral_id) / COUNT(DISTINCT f.funeral_home_id), 2) as avg_funerals_per_home,
  COUNT(CASE WHEN f.service_type = 'CREMATION' THEN 1 END) as cremation_count,
  COUNT(CASE WHEN f.service_type = 'TRADITIONAL' THEN 1 END) as traditional_count,
  COUNT(CASE WHEN f.service_type = 'BURIAL' THEN 1 END) as burial_count,
  SUM(f.cost) as monthly_revenue
FROM funerals f
WHERE YEAR(f.funeral_date) = 2026
GROUP BY MONTH(f.funeral_date), MONTHNAME(f.funeral_date)
ORDER BY MONTH(f.funeral_date);

-- ===================================================================
-- BONUS: Performance Optimization Demonstrations
-- ===================================================================

-- Q5.1: Show which indexes would help (execution plan analysis)
-- Before running, compare these two queries' execution times:

-- SLOW (no index):
EXPLAIN SELECT * FROM funerals 
WHERE customer_id = 5 AND YEAR(funeral_date) = 2026;

-- FAST (with index):
SELECT * FROM funerals 
WHERE customer_id = 5 AND funeral_date BETWEEN '2026-01-01' AND '2026-12-31';

-- Q5.2: Batch processing for claims (chunking large operations)
SELECT 
  cl.claim_id,
  cl.customer_id,
  CEILING(ROW_NUMBER() OVER (ORDER BY cl.claim_id) / 100.0) as batch_number
FROM insurance_claims cl
WHERE cl.status = 'SUBMITTED'
ORDER BY batch_number, cl.claim_id;

-- ===================================================================
-- CHALLENGE QUESTIONS FOR INTERVIEW PRACTICE
-- ===================================================================

-- Challenge 1: "Given the schema, design a query that identifies which funeral homes
-- are likely to exceed capacity this month. Output should show funeral_home_id, 
-- name, available_capacity, and scheduled_funerals."

-- Challenge 2: "A customer reports they never received notification of a claim payout.
-- Write a query that shows the full claim lifecycle (submitted → approved → paid)
-- with timestamps, and flag any claims where paid_at is NULL but status is PAID."

-- Challenge 3: "We need a monthly reconciliation: for each funeral home, 
-- compare total_funeral_costs against total_approved_claims_paid. 
-- Flag any discrepancies > 5%."

-- ===================================================================
-- END OF PRACTICE WORKBOOK
-- ===================================================================
