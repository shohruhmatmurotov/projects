go
create database banking_system_project
use banking_system_project;
 create schema  core_banking;
create table core_banking.customer(CustomerId int  identity(1,1)  primary key ,
FullName varchar(50) not null ,
DOB date  not null,
Email nvarchar(50) unique not null,
PhoneNumber varchar(20) unique not null,
Address Text not null,
NationalID varchar(50) unique not null,
TaxID varchar(50) unique not null,
EmploymentStatus varchar(50) not null ,
AnnualIncome decimal(30,2) check(AnnualIncome>0) ,
CreatedAt datetime default getdate(),
UpdatedAt datetime default getdate());

select * from core_banking.customers



select * from core_banking.customers


create table core_banking.accounts(AccountId int identity(1,1) primary key ,
CustomerId int not null,
AccountType nvarchar(50) check (AccountType in ('Savings','Checking','Business','Others')),
Balance decimal(30,2) default 0 check(Balance>0),
Currency nvarchar(20) not null,
Status nvarchar(20) check(Status in ('Active','Inactive','Closed','Suspended')),
BranchId int not null,
CreatedDate datetime default getdate());



alter table core_banking.accounts
add constraint fk_accounts
foreign key(customerId) references core_banking.customers(CustomerId)

alter table core_banking.accounts
add constraint fk_accounts2
foreign key (BranchId) references core_banking.Branches(BranchId)

create table core_banking.transactions(TransactionId int identity primary key,
AccountId int not null,
TransactionType varchar(50) check (TransactionType in ('Deposit','Withdrawal','Transfer','Payment')),
Amount decimal(30,2) check (amount>0),
Currency varchar(15) not null,
date datetime default getdate(),
Status varchar(20) check (Status in ('Pending','Completed','Failed','Reversed')),
ReferenceNo varchar(50) unique not null)

select * from core_banking.transactions

 

alter table core_banking.transactions
add constraint fk_transactions
foreign key (AccountId) references core_banking.accounts(accountId)


create    table core_banking.Branches(
BranchId int  identity(1,1) primary key ,
BranchName varchar(100) not null,
Address text not null,
City varchar(50) not null,
State varchar(50) not null,
Country varchar(50) not null,
ManagerID int not null ,
ContactNumber varchar(30) unique   not null)


exec sp_help 'core_banking.Branches'

alter table core_banking.branches
add constraint fk_branches
foreign key (ManagerId) references core_banking.employees(employeeId)



create  table core_banking.employees(
EmployeeId  int  primary key identity(1,1) ,
BranchId int not null,
FullName varchar(50) not null,
Position varchar(50) not null,
Department varchar(100) not null,
Salary decimal(30,2) check(salary>0),
HireDate date not null,
Status varchar(20) check (status in ('Active','On Leave','Resigned','Terminated')),
);
alter table core_banking.employees
add constraint fk_employees
foreign key (BranchId) references core_banking.branches(BranchId)










create schema digital_banking_payments

create table digital_banking_payments.creditcards(
CardId int primary key check(len(cardid)=16),
CustomerID int not null,
CardNumber varchar(16) unique not null,
CardType varchar(50) check (Cardtype in ('Visa','Mastercard','Uzcard','Humo','Pay Pal')),
CVV varchar(4) not null,
ExpiryDate date not null,
CreditLimit decimal(30,2) check(Creditlimit>0),
Status varchar(20) check(Status in ('Active','Blocked','Expired','Cancelled')))

alter table digital_banking_payments.creditcards
add constraint fk_cards
foreign key(customerId) references core_banking.Customers(CustomerId)




create   table digital_banking_payments.CreditCardTransactions(
TransactionId int  primary key  identity(1,1),
CardId int not null,
Merchant nvarchar(200) not null,
Amount decimal(30,2) check(amount>0),
Date datetime default getdate(),
Status nvarchar(20) check (Status in ('Pending', 'Completed', 'Failed', 'Reversed')))

alter table digital_banking_payments.CreditCardTransactions
add constraint fk_transcactions
foreign key(cardId) references  digital_banking_payments.creditcards(CardId)

create  table digital_banking_payments.onlinebankingusers(
UserId int primary key  identity(1,1) ,
CustomerId int not null,
Username varchar(50) unique not null,
PasswordHash varchar(40) not null,
LastLogin datetime default null,
)

alter table digital_banking_payments.onlinebankingusers
add constraint fk_users
foreign key(customerId) references core_banking.Customers(CustomerID)


create table digital_banking_payments.BillPayments(
PaymentId int   primary key identity(1,1) ,
CustomerId int not null,
BillerName varchar(100) not null,
Amount decimal(30,2) check(amount>0),
Date datetime default getdate() ,
Status varchar(30) check (status in ('Pending', 'Completed', 'Failed', 'Reversed')))

alter table digital_banking_payments.BillPayments
add constraint fk_bill
foreign key (customerId) references  core_banking.Customers(CustomerID)

