-- ===================================================================
-- DELA - COMPLETE 22 KPI QUERIES IN SQL
-- Build all KPIs directly in the database
-- No Tableau needed - just SQL!
-- ===================================================================

USE dela_services;

-- ===================================================================
-- CATEGORY 1: CUSTOMER / FAMILY EXPERIENCE (4 KPIs)
-- ===================================================================

-- ===================================================================
-- KPI 1.1: Customer Satisfaction Score (Average)
-- What: Average satisfaction rating from all customer feedback (1-10 scale)
-- Why: Measures overall customer satisfaction with services
-- ===================================================================

SELECT 
  ROUND(AVG(satisfaction_score), 2) as avg_satisfaction_score,
  COUNT(*) as total_feedback_responses,
  MIN(satisfaction_score) as lowest_score,
  MAX(satisfaction_score) as highest_score,
  STDDEV(satisfaction_score) as score_std_deviation
FROM customer_feedback;

-- ===================================================================
-- KPI 1.1B: Customer Satisfaction Score by Category
-- Break down satisfaction by feedback category
-- ===================================================================

SELECT 
  feedback_category,
  ROUND(AVG(satisfaction_score), 2) as avg_satisfaction,
  COUNT(*) as response_count
FROM customer_feedback
GROUP BY feedback_category
ORDER BY avg_satisfaction DESC;

-- ===================================================================
-- KPI 1.1C: Customer Satisfaction by Month/Time Trend
-- See how satisfaction changes over time
-- ===================================================================

SELECT 
  DATE_TRUNC(feedback_date, MONTH) as month,
  ROUND(AVG(satisfaction_score), 2) as avg_satisfaction,
  COUNT(*) as feedback_count
FROM customer_feedback
GROUP BY DATE_TRUNC(feedback_date, MONTH)
ORDER BY month DESC;

-- ===================================================================
-- KPI 1.2: Family Feedback Score (Average)
-- What: Average satisfaction rating from family members (1-10 scale)
-- Why: Family experience is critical for funeral services
-- ===================================================================

SELECT 
  ROUND(AVG(satisfaction_score), 2) as avg_family_satisfaction,
  COUNT(*) as total_family_feedback,
  MIN(satisfaction_score) as lowest_score,
  MAX(satisfaction_score) as highest_score
FROM family_feedback;

-- ===================================================================
-- KPI 1.2B: Family Satisfaction by Relationship to Deceased
-- Which family members are most/least satisfied?
-- ===================================================================

SELECT 
  relationship_to_deceased,
  ROUND(AVG(satisfaction_score), 2) as avg_satisfaction,
  COUNT(*) as feedback_count
FROM family_feedback
GROUP BY relationship_to_deceased
ORDER BY avg_satisfaction DESC;

-- ===================================================================
-- KPI 1.3: Complaint Rate
-- What: Percentage of funerals that had complaints
-- Why: Lower complaint rate = better service quality
-- Formula: (Total Complaints / Total Funerals) × 100
-- ===================================================================

SELECT 
  COUNT(DISTINCT c.complaint_id) as total_complaints,
  COUNT(DISTINCT f.funeral_id) as total_funerals,
  ROUND(
    (COUNT(DISTINCT c.complaint_id) / COUNT(DISTINCT f.funeral_id) * 100), 
    2
  ) as complaint_rate_percentage,
  ROUND(
    (COUNT(DISTINCT f.funeral_id) - COUNT(DISTINCT c.complaint_id)) / COUNT(DISTINCT f.funeral_id) * 100,
    2
  ) as complaint_free_percentage
FROM funerals f
LEFT JOIN complaints c ON f.funeral_id = c.funeral_id;

-- ===================================================================
-- KPI 1.3B: Complaint Rate by Severity
-- How many high-severity vs low-severity complaints?
-- ===================================================================

SELECT 
  severity,
  COUNT(*) as complaint_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM complaints) * 100),
    2
  ) as percentage_of_total
FROM complaints
GROUP BY severity
ORDER BY 
  CASE severity
    WHEN 'CRITICAL' THEN 1
    WHEN 'HIGH' THEN 2
    WHEN 'MEDIUM' THEN 3
    WHEN 'LOW' THEN 4
  END;

-- ===================================================================
-- KPI 1.3C: Complaint Rate by Status (Open vs Resolved)
-- How many complaints are still open?
-- ===================================================================

SELECT 
  status,
  COUNT(*) as complaint_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM complaints) * 100),
    2
  ) as percentage
FROM complaints
GROUP BY status;

-- ===================================================================
-- KPI 1.4: Response Time to Customer Requests (Average)
-- What: Average hours to respond to customer inquiries/complaints
-- Why: Fast response = better customer experience
-- Formula: Average of (response_date - request_date) in hours
-- ===================================================================

