-- 05_transactions_and_tests.sql
-- Crownfield Eye Hospital | CPU4:103 | MySQL 8.0+
USE crownfield_eye_hospital;

-- Test 1: Integrity check - look for orphaned appointment references.
-- Each query should return zero rows.
SELECT a.appointment_id
FROM Appointment AS a
LEFT JOIN Patient AS p ON p.patient_id = a.patient_id
WHERE p.patient_id IS NULL;

SELECT a.appointment_id
FROM Appointment AS a
LEFT JOIN Clinician AS c ON c.clinician_id = a.clinician_id
WHERE c.clinician_id IS NULL;

SELECT ad.appointment_id, ad.diagnosis_id
FROM AppointmentDiagnosis AS ad
LEFT JOIN Diagnosis AS d ON d.diagnosis_id = ad.diagnosis_id
WHERE d.diagnosis_id IS NULL;

-- Test 2: Demonstrate transaction control with ROLLBACK.
-- A temporary appointment note is applied, inspected, and then rolled back.
-- The final SELECT should show the original note, proving the change was undone.
START TRANSACTION;
UPDATE Appointment
SET notes = 'Transaction test - temporary note'
WHERE appointment_id = 12;
SELECT appointment_id, notes FROM Appointment WHERE appointment_id = 12;
ROLLBACK;
SELECT appointment_id, notes FROM Appointment WHERE appointment_id = 12;

-- Test 3: Duplicate clinician slot should be rejected by uq_clinician_slot.
-- Run separately if you need a screenshot of the expected error.
-- INSERT INTO Appointment
-- (patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes)
-- VALUES ('OP001','CL001',1,'2026-10-05','09:00:00','Duplicate-slot test');

-- Test 4: Invalid foreign key should be rejected. Run separately for screenshot evidence.
-- INSERT INTO Appointment
-- (patient_id, clinician_id, clinic_id, appointment_date, appointment_time)
-- VALUES ('NO_SUCH_PATIENT','CL001',1,'2026-10-20','09:00:00');

-- Test 5: Check follow-up statuses and priorities.
SELECT status, priority, COUNT(*) AS record_count
FROM FollowUp
GROUP BY status, priority
ORDER BY status, priority;
