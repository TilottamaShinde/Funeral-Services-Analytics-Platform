CREATE TABLE f_feedback AS
SELECT 
  feedback_id,
  funeral_id,
  customer_id,
  'customer' as feedback_type,
  satisfaction_score,
  feedback_category,
  DATE(feedback_date) as feedback_date_key,
  survey_type,
  created_at
FROM customer_feedback

UNION ALL

SELECT 
  family_feedback_id,
  funeral_id,
  NULL as customer_id,
  'family' as feedback_type,
  satisfaction_score,
  'family_experience' as feedback_category,
  DATE(feedback_date) as feedback_date_key,
  NULL as survey_type,
  created_at
FROM family_feedback;