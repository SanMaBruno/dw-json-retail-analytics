-- MODELO DIMENSIONAL DW

-- Dimensión: Clientes
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id TEXT PRIMARY KEY,
    username TEXT,
    name TEXT,
    birthdate TEXT,
    gender TEXT,
    tier TEXT,
    tier_and_details TEXT
);

-- Dimensión: Cuentas
CREATE TABLE IF NOT EXISTS dim_account (
    account_id TEXT PRIMARY KEY,
    customer_id TEXT,
    account_limit REAL,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);

-- Tabla puente: Cuentas ↔ Productos
CREATE TABLE IF NOT EXISTS dim_account_product (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id TEXT NOT NULL,
    product TEXT NOT NULL,
    FOREIGN KEY (account_id) REFERENCES dim_account(account_id)
);

-- Hechos: Transacciones
CREATE TABLE IF NOT EXISTS fact_transaction (
    transaction_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,
    transaction_date TEXT,
    amount REAL,
    transaction_type TEXT,
    symbol TEXT,
    FOREIGN KEY (account_id) REFERENCES dim_account(account_id)
);
