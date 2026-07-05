CREATE TABLE f_complaints AS
SELECT 
  complaint_id,
  funeral_id,
  customer_id,
  complaint_type,
  description,
  severity,
  DATE(complaint_date) as complaint_date_key,
  DATEDIFF(resolved_date, complaint_date) as resolution_days,
  status,
  resolution_notes,
  1 as complaint_count,
  created_at,
  updated_at
FROM complaints;