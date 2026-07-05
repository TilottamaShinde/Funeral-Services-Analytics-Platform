-- ===================================================================
-- DELA FUNERAL SERVICES DATABASE - Practice Project
-- ===================================================================
-- This is a realistic funeral services database modeled on DELA.
-- Tables include: funeral homes, insurance policies, funerals, 
-- cremations, repatriations, claims, and customers.
-- ===================================================================

-- Drop existing database if it exists (for clean restart)
DROP DATABASE IF EXISTS dela_services;
CREATE DATABASE dela_services;
USE dela_services;

-- ===================================================================
-- 1. CUSTOMERS TABLE
-- ===================================================================
CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(20),
  country_of_origin VARCHAR(100),
  date_of_birth DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_last_name (last_name),
  INDEX idx_created_at (created_at)
);

-- ===================================================================
-- 2. FUNERAL HOMES TABLE (130 locations across Belgium)
-- ===================================================================
CREATE TABLE funeral_homes (
  funeral_home_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  city VARCHAR(100) NOT NULL,
  region VARCHAR(100),
  address VARCHAR(255),
  postal_code VARCHAR(10),
  phone VARCHAR(20),
  manager_name VARCHAR(100),
  staff_count INT,
  capacity_per_day INT,  -- max funerals this home can handle per day
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_city (city),
  INDEX idx_region (region)
);

-- ===================================================================
-- 3. INSURANCE POLICIES TABLE
-- ===================================================================
CREATE TABLE insurance_policies (
  policy_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  policy_number VARCHAR(50) UNIQUE NOT NULL,
  policy_type ENUM('FUNERAL', 'REPATRIATION', 'COMBINED', 'SAVINGS') NOT NULL,
  coverage_amount DECIMAL(10, 2),
  annual_premium DECIMAL(10, 2),
  active BOOLEAN DEFAULT TRUE,
  started_at DATE,
  ended_at DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_customer_id (customer_id),
  INDEX idx_active (active)
);

