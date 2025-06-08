# 📊 Resultados Analíticos - Data Warehouse Retail

**Autor:** Bruno San Martín Navarro
**Fecha:** 2025-06-08
**Descripción:** Respuestas a las preguntas analíticas sobre el Data Warehouse construido a partir de archivos JSON. Consultas ejecutadas en SQLite.

---

## 1. Estadísticas del límite de las cuentas de usuarios

**Consulta SQL:**
```sql
SELECT
    'Promedio' AS Indicador, ROUND(AVG(account_limit), 2) AS Valor
FROM dim_account
UNION ALL
SELECT 'Mínimo', MIN(account_limit) FROM dim_account
UNION ALL
SELECT 'Máximo', MAX(account_limit) FROM dim_account
UNION ALL
SELECT 'Desviación estándar aprox.',
       ROUND((AVG(account_limit * account_limit) - AVG(account_limit) * AVG(account_limit)), 2)
FROM dim_account;
```

**Resultado:**

| Indicador                 | Valor      |
|---------------------------|------------|
| Promedio                  | 9955.87    |
| Mínimo                    | 3000.0     |
| Máximo                    | 10000.0    |
| Desviación estándar aprox | 125846.59  |

**Interpretación:**  
El límite promedio de las cuentas es de $9.955,87, con un mínimo de $3.000 y un máximo de $10.000. La alta desviación estándar indica gran dispersión, posiblemente por distintos perfiles de clientes.

---

## 2. ¿Cuántos clientes poseen más de una cuenta?

**Consulta SQL:**
```sql
SELECT COUNT(*) AS "Clientes con >1 Cuenta"
FROM (
    SELECT customer_id
    FROM dim_account
    GROUP BY customer_id
    HAVING COUNT(*) > 1
);
```

**Resultado:**

| Clientes con >1 Cuenta |
|------------------------|
| 414                    |

**Interpretación:**  
414 clientes tienen más de una cuenta, lo que puede indicar clientes con necesidades financieras diversificadas.

---

## 3. Monto promedio y número de transacciones en junio

**Consulta SQL:**
```sql
SELECT
    ROUND(AVG(amount), 2) AS "Promedio Monto Junio",
    COUNT(*) AS "Total Transacciones Junio"
FROM fact_transaction
WHERE strftime('%m', transaction_date) = '06';
```

**Resultado:**

| Promedio Monto Junio | Total Transacciones Junio |
|----------------------|--------------------------|
| 5003.49              | 7507                     |

**Interpretación:**  
En junio se realizaron 7.507 transacciones con un monto promedio de $5.003,49.

---

## 4. Cuenta con mayor diferencia entre transacción más alta y más baja

**Consulta SQL:**
```sql
SELECT account_id AS "Cuenta",
       MAX(amount) - MIN(amount) AS "Diferencia Máxima"
FROM fact_transaction
GROUP BY account_id
ORDER BY "Diferencia Máxima" DESC
LIMIT 1;
```

**Resultado:**

| Cuenta   | Diferencia Máxima |
|----------|-------------------|
| 909802   | 9991.0            |

**Interpretación:**  
La cuenta 909802 presenta la mayor diferencia entre sus transacciones, lo que puede indicar operaciones atípicas o clientes con alto movimiento.

---

## 5. Cuentas con exactamente 3 productos y uno es "Commodity"

**Consulta SQL:**
```sql
SELECT COUNT(*) AS "Cuentas con 3 productos y Commodity"
FROM (
    SELECT account_id
    FROM dim_account_product
    GROUP BY account_id
    HAVING COUNT(*) = 3 AND SUM(product = 'Commodity') > 0
);
```

**Resultado:**

| Cuentas con 3 productos y Commodity |
|-------------------------------------|
| 202                                 |

**Interpretación:**  
202 cuentas tienen exactamente 3 productos y al menos uno es "Commodity", mostrando una preferencia relevante por este producto.

---

## 6. Cliente con más transacciones de tipo "sell"

**Consulta SQL:**
```sql
SELECT c.name AS "Nombre del Cliente", COUNT(*) AS "Total Transacciones Sell"
FROM fact_transaction t
JOIN dim_account a ON t.account_id = a.account_id
JOIN dim_customer c ON a.customer_id = c.username
WHERE t.transaction_type = 'sell'
GROUP BY c.username
ORDER BY "Total Transacciones Sell" DESC
LIMIT 1;
```

**Resultado:**

| Nombre del Cliente | Total Transacciones Sell |
|--------------------|-------------------------|
| Jamie Bray         | 253                     |

