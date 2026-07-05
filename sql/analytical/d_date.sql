CREATE TABLE d_date AS
SELECT DISTINCT
  DATE(f.funeral_date) as date_key,
  DAY(f.funeral_date) as day_of_month,
  MONTH(f.funeral_date) as month_number,
  QUARTER(f.funeral_date) as quarter,
  YEAR(f.funeral_date) as year,
  WEEK(f.funeral_date) as week_number,
  DAYNAME(f.funeral_date) as day_name,
  CONCAT(YEAR(f.funeral_date), '-Q', QUARTER(f.funeral_date)) as quarter_label,
  CONCAT(YEAR(f.funeral_date), '-', LPAD(MONTH(f.funeral_date), 2, '0')) as month_label
FROM funerals f
WHERE f.funeral_date IS NOT NULL;