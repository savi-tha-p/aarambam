import sqlite3
import os

db_name = "aarambam.db"
schema_name = "schema.sql"

print("==================================================")
print("Aarambam Event Management Local Database Builder")
print("==================================================")

if not os.path.exists(schema_name):
    print(f"Error: Schema file '{schema_name}' not found!")
    exit(1)

print(f"Reading database schema from '{schema_name}'...")
with open(schema_name, "r", encoding="utf-8") as schema_file:
    sql_script = schema_file.read()

print(f"Connecting to database '{db_name}'...")
conn = sqlite3.connect(db_name)
cursor = conn.cursor()

try:
    print("Executing schema script...")
    cursor.executescript(sql_script)
    conn.commit()
    print("Database schema successfully applied!")
except Exception as e:
    print(f"Error applying database schema: {e}")
    conn.rollback()
    conn.close()
    exit(1)

# Verify table creation
print("\nVerifying database tables:")
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = [row[0] for row in cursor.fetchall()]
for table in ["accounts", "bookings", "members", "room_reservations", "room_meta", "settings"]:
    if table in tables:
        print(f"  [ OK ] Table '{table}' exists.")
    else:
        print(f"  [ERROR] Table '{table}' is MISSING!")

# Verify seeded admins
print("\nVerifying seeded records:")
cursor.execute("SELECT email, role FROM accounts;")
accounts = cursor.fetchall()
print(f"  Total accounts registered: {len(accounts)}")
for email, role in accounts:
    print(f"    - {email} ({role})")

cursor.execute("SELECT key, value FROM settings;")
settings = cursor.fetchall()
print(f"  Total settings applied: {len(settings)}")
for k, v in settings:
    print(f"    - {k}: {v}")

conn.close()
print("\n==================================================")
print("Database build completed successfully!")
print("==================================================")
