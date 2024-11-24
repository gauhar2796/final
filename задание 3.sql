WITH AgeGroups AS (
    SELECT 
        CASE
            WHEN c.Age IS NULL THEN 'Unknown'
            WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS AgeGroup,
        c.Id_client,
        t.date_new,
        t.Sum_payment,
        t.Id_check
    FROM 
        customers c
    JOIN 
        transactions t ON c.Id_client = t.ID_client
    WHERE 
        t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
),
QuarterlyStats AS (
    SELECT
        AGEGROUP,
        DATE_FORMAT(t.date_new, '%Y-Q%q') AS quarter,  -- Извлекаем квартал
        COUNT(t.Id_check) AS total_operations,  -- Количество операций в квартале
        SUM(t.Sum_payment) AS total_sum,  -- Сумма всех операций в квартале
        COUNT(DISTINCT t.Id_client) AS total_clients,  -- Количество уникальных клиентов в квартале
        AVG(t.Sum_payment) AS avg_check  -- Средний чек за квартал
    FROM 
        AgeGroups t
    GROUP BY 
        AGEGROUP, quarter
),
TotalStats AS (
    SELECT
        AGEGROUP,
        COUNT(t.Id_check) AS total_operations,  -- Общее количество операций за период
        SUM(t.Sum_payment) AS total_sum  -- Общая сумма операций за период
    FROM 
        AgeGroups t
    GROUP BY 
        AGEGROUP
)
SELECT 
    qs.AgeGroup,
    qs.quarter,
    qs.total_operations,
    qs.total_sum,
    qs.total_clients,
    qs.avg_check,
    qs.total_operations / ts.total_operations AS operations_percentage,  -- Доля операций от общего числа
    qs.total_sum / ts.total_sum AS sum_percentage,  -- Доля суммы операций от общей суммы
    qs.total_operations / qs.total_clients AS avg_operations_per_client,  -- Среднее количество операций на клиента
    qs.total_clients / (SELECT COUNT(DISTINCT t.ID_client) FROM transactions t WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01') AS client_percentage -- Процент клиентов от общего числа
FROM 
    QuarterlyStats qs
JOIN 
    TotalStats ts ON qs.AgeGroup = ts.AgeGroup
ORDER BY 
    qs.AgeGroup, qs.quarter;
