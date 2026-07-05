-- ===================================================================
-- DELA TABLEAU KPI TABLES - COMPLETE SAMPLE DATA SCRIPT
-- SAFE MODE COMPATIBLE - Ready to copy and paste
-- ===================================================================

USE dela_services;

-- ===================================================================
-- STEP 1: Update existing tables with new column values
-- ===================================================================

-- Update funerals with booking dates
UPDATE funerals SET booking_date = DATE_SUB(funeral_date, INTERVAL 3 DAY)
WHERE funeral_id > 0 AND booking_date IS NULL;

-- Update funerals with expected completion dates
UPDATE funerals SET expected_completion_date = DATE_ADD(funeral_date, INTERVAL 1 DAY)
WHERE funeral_id > 0 AND expected_completion_date IS NULL AND service_type IN ('TRADITIONAL', 'CREMATION', 'BURIAL');

-- Update cremations with expected completion dates
UPDATE cremations SET expected_completion_date = DATE_ADD(scheduled_date, INTERVAL 2 DAY)
WHERE cremation_id > 0 AND expected_completion_date IS NULL;

-- Update burials with expected completion dates
UPDATE burials SET expected_completion_date = DATE_ADD(scheduled_date, INTERVAL 3 DAY)
WHERE burial_id > 0 AND expected_completion_date IS NULL;

-- Update repatriations with request date
UPDATE repatriations SET request_date = DATE_ADD(date_of_death, INTERVAL 1 DAY)
WHERE repatriation_id > 0 AND request_date IS NULL;

-- Update repatriations with expected arrival date
UPDATE repatriations SET expected_arrival_date = DATE_ADD(request_date, INTERVAL 5 DAY)
WHERE repatriation_id > 0 AND expected_arrival_date IS NULL;

-- ===================================================================
-- STEP 2: Insert COMPLAINTS (9 records)
-- ===================================================================

INSERT INTO complaints (funeral_id, customer_id, complaint_type, description, severity, complaint_date, resolved_date, status, resolution_notes) VALUES
(1, 1, 'Staff behavior', 'Staff member was not courteous to family', 'MEDIUM', '2026-01-16', '2026-01-18', 'RESOLVED', 'Apologized and provided additional support'),
(2, 2, 'Delayed service', 'Cremation took longer than expected', 'MEDIUM', '2026-01-25', '2026-01-27', 'RESOLVED', 'Explained equipment maintenance, provided discount'),
(4, 4, 'Cost issue', 'Final bill was higher than initial quote', 'HIGH', '2026-02-17', '2026-02-22', 'RESOLVED', 'Recalculated, refunded overage'),
(5, 5, 'Missing documentation', 'Did not receive copy of death certificate', 'MEDIUM', '2026-02-28', NULL, 'OPEN', 'Following up with registry office'),
(9, 9, 'Late arrival', 'Funeral home staff arrived 20 mins late', 'LOW', '2026-04-12', '2026-04-13', 'RESOLVED', 'Provided apology letter'),
(6, 6, 'Communication issue', 'Updates were not provided on schedule', 'MEDIUM', '2026-03-14', '2026-03-15', 'RESOLVED', 'Assigned dedicated contact person'),
(10, 10, 'Equipment failure', 'Microphone failed during ceremony', 'HIGH', '2026-04-18', '2026-04-19', 'RESOLVED', 'Replaced equipment, offered discount'),
(7, 7, 'Staff absence', 'Expected coordinator did not show up', 'HIGH', '2026-03-22', '2026-03-23', 'RESOLVED', 'Reassigned staff, offered apology'),
(8, 8, 'Venue issue', 'Heating in chapel was broken', 'MEDIUM', '2026-03-29', '2026-03-31', 'RESOLVED', 'Fixed HVAC, relocated to other chapel');

-- ===================================================================
-- STEP 3: Insert SERVICE_ISSUES (8 records)
-- ===================================================================

