CREATE DATABASE IF NOT EXISTS CarRepairShopDB;
USE CarRepairShopDB;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Mechanics;
DROP TABLE IF EXISTS RepairJob;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Workshops;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Cars;
DROP TABLE IF EXISTS WorksOn;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Workshops (
	WorkShopID INT PRIMARY KEY,
    MaxCapacity INT,
    CurrCapacity INT
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    ContactInfo VARCHAR(30)
);

CREATE TABLE Cars (
    CarID INT PRIMARY KEY,
    CustomerID INT,
    Color VARCHAR(30),
    Brand VARCHAR(30),
    LastServiced DATE,
    Price DECIMAL(10,2),
    Mileage INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Mechanics (
    MechanicID INT PRIMARY KEY,
    WorkshopID INT,
    Salary DECIMAL(10,2),
    Brand VARCHAR(30),
    FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID)
);

CREATE TABLE RepairJob (
    JobID INT PRIMARY KEY,
    CarID INT,
    CustomerID INT,
    WorkshopID INT,
    RepairDescription TEXT,
    StartTime DATETIME,
    EndTime DATETIME,
    FOREIGN KEY (CarID) REFERENCES Cars(CarID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID)
);

CREATE TABLE WorksOn (
    MechanicID INT,
    JobID INT,
    FOREIGN KEY (MechanicID) REFERENCES Mechanics(MechanicID),
    FOREIGN KEY (JobID) REFERENCES RepairJob(JobID),
    PRIMARY KEY (MechanicID, JobID)
);

CREATE TABLE Inventory (
    ItemID INT PRIMARY KEY,
    WorkshopID INT,
    ItemName VARCHAR(30),
    ItemPrice DECIMAL(10,2),
    Quantity INT,
    FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID)
);


INSERT INTO Workshops (WorkshopID, MaxCapacity, CurrCapacity) VALUES
(1, 10, 4),
(2, 20, 2),
(3, 15, 2),
(4, 12, 2);

INSERT INTO Customers (CustomerID, ContactInfo) VALUES
(1, 'john.doe@email.com'),
(2, 'jane.doe@email.com'),
(3, 'sam.ross@email.com'),
(4, 'susan.connor@email.com'),
(5, 'john.jane@email.com'),
(6, 'jack.wayne@email.com'),
(7, 'ross.kent@email.com'),
(8, 'brent.prince@email.com');

INSERT INTO Cars (CarID, CustomerID, Color, Brand, LastServiced, Price, Mileage) VALUES
(1, 1, 'Red', 'Toyota', '2023-10-01', 25000, 30000),
(2, 2, 'Blue', 'Honda', '2023-09-15', 22000, 40000),
(3, 3, 'Black', 'Ford', '2023-08-20', 18000, 50000),
(4, 4, 'White', 'Chevrolet', '2023-07-05', 27000, 200000),
(5, 5, 'Silver', 'Tesla', '2023-11-11', 45000, 10000),
(6, 6, 'Grey', 'BMW', '2023-12-12', 55000, 8000),
(7, 7, 'Black', 'Audi', '2024-01-19', 35000, 25000),
(8, 8, 'Yellow', 'Mercedes', '2024-02-21', 36000, 15000),
(9, 1, 'Green', 'Nissan', '2023-05-25', 21000, 60000),
(10, 2, 'Blue', 'Tesla', '2023-06-30', 23000, 42000);

INSERT INTO Mechanics (MechanicID, WorkshopID, Salary, Brand) VALUES
(1, 1, 3350, 'General'),
(2, 1, 3200, 'General'),
(3, 2, 3100, 'General'),
(4, 3, 3800, 'General'),
(5, 3, 3400, 'General'),
(6, 4, 2100, 'General'),
(7, 4, 3300, 'General'),
(8, 4, 3900, 'General');

INSERT INTO RepairJob (JobID, CarID, CustomerID, WorkshopID, RepairDescription, StartTime, EndTime) VALUES
(1, 1, 1, 1, 'Oil change and general check-up', '2024-04-01 09:00:00', '2024-04-01 11:00:00'),
(2, 5, 5, 1, 'Battery replacement', '2024-04-02 09:00:00', '2024-04-02 10:00:00'),
(3, 3, 3, 2, 'Brake pad replacement', '2024-04-03 10:00:00', '2024-04-03 12:00:00'),
(4, 7, 7, 3, 'Transmission repair', '2024-04-04 13:00:00', '2024-04-04 16:00:00'),
(5, 2, 2, 1, 'Tire rotation', '2024-04-05 08:00:00', '2024-04-05 09:00:00'),
(6, 4, 4, 1, 'AC repair', '2024-04-06 11:00:00', '2024-04-06 14:00:00'),
(7, 8, 8, 4, 'Suspension check', '2024-04-07 09:00:00', '2024-04-07 11:00:00'),
(8, 6, 6, 3, 'Engine diagnostics', '2024-04-08 14:00:00', '2024-04-08 17:00:00'),
(9, 9, 1, 2, 'Exhaust system repair', '2024-04-09 10:00:00', '2024-04-09 13:00:00'),
(10, 10, 2, 4, 'Windshield replacement', '2024-04-10 15:00:00', '2024-04-10 17:00:00');


INSERT INTO Inventory (ItemID, WorkshopID, ItemName, ItemPrice, Quantity) VALUES
(1, 1, 'Oil Filter', 10.00, 50),
(2, 2, 'Brake Pads', 20.00, 40),
(3, 3, 'Spark Plug', 5.00, 100),
(4, 4, 'Timing Belt', 30.00, 30),
(5, 1, 'Alternator', 100.00, 10),
(6, 2, 'Tire', 80.00, 20),
(7, 3, 'Headlight', 15.00, 25);

INSERT INTO WorksOn (MechanicID, JobID) VALUES
(1, 1),
(2, 5),
(3, 3),
(4, 4),
(1, 6),
(5, 8),
(6, 7),
(7, 10),
(2, 2),
(3, 9);