create table digital_banking_payments.MobileBankingTransactions(
TransactionId int primary key identity(1,1),
CustomerId int not null ,
DeviceId varchar(50) not null,
AppVersion varchar(50) not null,
TransactionType varchar(50) check (transactiontype in ('Deposit', 'Withdrawal', 'Transfer', 'Bill Payment')),
Amount decimal(30,2) check(amount>0),
Date datetime default getdate())

alter table digital_banking_payments.MobileBankingTransactions
add constraint fk_mobilebanking
foreign key (customerid) references core_banking.Customers(CustomerID)

create schema Loans_credit

create table loans_credit.loans(
LoanId int  primary key identity(1,1) ,
CustomerId int not null,
LoanType varchar(50) not null check (LoanType in ('Mortgage','Personal','Auto','Business')),
Amount decimal(30,2) not null,
EndDate date not null,
Status varchar(50) not null check(status in ('Active','Closed','Default','Pending')),
)

alter table loans_credit.loans
add constraint fk_loans
foreign key (customerId) references core_banking.Customers(CustomerID)


create table Loans_credit.LoanPayments(
PaymentId int  primary key identity(1,1),
LoanId int not null,
AmountPaid decimal(30,2) not null default 0,
PaymentDate date not null,
ReamainingBalance decimal(30,2) not null,
)

alter table Loans_credit.LoanPayments
add constraint fk_loanpayments
foreign key (loanId) references loans_credit.loans(LoanId)




Create table Loans_credit.CreditScores(
CustomerId int not null,
CreditScore int not null check(creditscore between 0 and 10),
UpdatedAt datetime not null default getdate());

alter table Loans_credit.CreditScores
add constraint fk_creditscores
foreign key (customerId) references core_banking.customers(customerId)


create trigger trg_update_time_loans on loans_credit.CreditScores
after update 
as 
begin 
update loans_credit.CreditScores set UpdatedAt=GETDATE() where CustomerId in (SELECT DISTINCT CustomerID FROM Inserted)

end ;

create table Loans_credit.DebtCollection(
DebId int  primary key Identity(1,1),
CustomerId int not null,
AmountDue decimal(30,2) not null check(amountdue>0),
DueDate date not null ,
CollectorAssigned varchar(100) not null )

alter table Loans_credit.DebtCollection
add constraint fk_debt
foreign key (customerId) references  core_banking.customers(customerId)




create schema Compliance_risk_management 


create table compliance_risk_management.Kyc(
KycId int  primary key identity (1,1) ,
CustomerId int not null,
DocumentType varchar(50) check(documenttype in ('Passport','National Id','Driver License','Other') ) not null,
DocumentNumber nvarchar(50) unique not null ,
VerifiedAt datetime not null default getdate())

alter table compliance_risk_management.Kyc
add constraint fk_kyc
foreign key (customerId) references  core_banking.customers(customerId)

create table compliance_risk_management.FraudDetection(
FraudId int  primary key identity(1,1) ,
CustomerId int not null,
TransactionId int not null,
RiskLevel varchar(50) not null check(risklevel in ('Low','Medium','Critical')),
ReportDate datetime not null default getdate(),
)

alter table compliance_risk_management.FraudDetection
add constraint fk_frauddetection
foreign key (customerId) references  core_banking.customers(customerId)




create table compliance_risk_management.AML_Cases(
CaseId int  primary key identity(1,1),
CustomerId int not null ,
CaseType varchar(50) not null check(Casetype in ('Suspicious Transaction', 'Structuring', 'Terrorist Financing', 'Other')),
Status varchar (50) check(status in ('Open', 'Under Investigation', 'Closed', 'Escalated') ) DEFAULT 'Open',
InvestigatorId int not null,
OpenDate datetime not null default getdate()
)

alter table compliance_risk_management.AML_Cases
add constraint aml_cases1
foreign key (customerId) references core_banking.customers(customerId)



create table compliance_risk_management.RegulatoryReports(
ReportId int  primary key  identity(1,1),
ReportType varchar(50) not null check(reportType in ('AML Compliance', 'Fraud Report', 'Transaction Monitoring', 'Other')),
SubmissionDate datetime not null default getdate()
)

create schema human_rescources_payroll;
go

create  table human_rescources_payroll.departments(
DepartmentId int  primary key identity(1,1) ,
DepartmentName varchar(50) not null unique,
ManagerId int
 )
 exec sp_help 'human_rescources_payroll.departments'

 create table human_rescources_payroll.salaries(
 SalaryId int  primary key identity(1,1),
 EmployeeId int not null,
 BaseSalary decimal(30,2) default 0.00,
Bonus decimal(30,2) default 0,
Deductions decimal(30,2) default 0,
PaymentDate date not null)

alter table human_rescources_payroll.salaries
add constraint fk_salaries
foreign key (employeeId) references core_banking.employees(employeeId)




create table human_rescources_payroll.employeeAttendance(
AttendanceId int  primary key identity(1,1),
EmployeeId int not null,
CheckInTime datetime not null ,
CheckoutTime datetime  default null,
TotalHours AS (DATEDIFF(MINUTE, CheckInTime, CheckOutTime) / 60.0) PERSISTED)
        
