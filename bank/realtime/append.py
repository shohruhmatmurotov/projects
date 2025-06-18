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

# Configuration
UPDATE_FULLNAME = False

# Connect to SQL Server
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()



# Get IDs
cursor.execute("SELECT BranchID FROM Branches")
branch_ids = [row[0] for row in cursor.fetchall()]
cursor.execute("SELECT CashDeskID FROM CashDesks")
cash_desk_ids = [row[0] for row in cursor.fetchall()]
cursor.execute("SELECT EmployeeID FROM Employees")
employee_ids = [row[0] for row in cursor.fetchall()]

# 1. Update FullName (if enabled)
if UPDATE_FULLNAME:
    for employee_id in employee_ids:
        cursor.execute("""
            UPDATE Employees SET FullName = ? WHERE EmployeeID = ?
        """, (fake.name(), employee_id))
    conn.commit()

# 2. Append Transactions (1000 new records)
cursor.execute("SELECT MAX(CAST(REPLACE(TransactionID, 'T', '') AS INT)) FROM Transactions")
last_transaction_id = cursor.fetchone()[0] or 0

transactions = []
currencies = ['USD', 'EUR']
for i in range(1000):
    transaction_id = f"T{last_transaction_id + i + 1:06d}"
    transactions.append((
        transaction_id,
        random.choice(branch_ids),
        random.choice(cash_desk_ids),
        random.choice(employee_ids),
        fake.date_time_between(start_date='-1d', end_date='now').strftime('%Y-%m-%d %H:%M:%S'),
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

# 3. Update Performance
for employee_id in employee_ids:
    cursor.execute("""
        SELECT COUNT(*), SUM(CASE WHEN TransferTime > 8 THEN 1 ELSE 0 END), AVG(TransferTime)
        FROM Transactions WHERE EmployeeID = ? AND Date >= ?
    """, (employee_id, (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d %H:%M:%S')))
    count, errors, avg_time = cursor.fetchone()
    if count > 0:
        cursor.execute("""
            UPDATE Performance
            SET ProcessedTransactions = ProcessedTransactions + ?,
                Errors = Errors + ?,
                AvgProcessingTime = ?
            WHERE EmployeeID = ?
        """, (count, errors or 0, round(avg_time or 0, 2), employee_id))
    else:
        cursor.execute("""
            SELECT ProcessedTransactions, Errors, AvgProcessingTime
            FROM Performance WHERE EmployeeID = ?
        """, (employee_id,))
        if not cursor.fetchone():
            cursor.execute("""
                INSERT INTO Performance (EmployeeID, ProcessedTransactions, Errors, AvgProcessingTime)
                VALUES (?, ?, ?, ?)
            """, (employee_id, 0, 0, 0))
conn.commit()

# 4. Append Queues (1000 new records)
cursor.execute("SELECT MAX(CAST(REPLACE(QueueID, 'Q', '') AS INT)) FROM Queues")
last_queue_id = cursor.fetchone()[0] or 0

queues = []
for i in range(1000):
    queue_id = f"Q{last_queue_id + i + 1:04d}"
    queues.append((
        queue_id,
        random.choice(branch_ids),
        fake.date_time_between(start_date='-1d', end_date='now').strftime('%Y-%m-%d %H:%M:%S'),
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
print("Data updated in SQL Server: Transactions, Performance, Queues")
if UPDATE_FULLNAME:
    print("Employees FullName updated")

with open("log.txt", "a") as f:
    f.write(f"Script ran successfully {datetime.now()}\n")
