CREATE TABLE f_claims AS
SELECT 
  claim_id,
  policy_id,
  funeral_id,
  customer_id,
  claim_amount,
  claimed_at,
  approved_amount,
  approved_at,
  paid_at,
  DATEDIFF(paid_at, claimed_at) as days_to_pay,
  status,
  notes,
  created_at,
  updated_at
FROM insurance_claims;