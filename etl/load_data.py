import json
import sqlite3
from pathlib import Path

# Conexión a la base de datos
db_path = Path("db/dw_retail.db")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# === 1. Cargar customers.json ===
if not Path("data/raw/customers.json").exists():
    raise FileNotFoundError("El archivo 'data/raw/customers.json' no se encuentra. Verifica que esté en la ruta correcta.")
with open("data/raw/customers.json", "r") as f:
    customers = json.load(f)

# Mapear correctamente cada ID de cuenta (del campo "id" en accounts.json) al username del cliente
account_to_username = {}
for cust in customers:
    for acc_id in cust.get("accounts", []):
        account_to_username[int(acc_id)] = cust["username"]

# Inserta clientes
for cust in customers:
    birthdate = cust.get("birthdate")
    if isinstance(birthdate, dict):
        birthdate = (
            birthdate.get("$date")
            or birthdate.get("date")
            or birthdate.get("value")
            or None
        )
    if isinstance(birthdate, (dict, list)):
        birthdate = str(birthdate)
    tier_and_details_dict = cust.get("tier_and_details", {})
    # Extrae el primer tier encontrado en tier_and_details (o None si no hay)
    tier = None
    if isinstance(tier_and_details_dict, dict):
        for k, v in tier_and_details_dict.items():
            if isinstance(v, dict) and "tier" in v:
                tier = v["tier"]
                break
    tier_and_details = json.dumps(tier_and_details_dict)
    cursor.execute("""
        INSERT OR IGNORE INTO dim_customer (customer_id, username, name, birthdate, gender, tier, tier_and_details)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        cust.get("username"),
        cust.get("username"),
        cust.get("name"),
        birthdate,
        cust.get("gender"),
        tier,
        tier_and_details
    ))

# === 2. Cargar accounts.json ===
if not Path("data/raw/accounts.json").exists():
    raise FileNotFoundError("El archivo 'data/raw/accounts.json' no se encuentra. Verifica que esté en la ruta correcta.")
with open("data/raw/accounts.json", "r") as f:
    accounts = json.load(f)

for acc in accounts:
    account_id = acc.get("account_id") or acc.get("id")
    if account_id is None:
        continue
    customer_username = account_to_username.get(int(account_id))
    if not customer_username:
        continue
    cursor.execute("""
        INSERT OR IGNORE INTO dim_account (account_id, customer_id, account_limit)
        VALUES (?, ?, ?)
    """, (
        account_id,
        customer_username,
        acc.get("limit")
    ))

    for product in acc.get("products", []):
        cursor.execute("""
            INSERT INTO dim_account_product (account_id, product)
            VALUES (?, ?)
        """, (
            account_id,
            product
        ))

# === 3. Cargar transactions.json ===
if not Path("data/raw/transactions.json").exists():
    raise FileNotFoundError("El archivo 'data/raw/transactions.json' no se encuentra. Verifica que esté en la ruta correcta.")
with open("data/raw/transactions.json", "r") as f:
    transactions = json.load(f)

transaction_id = 1
for tx_group in transactions:
    account_id = tx_group.get("account_id")
    for tx in tx_group.get("transactions", []):
        tx_date = tx.get("date")
        if isinstance(tx_date, dict):
            tx_date = (
                tx_date.get("$date")
                or tx_date.get("date")
                or tx_date.get("value")
                or None
            )
        if isinstance(tx_date, (dict, list)):
            tx_date = str(tx_date)
        cursor.execute("""
            INSERT OR IGNORE INTO fact_transaction (
                transaction_id, account_id, transaction_date,
                amount, transaction_type, symbol
            )
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            transaction_id,
            account_id,
            tx_date,
            tx.get("amount"),
            tx.get("transaction_code"),
            tx.get("symbol")
        ))
        transaction_id += 1

# Commit y cerrar
conn.commit()
conn.close()
print("✅ ETL completado correctamente.")