alter table human_rescources_payroll.employeeAttendance
add constraint fk_attendence
foreign key (employeeId) references core_banking.employees(employeeId)


create schema investment_treasury

create table investment_treasury.Investments(
InvestmentId int  primary key identity(1,1),
CustomerId int not null,
InvestmentType varchar(50) not null,
Amount decimal(30,2) not null,
ROI decimal(5,2) not null,
MaturityDate date not null)

alter table investment_treasury.Investments
add constraint fk_investment
foreign key (customerId) references core_banking.customers(customerId)



create table investment_treasury.stocktradingaccounts(
AccountId int  primary key identity(1,2),
CustomerId int not null,
BrokerageFirm varchar(100) not null,
TotalInvested decimal(30,2) not null,
CurrentValue decimal(30,2) not null)

alter table investment_treasury.stocktradingaccounts
add constraint fk_accounts
foreign key (customerID) references core_banking.customers(customerId)



create table investment_treasury.ForeignExchange(
FXID int  primary key identity(1,1),
CustomerId int not null,
CurrencyPair varchar(10) not null,
ExchangeRate decimal(30,2) not null,
AmountExchanged decimal(30,2) not null,
TransactionDate datetime default getdate())

alter table investment_treasury.ForeignExchange
add constraint fk_exchange
foreign key(customerId) references core_banking.Customers(customerId)



create schema Insurance_security

create table Insurance_security.InsurancePolicies(
PolicyId int  primary key identity(1,1),
CustomerId int not null,
InsuranceType varchar(50) not null,
PremiumAmount decimal(30,2) not null,
CoverageAmount decimal(30,2) not null,
StartDate date not null,
Enddate date not null)

alter table Insurance_security.InsurancePolicies
add constraint fk_policies
foreign key (customerId) references  core_banking.Customers(customerId)

delete from Insurance_security.InsurancePolicies
where CustomerId in (1,2,3,4,5,6,7,8,9)

create table insurance_security.claims(
ClaimId int  primary key identity(1,1),
PolicyId int not null,
ClaimAmount decimal(30,2),
Status varchar(50) check(status in ('Pending', 'Approved', 'Rejected', 'Processing', 'Paid')),
Fileddate date default getdate())

alter table insurance_security.claims
add constraint fk_claim
foreign key (policyId) references Insurance_security.InsurancePolicies(policyId)



create table insurance_security.useraccesslogs(
LogId int primary key  identity(1,1),
UserId int   not null,
ActionType varchar(40)  check (actiontype in ('Login', 'Logout', 'Failed Login', 'Password Change', 'Account Lock')),
TimeStamp datetime not null)

create table insurance_security.CybersecurityIncidents(
IncidentId int primary key identity(1,2) ,
Affectedsystem varchar(100) not null,
Reporteddate datetime default getdate(),
ResolutionStatus varchar(40) check (resolutionstatus in ('Open', 'Investigating', 'Resolved', 'Mitigated', 'Closed')))


create schema merchant_services

create table merchant_services.merchants(
MerchantId int  primary key identity(1,1),
MerchantName varchar(50) not null,
Industry varchar(50) not null,
Location varchar(100) not null,
CustomerId int  not null)

create table merchant_services.merchantTransactions(
TransactionId int  primary key identity(1,1),
MerchantId int not null,
Amount decimal(30,2) not null,
PaymentMethod varchar(40) check (paymentmethod in ('Cash','Credit card ','Debit card')),
Date datetime default getdate())



alter table merchant_services.merchantTransactions
add constraint fk_merchant
foreign key(merchantId) references merchant_services.merchants(merchantId)




select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE


select * from core_banking.customers--
select * from core_banking.accounts--
select * from core_banking.transactions--
select * from core_banking.Branches--
select * from core_banking.employees--

select * from digital_banking_payments.creditcards--
select * from digital_banking_payments.CreditCardTransactions--
select * from digital_banking_payments.onlinebankingusers--
select * from digital_banking_payments.BillPayments--
select * from digital_banking_payments.MobileBankingTransactions--



select * from Loans_credit.loans--
select * from Loans_credit.LoanPayments--
select * from Loans_credit.CreditScores--
select * from Loans_credit.DebtCollection--


select * from Compliance_risk_management.Kyc--
select * from Compliance_risk_management.FraudDetection--
select * from Compliance_risk_management.AML_Cases--
select * from Compliance_risk_management.RegulatoryReports--


select * from human_rescources_payroll.departments---
select * from human_rescources_payroll.salaries--
select * from  human_rescources_payroll.employeeAttendance--


select * from investment_treasury.Investments---
select * from  investment_treasury.stocktradingaccounts--account id from 5
select * from investment_treasury.ForeignExchange--customerid from 10


select * from  Insurance_security.InsurancePolicies--
select * from  Insurance_security.claims---
select * from  Insurance_security.useraccesslogs--
select * from  Insurance_security.CybersecurityIncidents--


select * from merchant_services.merchants--
select * from  merchant_services.merchantTransactions--