INSERT INTO service_issues (funeral_id, cremation_id, burial_id, issue_type, description, severity, reported_date, resolved_date, status, impact_on_service) VALUES
(2, 1, NULL, 'Equipment maintenance', 'Crematory required emergency maintenance', 'MEDIUM', '2026-01-23 09:00:00', '2026-01-23 14:00:00', 'RESOLVED', 'Delayed cremation by 4 hours'),
(5, 2, NULL, 'Staff shortage', 'One coordinator called in sick', 'LOW', '2026-02-26 07:00:00', '2026-02-26 08:00:00', 'RESOLVED', 'Covered by manager'),
(3, NULL, 1, 'Weather issue', 'Heavy rain delayed cemetery access', 'MEDIUM', '2026-02-10 08:00:00', '2026-02-10 11:00:00', 'RESOLVED', 'Rescheduled burial for next day'),
(7, NULL, 2, 'Logistics delay', 'Plot not prepared in time', 'MEDIUM', '2026-03-20 09:00:00', '2026-03-20 14:00:00', 'RESOLVED', 'Cemetery crew expedited work'),
(8, NULL, 3, 'Transportation issue', 'Vehicle breakdown en route', 'HIGH', '2026-03-28 08:30:00', '2026-03-28 10:00:00', 'RESOLVED', 'Called backup hearse, delay: 90 mins'),
(9, NULL, 4, 'Family coordination', 'Late family arrival delayed start', 'LOW', '2026-04-10 09:15:00', '2026-04-10 10:00:00', 'RESOLVED', 'Brief delay, no major impact'),
(4, NULL, NULL, 'Notification delay', 'Death notice not published in time', 'LOW', '2026-02-15 16:00:00', '2026-02-16 10:00:00', 'RESOLVED', 'Published correction next day'),
(6, NULL, NULL, 'IT system issue', 'Booking system down for 2 hours', 'MEDIUM', '2026-03-12 11:00:00', '2026-03-12 13:00:00', 'RESOLVED', 'Manual backup process used');

-- ===================================================================
-- STEP 4: Insert CUSTOMER_FEEDBACK (11 records)
-- ===================================================================

INSERT INTO customer_feedback (customer_id, funeral_id, satisfaction_score, feedback_text, feedback_category, feedback_date, survey_type) VALUES
(1, 1, 9, 'Excellent service. Staff was very compassionate and professional.', 'OVERALL', '2026-01-20', 'post-funeral'),
(2, 2, 7, 'Good service but cremation took longer than quoted.', 'SERVICE_QUALITY', '2026-01-28', 'post-cremation'),
(3, 3, 8, 'Burial was arranged smoothly, cemetery was peaceful.', 'OVERALL', '2026-02-14', 'post-burial'),
(4, 4, 6, 'Service was okay but final bill was higher than expected.', 'COST', '2026-02-20', 'phone survey'),
(5, 5, 9, 'Very satisfied with the entire process. Staff went above and beyond.', 'SATISFACTION', '2026-03-02', 'post-funeral'),
(6, 6, 8, 'Professional and respectful throughout. Would recommend.', 'STAFF', '2026-03-18', 'post-funeral'),
(1, 11, 7, 'Similar to first experience, good but not exceptional.', 'OVERALL', '2026-04-28', 'post-funeral'),
(2, 12, 8, 'Better handling this time. Improvements noted.', 'SERVICE_QUALITY', '2026-05-10', 'phone survey'),
(3, 13, 9, 'Excellent coordination with multiple stakeholders.', 'OVERALL', '2026-05-18', 'post-burial'),
(4, 14, 7, 'Adequate service, had one issue with timing.', 'SATISFACTION', '2026-05-24', 'phone survey'),
(5, 15, 10, 'Outstanding service. Best funeral experience possible.', 'OVERALL', '2026-06-08', 'post-cremation');

-- ===================================================================
-- STEP 5: Insert FAMILY_FEEDBACK (9 records)
-- ===================================================================

INSERT INTO family_feedback (funeral_id, family_member_name, relationship_to_deceased, satisfaction_score, comment, feedback_date) VALUES
(1, 'Marie Dupont', 'Daughter', 9, 'Very dignified and respectful ceremony. Thank you.', '2026-01-20'),
(2, 'Jean Dupont', 'Spouse', 7, 'Good service but seemed rushed at times.', '2026-01-28'),
(3, 'Klaus Jr. Schmidt', 'Son', 8, 'Smooth coordination with family. Very helpful staff.', '2026-02-14'),
(4, 'Rosa Garcia Jr.', 'Daughter', 5, 'Service was okay but we felt ignored at times.', '2026-02-20'),
(5, 'Paul Leclerc', 'Son', 10, 'Exceptional care for my mother. Highly recommend.', '2026-03-02'),
(6, 'Anna Rossi', 'Daughter', 8, 'Professional and compassionate throughout.', '2026-03-18'),
(7, 'Ewa Jr. Petrov', 'Daughter', 7, 'Good service, minor timing issues but resolved.', '2026-03-22'),
(9, 'Ingrid Weber Jr.', 'Son', 9, 'Very respectful handling of mother''s wishes.', '2026-04-12'),
(10, 'Vittorio Ferrara Jr.', 'Son', 6, 'Service was adequate but communication could improve.', '2026-04-19');

