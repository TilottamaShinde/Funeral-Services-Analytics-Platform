CREATE TABLE d_employees AS
SELECT 
  employee_id,
  first_name,
  last_name,
  email,
  phone,
  funeral_home_id,
  position,
  hire_date,
  termination_date,
  termination_reason,
  status,
  created_at
FROM employees;