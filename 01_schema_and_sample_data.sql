-- Crownfield Eye Hospital — CPU4:103 database implementation
-- MySQL 8.0+ | Fictional teaching data only
-- Run this file in MySQL Workbench using a local/test schema.
-- This script creates the database only if it does not already exist.
-- It deliberately does NOT drop or overwrite an existing database.
-- Run this against a fresh/empty schema. If tables already exist, stop and
-- inspect them before running CREATE TABLE statements; do not delete your work.

CREATE DATABASE IF NOT EXISTS crownfield_eye_hospital
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE crownfield_eye_hospital;

-- 1. Patient
CREATE TABLE Patient (
    patient_id VARCHAR(10) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    postcode VARCHAR(12) NOT NULL
) ENGINE=InnoDB;

-- 2. Specialty
CREATE TABLE Specialty (
    specialty_id INT PRIMARY KEY,
    specialty_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 3. Clinician
CREATE TABLE Clinician (
    clinician_id VARCHAR(10) PRIMARY KEY,
    clinician_name VARCHAR(100) NOT NULL,
    specialty_id INT NOT NULL,
    CONSTRAINT fk_clinician_specialty
      FOREIGN KEY (specialty_id) REFERENCES Specialty(specialty_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Clinic
CREATE TABLE Clinic (
    clinic_id INT PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 5. Appointment
CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id VARCHAR(10) NOT NULL,
    clinician_id VARCHAR(10) NOT NULL,
    clinic_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    notes TEXT NULL,
    CONSTRAINT chk_appointment_date CHECK (appointment_date >= '2000-01-01'),
    CONSTRAINT uq_clinician_slot UNIQUE (clinician_id, appointment_date, appointment_time),
    CONSTRAINT fk_appointment_patient
      FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_clinician
      FOREIGN KEY (clinician_id) REFERENCES Clinician(clinician_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_clinic
      FOREIGN KEY (clinic_id) REFERENCES Clinic(clinic_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. Diagnosis
CREATE TABLE Diagnosis (
    diagnosis_id INT PRIMARY KEY,
    diagnosis_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 7. AppointmentDiagnosis (many-to-many bridge)
CREATE TABLE AppointmentDiagnosis (
    appointment_id INT NOT NULL,
    diagnosis_id INT NOT NULL,
    PRIMARY KEY (appointment_id, diagnosis_id),
    CONSTRAINT fk_appdiagnosis_appointment
      FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appdiagnosis_diagnosis
      FOREIGN KEY (diagnosis_id) REFERENCES Diagnosis(diagnosis_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. Medicine
CREATE TABLE Medicine (
    medicine_id INT PRIMARY KEY,
    medicine_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 9. Prescription
CREATE TABLE Prescription (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    prescribed_date DATE NOT NULL,
    CONSTRAINT fk_prescription_appointment
      FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 10. PrescriptionItem (medicines and their prescription instructions)
CREATE TABLE PrescriptionItem (
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dose VARCHAR(100) NULL,
    route VARCHAR(50) NULL,
    frequency VARCHAR(100) NULL,
    duration VARCHAR(100) NULL,
    PRIMARY KEY (prescription_id, medicine_id),
    CONSTRAINT fk_item_prescription
      FOREIGN KEY (prescription_id) REFERENCES Prescription(prescription_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_medicine
      FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11. FollowUp (zero or one follow-up per appointment)
CREATE TABLE FollowUp (
    followup_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL UNIQUE,
    due_date DATE NOT NULL,
    priority ENUM('Routine','High','Urgent') NOT NULL,
    status ENUM('Pending','Booked','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_followup_appointment
      FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_followup_due_date CHECK (due_date >= '2000-01-01')
) ENGINE=InnoDB;

-- Synthetic lookup and patient data (10+ records per table).
INSERT INTO Patient (patient_id, patient_name, postcode) VALUES
('OP001','Amina Yusuf','NE14AB'),
('OP002','Daniel Reed','N167QP'),
('OP003','Sofia Bennett','E82LD'),
('OP004','Michael Okoro','SE63RT'),
('OP005','Priya Shah','B712AA'),
('OP006','Oliver James','M14DX'),
('OP007','Hannah Cole','L18XY'),
('OP008','Noah Williams','BS16QH'),
('OP009','Grace Patel','CV35GH'),
('OP010','Ethan Morgan','NG72PL'),
('OP011','Isla Turner','LS61AB'),
('OP012','Amir Hussain','WS10 0AA');

INSERT INTO Specialty (specialty_id, specialty_name) VALUES
(1,'Glaucoma'),(2,'Retina'),(3,'Cornea'),(4,'Paediatric Ophthalmology'),
(5,'Cataract'),(6,'Oculoplastics'),(7,'Neuro-ophthalmology'),
(8,'Medical Retina'),(9,'Uveitis'),(10,'Emergency Eye Care');

INSERT INTO Clinician (clinician_id, clinician_name, specialty_id) VALUES
('CL001','Dr Maya Shah',1),('CL002','Dr Leo Grant',2),
('CL003','Dr Priya Nair',3),('CL004','Dr Samuel Price',4),
('CL005','Dr Emily Chen',5),('CL006','Dr Adam Lewis',6),
('CL007','Dr Farah Khan',7),('CL008','Dr Ben Carter',8),
('CL009','Dr Nadia Ali',9),('CL010','Dr Oliver Wright',10);

INSERT INTO Clinic (clinic_id, clinic_name) VALUES
(1,'City Road Eye Clinic'),(2,'Bedford Specialist Clinic'),
(3,'Croydon Eye Centre'),(4,'Paediatric Eye Clinic'),
(5,'Cataract Assessment Suite'),(6,'Retina Imaging Unit'),
(7,'Cornea Treatment Room'),(8,'Neuro-ophthalmology Clinic'),
(9,'Urgent Eye Assessment'),(10,'Follow-up Clinic');

INSERT INTO Diagnosis (diagnosis_id, diagnosis_name) VALUES
(1,'Ocular hypertension'),(2,'Diabetic macular oedema'),
(3,'Glaucoma suspect'),(4,'Keratoconus'),
(5,'Age-related macular degeneration'),(6,'Cataract'),
(7,'Dry eye disease'),(8,'Uveitis'),(9,'Retinal vein occlusion'),
(10,'Conjunctivitis');

INSERT INTO Medicine (medicine_id, medicine_name) VALUES
(1,'Latanoprost'),(2,'Timolol'),(3,'Aflibercept'),
(4,'Sodium chloride eye drops'),(5,'Lubricating eye drops'),
(6,'Prednisolone eye drops'),(7,'Dorzolamide'),
(8,'Cyclopentolate'),(9,'Artificial tears gel'),(10,'Antibiotic eye drops');

-- 12 appointments; appointment IDs are generated as 1–12 in a fresh database.
INSERT INTO Appointment
(patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes) VALUES
('OP001','CL001',1,'2026-10-05','09:00:00','Review intraocular pressure'),
('OP002','CL002',6,'2026-10-05','09:30:00','OCT before review'),
('OP003','CL001',2,'2026-10-06','11:00:00','Monitor visual field'),
('OP004','CL003',7,'2026-10-07','14:00:00','Corneal topography'),
('OP005','CL005',5,'2026-10-08','10:00:00','Cataract assessment'),
('OP006','CL004',4,'2026-10-09','10:30:00','Paediatric vision review'),
('OP007','CL008',6,'2026-10-12','13:00:00','Retinal imaging review'),
('OP008','CL007',8,'2026-10-13','09:15:00','Visual symptoms assessment'),
('OP009','CL009',3,'2026-10-14','15:00:00','Inflammation review'),
('OP010','CL010',9,'2026-10-15','08:45:00','Urgent eye assessment'),
('OP011','CL006',10,'2026-10-16','11:45:00','Eyelid assessment'),
('OP012','CL002',6,'2026-10-19','14:30:00','Retina follow-up');

INSERT INTO AppointmentDiagnosis (appointment_id, diagnosis_id) VALUES
(1,1),(1,3),(2,2),(3,3),(4,4),(5,6),
(6,7),(7,5),(8,9),(9,8),(10,10),(12,5);

INSERT INTO Prescription (appointment_id, prescribed_date) VALUES
(1,'2026-10-05'),(2,'2026-10-05'),(4,'2026-10-07'),
(5,'2026-10-08'),(6,'2026-10-09'),(7,'2026-10-12'),
(8,'2026-10-13'),(9,'2026-10-14'),(10,'2026-10-15'),
(12,'2026-10-19');

-- Prescription IDs are generated as 1–10 in a fresh database.
INSERT INTO PrescriptionItem
(prescription_id, medicine_id, dose, route, frequency, duration) VALUES
(1,1,'1 drop','Ophthalmic','Once daily','Ongoing pending review'),
(1,2,'1 drop','Ophthalmic','Twice daily','As directed by clinician'),
(2,3,'As prescribed','Intravitreal','As scheduled','Specialist-directed'),
(3,4,'1 drop','Ophthalmic','As directed','As directed by clinician'),
(4,5,'1 drop','Ophthalmic','Four times daily','As directed by clinician'),
(5,5,'1 drop','Ophthalmic','As needed','As directed by clinician'),
(6,3,'As prescribed','Intravitreal','As scheduled','Specialist-directed'),
(7,7,'1 drop','Ophthalmic','Twice daily','As directed by clinician'),
(8,6,'1 drop','Ophthalmic','As prescribed','Taper only as directed'),
(9,10,'1 drop','Ophthalmic','As prescribed','As directed by clinician'),
(10,3,'As prescribed','Intravitreal','As scheduled','Specialist-directed');

INSERT INTO FollowUp (appointment_id, due_date, priority, status) VALUES
(1,'2026-11-16','High','Booked'),
(2,'2026-11-02','Urgent','Pending'),
(3,'2027-01-05','Routine','Pending'),
(4,'2026-12-02','Routine','Booked'),
(5,'2026-11-08','Routine','Pending'),
(6,'2026-11-09','Routine','Completed'),
(7,'2026-11-23','High','Pending'),
(8,'2026-11-13','High','Booked'),
(9,'2026-11-11','Routine','Pending'),
(10,'2026-10-22','Urgent','Completed');

-- Basic validation: each query should return 10+ rows for the principal data tables.
SELECT 'Patient' AS table_name, COUNT(*) AS record_count FROM Patient
UNION ALL SELECT 'Specialty', COUNT(*) FROM Specialty
UNION ALL SELECT 'Clinician', COUNT(*) FROM Clinician
UNION ALL SELECT 'Clinic', COUNT(*) FROM Clinic
UNION ALL SELECT 'Appointment', COUNT(*) FROM Appointment
UNION ALL SELECT 'Diagnosis', COUNT(*) FROM Diagnosis
UNION ALL SELECT 'AppointmentDiagnosis', COUNT(*) FROM AppointmentDiagnosis
UNION ALL SELECT 'Medicine', COUNT(*) FROM Medicine
UNION ALL SELECT 'Prescription', COUNT(*) FROM Prescription
UNION ALL SELECT 'PrescriptionItem', COUNT(*) FROM PrescriptionItem
UNION ALL SELECT 'FollowUp', COUNT(*) FROM FollowUp;

-- Sample joined report to confirm the foreign-key relationships work.
SELECT a.appointment_id, p.patient_name, c.clinician_name, cl.clinic_name,
       a.appointment_date, a.appointment_time, d.diagnosis_name
FROM Appointment AS a
INNER JOIN Patient AS p ON p.patient_id = a.patient_id
INNER JOIN Clinician AS c ON c.clinician_id = a.clinician_id
INNER JOIN Clinic AS cl ON cl.clinic_id = a.clinic_id
LEFT JOIN AppointmentDiagnosis AS ad ON ad.appointment_id = a.appointment_id
LEFT JOIN Diagnosis AS d ON d.diagnosis_id = ad.diagnosis_id
ORDER BY a.appointment_date, a.appointment_time;

-- Controlled UPDATE and DELETE demonstration.
-- These operations are rolled back so the submitted sample dataset remains intact.
START TRANSACTION;
UPDATE FollowUp
SET status = 'Pending'
WHERE followup_id = 1 AND status = 'Booked';
SELECT followup_id, appointment_id, status
FROM FollowUp WHERE followup_id = 1;

-- Insert a temporary test patient, then delete that same record.
INSERT INTO Patient (patient_id, patient_name, postcode)
VALUES ('TEST001','Temporary Test Patient','ZZ99ZZ');
DELETE FROM Patient WHERE patient_id = 'TEST001';
ROLLBACK;

-- Final check: TEST001 should not exist because the transaction was rolled back.
SELECT COUNT(*) AS temporary_test_patient_count
FROM Patient WHERE patient_id = 'TEST001';