SELECT 
  ROUND(AVG(response_time_hours), 2) as avg_response_hours,
  ROUND(AVG(response_time_hours) / 24, 2) as avg_response_days,
  COUNT(*) as total_requests,
  MIN(response_time_hours) as fastest_response_hours,
  MAX(response_time_hours) as slowest_response_hours,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY response_time_hours) as median_response_hours
FROM customer_requests
WHERE response_date IS NOT NULL;

-- ===================================================================
-- KPI 1.4B: Response Time by Request Type
-- Which types of requests get fastest responses?
-- ===================================================================

SELECT 
  request_type,
  ROUND(AVG(response_time_hours), 2) as avg_response_hours,
  COUNT(*) as request_count,
  MIN(response_time_hours) as fastest,
  MAX(response_time_hours) as slowest
FROM customer_requests
WHERE response_date IS NOT NULL
GROUP BY request_type
ORDER BY avg_response_hours ASC;

-- ===================================================================
-- KPI 1.4C: Response Time SLA Compliance
-- What: Percentage of requests answered within 4 hours (SLA target)
-- ===================================================================

SELECT 
  COUNT(*) as total_requests,
  SUM(CASE WHEN response_time_hours <= 4 THEN 1 ELSE 0 END) as within_sla,
  SUM(CASE WHEN response_time_hours > 4 THEN 1 ELSE 0 END) as exceeded_sla,
  ROUND(
    (SUM(CASE WHEN response_time_hours <= 4 THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as sla_compliance_percentage
FROM customer_requests
WHERE response_date IS NOT NULL;

-- ===================================================================
-- CATEGORY 2: SERVICE QUALITY (4 KPIs)
-- ===================================================================

-- ===================================================================
-- KPI 2.1: Average Time to Arrange Funeral
-- What: Average days from booking to funeral service date
-- Why: Fast arrangement = responsive service
-- Formula: Average of (funeral_date - booking_date)
-- ===================================================================

SELECT 
  ROUND(AVG(DATEDIFF(funeral_date, booking_date)), 2) as avg_days_to_arrange,
  COUNT(*) as total_funerals_with_booking,
  MIN(DATEDIFF(funeral_date, booking_date)) as min_days,
  MAX(DATEDIFF(funeral_date, booking_date)) as max_days
FROM funerals
WHERE booking_date IS NOT NULL AND funeral_date IS NOT NULL;

-- ===================================================================
-- KPI 2.1B: Time to Arrange by Service Type
-- Which service types take longest to arrange?
-- ===================================================================

SELECT 
  service_type,
  ROUND(AVG(DATEDIFF(funeral_date, booking_date)), 2) as avg_days,
  COUNT(*) as funeral_count
FROM funerals
WHERE booking_date IS NOT NULL AND funeral_date IS NOT NULL
GROUP BY service_type
ORDER BY avg_days DESC;

-- ===================================================================
-- KPI 2.2: On-Time Service Delivery Percentage
-- What: Percentage of funerals completed by expected completion date
-- Why: Meeting SLA targets = operational excellence
-- Formula: (Completed on time / Total completed) × 100
-- ===================================================================

SELECT 
  COUNT(*) as total_completed_funerals,
  SUM(CASE 
    WHEN status = 'COMPLETED' AND funeral_date <= expected_completion_date THEN 1 
    ELSE 0 
  END) as completed_on_time,
  SUM(CASE 
    WHEN status = 'COMPLETED' AND funeral_date > expected_completion_date THEN 1 
    ELSE 0 
  END) as completed_late,
  ROUND(
    (SUM(CASE WHEN status = 'COMPLETED' AND funeral_date <= expected_completion_date THEN 1 ELSE 0 END) / 
     COUNT(*) * 100),
    2
  ) as on_time_delivery_percentage
FROM funerals
WHERE status = 'COMPLETED' AND expected_completion_date IS NOT NULL;

-- ===================================================================
-- KPI 2.2B: On-Time Delivery by Service Type
-- Which service types meet SLAs better?
-- ===================================================================

SELECT 
  f.service_type,
  COUNT(*) as total_completed,
  SUM(CASE 
    WHEN f.funeral_date <= f.expected_completion_date THEN 1 
    ELSE 0 
  END) as on_time,
  SUM(CASE 
    WHEN f.funeral_date > f.expected_completion_date THEN 1 
    ELSE 0 
  END) as late,
  ROUND(
    (SUM(CASE WHEN f.funeral_date <= f.expected_completion_date THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as on_time_percentage
FROM funerals f
WHERE f.status = 'COMPLETED' AND f.expected_completion_date IS NOT NULL
GROUP BY f.service_type
ORDER BY on_time_percentage DESC;

-- ===================================================================
-- KPI 2.2C: Cremation On-Time Delivery (Specific SLA)
-- Cremations: Should complete within 2 days
-- ===================================================================

SELECT 
  COUNT(*) as total_cremations_completed,
  SUM(CASE 
    WHEN c.completed_date <= c.expected_completion_date THEN 1 
    ELSE 0 
  END) as on_time,
  SUM(CASE 
    WHEN c.completed_date > c.expected_completion_date THEN 1 
    ELSE 0 
  END) as late,
  ROUND(
    (SUM(CASE WHEN c.completed_date <= c.expected_completion_date THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as cremation_on_time_percentage,
  ROUND(AVG(DATEDIFF(c.completed_date, c.scheduled_date)), 2) as avg_days_to_complete
FROM cremations c
WHERE c.status = 'COMPLETED' AND c.expected_completion_date IS NOT NULL;

-- ===================================================================
-- KPI 2.2D: Burial On-Time Delivery (Specific SLA)
-- Burials: Should complete within 3 days
-- ===================================================================

SELECT 
  COUNT(*) as total_burials_completed,
  SUM(CASE 
    WHEN b.completed_date <= b.expected_completion_date THEN 1 
    ELSE 0 
  END) as on_time,
  SUM(CASE 
    WHEN b.completed_date > b.expected_completion_date THEN 1 
    ELSE 0 
  END) as late,
  ROUND(
    (SUM(CASE WHEN b.completed_date <= b.expected_completion_date THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as burial_on_time_percentage,
  ROUND(AVG(DATEDIFF(b.completed_date, b.scheduled_date)), 2) as avg_days_to_complete
FROM burials b
WHERE b.status = 'COMPLETED' AND b.expected_completion_date IS NOT NULL;

-- ===================================================================
-- KPI 2.3: Number of Service Issues
-- What: Total count of operational issues during funerals
-- Why: Fewer issues = better quality and smoother operations
-- ===================================================================

SELECT 
  COUNT(*) as total_service_issues,
  COUNT(DISTINCT funeral_id) as funerals_with_issues,
  ROUND(
    (COUNT(DISTINCT funeral_id) / (SELECT COUNT(*) FROM funerals) * 100),
    2
  ) as percentage_of_funerals_affected
FROM service_issues;

-- ===================================================================
-- KPI 2.3B: Service Issues by Severity
-- How critical are the issues?
-- ===================================================================

SELECT 
  severity,
  COUNT(*) as issue_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM service_issues) * 100),
    2
  ) as percentage_of_total
FROM service_issues
GROUP BY severity
ORDER BY 
  CASE severity
    WHEN 'CRITICAL' THEN 1
    WHEN 'HIGH' THEN 2
    WHEN 'MEDIUM' THEN 3
    WHEN 'LOW' THEN 4
  END;

-- ===================================================================
-- KPI 2.3C: Service Issues by Type
-- What types of issues occur most frequently?
-- ===================================================================

SELECT 
  issue_type,
  COUNT(*) as issue_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM service_issues) * 100),
    2
  ) as percentage_of_total
FROM service_issues
GROUP BY issue_type
ORDER BY issue_count DESC;

-- ===================================================================
-- KPI 2.3D: Service Issues Resolution Status
-- How many issues are still open vs resolved?
-- ===================================================================

SELECT 
  status,
  COUNT(*) as issue_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM service_issues) * 100),
    2
  ) as percentage
FROM service_issues
GROUP BY status;

-- ===================================================================
-- KPI 2.4: Repatriation Completion Time
-- What: Average days from repatriation request to arrival
-- Why: Timely repatriation is critical for bereaved families
-- Formula: Average of (arrival_date - request_date)
-- ===================================================================

SELECT 
  COUNT(*) as total_repatriations_completed,
  ROUND(AVG(DATEDIFF(arrival_date, request_date)), 2) as avg_days_to_complete,
  MIN(DATEDIFF(arrival_date, request_date)) as fastest_days,
  MAX(DATEDIFF(arrival_date, request_date)) as slowest_days,
  ROUND(AVG(DATEDIFF(arrival_date, request_date)), 0) as avg_days_rounded
FROM repatriations
WHERE arrival_date IS NOT NULL AND request_date IS NOT NULL AND status = 'COMPLETED';

-- ===================================================================
-- KPI 2.4B: Repatriation Completion by Destination Country
-- Which countries take longest to repatriate to?
-- ===================================================================

SELECT 
  destination_country,
  COUNT(*) as repatriations,
  ROUND(AVG(DATEDIFF(arrival_date, request_date)), 2) as avg_days_to_complete,
  MIN(DATEDIFF(arrival_date, request_date)) as fastest,
  MAX(DATEDIFF(arrival_date, request_date)) as slowest
FROM repatriations
WHERE arrival_date IS NOT NULL AND request_date IS NOT NULL AND status = 'COMPLETED'
GROUP BY destination_country
ORDER BY avg_days_to_complete DESC;

-- ===================================================================
-- KPI 2.4C: Repatriation SLA Compliance (5 days target)
-- What: Percentage of repatriations completed within 5-day SLA
-- ===================================================================

SELECT 
  COUNT(*) as total_repatriations,
  SUM(CASE 
    WHEN DATEDIFF(arrival_date, request_date) <= 5 THEN 1 
    ELSE 0 
  END) as within_sla,
  SUM(CASE 
    WHEN DATEDIFF(arrival_date, request_date) > 5 THEN 1 
    ELSE 0 
  END) as exceeded_sla,
  ROUND(
    (SUM(CASE WHEN DATEDIFF(arrival_date, request_date) <= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as sla_compliance_percentage
FROM repatriations
WHERE arrival_date IS NOT NULL AND request_date IS NOT NULL AND status = 'COMPLETED';

-- ===================================================================
-- CATEGORY 3: OPERATIONAL KPIs (4 KPIs)
-- ===================================================================

-- ===================================================================
-- KPI 3.1: Number of Funerals Handled
-- What: Total count of funerals arranged and completed
-- Why: Volume metric - how many funerals does DELA handle?
-- ===================================================================

SELECT 
  COUNT(*) as total_funerals,
  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
  SUM(CASE WHEN status = 'SCHEDULED' THEN 1 ELSE 0 END) as scheduled,
  SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) as pending,
  SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled
FROM funerals;

-- ===================================================================
-- KPI 3.1B: Funerals by Month
-- Track monthly volume trends
-- ===================================================================

SELECT 
  DATE_TRUNC(funeral_date, MONTH) as month,
  COUNT(*) as funeral_count,
  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
  ROUND(AVG(cost), 2) as avg_funeral_cost,
  SUM(cost) as total_revenue
FROM funerals
WHERE funeral_date IS NOT NULL
GROUP BY DATE_TRUNC(funeral_date, MONTH)
ORDER BY month DESC;

-- ===================================================================
-- KPI 3.1C: Funerals by Year-to-Date
-- YTD comparison
-- ===================================================================

SELECT 
  YEAR(funeral_date) as year,
  COUNT(*) as funeral_count,
  SUM(cost) as total_revenue
FROM funerals
WHERE funeral_date IS NOT NULL AND status = 'COMPLETED'
GROUP BY YEAR(funeral_date)
ORDER BY year DESC;

-- ===================================================================
-- KPI 3.2: Funerals by Region
-- What: Distribution of funerals across Belgium regions
-- Why: Regional performance tracking
-- ===================================================================

SELECT 
  fh.region,
  COUNT(f.funeral_id) as funeral_count,
  COUNT(DISTINCT fh.funeral_home_id) as num_funeral_homes,
  ROUND(AVG(f.cost), 2) as avg_funeral_cost,
  SUM(f.cost) as total_region_revenue
FROM funerals f
JOIN funeral_homes fh ON f.funeral_home_id = fh.funeral_home_id
GROUP BY fh.region
ORDER BY funeral_count DESC;

-- ===================================================================
-- KPI 3.2B: Funerals by Individual Funeral Home
-- Which homes are busiest?
-- ===================================================================

SELECT 
  fh.funeral_home_id,
  fh.name,
  fh.city,
  fh.region,
  COUNT(f.funeral_id) as funeral_count,
  ROUND(AVG(f.cost), 2) as avg_funeral_cost,
  SUM(f.cost) as total_revenue
FROM funerals f
JOIN funeral_homes fh ON f.funeral_home_id = fh.funeral_home_id
GROUP BY fh.funeral_home_id, fh.name, fh.city, fh.region
ORDER BY funeral_count DESC;

-- ===================================================================
-- KPI 3.2C: Funerals by Service Type by Region
-- Which regions prefer which service types?
-- ===================================================================

SELECT 
  fh.region,
  f.service_type,
  COUNT(f.funeral_id) as funeral_count,
  ROUND(
    (COUNT(f.funeral_id) / 
     (SELECT COUNT(*) FROM funerals WHERE funeral_home_id IN 
        (SELECT funeral_home_id FROM funeral_homes WHERE region = fh.region)
     ) * 100),
    2
  ) as percentage_of_region_funerals
FROM funerals f
JOIN funeral_homes fh ON f.funeral_home_id = fh.funeral_home_id
GROUP BY fh.region, f.service_type
ORDER BY fh.region, funeral_count DESC;

-- ===================================================================
-- KPI 3.3: Capacity Utilization of Funeral Homes
-- What: Percentage of available capacity being used per funeral home
-- Why: Operational efficiency - are we using resources optimally?
-- ===================================================================

SELECT 
  fh.funeral_home_id,
  fh.name,
  fh.capacity_per_day,
  COUNT(DISTINCT DATE(f.funeral_date)) as days_with_funerals,
  COUNT(f.funeral_id) as total_funerals,
  ROUND(
    (COUNT(f.funeral_id) / (fh.capacity_per_day * 30) * 100),
    2
  ) as avg_monthly_capacity_utilization_percentage
FROM funeral_homes fh
LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id 
  AND YEAR(f.funeral_date) = YEAR(CURDATE())
  AND MONTH(f.funeral_date) = MONTH(CURDATE())
GROUP BY fh.funeral_home_id, fh.name, fh.capacity_per_day
ORDER BY avg_monthly_capacity_utilization_percentage DESC;

-- ===================================================================
-- KPI 3.3B: Daily Capacity Utilization by Funeral Home
-- How many funerals scheduled per day vs capacity?
-- ===================================================================

SELECT 
  fh.funeral_home_id,
  fh.name,
  fh.capacity_per_day,
  DATE(f.funeral_date) as funeral_date,
  COUNT(f.funeral_id) as funerals_scheduled,
  ROUND(
    (COUNT(f.funeral_id) / fh.capacity_per_day * 100),
    2
  ) as utilization_percentage,
  CASE 
    WHEN COUNT(f.funeral_id) > fh.capacity_per_day THEN 'OVER CAPACITY'
    WHEN COUNT(f.funeral_id) = fh.capacity_per_day THEN 'AT CAPACITY'
    ELSE 'UNDER CAPACITY'
  END as capacity_status
FROM funeral_homes fh
LEFT JOIN funerals f ON fh.funeral_home_id = f.funeral_home_id
WHERE f.funeral_date IS NOT NULL
GROUP BY fh.funeral_home_id, fh.name, fh.capacity_per_day, DATE(f.funeral_date)
ORDER BY fh.funeral_home_id, funeral_date DESC;

-- ===================================================================
-- KPI 3.4: Case Processing Time
-- What: Average days from case opened to case closed
-- Why: Faster processing = better operational efficiency
-- Formula: Average of (case_closed_date - case_opened_date)
-- ===================================================================

SELECT 
  COUNT(*) as total_cases_closed,
  ROUND(AVG(processing_days), 2) as avg_processing_days,
  MIN(processing_days) as fastest_case_days,
  MAX(processing_days) as slowest_case_days,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY processing_days) as median_processing_days
FROM case_processing
WHERE case_closed_date IS NOT NULL;

-- ===================================================================
-- KPI 3.4B: Case Processing Time by Case Type
-- Which case types take longest to process?
-- ===================================================================

SELECT 
  case_type,
  COUNT(*) as total_cases,
  ROUND(AVG(processing_days), 2) as avg_processing_days,
  MIN(processing_days) as fastest,
  MAX(processing_days) as slowest
FROM case_processing
WHERE case_closed_date IS NOT NULL
GROUP BY case_type
ORDER BY avg_processing_days DESC;

-- ===================================================================
-- KPI 3.4C: Case Processing Status
-- How many cases are still open vs closed?
-- ===================================================================

SELECT 
  status,
  COUNT(*) as case_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM case_processing) * 100),
    2
  ) as percentage
FROM case_processing
GROUP BY status;

-- ===================================================================
-- CATEGORY 4: INSURANCE KPIs (4 KPIs)
-- ===================================================================

-- ===================================================================
-- KPI 4.1: Active Policies
-- What: Total number of currently active insurance policies
-- Why: Customer base size and revenue base
-- ===================================================================

SELECT 
  COUNT(*) as total_active_policies,
  COUNT(DISTINCT customer_id) as total_customers_with_active_policies,
  ROUND(AVG(annual_premium), 2) as avg_annual_premium,
  SUM(annual_premium) as total_annual_premium_revenue
FROM insurance_policies
WHERE active = TRUE;

-- ===================================================================
-- KPI 4.1B: Active Policies by Type
-- What types of policies are most common?
-- ===================================================================

SELECT 
  policy_type,
  COUNT(*) as policy_count,
  ROUND(
    (COUNT(*) / (SELECT COUNT(*) FROM insurance_policies WHERE active = TRUE) * 100),
    2
  ) as percentage_of_active_policies,
  ROUND(AVG(annual_premium), 2) as avg_premium,
  SUM(annual_premium) as total_premium_revenue
FROM insurance_policies
WHERE active = TRUE
GROUP BY policy_type
ORDER BY policy_count DESC;

-- ===================================================================
-- KPI 4.1C: Active Policies by Coverage Amount
-- Price segmentation
-- ===================================================================

SELECT 
  CASE 
    WHEN coverage_amount <= 3000 THEN 'BASIC (≤€3000)'
    WHEN coverage_amount <= 6000 THEN 'STANDARD (€3001-€6000)'
    WHEN coverage_amount <= 10000 THEN 'PREMIUM (€6001-€10000)'
    ELSE 'ELITE (>€10000)'
  END as coverage_tier,
  COUNT(*) as policy_count,
  ROUND(AVG(annual_premium), 2) as avg_premium,
  ROUND(AVG(coverage_amount), 2) as avg_coverage
FROM insurance_policies
WHERE active = TRUE
GROUP BY coverage_tier;

-- ===================================================================
-- KPI 4.2: Policy Renewal Rate
-- What: Percentage of expiring policies that renew
-- Why: Customer retention metric
-- ===================================================================

SELECT 
  COUNT(*) as total_policies_analyzed,
  COUNT(CASE WHEN previous_policy_id IS NOT NULL THEN 1 END) as renewed_policies,
  COUNT(CASE WHEN previous_policy_id IS NULL THEN 1 END) as new_policies,
  ROUND(
    (COUNT(CASE WHEN previous_policy_id IS NOT NULL THEN 1 END) / COUNT(*) * 100),
    2
  ) as renewal_rate_percentage
FROM insurance_policies;

-- ===================================================================
-- KPI 4.3: Claims Processing Time (Average)
-- What: Average days from claim submission to payment
-- Why: Cash flow metric and customer satisfaction
-- Formula: Average of (paid_at - claimed_at)
-- ===================================================================

SELECT 
  COUNT(*) as total_claims_paid,
  ROUND(AVG(DATEDIFF(paid_at, claimed_at)), 2) as avg_days_to_pay,
  ROUND(AVG(DATEDIFF(paid_at, claimed_at)) / 7, 2) as avg_weeks_to_pay,
  MIN(DATEDIFF(paid_at, claimed_at)) as fastest_claim_days,
  MAX(DATEDIFF(paid_at, claimed_at)) as slowest_claim_days,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DATEDIFF(paid_at, claimed_at)) as median_days
