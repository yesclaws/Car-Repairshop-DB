USE CarRepairShopDB;

# ------------- (Section 6) Query Example 1 (Join and Group By) --------------

SELECT m.MechanicID AS MechanicID, COUNT(w.MechanicID) AS NumOfJobs, m.Salary
FROM mechanics m
	LEFT JOIN workson w
	ON m.MechanicID = w.MechanicID
GROUP BY m.MechanicID;

# -------------------- (Section 6) Query Example 2 (In) ----------------------
SELECT * FROM Cars
WHERE CarID IN 
(SELECT CarID FROM RepairJob WHERE StartTime > '2024-04-02 00:00:00' AND EndTime < '2024-04-02 12:00:00');

# -------------------- (Section 6) Query Example 3 (Union) -------------------- 
SELECT CarID, Brand, Color FROM Cars
WHERE Color = 'Red' UNION SELECT CarID, Brand, Color FROM Cars WHERE LastServiced > '2024-01-01';

# ---------------------------- START - (Section 7) TRIGGER ---------------------------- 
DROP TRIGGER IF EXISTS SelectSuitableMechanic;
DELIMITER //
CREATE TRIGGER SelectSuitableMechanic
AFTER INSERT ON repairjob FOR EACH ROW
BEGIN
	# automatically choose a mechanic. we assign the job to the mechanic with the lowest amount of current jobs that also lives up to the requirements. 
	# The requirements are:
	#	* the mechanic must be able to work on the same brand as the car(having general, or the same brand)
	#	* the workshopID of the mechanic must be the same as the workshopID of the repairJob
	DECLARE vMechanic INT;
    
    SET vMechanic = (
		SELECT MechanicID
		FROM (
			# sorts the list based on fewest number of jobs, and selects the top result
			SELECT MechanicID, COUNT(jobID) AS num_jobs
			FROM workson
			WHERE MechanicID IN (
					# a list of all the mechanics that meet the requirements
					SELECT MechanicID 
					FROM mechanics 
					WHERE (Brand = (SELECT Brand FROM Cars WHERE CarID = NEW.CarID) OR Brand = 'General') 
					AND WorkshopID = NEW.WorkshopID
			)
			GROUP BY MechanicID
            order by num_jobs asc
            ) as subQuery
		LIMIT 1
	);
    
    
    # If no mechanic found, raise an error
	IF (vMechanic IS NULL) THEN 
		SIGNAL SQLSTATE 'HY000'
			SET MYSQL_ERRNO = 404,
			MESSAGE_TEXT = 'Error: No suitable mechanic found';
	END IF;
    
    # If workshop capacity exceeds maximum, raise an error
    IF (SELECT CurrCapacity >= MaxCapacity FROM workshops WHERE workshopID = NEW.WorkshopID) THEN
		SIGNAL SQLSTATE 'HY000'
			SET MYSQL_ERRNO = 1525,
			MESSAGE_TEXT = 'Error: Workshop at maximum capacity';
	END IF;
    
	# INSERT row signaling that the chosen mechanic is working on the given job
	INSERT INTO workson VALUES (vMechanic, NEW.JobID);
    
    # increases the current capacity of the workshop that got the job
    UPDATE workshops
    SET CurrCapacity = CurrCapacity + 1
    WHERE workshopID = NEW.WorkshopID;
	
END //
DELIMITER ;
# ------------------------------ END - (Section 7) TRIGGER ------------------------------
# ---------------------------- START - (Section 7) PROCEDURE ---------------------------- 
DROP PROCEDURE IF EXISTS DeleteRepairJob;
DELIMITER //
CREATE PROCEDURE DeleteRepairJob(IN vJobID INT)
BEGIN
START TRANSACTION;

DELETE FROM workson
	WHERE JobID = vJobID;

UPDATE workshops
    SET CurrCapacity = CurrCapacity - 1
    WHERE workshopID = (SELECT WorkshopID FROM repairjob where JobID = vJobID);

DELETE FROM repairjob
	WHERE JobID = vJobID;	

COMMIT;
END //
DELIMITER ;
# ---------------------------- END - (Section 7) PROCEDURE ---------------------------- 
# --------------------------- START - (Section 7) FUNCTION ---------------------------- 
DROP FUNCTION IF EXISTS NumOfJobs;
CREATE FUNCTION NumOfJobs(vMechanicID INT) RETURNS INTEGER
RETURN (
	SELECT count(jobID) 
		FROM workson 
		WHERE MechanicID = vMechanicID);
# ---------------------------- END - (Section 7) FUNCTION ---------------------------- 
# ---------------------- START - (Section 8) UPDATE and DELETE -----------------------

UPDATE workson SET MechanicID = 5 WHERE MechanicID = 4;

UPDATE Mechanics SET salary = salary*1.2 WHERE MechanicID = 5;

DELETE FROM Mechanics WHERE MechanicID = 4;

# ----------------------- END - (Section 8) UPDATE and DELETE ------------------------ 



# --------------------------- START - Miscellaneous --------------------------- 
/*
# The INSERT and SELECT statements used to illustate the visualizing of the TRIGGER from section 7

INSERT INTO RepairJob (JobID, CarID, CustomerID, WorkshopID, RepairDescription, StartTime, EndTime) VALUES
(11, 1, 1, 1, 'Oil change and general check-up', '2024-04-04 09:00:00', '2024-04-04 11:00:00');

SELECT workson.MechanicID as MechanicID, COUNT(workson.MechanicID) as NumOfJobs, workshop.CurrCapacity
FROM workson workson
	JOIN repairjob job
	on job.JobID = workson.JobID
		JOIN workshops workshop
		on job.WorkshopID = workshop.WorkShopID
GROUP BY workson.MechanicID;
*/

/*
# Used to visualize the Update and Delete statements from Section 8
SELECT m.MechanicID AS MechanicID, COUNT(w.MechanicID) AS NumOfJobs, m.Salary
FROM mechanics m
	LEFT JOIN workson w
	ON m.MechanicID = w.MechanicID
WHERE m.MechanicID = 4 or m.MechanicID = 5
GROUP BY m.MechanicID;
*/
# ---------------------------- END - Miscellaneous --------------------------- 

