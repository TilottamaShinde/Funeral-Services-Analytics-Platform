-- ===================================================================
-- DELA TABLEAU KPI TABLES - COMPLETE SCRIPT
-- Add 11 new tables to support 22 KPIs across 5 categories
-- ===================================================================

USE dela_services;

-- ===================================================================
-- PHASE 1: Quick Wins (2-3 hours) — Add 5 columns + 2 tables
-- ===================================================================

-- Step 1: Add columns to existing tables
-- These capture booking dates and SLA targets
/*ALTER TABLE funerals 
ADD COLUMN booking_date DATE COMMENT 'When customer booked the funeral',
ADD COLUMN expected_completion_date DATE COMMENT 'SLA target completion date',
ADD INDEX idx_booking_date (booking_date);

ALTER TABLE cremations 
ADD COLUMN expected_completion_date DATE COMMENT 'SLA target for cremation completion',
ADD INDEX idx_expected_completion (expected_completion_date);

ALTER TABLE burials 
ADD COLUMN expected_completion_date DATE COMMENT 'SLA target for burial completion',
ADD INDEX idx_expected_completion (expected_completion_date);

ALTER TABLE repatriations 
ADD COLUMN request_date DATE COMMENT 'When repatriation was requested',
ADD COLUMN expected_arrival_date DATE COMMENT 'SLA target arrival date',
ADD INDEX idx_request_date (request_date);
*/
-- ===================================================================
-- PHASE 1 TABLE 1: COMPLAINTS
-- Tracks service complaints for KPI: Complaint Rate, Service Issues
-- ===================================================================
CREATE TABLE complaints (
  complaint_id INT PRIMARY KEY AUTO_INCREMENT,
  funeral_id INT NOT NULL,
  customer_id INT NOT NULL,
  complaint_type VARCHAR(100) COMMENT 'e.g., staff behavior, delayed service, cost issue',
  description TEXT,
  severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
  complaint_date DATE NOT NULL,
  resolved_date DATE COMMENT 'NULL if not resolved',
  status ENUM('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') DEFAULT 'OPEN',
  resolution_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_funeral_id (funeral_id),
  INDEX idx_complaint_date (complaint_date),
  INDEX idx_status (status),
  INDEX idx_severity (severity)
);

-- ===================================================================
-- PHASE 1 TABLE 2: SERVICE_ISSUES
-- Tracks operational issues during funerals (cremations, burials, etc.)
-- ===================================================================
CREATE TABLE service_issues (
  issue_id INT PRIMARY KEY AUTO_INCREMENT,
  funeral_id INT NOT NULL,
  cremation_id INT COMMENT 'If issue is cremation-specific',
  burial_id INT COMMENT 'If issue is burial-specific',
  issue_type VARCHAR(100) COMMENT 'e.g., staff absence, venue problem, equipment failure',
  description TEXT,
  severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
  reported_date TIMESTAMP,
  resolved_date TIMESTAMP COMMENT 'NULL if unresolved',
  status ENUM('REPORTED', 'IN_PROGRESS', 'RESOLVED') DEFAULT 'REPORTED',
  impact_on_service VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  FOREIGN KEY (cremation_id) REFERENCES cremations(cremation_id),
  FOREIGN KEY (burial_id) REFERENCES burials(burial_id),
  INDEX idx_funeral_id (funeral_id),
  INDEX idx_severity (severity),
  INDEX idx_reported_date (reported_date)
);

-- ===================================================================
-- PHASE 2: Customer & Employee Feedback (3-4 hours) — 4 tables
-- ===================================================================