FROM insurance_claims
WHERE paid_at IS NOT NULL;

-- ===================================================================
-- KPI 4.3B: Claims Processing Time by Status
-- Which claims are still pending?
-- ===================================================================

SELECT 
  status,
  COUNT(*) as claim_count,
  ROUND(AVG(DATEDIFF(CURDATE(), claimed_at)), 2) as avg_days_pending
FROM insurance_claims
WHERE status IN ('SUBMITTED', 'UNDER_REVIEW', 'APPROVED')
GROUP BY status;

-- ===================================================================
-- KPI 4.3C: Claims Processing SLA Compliance (14 days target)
-- What: Percentage of claims paid within 14 days
-- ===================================================================

SELECT 
  COUNT(*) as total_claims_paid,
  SUM(CASE 
    WHEN DATEDIFF(paid_at, claimed_at) <= 14 THEN 1 
    ELSE 0 
  END) as within_sla,
  SUM(CASE 
    WHEN DATEDIFF(paid_at, claimed_at) > 14 THEN 1 
    ELSE 0 
  END) as exceeded_sla,
  ROUND(
    (SUM(CASE WHEN DATEDIFF(paid_at, claimed_at) <= 14 THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as sla_compliance_percentage
FROM insurance_claims
WHERE paid_at IS NOT NULL;

-- ===================================================================
-- KPI 4.4: New Policies Sold
-- What: Number of new policies created (not renewals)
-- Why: Growth metric - acquiring new customers
-- ===================================================================

SELECT 
  COUNT(*) as total_new_policies,
  COUNT(DISTINCT customer_id) as new_customers,
  ROUND(AVG(annual_premium), 2) as avg_premium_new_policies,
  SUM(annual_premium) as total_new_revenue
FROM insurance_policies
WHERE previous_policy_id IS NULL;

-- ===================================================================
-- KPI 4.4B: New Policies Sold by Month
-- Track monthly new policy sales growth
-- ===================================================================

SELECT 
  DATE_TRUNC(started_at, MONTH) as month,
  COUNT(*) as new_policies_sold,
  COUNT(DISTINCT customer_id) as new_customers,
  ROUND(AVG(annual_premium), 2) as avg_premium,
  SUM(annual_premium) as monthly_revenue
FROM insurance_policies
WHERE previous_policy_id IS NULL AND started_at IS NOT NULL
GROUP BY DATE_TRUNC(started_at, MONTH)
ORDER BY month DESC;

-- ===================================================================
-- CATEGORY 5: EMPLOYEE / MISSION KPIs (4 KPIs)
-- ===================================================================

-- ===================================================================
-- KPI 5.1: Employee Satisfaction Score (Average)
-- What: Average satisfaction rating from employee surveys (1-10)
-- Why: Happy employees = better service
-- ===================================================================

SELECT 
  ROUND(AVG(satisfaction_score), 2) as avg_employee_satisfaction,
  COUNT(*) as total_feedback_responses,
  COUNT(DISTINCT employee_id) as employees_surveyed,
  MIN(satisfaction_score) as lowest_score,
  MAX(satisfaction_score) as highest_score
FROM employee_feedback;

-- ===================================================================
-- KPI 5.1B: Employee Satisfaction by Feedback Category
-- Which aspects of work need improvement?
-- ===================================================================

SELECT 
  feedback_category,
  ROUND(AVG(satisfaction_score), 2) as avg_satisfaction,
  COUNT(*) as response_count,
  COUNT(DISTINCT employee_id) as employees_responding
FROM employee_feedback
GROUP BY feedback_category
ORDER BY avg_satisfaction ASC;

-- ===================================================================
-- KPI 5.1C: Employee Satisfaction by Funeral Home
-- Which homes have happier employees?
-- ===================================================================

SELECT 
  fh.funeral_home_id,
  fh.name,
  fh.city,
  ROUND(AVG(ef.satisfaction_score), 2) as avg_satisfaction,
  COUNT(DISTINCT ef.employee_id) as employees_with_feedback,
  COUNT(DISTINCT e.employee_id) as total_employees_at_home
FROM employee_feedback ef
JOIN employees e ON ef.employee_id = e.employee_id
JOIN funeral_homes fh ON e.funeral_home_id = fh.funeral_home_id
GROUP BY fh.funeral_home_id, fh.name, fh.city
ORDER BY avg_satisfaction DESC;

-- ===================================================================
-- KPI 5.2: Employee Retention Rate
-- What: Percentage of employees who remain employed
-- Why: Staff stability = better service quality
-- Formula: (Current employees / (Current + Terminated)) × 100
-- ===================================================================

SELECT 
  COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as active_employees,
  COUNT(CASE WHEN status = 'INACTIVE' THEN 1 END) as terminated_employees,
  COUNT(*) as total_employees_ever,
  ROUND(
    (COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) / COUNT(*) * 100),
    2
  ) as retention_rate_percentage
FROM employees;

-- ===================================================================
-- KPI 5.2B: Turnover Rate by Funeral Home
-- Which homes have turnover problems?
-- ===================================================================

SELECT 
  fh.funeral_home_id,
  fh.name,
  COUNT(CASE WHEN e.status = 'ACTIVE' THEN 1 END) as active_employees,
  COUNT(CASE WHEN e.status = 'INACTIVE' THEN 1 END) as terminated_employees,
  ROUND(
    (COUNT(CASE WHEN e.status = 'INACTIVE' THEN 1 END) / 
     (COUNT(CASE WHEN e.status = 'ACTIVE' THEN 1 END) + 
      COUNT(CASE WHEN e.status = 'INACTIVE' THEN 1 END)) * 100),
    2
  ) as turnover_rate_percentage
FROM employees e
JOIN funeral_homes fh ON e.funeral_home_id = fh.funeral_home_id
GROUP BY fh.funeral_home_id, fh.name
ORDER BY turnover_rate_percentage DESC;

-- ===================================================================
-- KPI 5.2C: Average Tenure
-- How long do employees typically stay?
-- ===================================================================

SELECT 
  ROUND(AVG(
    DATEDIFF(COALESCE(termination_date, CURDATE()), hire_date)
  ) / 365.25, 2) as avg_tenure_years,
  MIN(DATEDIFF(COALESCE(termination_date, CURDATE()), hire_date)) as shortest_tenure_days,
  MAX(DATEDIFF(COALESCE(termination_date, CURDATE()), hire_date)) as longest_tenure_days
FROM employees;

-- ===================================================================
-- KPI 5.3: Training Completion Rate
-- What: Percentage of employees who completed required trainings
-- Why: Competency assurance - staff are properly trained
-- Formula: (Completed trainings / Total required trainings) × 100
-- ===================================================================

SELECT 
  COUNT(*) as total_required_trainings_assigned,
  SUM(CASE WHEN et.status = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
  SUM(CASE WHEN et.status IN ('PENDING', 'IN_PROGRESS') THEN 1 ELSE 0 END) as not_completed,
  ROUND(
    (SUM(CASE WHEN et.status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as completion_rate_percentage
FROM employee_training et
JOIN training_programs tp ON et.training_id = tp.training_id
WHERE tp.required = TRUE;

-- ===================================================================
-- KPI 5.3B: Training Completion by Training Type
-- Which trainings have completion gaps?
-- ===================================================================

SELECT 
  tp.training_name,
  COUNT(*) as employees_assigned,
  SUM(CASE WHEN et.status = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
  SUM(CASE WHEN et.status IN ('PENDING', 'IN_PROGRESS') THEN 1 ELSE 0 END) as not_completed,
  ROUND(
    (SUM(CASE WHEN et.status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as completion_percentage
FROM employee_training et
JOIN training_programs tp ON et.training_id = tp.training_id
WHERE tp.required = TRUE
GROUP BY tp.training_name
ORDER BY completion_percentage ASC;

-- ===================================================================
-- KPI 5.3C: Training Completion by Funeral Home
-- Which homes have trained staff?
-- ===================================================================

SELECT 
  fh.funeral_home_id,
  fh.name,
  COUNT(DISTINCT et.employee_id) as employees_trained,
  COUNT(*) as total_training_assignments,
  SUM(CASE WHEN et.status = 'COMPLETED' THEN 1 ELSE 0 END) as trainings_completed,
  ROUND(
    (SUM(CASE WHEN et.status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*) * 100),
    2
  ) as completion_rate_percentage
FROM employee_training et
JOIN employees e ON et.employee_id = e.employee_id
JOIN funeral_homes fh ON e.funeral_home_id = fh.funeral_home_id
JOIN training_programs tp ON et.training_id = tp.training_id
WHERE tp.required = TRUE
GROUP BY fh.funeral_home_id, fh.name
ORDER BY completion_rate_percentage DESC;

-- ===================================================================
-- KPI 5.3D: Average Training Scores (Competency)
-- How well are employees performing in training?
-- ===================================================================

SELECT 
  tp.training_name,
  COUNT(*) as employees_who_took_test,
  ROUND(AVG(et.score), 2) as avg_score,
  MIN(et.score) as lowest_score,
  MAX(et.score) as highest_score
FROM employee_training et
JOIN training_programs tp ON et.training_id = tp.training_id
WHERE et.score IS NOT NULL AND et.status = 'COMPLETED'
GROUP BY tp.training_name
ORDER BY avg_score DESC;

-- ===================================================================
-- SUMMARY: ALL 22 KPIs AT A GLANCE
-- Run this to see all major KPIs in one dashboard view
-- ===================================================================

SELECT 'Customer Satisfaction Score' as kpi, ROUND(AVG(satisfaction_score), 2) as value, 'Score (1-10)' as metric FROM customer_feedback
UNION ALL
SELECT 'Family Feedback Score', ROUND(AVG(satisfaction_score), 2), 'Score (1-10)' FROM family_feedback
UNION ALL
SELECT 'Complaint Rate %', 
  ROUND((COUNT(DISTINCT complaint_id) / (SELECT COUNT(*) FROM funerals) * 100), 2),
  'Percentage' 
FROM complaints, funerals
UNION ALL
SELECT 'Response Time (hours)', ROUND(AVG(response_time_hours), 2), 'Hours' FROM customer_requests WHERE response_date IS NOT NULL
UNION ALL
SELECT 'Days to Arrange Funeral', ROUND(AVG(DATEDIFF(funeral_date, booking_date)), 2), 'Days' FROM funerals WHERE booking_date IS NOT NULL
UNION ALL
SELECT 'On-Time Delivery %', 
  ROUND((SUM(CASE WHEN status = 'COMPLETED' AND funeral_date <= expected_completion_date THEN 1 ELSE 0 END) / COUNT(*) * 100), 2),
  'Percentage' 
FROM funerals WHERE status = 'COMPLETED' AND expected_completion_date IS NOT NULL
UNION ALL
SELECT 'Service Issues Count', COUNT(*), 'Total' FROM service_issues
UNION ALL
SELECT 'Repatriation Days', ROUND(AVG(DATEDIFF(arrival_date, request_date)), 2), 'Days' FROM repatriations WHERE arrival_date IS NOT NULL AND request_date IS NOT NULL
UNION ALL
SELECT 'Funerals Handled', COUNT(*), 'Total' FROM funerals
UNION ALL
SELECT 'Active Policies', COUNT(*), 'Total' FROM insurance_policies WHERE active = TRUE
UNION ALL
SELECT 'Claims Processing Days', ROUND(AVG(DATEDIFF(paid_at, claimed_at)), 2), 'Days' FROM insurance_claims WHERE paid_at IS NOT NULL
UNION ALL
SELECT 'New Policies Sold', COUNT(*), 'Total' FROM insurance_policies WHERE previous_policy_id IS NULL
UNION ALL
SELECT 'Employee Satisfaction', ROUND(AVG(satisfaction_score), 2), 'Score (1-10)' FROM employee_feedback
UNION ALL
SELECT 'Retention Rate %', 
  ROUND((COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) / COUNT(*) * 100), 2),
  'Percentage' 
FROM employees
UNION ALL
SELECT 'Training Completion %', 
  ROUND((SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2),
  'Percentage' 
FROM employee_training 
JOIN training_programs ON employee_training.training_id = training_programs.training_id 
WHERE training_programs.required = TRUE;

-- ===================================================================
-- END OF SQL KPI QUERIES
-- All 22 KPIs are now in SQL queries
-- Run each query individually or all together
-- ===================================================================