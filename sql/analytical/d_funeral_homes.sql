CREATE TABLE d_funeral_homes AS
SELECT 
  funeral_home_id,
  name,
  city,
  region,
  address,
  postal_code,
  phone,
  manager_name,
  staff_count,
  capacity_per_day,
  created_at
FROM funeral_homes;