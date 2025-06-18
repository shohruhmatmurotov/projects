import pandas as pd
import pyodbc
from faker import Faker
import random
from datetime import datetime, timedelta
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()
conn_str = os.getenv('SQL_SERVER_CONN')

# Initialize Faker with Uzbek locale
fake = Faker('uz_UZ')

# Connect to SQL Server
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Clear existing data (optional)
cursor.execute(
    "DELETE FROM Queues; DELETE FROM Performance; DELETE FROM Transactions; DELETE FROM Employees; DELETE FROM CashDesks; DELETE FROM Branches;")
conn.commit()

# 1. Branches (100 records)
branches = []
regions = ['Toshkent', 'Samarqand', 'Buxoro', 'Andijon', 'Fargona', 'Namangan', 'Qarshi']
for i in range(100):
    branch_id = f"B{i + 1:04d}"
    branches.append((
        branch_id,
        f"{random.choice(regions)} Branch",
        random.choice(regions),
        fake.street_address(),
        f"M{i + 1:04d}"
    ))
for branch in branches:
    cursor.execute("""
        INSERT INTO Branches (BranchID, BranchName, Region, Address, ManagerID)
        VALUES (?, ?, ?, ?, ?)
    """, branch)
conn.commit()

# 2. CashDesks (300 records)
cash_desks = []
branch_ids = [b[0] for b in branches]
for i in range(300):
    cash_desk_id = f"D{i + 1:04d}"
    cash_desks.append((
        cash_desk_id,
        random.choice(branch_ids),
        f"Cash Desk {i % 5 + 1}",
        random.choice(['Active', 'Inactive'])
    ))
for cash_desk in cash_desks:
    cursor.execute("""
        INSERT INTO CashDesks (CashDeskID, BranchID, CashDeskName, Status)
        VALUES (?, ?, ?, ?)
    """, cash_desk)
conn.commit()

# 3. Employees (~4000–6000 records)
employees = []
cash_desk_ids = [cd[0] for cd in cash_desks]
employee_id_counter = 1
for branch_id in branch_ids:
    num_employees = random.randint(40, 60)
    for _ in range(num_employees):
        employee_id = f"E{employee_id_counter:04d}"
        employee_id_counter += 1
        employees.append((
            employee_id,
            branch_id,
            random.choice(cash_desk_ids) if random.random() > 0.2 else None,
            fake.name(),
            random.choice(['Cashier', 'Senior Cashier', 'Manager']),
            fake.date_between(start_date='-8y', end_date='today'),
            round(random.uniform(4000000, 10000000), 2)
        ))
for employee in employees:
    cursor.execute("""
        INSERT INTO Employees (EmployeeID, BranchID, CashDeskID, FullName, Position, HireDate, Salary)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, employee)
conn.commit()

# 4. Transactions (10000 initial records)
transactions = []
employee_ids = [e[0] for e in employees]
currencies = ['USD', 'EUR']
for i in range(10000):
    transaction_id = f"T{i + 1:06d}"
    transactions.append((
        transaction_id,
        random.choice(branch_ids),
        random.choice(cash_desk_ids),
        random.choice(employee_ids),
        fake.date_time_between(start_date='-1y', end_date='now').strftime('%Y-%m-%d %H:%M:%S'),
        round(random.uniform(100, 5000), 2),
        round(random.uniform(1, 50), 2),
        random.choice(currencies),
        random.randint(1, 10)
    ))
for transaction in transactions:
    cursor.execute("""
        INSERT INTO Transactions (TransactionID, BranchID, CashDeskID, EmployeeID, Date, Amount, Profit, Currency, TransferTime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, transaction)
conn.commit()

# 5. Performance (~4000–6000 records)
performance = []
for employee_id in employee_ids:
    performance.append((
        employee_id,
        random.randint(50, 1000),
        random.randint(0, 20),
        round(random.uniform(1, 8), 2)
    ))
for perf in performance:
    cursor.execute("""
        INSERT INTO Performance (EmployeeID, ProcessedTransactions, Errors, AvgProcessingTime)
        VALUES (?, ?, ?, ?)
    """, perf)
conn.commit()

# 6. Queues (5000 initial records)
queues = []
for i in range(5000):
    queue_id = f"Q{i + 1:04d}"
    queues.append((
        queue_id,
        random.choice(branch_ids),
        fake.date_time_between(start_date='-1y', end_date='now').strftime('%Y-%m-%d %H:%M:%S'),
        random.randint(0, 25),
        round(random.uniform(1, 15), 2)
    ))
for queue in queues:
    cursor.execute("""
        INSERT INTO Queues (QueueID, BranchID, DateTime, ClientsInQueue, AvgWaitingTime)
        VALUES (?, ?, ?, ?, ?)
    """, queue)
conn.commit()

# Close connection
cursor.close()
conn.close()
print("All data inserted into SQL Server: Branches, CashDesks, Employees, Transactions, Performance, Queues")
