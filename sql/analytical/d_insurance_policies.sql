CREATE TABLE d_insurance_policies AS
SELECT 
  policy_id,
  customer_id,
  policy_number,
  policy_type,
  coverage_amount,
  annual_premium,
  active,
  started_at,
  ended_at,
  created_at
FROM insurance_policies;