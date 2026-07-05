# Analytical Database Scripts

Star schema creation scripts for Tableau analytics.

## Files
- `create-fact-funerals.sql` - FACT_FUNERALS table
- `create-dimensions.sql` - All dimension tables (D_CUSTOMERS, D_FUNERAL_HOMES, etc.)
- `create-sub-facts.sql` - Sub-fact tables (F_COMPLAINTS, F_FEEDBACK, F_CLAIMS)

## How to Use
1. Run operational scripts first
2. Then run analytical scripts in order:
   - Dimensions first
   - Fact table
   - Sub-facts
3. Export to CSV for Tableau