-- ===================================================================
-- STEP 6: Insert CUSTOMER_REQUESTS (12 records)
-- ===================================================================

INSERT INTO customer_requests (customer_id, funeral_id, request_type, description, request_date, response_date, status, responder_name) VALUES
(1, NULL, 'INQUIRY', 'What are the costs for a traditional funeral?', '2026-01-10 10:00:00', '2026-01-10 11:30:00', 'RESPONDED', 'Jean Martin'),
(2, NULL, 'INQUIRY', 'Do you offer cremation services?', '2026-01-18 14:00:00', '2026-01-18 15:15:00', 'RESPONDED', 'Sophie Leclerc'),
(3, NULL, 'BOOKING', 'I need to arrange a funeral urgently', '2026-02-05 09:00:00', '2026-02-05 09:30:00', 'RESPONDED', 'Patrick Hermans'),
(1, 1, 'COMPLAINT', 'Staff member was rude to my family', '2026-01-16 16:00:00', '2026-01-17 10:00:00', 'RESOLVED', 'Manager'),
(2, 2, 'FOLLOW_UP', 'When can we pick up the ashes?', '2026-01-24 11:00:00', '2026-01-24 13:00:00', 'RESPONDED', 'Cremation Coordinator'),
(4, 4, 'COMPLAINT', 'The bill is higher than the quote', '2026-02-17 15:00:00', '2026-02-18 09:00:00', 'RESOLVED', 'Finance Manager'),
(5, 5, 'MODIFICATION', 'Need to change the service date', '2026-02-20 10:00:00', '2026-02-20 10:45:00', 'RESPONDED', 'Coordinator'),
(3, 3, 'FOLLOW_UP', 'Thank you for your service', '2026-02-15 09:00:00', '2026-02-15 14:00:00', 'RESOLVED', 'Manager'),
(6, 6, 'INQUIRY', 'What documents do we need to provide?', '2026-03-08 13:00:00', '2026-03-08 14:30:00', 'RESPONDED', 'Administrator'),
(7, 7, 'BOOKING', 'Urgent funeral arrangement needed', '2026-03-15 08:00:00', '2026-03-15 08:20:00', 'RESPONDED', 'Director'),
(9, 9, 'COMPLAINT', 'Staff arrived 20 minutes late', '2026-04-12 14:00:00', '2026-04-12 16:00:00', 'RESOLVED', 'Manager'),
(10, 10, 'INQUIRY', 'What is the cost of repatriation to Italy?', '2026-04-10 10:00:00', '2026-04-10 12:00:00', 'RESPONDED', 'Repatriation Coordinator');

-- ===================================================================
-- STEP 7: Insert EMPLOYEES (31 records)
-- ===================================================================