**Interpretación:**  
Jamie Bray es el cliente con mayor cantidad de ventas, lo que puede indicar un perfil de cliente activo en el mercado secundario.

---

## 7. Usuario con cuenta (10-20) transacciones "buy" y mayor promedio

**Consulta SQL:**
```sql
SELECT c.username AS "Usuario",
       ROUND(AVG(t.amount), 2) AS "Promedio de Inversión"
FROM fact_transaction t
JOIN dim_account a ON t.account_id = a.account_id
JOIN dim_customer c ON a.customer_id = c.username
WHERE t.transaction_type = 'buy'
GROUP BY a.account_id
HAVING COUNT(*) BETWEEN 10 AND 20
ORDER BY "Promedio de Inversión" DESC
LIMIT 1;
```

**Resultado:**

| Usuario | Promedio de Inversión |
|---------|----------------------|
| pbrown  | 7453.84              |

**Interpretación:**  
El usuario `pbrown` tiene la cuenta con mayor promedio de inversión entre quienes realizaron entre 10 y 20 compras.

---

## 8. Promedio de transacciones de compra y venta por acción (symbol)

**Consulta SQL:**
```sql
SELECT
    symbol AS "Acción",
    ROUND(AVG(CASE WHEN transaction_type = 'buy' THEN amount END), 2) AS "Promedio Compra",
    ROUND(AVG(CASE WHEN transaction_type = 'sell' THEN amount END), 2) AS "Promedio Venta"
FROM fact_transaction
GROUP BY symbol;
```

**Resultado (extracto):**

| Acción | Promedio Compra | Promedio Venta |
|--------|-----------------|---------------|
| aapl   | 4960.32         | 5007.65       |
| adbe   | 5034.05         | 4957.62       |
| ...    | ...             | ...           |

**Interpretación:**  
Se observa un comportamiento estable en los montos promedio de compra y venta por acción, con ligeras variaciones entre símbolos.

---

## 9. Beneficios de clientes del tier “Gold”

**Consulta SQL:**
```sql
SELECT DISTINCT b.value AS "Beneficio"
FROM dim_customer c,
     json_each(c.tier_and_details) AS j,
     json_each(j.value, '$.benefits') AS b
WHERE json_extract(j.value, '$.tier') = 'Gold';
```

**Resultado:**

| Beneficio                      |
|--------------------------------|
| sports tickets                 |
| concert tickets                |
| dedicated account representative|
| airline lounge access          |
| car rental insurance           |
| financial planning assistance  |
| concierge services             |
| shopping discounts             |
| travel insurance               |
| 24 hour dedicated line         |

**Interpretación:**  
Los clientes Gold acceden a una amplia gama de beneficios exclusivos, lo que puede ser un factor de retención y diferenciación.

---

## 10. Cantidad de clientes por rangos etarios con al menos una compra de “amzn”

**Consulta SQL:**
```sql
SELECT
    COALESCE(
        ((CAST((julianday('2025-05-16') - julianday(SUBSTR(birthdate, 1, 10))) / 365 AS INT) / 10) * 10) || '-' ||
        (((CAST((julianday('2025-05-16') - julianday(SUBSTR(birthdate, 1, 10))) / 365 AS INT) / 10) * 10) + 9),
        '10–19'
    ) AS "Rango Etario",
    COUNT(DISTINCT c.customer_id) AS "Cantidad de Clientes"
FROM dim_customer c
JOIN dim_account a ON c.username = a.customer_id
JOIN fact_transaction t ON a.account_id = t.account_id
WHERE t.symbol = 'amzn'
  AND t.transaction_type = 'buy'
  AND birthdate IS NOT NULL
  AND LENGTH(SUBSTR(birthdate, 1, 10)) = 10
GROUP BY "Rango Etario"
ORDER BY
    CASE WHEN "Rango Etario" = '[10–19]' THEN 0 ELSE CAST(SUBSTR("Rango Etario", 1, 2) AS INT) END;
```

**Resultado:**

| Rango Etario | Cantidad de Clientes |
|--------------|---------------------|
| 10–19        | 17                  |
| 20-29        | 10                  |
| 30-39        | 56                  |
| 40-49        | 44                  |
| 50-59        | 23                  |

**Interpretación:**  
La mayor cantidad de clientes compradores de "amzn" se concentra en los rangos de 30 a 49 años, lo que puede orientar estrategias de marketing y producto.

---

**Fin de resultados analíticos.**
