-- 03_procedure_and_trigger.sql
-- Crownfield Eye Hospital | CPU4:103 | MySQL 8.0+
-- Run after 01_schema.sql.
USE crownfield_eye_hospital;

-- Stored procedure with an input parameter.
-- Returns appointments for the supplied patient ID.
DROP PROCEDURE IF EXISTS GetPatientAppointments;
DELIMITER //
CREATE PROCEDURE GetPatientAppointments(IN p_patient_id VARCHAR(10))
BEGIN
    SELECT a.appointment_id, a.appointment_date, a.appointment_time,
           c.clinician_name, cl.clinic_name, a.notes
    FROM Appointment AS a
    INNER JOIN Clinician AS c ON c.clinician_id = a.clinician_id
    INNER JOIN Clinic AS cl ON cl.clinic_id = a.clinic_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date, a.appointment_time;
END //
DELIMITER ;

-- Test the procedure with a synthetic patient ID:
CALL GetPatientAppointments('OP001');

-- Trigger: prevent a follow-up due date from being earlier than its appointment date.
-- This enforces a meaningful business rule. The table CHECK separately prevents dates
-- before 2000-01-01; this trigger checks the cross-table relationship.
DROP TRIGGER IF EXISTS trg_followup_due_after_appointment;
DELIMITER //
CREATE TRIGGER trg_followup_due_after_appointment
BEFORE INSERT ON FollowUp
FOR EACH ROW
BEGIN
    DECLARE v_appointment_date DATE;
    SELECT appointment_date
      INTO v_appointment_date
      FROM Appointment
     WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date < v_appointment_date THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Follow-up due date cannot be earlier than the appointment date';
    END IF;
END //
DELIMITER ;

-- Test the trigger safely in a transaction.
-- This deliberately invalid insert should fail with the trigger message.
-- Uncomment and run separately if you want to capture the expected error:
-- INSERT INTO FollowUp (appointment_id, due_date, priority, status)
-- VALUES (11, '2020-01-01', 'Routine', 'Pending');

-- UPDATE trigger: enforce the same rule when an existing follow-up is changed.
DROP TRIGGER IF EXISTS trg_followup_due_after_appointment_update;
DELIMITER //
CREATE TRIGGER trg_followup_due_after_appointment_update
BEFORE UPDATE ON FollowUp
FOR EACH ROW
BEGIN
    DECLARE v_appointment_date DATE;

    SELECT appointment_date
      INTO v_appointment_date
      FROM Appointment
     WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date < v_appointment_date THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Follow-up due date cannot be earlier than the appointment date';
    END IF;
END //
DELIMITER ;

-- Test the UPDATE trigger separately; it should be rejected.
-- UPDATE FollowUp SET due_date = '2020-01-01' WHERE followup_id = 1;
