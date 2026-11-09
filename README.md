# Crownfield Eye Hospital — CPU4:103 SQL Repository

Fictional teaching database for the CPU4:103 Introduction to Database assessment.
All sample records are synthetic. Do not enter real patient information.

## Requirements
- MySQL Server 8.0 or later
- MySQL Workbench
- Run only in a local/test environment
- Use a fresh, empty database for the setup script

## Files and execution order
1. `01_schema_and_sample_data.sql` — creates `crownfield_eye_hospital`, the 11 tables, synthetic sample data, row-count checks and a joined validation report.
2. `02_individual_queries.sql` — six purposeful SQL queries, including aggregation/HAVING, multi-table INNER JOIN, LEFT JOIN, a subquery and medication history.
3. `03_procedure_and_trigger.sql` — creates the patient-appointments stored procedure and both BEFORE INSERT and BEFORE UPDATE triggers enforcing the follow-up date rule.
4. `04_security.sql` — creates four database roles and grants role-specific permissions. Run as an administrator. User creation is intentionally left commented until you replace the example passwords.
5. `05_transactions_and_tests.sql` — integrity checks, a ROLLBACK demonstration and optional negative tests for duplicate appointment slots and invalid foreign keys.

## Important execution notes
- Run the scripts in the order above.
- The setup script uses `CREATE DATABASE IF NOT EXISTS`, but the table statements are not designed to be rerun over existing tables. If `crownfield_eye_hospital` already contains tables, stop and inspect the schema before running the setup script again. Do not drop existing work.
- The sample setup script creates 12 appointments, 10 prescriptions and 10 follow-ups. The bridge tables contain multiple records. Run the row-count validation query to confirm the data loaded.
- The two follow-up triggers reject a due date earlier than the related appointment date on both INSERT and UPDATE.
- The invalid INSERT/UPDATE examples and negative integrity tests are commented out intentionally. Run them individually only when you are ready to capture the expected error.
- In `04_security.sql`, replace placeholder passwords with unique strong passwords before uncommenting account-creation statements. Role creation and grants require an account with sufficient privileges.
- Capture your own screenshots from MySQL Workbench after executing the scripts. Do not claim a test passed unless you ran it and observed the result.
- Add your own contribution notes and explain each query, procedure, trigger and permission choice in your report and presentation.

## Schema
The implementation follows the original 11-table logical design:
Patient, Specialty, Clinician, Clinic, Appointment, Diagnosis, AppointmentDiagnosis, Medicine, Prescription, PrescriptionItem and FollowUp.
