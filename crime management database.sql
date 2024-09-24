create database crime_management;

use crime_management;

CREATE TABLE Crime (
CrimeID INT PRIMARY KEY,
IncidentType VARCHAR(255),
IncidentDate DATE,
Location VARCHAR(255),
Description TEXT,
Status VARCHAR(20)
);

CREATE TABLE Victim (
VictimID INT PRIMARY KEY,
CrimeID INT,
Name VARCHAR(255),
ContactInfo VARCHAR(255),
Injuries VARCHAR(255),
FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE Suspect (
SuspectID INT PRIMARY KEY,
CrimeID INT,
Name VARCHAR(255),
Description TEXT,
CriminalHistory TEXT,
FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);


INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
(1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
(2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under Investigation'),
(3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');


INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries)
VALUES
(1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
(2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
(3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');


INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory)
VALUES
(1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
(2, 2, 'Unknown', 'Investigation ongoing', NULL),
(3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');

Select * From Crime;
Select * From Victim;
Select * From Suspect;




-- Select all open incidents:
SELECT * FROM Crime WHERE Status = 'Open';


-- Find the total number of incidents:
SELECT COUNT(*) AS TotalIncidents FROM Crime;


-- List all unique incident types:
SELECT DISTINCT IncidentType FROM Crime;


-- Retrieve incidents that occurred between '2023-09-01' and '2023-09-10':

SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';


-- List persons involved in incidents in descending order of age: (Assuming you have an age column in the victims table):

SELECT Name, Age FROM Victim
JOIN Crime ON Victim.CrimeID = Crime.CrimeID
UNION ALL
SELECT Name, Age FROM Suspect
JOIN Crime ON Suspect.CrimeID = Crime.CrimeID
ORDER BY Age DESC;



-- Find the average age of persons involved in incidents

SELECT AVG(Age) AS AverageAge FROM (
    SELECT Age FROM Victim
    UNION ALL
    SELECT Age FROM Suspect
) AS AllPersons;


--  List incident types and their counts, only for open cases:

SELECT IncidentType, COUNT(*) AS IncidentCount 
FROM Crime 
WHERE Status = 'Open'
GROUP BY IncidentType;


-- Find persons with names containing 'Doe':

SELECT Name FROM Victim WHERE Name LIKE '%Doe%'
UNION ALL
SELECT Name FROM Suspect WHERE Name LIKE '%Doe%';


-- Retrieve the names of persons involved in open cases and closed cases:

SELECT v.Name, c.Status
FROM Victim v 
JOIN Crime c ON v.CrimeID = c.CrimeID
UNION ALL
SELECT s.Name, c.Status
FROM Suspect s 
JOIN Crime c ON s.CrimeID = c.CrimeID;


-- List incident types where there are persons aged 30 or 35 involved:

SELECT DISTINCT c.IncidentType
FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE v.Age IN (30, 35) OR s.Age IN (30, 35);


-- Find persons involved in incidents of the same type as 'Robbery':

SELECT v.Name 
FROM Victim v 
JOIN Crime c ON v.CrimeID = c.CrimeID
WHERE c.IncidentType = 'Robbery'
UNION ALL
SELECT s.Name 
FROM Suspect s
JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType = 'Robbery';

 -- List incident types with more than one open case:
 
SELECT IncidentType, COUNT(*) AS CaseCount
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType
HAVING COUNT(*) > 1;

-- List all incidents with suspects whose names also appear as victims in other incidents:

SELECT DISTINCT c.CrimeID, c.IncidentType, s.Name AS Suspect
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Name IN (SELECT Name FROM Victim);


-- Retrieve all incidents along with victim and suspect details:

SELECT c.CrimeID, c.IncidentType, v.Name AS Victim, s.Name AS Suspect
FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;



-- Find incidents where the suspect is older than any victim:

SELECT DISTINCT c.CrimeID, c.IncidentType
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Age > (SELECT MAX(Age) FROM Victim WHERE CrimeID = c.CrimeID);


-- Find suspects involved in multiple incidents:

SELECT Name, COUNT(CrimeID) AS IncidentCount
FROM Suspect
GROUP BY Name
HAVING COUNT(CrimeID) > 1;


-- List incidents with no suspects involved:

SELECT CrimeID, IncidentType FROM Crime
WHERE CrimeID NOT IN (SELECT CrimeID FROM Suspect);



-- List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery':

SELECT CrimeID, IncidentType
FROM Crime
WHERE IncidentType = 'Homicide'
UNION ALL
SELECT CrimeID, IncidentType
FROM Crime
WHERE IncidentType = 'Robbery';



-- Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, 
-- or 'No Suspect' if there are none:

SELECT c.CrimeID, c.IncidentType, IFNULL(s.Name, 'No Suspect') AS Suspect
FROM Crime c
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;



-- List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault':

SELECT DISTINCT s.Name
FROM Suspect s
JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType IN ('Robbery', 'Assault');