-- ===================================================================
-- PHASE 2 TABLE 3: CUSTOMER_FEEDBACK
-- Tracks customer satisfaction scores and feedback
-- ===================================================================
CREATE TABLE customer_feedback (
  feedback_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  funeral_id INT COMMENT 'Which funeral is this feedback about',
  satisfaction_score INT CHECK (satisfaction_score >= 1 AND satisfaction_score <= 10) COMMENT '1-10 scale',
  feedback_text TEXT COMMENT 'Open-ended comments',
  feedback_category ENUM('SATISFACTION', 'SERVICE_QUALITY', 'OVERALL', 'STAFF', 'COST') DEFAULT 'OVERALL',
  feedback_date DATE NOT NULL,
  survey_type VARCHAR(100) COMMENT 'e.g., post-funeral, post-cremation, phone survey',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  INDEX idx_customer_id (customer_id),
  INDEX idx_feedback_date (feedback_date),
  INDEX idx_satisfaction_score (satisfaction_score)
);

-- ===================================================================
-- PHASE 2 TABLE 4: FAMILY_FEEDBACK
-- Tracks family member satisfaction (separate from customer who booked)
-- ===================================================================
CREATE TABLE family_feedback (
  family_feedback_id INT PRIMARY KEY AUTO_INCREMENT,
  funeral_id INT NOT NULL,
  family_member_name VARCHAR(150),
  relationship_to_deceased VARCHAR(100) COMMENT 'spouse, child, sibling, etc.',
  satisfaction_score INT CHECK (satisfaction_score >= 1 AND satisfaction_score <= 10) COMMENT '1-10 scale',
  comment TEXT,
  feedback_date DATE NOT NULL,
  contact_phone VARCHAR(20),
  email VARCHAR(150),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  INDEX idx_funeral_id (funeral_id),
  INDEX idx_feedback_date (feedback_date),
  INDEX idx_satisfaction_score (satisfaction_score)
);

-- ===================================================================
-- PHASE 2 TABLE 5: CUSTOMER_REQUESTS
-- Tracks customer inquiries and response time (for KPI: Response Time)
-- ===================================================================
CREATE TABLE customer_requests (
  request_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  funeral_id INT COMMENT 'Which funeral is this request about (if any)',
  request_type ENUM('INQUIRY', 'BOOKING', 'COMPLAINT', 'MODIFICATION', 'FOLLOW_UP', 'OTHER') DEFAULT 'INQUIRY',
  description TEXT,
  request_date TIMESTAMP NOT NULL COMMENT 'When customer made request',
  response_date TIMESTAMP COMMENT 'When staff responded',
  response_time_hours INT GENERATED ALWAYS AS (
    TIMESTAMPDIFF(HOUR, request_date, response_date)
  ) STORED COMMENT 'Auto-calculated hours to respond',
  status ENUM('PENDING', 'RESPONDED', 'RESOLVED') DEFAULT 'PENDING',
  responder_name VARCHAR(150),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  INDEX idx_request_date (request_date),
  INDEX idx_response_time_hours (response_time_hours),
  INDEX idx_status (status)
);

-- ===================================================================
-- PHASE 2 TABLE 6: EMPLOYEES
-- Staff directory — needed for employee KPIs
-- ===================================================================
CREATE TABLE employees (
  employee_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(20),
  funeral_home_id INT NOT NULL,
  position VARCHAR(100) COMMENT 'e.g., Funeral Director, Coordinator, Driver',
  hire_date DATE NOT NULL,
  termination_date DATE COMMENT 'NULL if still employed',
  termination_reason VARCHAR(255) COMMENT 'e.g., resignation, retirement, end of contract',
  status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_home_id) REFERENCES funeral_homes(funeral_home_id),
  INDEX idx_funeral_home_id (funeral_home_id),
  INDEX idx_hire_date (hire_date),
  INDEX idx_status (status)
);

-- ===================================================================
-- PHASE 2 TABLE 7: EMPLOYEE_FEEDBACK
-- Employee satisfaction surveys (for KPI: Employee Satisfaction)
-- ===================================================================
CREATE TABLE employee_feedback (
  feedback_id INT PRIMARY KEY AUTO_INCREMENT,
  employee_id INT NOT NULL,
  satisfaction_score INT CHECK (satisfaction_score >= 1 AND satisfaction_score <= 10) COMMENT '1-10 scale',
  survey_date DATE NOT NULL,
  comments TEXT,
  feedback_category ENUM('MANAGEMENT', 'WORKLOAD', 'SAFETY', 'CULTURE', 'OVERALL') DEFAULT 'OVERALL',
  survey_type VARCHAR(100) COMMENT 'e.g., quarterly survey, pulse survey, exit interview',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  INDEX idx_employee_id (employee_id),
  INDEX idx_survey_date (survey_date),
  INDEX idx_satisfaction_score (satisfaction_score)
);

