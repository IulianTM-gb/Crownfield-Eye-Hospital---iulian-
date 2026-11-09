-- 02_individual_queries.sql
-- Crownfield Eye Hospital | CPU4:103 | MySQL 8.0+
-- Run after 01_schema.sql.
USE crownfield_eye_hospital;

-- Query 1: Aggregate + GROUP BY + HAVING
-- Question: Which clinicians have handled more than one appointment?
SELECT c.clinician_id, c.clinician_name, COUNT(a.appointment_id) AS appointment_count
FROM Clinician AS c
INNER JOIN Appointment AS a ON a.clinician_id = c.clinician_id
GROUP BY c.clinician_id, c.clinician_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY appointment_count DESC, c.clinician_name;

-- Query 2: INNER JOIN across at least three related tables
-- Question: Which patient appointments have a recorded diagnosis?
SELECT a.appointment_id, p.patient_name, a.appointment_date,
       c.clinician_name, d.diagnosis_name
FROM Appointment AS a
INNER JOIN Patient AS p ON p.patient_id = a.patient_id
INNER JOIN Clinician AS c ON c.clinician_id = a.clinician_id
INNER JOIN AppointmentDiagnosis AS ad ON ad.appointment_id = a.appointment_id
INNER JOIN Diagnosis AS d ON d.diagnosis_id = ad.diagnosis_id
ORDER BY a.appointment_date, a.appointment_id;

-- Query 3: LEFT JOIN to reveal optional/missing related data
-- Question: Which appointments have no follow-up plan recorded?
SELECT a.appointment_id, p.patient_name, a.appointment_date,
       f.followup_id, f.due_date, f.status
FROM Appointment AS a
INNER JOIN Patient AS p ON p.patient_id = a.patient_id
LEFT JOIN FollowUp AS f ON f.appointment_id = a.appointment_id
WHERE f.followup_id IS NULL
ORDER BY a.appointment_date;

-- Query 4: Subquery
-- Question: Which follow-ups are due earlier than the average follow-up due date?
-- DATEDIFF converts each date to a day count so AVG can calculate a meaningful mean.
SELECT f.followup_id, f.appointment_id, f.due_date, f.priority, f.status
FROM FollowUp AS f
WHERE DATEDIFF(f.due_date, '2000-01-01') < (
    SELECT AVG(DATEDIFF(due_date, '2000-01-01'))
    FROM FollowUp
)
ORDER BY f.due_date;

-- Query 5: Patient medication history using joins
-- Question: Which medicines were recorded for each patient appointment?
SELECT p.patient_name, a.appointment_id, pr.prescribed_date,
       m.medicine_name, pi.dose, pi.route, pi.frequency, pi.duration
FROM Patient AS p
INNER JOIN Appointment AS a ON a.patient_id = p.patient_id
INNER JOIN Prescription AS pr ON pr.appointment_id = a.appointment_id
INNER JOIN PrescriptionItem AS pi ON pi.prescription_id = pr.prescription_id
INNER JOIN Medicine AS m ON m.medicine_id = pi.medicine_id
ORDER BY p.patient_name, pr.prescribed_date, m.medicine_name;

-- Query 6: Follow-up workload by status and priority
-- Question: How many follow-ups are in each status/priority combination?
SELECT status, priority, COUNT(*) AS followup_count
FROM FollowUp
GROUP BY status, priority
ORDER BY status, priority;