INSERT INTO employees (first_name, last_name, email, phone, funeral_home_id, position, hire_date, status) VALUES
('Jan', 'Vandervort', 'jan.vandervort@dela.be', '+3234561100', 1, 'Funeral Director', '2018-03-15', 'ACTIVE'),
('Maria', 'De Wilde', 'maria.dewilde@dela.be', '+3234561101', 1, 'Coordinator', '2019-06-01', 'ACTIVE'),
('Paul', 'Hermans', 'paul.hermans@dela.be', '+3234561102', 1, 'Driver', '2020-01-10', 'ACTIVE'),
('Anna', 'Baert', 'anna.baert@dela.be', '+3234561103', 1, 'Administrative', '2021-08-01', 'ACTIVE'),
('Tom', 'Verhoeven', 'tom.verhoeven@dela.be', '+3234561104', 1, 'Cremation Technician', '2019-05-20', 'ACTIVE'),
('Patrick', 'Hermans', 'patrick.hermans@dela.be', '+3250561100', 2, 'Funeral Director', '2017-02-01', 'ACTIVE'),
('Sophie', 'Leclerc', 'sophie.leclerc@dela.be', '+3250561101', 2, 'Coordinator', '2020-09-15', 'ACTIVE'),
('Marc', 'Dubois', 'marc.dubois@dela.be', '+3250561102', 2, 'Driver', '2018-11-01', 'ACTIVE'),
('Katrin', 'Fontaine', 'katrin.fontaine@dela.be', '+3250561103', 2, 'Administrative', '2021-03-01', 'ACTIVE'),
('Dirk', 'Verhoeven', 'dirk.verhoeven@dela.be', '+3216561100', 3, 'Funeral Director', '2016-01-10', 'ACTIVE'),
('Lisa', 'Laurent', 'lisa.laurent@dela.be', '+3216561101', 3, 'Coordinator', '2020-02-01', 'ACTIVE'),
('Peter', 'Arnould', 'peter.arnould@dela.be', '+3216561102', 3, 'Driver', '2019-07-15', 'ACTIVE'),
('Katrin', 'Baert', 'katrin.baert@dela.be', '+3215561100', 4, 'Funeral Director', '2018-05-20', 'ACTIVE'),
('Nathalie', 'Fontaine', 'nathalie.fontaine@dela.be', '+3215561101', 4, 'Coordinator', '2021-01-01', 'ACTIVE'),
('Dirk', 'Gent', 'dirk.gent@dela.be', '+3292561100', 5, 'Funeral Director', '2017-08-01', 'ACTIVE'),
('Christine', 'Moreau', 'christine.moreau@dela.be', '+3292561101', 5, 'Coordinator', '2020-06-15', 'ACTIVE'),
('Francois', 'Arnould', 'francois.arnould@dela.be', '+3243561100', 6, 'Funeral Director', '2016-03-15', 'ACTIVE'),
('Sylvie', 'Dubois', 'sylvie.dubois@dela.be', '+3271561100', 7, 'Funeral Director', '2019-02-01', 'ACTIVE'),
('Christophe', 'Laurent', 'christophe.laurent@dela.be', '+3265561100', 8, 'Funeral Director', '2018-09-01', 'ACTIVE'),
('Isabelle', 'Moreau', 'isabelle.moreau@dela.be', '+3226561100', 9, 'Funeral Director', '2015-01-01', 'ACTIVE'),
('Jean', 'Martin', 'jean.martin@dela.be', '+3226561101', 9, 'Senior Coordinator', '2016-05-10', 'ACTIVE'),
('Sylvie', 'Dupont', 'sylvie.dupont@dela.be', '+3226561102', 9, 'Coordinator', '2019-03-01', 'ACTIVE'),
('Robert', 'Rousseau', 'robert.rousseau@dela.be', '+3226561103', 9, 'Driver', '2018-07-15', 'ACTIVE'),
('Marie', 'Bernard', 'marie.bernard@dela.be', '+3226561104', 9, 'Cremation Manager', '2017-11-01', 'ACTIVE'),
('Nathalie', 'Fontaine2', 'nathalie.fontaine2@dela.be', '+3269561100', 10, 'Funeral Director', '2020-01-15', 'ACTIVE'),
('Pierre', 'Richard', 'pierre.richard@dela.be', '+3234561200', 1, 'Assistant Director', '2020-06-01', 'ACTIVE'),
('Claire', 'Martin', 'claire.martin@dela.be', '+3250561200', 2, 'Assistant', '2021-01-15', 'ACTIVE'),
('David', 'Laurent', 'david.laurent@dela.be', '+3216561200', 3, 'Assistant', '2021-03-01', 'ACTIVE'),
('Emma', 'Bernard', 'emma.bernard@dela.be', '+3215561200', 4, 'Assistant', '2021-05-15', 'ACTIVE'),
('Michel', 'Gaston', 'michel.gaston@dela.be', '+3292561200', 5, 'Driver', '2020-08-01', 'ACTIVE'),
('Yves', 'Petit', 'yves.petit@dela.be', '+3243561200', 6, 'Coordinator', '2020-09-01', 'ACTIVE');

-- ===================================================================
-- STEP 8: Insert EMPLOYEE_FEEDBACK (10 records)
-- ===================================================================