-- ===================================================================
-- 4. FUNERALS TABLE (core business process)
-- ===================================================================
CREATE TABLE funerals (
  funeral_id INT PRIMARY KEY AUTO_INCREMENT,
  policy_id INT,
  customer_id INT NOT NULL,
  deceased_name VARCHAR(150) NOT NULL,
  date_of_death DATE NOT NULL,
  funeral_date DATE,
  funeral_home_id INT NOT NULL,
  service_type ENUM('TRADITIONAL', 'CREMATION', 'BURIAL', 'NATURAL_BURIAL') NOT NULL,
  cost DECIMAL(10, 2),
  status ENUM('PENDING', 'SCHEDULED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
  attended_staff_count INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(policy_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (funeral_home_id) REFERENCES funeral_homes(funeral_home_id),
  INDEX idx_funeral_date (funeral_date),
  INDEX idx_funeral_home_id (funeral_home_id),
  INDEX idx_status (status),
  INDEX idx_customer_id (customer_id)
);

-- ===================================================================
-- 5. CREMATIONS TABLE (one-to-one with funerals, some funerals have cremations)
-- ===================================================================
CREATE TABLE cremations (
  cremation_id INT PRIMARY KEY AUTO_INCREMENT,
  funeral_id INT NOT NULL,
  crematorium_location ENUM('BRUGES', 'BRUSSELS', 'ANTWERP') NOT NULL,
  scheduled_date DATE,
  completed_date DATE,
  ashes_collected BOOLEAN DEFAULT FALSE,
  cremation_cost DECIMAL(10, 2),
  status ENUM('PENDING', 'SCHEDULED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  INDEX idx_funeral_id (funeral_id),
  INDEX idx_completed_date (completed_date)
);

-- ===================================================================
-- 5B. BURIALS TABLE (one-to-one with funerals, some funerals have burials)
-- ===================================================================
CREATE TABLE burials (
  burial_id INT PRIMARY KEY AUTO_INCREMENT,
  funeral_id INT NOT NULL,
  cemetery_name VARCHAR(150) NOT NULL,
  cemetery_location VARCHAR(100),
  plot_number VARCHAR(50),
  ground_preparation_date DATE,
  scheduled_date DATE,
  completed_date DATE,
  headstone_ordered BOOLEAN DEFAULT FALSE,
  burial_cost DECIMAL(10, 2),
  status ENUM('PENDING', 'SCHEDULED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  INDEX idx_funeral_id (funeral_id),
  INDEX idx_completed_date (completed_date),
  INDEX idx_cemetery_name (cemetery_name)
);

-- ===================================================================
-- 6. REPATRIATIONS TABLE (deceased flown home to another country)
-- ===================================================================
CREATE TABLE repatriations (
  repatriation_id INT PRIMARY KEY AUTO_INCREMENT,
  funeral_id INT,
  customer_id INT NOT NULL,
  deceased_name VARCHAR(150) NOT NULL,
  date_of_death DATE NOT NULL,
  origin_country VARCHAR(100),
  destination_country VARCHAR(100) NOT NULL,
  departure_date DATE,
  arrival_date DATE,
  repatriation_cost DECIMAL(10, 2),
  status ENUM('PENDING', 'IN_TRANSIT', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
  airline VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_customer_id (customer_id),
  INDEX idx_destination_country (destination_country),
  INDEX idx_arrival_date (arrival_date)
);

-- ===================================================================
-- 7. INSURANCE CLAIMS TABLE (payout requests)
-- ===================================================================
CREATE TABLE insurance_claims (
  claim_id INT PRIMARY KEY AUTO_INCREMENT,
  policy_id INT NOT NULL,
  funeral_id INT,
  customer_id INT NOT NULL,
  claim_amount DECIMAL(10, 2),
  claimed_at DATE,
  approved_amount DECIMAL(10, 2),
  approved_at DATE,
  paid_at DATE,
  status ENUM('SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'PAID', 'REJECTED') DEFAULT 'SUBMITTED',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(policy_id),
  FOREIGN KEY (funeral_id) REFERENCES funerals(funeral_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_customer_id (customer_id),
  INDEX idx_status (status),
  INDEX idx_claimed_at (claimed_at)
);

-- ===================================================================
-- INSERT SAMPLE DATA
-- ===================================================================

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, country_of_origin, date_of_birth) VALUES
('Jean', 'Dupont', 'jean.dupont@email.com', '+32123456789', 'Belgium', '1950-05-12'),
('Marie', 'Martin', 'marie.martin@email.com', '+32987654321', 'France', '1955-08-20'),
('Anna', 'Schmidt', 'anna.schmidt@email.com', '+32456789012', 'Germany', '1948-03-15'),
('Carlos', 'Garcia', 'carlos.garcia@email.com', '+32789012345', 'Spain', '1952-11-08'),
('Sophie', 'Leclerc', 'sophie.leclerc@email.com', '+32234567890', 'Belgium', '1960-07-25'),
('Marco', 'Rossi', 'marco.rossi@email.com', '+32567890123', 'Italy', '1945-02-18'),
('Elena', 'Petrov', 'elena.petrov@email.com', '+32890123456', 'Poland', '1958-09-30'),
('Thomas', 'Mueller', 'thomas.mueller@email.com', '+32345678901', 'Germany', '1955-04-12'),
('Lisa', 'Weber', 'lisa.weber@email.com', '+32678901234', 'Austria', '1962-12-05'),
('Antonio', 'Ferrara', 'antonio.ferrara@email.com', '+32012345678', 'Italy', '1950-06-20');

-- Insert funeral homes (realistic Belgian locations)
INSERT INTO funeral_homes (name, city, region, address, postal_code, phone, manager_name, staff_count, capacity_per_day) VALUES
('DELA Antwerpen Centrum', 'Antwerp', 'Flanders', 'Noorderplaats 5 b2', '2000', '+3234561000', 'Jan Vandervort', 15, 3),
('DELA Brugge', 'Bruges', 'Flanders', 'Steenstraat 45', '8000', '+3250561001', 'Maria De Wilde', 12, 2),
('DELA Leuven', 'Leuven', 'Flanders', 'Martelarenplein 8', '3000', '+3216561002', 'Patrick Hermans', 10, 2),
('DELA Mechelen', 'Mechelen', 'Flanders', 'Veemarkt 12', '2800', '+3215561003', 'Katrin Baert', 11, 2),
('DELA Gent', 'Ghent', 'Flanders', 'Sint-Veerleplein 5', '9000', '+3292561004', 'Dirk Verhoeven', 13, 2),
('DELA Liège', 'Liège', 'Wallonia', 'Boulevard de la Sauvenière 42', '4000', '+3243561005', 'François Arnould', 10, 2),
('DELA Charleroi', 'Charleroi', 'Wallonia', 'Rue de Lodelinsart 67', '6000', '+3271561006', 'Sylvie Dubois', 9, 2),
('DELA Mons', 'Mons', 'Wallonia', 'Grand Place 15', '7000', '+3265561007', 'Christophe Laurent', 8, 1),
('DELA Brussels', 'Brussels', 'Brussels', 'Avenue Louise 123', '1050', '+3226561008', 'Isabelle Moreau', 18, 4),
('DELA Tournai', 'Tournai', 'Wallonia', 'Place de l''Évêché 3', '7500', '+3269561009', 'Nathalie Fontaine', 7, 1);

-- Insert insurance policies
INSERT INTO insurance_policies (customer_id, policy_number, policy_type, coverage_amount, annual_premium, started_at) VALUES
(1, 'POL-2020-001', 'FUNERAL', 5000.00, 120.00, '2020-01-15'),
(2, 'POL-2019-002', 'COMBINED', 8000.00, 200.00, '2019-06-20'),
(3, 'POL-2021-003', 'REPATRIATION', 3000.00, 80.00, '2021-03-10'),
(4, 'POL-2018-004', 'FUNERAL', 5500.00, 130.00, '2018-11-01'),
(5, 'POL-2022-005', 'SAVINGS', 10000.00, 250.00, '2022-01-05'),
(6, 'POL-2020-006', 'FUNERAL', 5000.00, 120.00, '2020-05-12'),
(7, 'POL-2021-007', 'COMBINED', 7500.00, 180.00, '2021-08-22'),
(8, 'POL-2019-008', 'FUNERAL', 4500.00, 110.00, '2019-02-14'),
(9, 'POL-2022-009', 'REPATRIATION', 3500.00, 90.00, '2022-07-18'),
(10, 'POL-2020-010', 'FUNERAL', 5000.00, 120.00, '2020-09-03');

-- Insert funerals (Q1-Q2 2026)
INSERT INTO funerals (policy_id, customer_id, deceased_name, date_of_death, funeral_date, funeral_home_id, service_type, cost, status, attended_staff_count) VALUES
(1, 1, 'Henri Dupont', '2026-01-10', '2026-01-15', 1, 'TRADITIONAL', 3500.00, 'COMPLETED', 4),
(2, 2, 'Louise Martin', '2026-01-18', '2026-01-22', 9, 'CREMATION', 2800.00, 'COMPLETED', 3),
(3, 3, 'Klaus Schmidt', '2026-02-05', '2026-02-10', 2, 'BURIAL', 4000.00, 'COMPLETED', 5),
(4, 4, 'Rosa Garcia', '2026-02-12', '2026-02-16', 5, 'TRADITIONAL', 3800.00, 'COMPLETED', 4),
(5, 5, 'Pierre Leclerc', '2026-02-20', '2026-02-25', 9, 'CREMATION', 2900.00, 'COMPLETED', 3),
(6, 6, 'Giovanni Rossi', '2026-03-08', '2026-03-12', 1, 'TRADITIONAL', 3600.00, 'COMPLETED', 4),
(7, 7, 'Ewa Petrov', '2026-03-15', '2026-03-20', 4, 'CREMATION', 2750.00, 'SCHEDULED', 0),
(8, 8, 'Wolfgang Mueller', '2026-03-22', '2026-03-28', 3, 'BURIAL', 4100.00, 'PENDING', 0),
(9, 9, 'Ingrid Weber', '2026-04-05', '2026-04-10', 6, 'TRADITIONAL', 3500.00, 'SCHEDULED', 0),
(10, 10, 'Vittorio Ferrara', '2026-04-12', '2026-04-16', 7, 'CREMATION', 2850.00, 'PENDING', 0),
(1, 1, 'Marie Dupont', '2026-04-20', '2026-04-25', 9, 'TRADITIONAL', 3700.00, 'PENDING', 0),
(2, 2, 'Jean Martin', '2026-05-03', '2026-05-08', 2, 'CREMATION', 2800.00, 'PENDING', 0),
(3, 3, 'Erich Schmidt', '2026-05-10', '2026-05-15', 1, 'BURIAL', 4200.00, 'PENDING', 0),
(4, 4, 'Miguel Garcia', '2026-05-18', '2026-05-22', 5, 'TRADITIONAL', 3600.00, 'PENDING', 0),
(5, 5, 'Suzette Leclerc', '2026-06-02', '2026-06-06', 10, 'CREMATION', 2950.00, 'PENDING', 0);

-- Insert cremations (for cremation-type funerals)
INSERT INTO cremations (funeral_id, crematorium_location, scheduled_date, completed_date, ashes_collected, cremation_cost, status) VALUES
(2, 'BRUSSELS', '2026-01-23', '2026-01-23', TRUE, 800.00, 'COMPLETED'),
(5, 'BRUGES', '2026-02-26', '2026-02-26', TRUE, 800.00, 'COMPLETED'),
(7, 'ANTWERP', '2026-03-21', NULL, FALSE, 800.00, 'SCHEDULED'),
(10, 'BRUSSELS', '2026-04-17', NULL, FALSE, 800.00, 'PENDING'),
(12, 'BRUGES', '2026-05-09', NULL, FALSE, 800.00, 'PENDING'),
(15, 'BRUSSELS', '2026-06-07', NULL, FALSE, 800.00, 'PENDING');

-- Insert burials (for burial-type funerals)
INSERT INTO burials (funeral_id, cemetery_name, cemetery_location, plot_number, ground_preparation_date, scheduled_date, completed_date, headstone_ordered, burial_cost, status) VALUES
(3, 'Schoonselhof Cemetery', 'Antwerp', 'PLOT-2847', '2026-02-08', '2026-02-10', '2026-02-10', FALSE, 1200.00, 'COMPLETED'),
(8, 'Laeken Cemetery', 'Brussels', 'PLOT-5521', '2026-03-24', '2026-03-28', NULL, FALSE, 1200.00, 'SCHEDULED'),
(11, 'Sint-Goriks Cemetery', 'Bruges', 'PLOT-1122', '2026-04-20', '2026-04-25', NULL, FALSE, 1200.00, 'PENDING'),
(13, 'Evergreen Cemetery', 'Leuven', 'PLOT-3344', '2026-05-12', '2026-05-15', NULL, TRUE, 1200.00, 'PENDING'),
(14, 'Schoonselhof Cemetery', 'Antwerp', 'PLOT-2848', '2026-05-17', '2026-05-22', NULL, FALSE, 1200.00, 'PENDING');

-- Insert repatriations
INSERT INTO repatriations (funeral_id, customer_id, deceased_name, date_of_death, origin_country, destination_country, departure_date, arrival_date, repatriation_cost, status, airline) VALUES
(3, 3, 'Klaus Schmidt', '2026-02-05', 'Belgium', 'Germany', '2026-02-15', '2026-02-16', 2500.00, 'COMPLETED', 'Lufthansa'),
(9, 9, 'Ingrid Weber', '2026-04-05', 'Belgium', 'Austria', '2026-04-12', NULL, 2300.00, 'IN_TRANSIT', 'Austrian Airlines'),
(13, 3, 'Erich Schmidt', '2026-05-10', 'Belgium', 'Germany', '2026-05-18', NULL, 2500.00, 'PENDING', 'Lufthansa');

-- Insert insurance claims
INSERT INTO insurance_claims (policy_id, funeral_id, customer_id, claim_amount, claimed_at, approved_amount, approved_at, paid_at, status, notes) VALUES
(1, 1, 1, 3500.00, '2026-01-16', 3500.00, '2026-01-18', '2026-01-20', 'PAID', 'Approved without issues'),
(2, 2, 2, 2800.00, '2026-01-23', 2800.00, '2026-01-25', '2026-01-27', 'PAID', 'Cremation claim'),
(3, 3, 3, 4000.00, '2026-02-11', 3000.00, '2026-02-13', '2026-02-15', 'PAID', 'Repatriation included - partial'),
(4, 4, 4, 3800.00, '2026-02-17', 3800.00, '2026-02-19', '2026-02-21', 'PAID', 'Standard funeral'),
(5, 5, 5, 2900.00, '2026-02-26', 2900.00, '2026-02-28', '2026-03-02', 'PAID', 'Cremation'),
(6, 6, 6, 3600.00, '2026-03-13', 3600.00, '2026-03-15', '2026-03-17', 'PAID', 'Traditional funeral'),
(7, 7, 7, 2750.00, '2026-03-21', NULL, NULL, NULL, 'UNDER_REVIEW', 'Cremation - pending completion'),
(8, 8, 8, 4100.00, '2026-03-29', NULL, NULL, NULL, 'SUBMITTED', 'Burial - pending funeral'),
(9, 9, 9, 3500.00, '2026-04-11', NULL, NULL, NULL, 'UNDER_REVIEW', 'Repatriation pending'),
(10, 10, 10, 2850.00, '2026-04-17', NULL, NULL, NULL, 'SUBMITTED', 'Cremation - pending funeral');

-- ===================================================================
-- VERIFY DATA LOAD
-- ===================================================================
SELECT 'Customers:' as table_name, COUNT(*) as row_count FROM customers
UNION ALL
SELECT 'Funeral Homes', COUNT(*) FROM funeral_homes
UNION ALL
SELECT 'Policies', COUNT(*) FROM insurance_policies
UNION ALL
SELECT 'Funerals', COUNT(*) FROM funerals
UNION ALL
SELECT 'Cremations', COUNT(*) FROM cremations
UNION ALL
SELECT 'Burials', COUNT(*) FROM burials
UNION ALL
SELECT 'Repatriations', COUNT(*) FROM repatriations
UNION ALL
SELECT 'Claims', COUNT(*) FROM insurance_claims;