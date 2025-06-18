CREATE DATABASE BankDB;
GO
USE BankDB;

CREATE TABLE Branches (
    BranchID VARCHAR(10) PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    ManagerID VARCHAR(10) NOT NULL
);

CREATE TABLE CashDesks (
    CashDeskID VARCHAR(10) PRIMARY KEY,
    BranchID VARCHAR(10) NOT NULL,
    CashDeskName VARCHAR(50) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

CREATE TABLE Employees (
    EmployeeID VARCHAR(10) PRIMARY KEY,
    BranchID VARCHAR(10) NOT NULL,
    CashDeskID VARCHAR(10),
    FullName VARCHAR(100) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CashDeskID) REFERENCES CashDesks(CashDeskID)
);

CREATE TABLE Transactions (
    TransactionID VARCHAR(10) PRIMARY KEY,
    BranchID VARCHAR(10) NOT NULL,
    CashDeskID VARCHAR(10) NOT NULL,
    EmployeeID VARCHAR(10) NOT NULL,
    Date VARCHAR(50) NOT NULL,
    Amount DECIMAL(15, 2) NOT NULL,
    Profit DECIMAL(15, 2) NOT NULL,
    Currency VARCHAR(3) NOT NULL,
    TransferTime INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CashDeskID) REFERENCES CashDesks(CashDeskID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Performance (
    EmployeeID VARCHAR(10) PRIMARY KEY,
    ProcessedTransactions INT NOT NULL,
    Errors INT NOT NULL,
    AvgProcessingTime DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Queues (
    QueueID VARCHAR(10) PRIMARY KEY,
    BranchID VARCHAR(10) NOT NULL,
    DateTime VARCHAR(50) NOT NULL,
    ClientsInQueue INT NOT NULL,
    AvgWaitingTime DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