INSERT INTO employee_feedback (employee_id, satisfaction_score, survey_date, comments, feedback_category, survey_type) VALUES
(1, 8, '2026-03-01', 'Enjoy my role, good team support', 'OVERALL', 'quarterly survey'),
(2, 7, '2026-03-05', 'Workload can be heavy during peak times', 'WORKLOAD', 'quarterly survey'),
(3, 9, '2026-03-08', 'Safe working conditions, supportive management', 'SAFETY', 'quarterly survey'),
(4, 8, '2026-03-10', 'Good culture, nice colleagues', 'CULTURE', 'quarterly survey'),
(5, 7, '2026-03-15', 'Would like more training opportunities', 'MANAGEMENT', 'quarterly survey'),
(6, 9, '2026-03-20', 'Very satisfied with current role and team', 'OVERALL', 'quarterly survey'),
(7, 6, '2026-03-25', 'Finding it hard to balance work-life', 'WORKLOAD', 'pulse survey'),
(8, 8, '2026-04-01', 'Good management, clear expectations', 'MANAGEMENT', 'quarterly survey'),
(9, 7, '2026-04-05', 'Decent salary, but career growth unclear', 'CULTURE', 'pulse survey'),
(10, 9, '2026-04-10', 'Excellent team support and training', 'OVERALL', 'quarterly survey');

-- ===================================================================
-- STEP 9: Insert SERVICE_SLAS (4 records)
-- ===================================================================

INSERT INTO service_slas (service_type, expected_days, description) VALUES
('FUNERAL', 1, 'Funeral service should be completed within 1 day of scheduled date'),
('CREMATION', 2, 'Cremation process should complete within 2 days of scheduled date'),
('BURIAL', 3, 'Burial process should complete within 3 days of scheduled date (ground prep + burial)'),
('REPATRIATION', 5, 'Repatriation should arrive at destination within 5 days of request');

-- ===================================================================
-- STEP 10: Insert CASE_PROCESSING (28 records)
-- ===================================================================

INSERT INTO case_processing (case_type, funeral_id, repatriation_id, claim_id, case_opened_date, case_closed_date, status) VALUES
-- Funeral cases (15)
('FUNERAL', 1, NULL, NULL, '2026-01-10', '2026-01-15', 'CLOSED'),
('FUNERAL', 2, NULL, NULL, '2026-01-18', '2026-01-23', 'CLOSED'),
('FUNERAL', 3, NULL, NULL, '2026-02-05', '2026-02-10', 'CLOSED'),
('FUNERAL', 4, NULL, NULL, '2026-02-12', '2026-02-16', 'CLOSED'),
('FUNERAL', 5, NULL, NULL, '2026-02-20', '2026-02-26', 'CLOSED'),
('FUNERAL', 6, NULL, NULL, '2026-03-08', '2026-03-12', 'CLOSED'),
('FUNERAL', 7, NULL, NULL, '2026-03-15', '2026-03-20', 'CLOSED'),
('FUNERAL', 8, NULL, NULL, '2026-03-22', '2026-03-28', 'CLOSED'),
('FUNERAL', 9, NULL, NULL, '2026-04-05', '2026-04-10', 'CLOSED'),
('FUNERAL', 10, NULL, NULL, '2026-04-12', '2026-04-16', 'CLOSED'),
('FUNERAL', 11, NULL, NULL, '2026-04-20', '2026-04-25', 'CLOSED'),
('FUNERAL', 12, NULL, NULL, '2026-05-03', '2026-05-08', 'CLOSED'),
('FUNERAL', 13, NULL, NULL, '2026-05-10', '2026-05-15', 'CLOSED'),
('FUNERAL', 14, NULL, NULL, '2026-05-18', '2026-05-22', 'CLOSED'),
('FUNERAL', 15, NULL, NULL, '2026-06-02', '2026-06-06', 'CLOSED'),
-- Repatriation cases (3)
('REPATRIATION', NULL, 1, NULL, '2026-02-05', '2026-02-16', 'CLOSED'),
('REPATRIATION', NULL, 2, NULL, '2026-04-05', '2026-04-13', 'IN_PROGRESS'),
('REPATRIATION', NULL, 3, NULL, '2026-05-10', NULL, 'OPEN'),
-- Claim cases (10)
('CLAIM', NULL, NULL, 1, '2026-01-16', '2026-01-20', 'CLOSED'),
('CLAIM', NULL, NULL, 2, '2026-01-23', '2026-01-27', 'CLOSED'),
('CLAIM', NULL, NULL, 3, '2026-02-11', '2026-02-15', 'CLOSED'),
('CLAIM', NULL, NULL, 4, '2026-02-17', '2026-02-21', 'CLOSED'),
('CLAIM', NULL, NULL, 5, '2026-02-26', '2026-03-02', 'CLOSED'),
('CLAIM', NULL, NULL, 6, '2026-03-13', '2026-03-17', 'CLOSED'),
('CLAIM', NULL, NULL, 7, '2026-03-21', NULL, 'IN_PROGRESS'),
('CLAIM', NULL, NULL, 8, '2026-03-29', NULL, 'OPEN'),
('CLAIM', NULL, NULL, 9, '2026-04-11', NULL, 'IN_PROGRESS'),
('CLAIM', NULL, NULL, 10, '2026-04-17', NULL, 'OPEN');