-- ===================================================================
-- PHASE 3: Advanced Tracking (2-3 hours) — 3 tables
-- ===================================================================

-- ===================================================================
-- PHASE 3 TABLE 8: SERVICE_SLAS
-- Master table defining SLA targets (expected completion days)
-- ===================================================================
CREATE TABLE service_slas (
  sla_id INT PRIMARY KEY AUTO_INCREMENT,
  service_type ENUM('FUNERAL', 'CREMATION', 'BURIAL', 'REPATRIATION') UNIQUE NOT NULL,
  expected_days INT COMMENT 'Target days from scheduled to completion',
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ===================================================================
-- PHASE 3 TABLE 9: CASE_PROCESSING
-- Unified view of case lifecycle (funeral, repatriation, claim)
-- ===================================================================
CREATE TABLE case_processing (
  case_id INT PRIMARY KEY AUTO_INCREMENT,
  case_type ENUM('FUNERAL', 'REPATRIATION', 'CLAIM') NOT NULL,
  funeral_id INT COMMENT 'If case_type = FUNERAL',
  repatriation_id INT COMMENT 'If case_type = REPATRIATION',
  claim_id INT COMMENT 'If case_type = CLAIM',
  case_opened_date DATE NOT NULL COMMENT 'When customer first inquired',
  case_closed_date DATE COMMENT 'When case completed/resolved',
  processing_days INT GENERATED ALWAYS AS (
    DATEDIFF(case_closed_date, case_opened_date)
  ) STORED COMMENT 'Auto-calculated days to process',
  status ENUM('OPEN', 'IN_PROGRESS', 'CLOSED') DEFAULT 'OPEN',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  FOREIGN KEY (repatriation_id) REFERENCES repatriations(repatriation_id),
  FOREIGN KEY (claim_id) REFERENCES insurance_claims(claim_id),
  INDEX idx_case_opened_date (case_opened_date),
  INDEX idx_processing_days (processing_days),
  INDEX idx_status (status)
);

-- ===================================================================
-- PHASE 3 TABLE 10: TRAINING_PROGRAMS
-- Master list of training courses available
-- ===================================================================
CREATE TABLE training_programs (
  training_id INT PRIMARY KEY AUTO_INCREMENT,
  training_name VARCHAR(150) NOT NULL,
  category ENUM('SAFETY', 'CUSTOMER_SERVICE', 'TECHNICAL', 'COMPLIANCE', 'LEADERSHIP') DEFAULT 'TECHNICAL',
  required BOOLEAN DEFAULT FALSE COMMENT 'Is this training mandatory?',
  duration_hours INT COMMENT 'How many hours does training take',
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_required (required)
);

-- ===================================================================
-- PHASE 3 TABLE 11: EMPLOYEE_TRAINING
-- Tracks which employees completed which trainings
-- ===================================================================
CREATE TABLE employee_training (
  enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
  employee_id INT NOT NULL,
  training_id INT NOT NULL,
  enrollment_date DATE NOT NULL COMMENT 'When employee enrolled',
  completion_date DATE COMMENT 'When employee completed (NULL if pending)',
  status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
  score INT COMMENT 'If graded (NULL if not graded)',
  instructor_name VARCHAR(150),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  FOREIGN KEY (training_id) REFERENCES training_programs(training_id),
  INDEX idx_employee_id (employee_id),
  INDEX idx_completion_date (completion_date),
  INDEX idx_status (status),
  UNIQUE KEY unique_enrollment (employee_id, training_id, enrollment_date)
);

-- ===================================================================
-- VERIFY ALL NEW TABLES CREATED
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

SHOW TABLES;