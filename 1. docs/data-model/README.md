# Data Model Documentation

Complete guide to all tables in the database.

## Operational Tables (12)
### Core Tables
- **customers** - Customer information
- **funeral_homes** - Funeral home locations & capacity
- **insurance_policies** - Insurance policy details
- **employees** - Staff members

### Central Fact Table
- **funerals** - All funeral services (central hub connecting all tables)

### Detail Tables
- **cremations** - Cremation details (1:1 with funerals)
- **burials** - Burial details (1:1 with funerals)
- **insurance_claims** - Insurance claims

### Event Tables
- **complaints** - Customer complaints (1:Many with funerals)
- **customer_feedback** - Customer satisfaction feedback
- **family_feedback** - Family member feedback
- **service_issues** - Service issues logged
- **customer_requests** - Customer requests & responses

## Analytical Star Schema (11 tables)

### Fact Table
- **FACT_FUNERALS** - One row per funeral with pre-calculated metrics

### Dimension Tables
- **D_CUSTOMERS** - Customer dimension
- **D_FUNERAL_HOMES** - Location & facility dimension
- **D_POLICIES** - Insurance policy dimension
- **D_EMPLOYEES** - Employee dimension
- **D_DATE** - Time dimension

### Sub-Fact Tables
- **F_COMPLAINTS** - Multiple complaints per funeral
- **F_CUSTOMER_FEEDBACK** - Multiple feedback entries per funeral
- **F_INSURANCE_CLAIMS** - Multiple claims per policy

## Key Design Principles
✓ Kimball dimensional modeling
✓ Star schema optimized for analytics
✓ Pre-calculated metrics in fact table
✓ No data duplication
✓ Tableau-ready structure
