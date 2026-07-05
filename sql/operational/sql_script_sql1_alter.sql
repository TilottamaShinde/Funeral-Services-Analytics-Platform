ALTER TABLE funerals ADD COLUMN booking_date DATE;
ALTER TABLE funerals ADD COLUMN expected_completion_date DATE;
ALTER TABLE cremations ADD COLUMN expected_completion_date DATE;
ALTER TABLE burials ADD COLUMN expected_completion_date DATE;
ALTER TABLE repatriations ADD COLUMN request_date DATE;
ALTER TABLE repatriations ADD COLUMN expected_arrival_date DATE;