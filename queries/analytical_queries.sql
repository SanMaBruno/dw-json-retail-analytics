-- ===========================================
-- CONSULTAS ANALÍTICAS - DATA WAREHOUSE RETAIL
-- ===========================================

-- Recomendación: Antes de ejecutar, activa modo columnas y encabezados en SQLite CLI:
-- .mode column
-- .headers on

-- -------------------------------------------------
-- 1. Estadísticas del límite de las cuentas de usuarios
-- -------------------------------------------------
SELECT
    'Promedio' AS Indicador, ROUND(AVG(account_limit), 2) AS Valor
FROM dim_account
UNION ALL
SELECT
    'Mínimo', MIN(account_limit)
FROM dim_account
UNION ALL
SELECT
    'Máximo', MAX(account_limit)
FROM dim_account
UNION ALL
SELECT
    'Desviación estándar aprox.',
    ROUND((AVG(account_limit * account_limit) - AVG(account_limit) * AVG(account_limit)), 2)
FROM dim_account;

-- -------------------------------------------------
-- 2. ¿Cuántos clientes poseen más de una cuenta?
-- -------------------------------------------------
SELECT COUNT(*) AS "Clientes con >1 Cuenta"
FROM (
    SELECT customer_id
    FROM dim_account
    GROUP BY customer_id
    HAVING COUNT(*) > 1
);

-- -------------------------------------------------
-- 3. Monto promedio y número de transacciones en junio
-- -------------------------------------------------
SELECT
    ROUND(AVG(amount), 2) AS "Promedio Monto Junio",
    COUNT(*) AS "Total Transacciones Junio"
FROM fact_transaction
WHERE strftime('%m', transaction_date) = '06';

-- -------------------------------------------------
-- 4. Cuenta con mayor diferencia entre transacción más alta y más baja
-- -------------------------------------------------
SELECT account_id AS "Cuenta",
       MAX(amount) - MIN(amount) AS "Diferencia Máxima"
FROM fact_transaction
GROUP BY account_id
ORDER BY "Diferencia Máxima" DESC
LIMIT 1;

-- -------------------------------------------------
-- 5. Cuentas con exactamente 3 productos y uno es "Commodity"
-- -------------------------------------------------
SELECT COUNT(*) AS "Cuentas con 3 productos y Commodity"
FROM (
    SELECT account_id
    FROM dim_account_product
    GROUP BY account_id
    HAVING COUNT(*) = 3 AND SUM(product = 'Commodity') > 0
);

-- -------------------------------------------------
-- 6. Cliente con más transacciones de tipo "sell"
-- -------------------------------------------------
SELECT c.name AS "Nombre del Cliente", COUNT(*) AS "Total Transacciones Sell"
FROM fact_transaction t
JOIN dim_account a ON t.account_id = a.account_id
JOIN dim_customer c ON a.customer_id = c.username
WHERE t.transaction_type = 'sell'
GROUP BY c.username
ORDER BY "Total Transacciones Sell" DESC
LIMIT 1;

-- -------------------------------------------------
-- 7. Usuario con cuenta (10-20) transacciones "buy" y mayor promedio
-- -------------------------------------------------
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

-- -------------------------------------------------
-- 8. Promedio de transacciones de compra y venta por acción (symbol)
-- -------------------------------------------------
SELECT
    symbol AS "Acción",
    ROUND(AVG(CASE WHEN transaction_type = 'buy' THEN amount END), 2) AS "Promedio Compra",
    ROUND(AVG(CASE WHEN transaction_type = 'sell' THEN amount END), 2) AS "Promedio Venta"
FROM fact_transaction
GROUP BY symbol;

-- -------------------------------------------------
-- 9. Beneficios de clientes del tier “Gold”
-- -------------------------------------------------
SELECT DISTINCT b.value AS "Beneficio"
FROM dim_customer c,
     json_each(c.tier_and_details) AS j,
     json_each(j.value, '$.benefits') AS b
WHERE json_extract(j.value, '$.tier') = 'Gold';

-- -------------------------------------------------
-- 10. Cantidad de clientes por rangos etarios con al menos una compra de “amzn”
-- -------------------------------------------------
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

-- ===========================================
-- FIN DE CONSULTAS ANALÍTICAS
-- ===========================================