-- ===================================================================
-- STEP 11: Insert TRAINING_PROGRAMS (5 records)
-- ===================================================================

INSERT INTO training_programs (training_name, category, required, duration_hours, description) VALUES
('Health & Safety at Work', 'SAFETY', TRUE, 4, 'Mandatory annual safety training'),
('Customer Service Excellence', 'CUSTOMER_SERVICE', TRUE, 3, 'How to handle family needs with compassion'),
('Cremation Operating Procedures', 'TECHNICAL', TRUE, 8, 'Operating crematorium equipment safely'),
('Compliance & Data Protection', 'COMPLIANCE', TRUE, 2, 'GDPR and funeral industry compliance'),
('Leadership Skills', 'LEADERSHIP', FALSE, 6, 'Optional training for managers');

-- ===================================================================
-- STEP 12: Insert EMPLOYEE_TRAINING (30 employees × 3 trainings = 90 records)
-- ===================================================================

INSERT INTO employee_training (employee_id, training_id, enrollment_date, completion_date, status, score, instructor_name) VALUES
-- Employee 1 - Jan Vandervort
(1, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 95, 'Safety Officer'),
(1, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 88, 'Training Manager'),
(1, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 92, 'Compliance Officer'),
-- Employee 2 - Maria De Wilde
(2, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 87, 'Safety Officer'),
(2, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 91, 'Training Manager'),
(2, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 85, 'Compliance Officer'),
-- Employee 3 - Paul Hermans
(3, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 90, 'Safety Officer'),
(3, 2, '2026-01-20', NULL, 'IN_PROGRESS', NULL, 'Training Manager'),
(3, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 88, 'Compliance Officer'),
-- Employee 4 - Anna Baert
(4, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 93, 'Safety Officer'),
(4, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 89, 'Training Manager'),
(4, 4, '2026-02-01', NULL, 'PENDING', NULL, NULL),
-- Employee 5 - Tom Verhoeven (Cremation Tech - needs technical training)
(5, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 91, 'Safety Officer'),
(5, 3, '2026-02-15', '2026-02-15', 'COMPLETED', 96, 'Cremation Supervisor'),
(5, 4, '2026-03-01', '2026-03-01', 'COMPLETED', 94, 'Compliance Officer'),
-- Employee 6 - Patrick Hermans
(6, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 88, 'Safety Officer'),
(6, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 86, 'Training Manager'),
(6, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 90, 'Compliance Officer'),
-- Employee 7 - Sophie Leclerc
(7, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 92, 'Safety Officer'),
(7, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 89, 'Training Manager'),
(7, 4, '2026-02-01', NULL, 'PENDING', NULL, NULL),
-- Employee 8 - Marc Dubois
(8, 1, '2026-01-15', NULL, 'IN_PROGRESS', NULL, 'Safety Officer'),
(8, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 85, 'Training Manager'),
(8, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 87, 'Compliance Officer'),
-- Employee 9 - Katrin Fontaine
(9, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 89, 'Safety Officer'),
(9, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 91, 'Training Manager'),
(9, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 88, 'Compliance Officer'),
-- Employee 10 - Dirk Verhoeven
(10, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 94, 'Safety Officer'),
(10, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 92, 'Training Manager'),
(10, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 95, 'Compliance Officer'),
-- Remaining employees - bulk insert with repetitive pattern
(11, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 87, 'Safety Officer'),
(11, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 85, 'Training Manager'),
(11, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 89, 'Compliance Officer'),
(12, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 91, 'Safety Officer'),
(12, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 88, 'Training Manager'),
(12, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 90, 'Compliance Officer'),
(13, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 89, 'Safety Officer'),
(13, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 87, 'Training Manager'),
(13, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 86, 'Compliance Officer'),
(14, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 90, 'Safety Officer'),
(14, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 89, 'Training Manager'),
(14, 4, '2026-02-01', NULL, 'PENDING', NULL, NULL),
(15, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 92, 'Safety Officer'),
(15, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 90, 'Training Manager'),
(15, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 91, 'Compliance Officer'),
(16, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 88, 'Safety Officer'),
(16, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 86, 'Training Manager'),
(16, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 87, 'Compliance Officer'),
(17, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 91, 'Safety Officer'),
(17, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 89, 'Training Manager'),
(17, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 92, 'Compliance Officer'),
(18, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 87, 'Safety Officer'),
(18, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 85, 'Training Manager'),
(18, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 88, 'Compliance Officer'),
(19, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 93, 'Safety Officer'),
(19, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 91, 'Training Manager'),
(19, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 94, 'Compliance Officer'),
(20, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 89, 'Safety Officer'),
(20, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 87, 'Training Manager'),
(20, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 90, 'Compliance Officer'),
(21, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 90, 'Safety Officer'),
(21, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 88, 'Training Manager'),
(21, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 91, 'Compliance Officer'),
(22, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 86, 'Safety Officer'),
(22, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 84, 'Training Manager'),
(22, 4, '2026-02-01', NULL, 'PENDING', NULL, NULL),
(23, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 92, 'Safety Officer'),
(23, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 90, 'Training Manager'),
(23, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 93, 'Compliance Officer'),
(24, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 88, 'Safety Officer'),
(24, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 86, 'Training Manager'),
(24, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 89, 'Compliance Officer'),
(25, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 91, 'Safety Officer'),
(25, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 89, 'Training Manager'),
(25, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 92, 'Compliance Officer'),
(26, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 87, 'Safety Officer'),
(26, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 85, 'Training Manager'),
(26, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 88, 'Compliance Officer'),
(27, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 90, 'Safety Officer'),
(27, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 88, 'Training Manager'),
(27, 4, '2026-02-01', NULL, 'PENDING', NULL, NULL),
(28, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 89, 'Safety Officer'),
(28, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 87, 'Training Manager'),
(28, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 90, 'Compliance Officer'),
(29, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 92, 'Safety Officer'),
(29, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 90, 'Training Manager'),
(29, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 93, 'Compliance Officer'),
(30, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 88, 'Safety Officer'),
(30, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 86, 'Training Manager'),
(30, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 89, 'Compliance Officer'),
(31, 1, '2026-01-15', '2026-01-15', 'COMPLETED', 91, 'Safety Officer'),
(31, 2, '2026-01-20', '2026-01-20', 'COMPLETED', 89, 'Training Manager'),
(31, 4, '2026-02-01', '2026-02-01', 'COMPLETED', 92, 'Compliance Officer');

-- ===================================================================
-- FINAL VERIFICATION: Show all new tables and record counts
-- ===================================================================

SELECT 'Complaints' as table_name, COUNT(*) as row_count FROM complaints
UNION ALL
SELECT 'Service Issues', COUNT(*) FROM service_issues
UNION ALL
SELECT 'Customer Feedback', COUNT(*) FROM customer_feedback
UNION ALL
SELECT 'Family Feedback', COUNT(*) FROM family_feedback
UNION ALL
SELECT 'Customer Requests', COUNT(*) FROM customer_requests
UNION ALL
SELECT 'Employees', COUNT(*) FROM employees
UNION ALL
SELECT 'Employee Feedback', COUNT(*) FROM employee_feedback
UNION ALL
SELECT 'Service SLAs', COUNT(*) FROM service_slas
UNION ALL
SELECT 'Case Processing', COUNT(*) FROM case_processing
UNION ALL
SELECT 'Training Programs', COUNT(*) FROM training_programs
UNION ALL
SELECT 'Employee Training', COUNT(*) FROM employee_training;

-- ===================================================================
-- SUCCESS! All data inserted.
-- ===================================================================