-- 04_security.sql
-- Crownfield Eye Hospital | CPU4:103 | MySQL 8.0+
-- Run as an administrator on a local/test server.
-- IMPORTANT: change the example passwords before use. These are teaching examples only.
USE crownfield_eye_hospital;

-- Create separate roles. Availability of CREATE ROLE depends on MySQL version/privileges.
CREATE ROLE IF NOT EXISTS 'ceh_admin_role', 'ceh_doctor_role',
                       'ceh_receptionist_role', 'ceh_reporting_role';

-- Administrator: full access to this database (assign only to trusted administrators).
GRANT ALL PRIVILEGES ON crownfield_eye_hospital.* TO 'ceh_admin_role';

-- Doctor: can view patient/appointment/diagnosis/medicine information and maintain
-- diagnoses, prescriptions, items and follow-up plans. No direct patient deletion.
GRANT SELECT ON crownfield_eye_hospital.Patient TO 'ceh_doctor_role';
GRANT SELECT ON crownfield_eye_hospital.Clinician TO 'ceh_doctor_role';
GRANT SELECT ON crownfield_eye_hospital.Specialty TO 'ceh_doctor_role';
GRANT SELECT ON crownfield_eye_hospital.Clinic TO 'ceh_doctor_role';
GRANT SELECT ON crownfield_eye_hospital.Appointment TO 'ceh_doctor_role';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital.AppointmentDiagnosis TO 'ceh_doctor_role';
GRANT SELECT ON crownfield_eye_hospital.Diagnosis TO 'ceh_doctor_role';
GRANT SELECT ON crownfield_eye_hospital.Medicine TO 'ceh_doctor_role';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital.Prescription TO 'ceh_doctor_role';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital.PrescriptionItem TO 'ceh_doctor_role';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital.FollowUp TO 'ceh_doctor_role';

-- Receptionist: patient and appointment administration, without clinical table write access.
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital.Patient TO 'ceh_receptionist_role';
GRANT SELECT ON crownfield_eye_hospital.Clinician TO 'ceh_receptionist_role';
GRANT SELECT ON crownfield_eye_hospital.Clinic TO 'ceh_receptionist_role';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital.Appointment TO 'ceh_receptionist_role';
GRANT SELECT ON crownfield_eye_hospital.FollowUp TO 'ceh_receptionist_role';

-- Reporting role: read-only access for approved reports.
GRANT SELECT ON crownfield_eye_hospital.Patient TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Specialty TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Clinician TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Clinic TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Appointment TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.AppointmentDiagnosis TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Diagnosis TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Medicine TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.Prescription TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.PrescriptionItem TO 'ceh_reporting_role';
GRANT SELECT ON crownfield_eye_hospital.FollowUp TO 'ceh_reporting_role';

-- Example accounts (use unique, strong passwords; do not reuse these placeholders).
-- Uncomment and replace password strings before running:
-- CREATE USER 'ceh_admin'@'localhost' IDENTIFIED BY 'Replace-With-Strong-Unique-Password!';
-- CREATE USER 'ceh_doctor'@'localhost' IDENTIFIED BY 'Replace-With-Strong-Unique-Password!';
-- CREATE USER 'ceh_receptionist'@'localhost' IDENTIFIED BY 'Replace-With-Strong-Unique-Password!';
-- CREATE USER 'ceh_reporting'@'localhost' IDENTIFIED BY 'Replace-With-Strong-Unique-Password!';
-- GRANT 'ceh_admin_role' TO 'ceh_admin'@'localhost';
-- GRANT 'ceh_doctor_role' TO 'ceh_doctor'@'localhost';
-- GRANT 'ceh_receptionist_role' TO 'ceh_receptionist'@'localhost';
-- GRANT 'ceh_reporting_role' TO 'ceh_reporting'@'localhost';
-- SET DEFAULT ROLE ALL TO 'ceh_admin'@'localhost';
-- SET DEFAULT ROLE ALL TO 'ceh_doctor'@'localhost';
-- SET DEFAULT ROLE ALL TO 'ceh_receptionist'@'localhost';
-- SET DEFAULT ROLE ALL TO 'ceh_reporting'@'localhost';

-- Check the role grants after running:
SHOW GRANTS FOR 'ceh_admin_role';
SHOW GRANTS FOR 'ceh_doctor_role';
SHOW GRANTS FOR 'ceh_receptionist_role';
SHOW GRANTS FOR 'ceh_reporting_role';

-- Data protection demonstration using synthetic information.
-- Educational example only; not suitable for production key management.

CREATE TEMPORARY TABLE SecurityDemo (
    demo_id INT PRIMARY KEY,
    encrypted_record VARBINARY(255)
);

SET @encryption_key = 'DemoKey_2026';

INSERT INTO SecurityDemo
VALUES (
    1,
    AES_ENCRYPT('Synthetic medical record', @encryption_key)
);

-- Display the encrypted information.
SELECT
    demo_id,
    HEX(encrypted_record) AS encrypted_value
FROM SecurityDemo;

-- Decrypt the information using the same demonstration key.
SELECT
    demo_id,
    CAST(
        AES_DECRYPT(encrypted_record, @encryption_key)
        AS CHAR
    ) AS decrypted_record
FROM SecurityDemo;

