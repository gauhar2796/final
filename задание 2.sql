WITH MonthlyStats AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        COUNT(t.Id_check) AS total_operations,  -- Количество операций в месяц
        SUM(t.Sum_payment) AS total_sum,  -- Сумма всех операций в месяц
        COUNT(DISTINCT t.ID_client) AS total_clients,  -- Количество уникальных клиентов в месяц
        AVG(t.Sum_payment) AS avg_check  -- Средняя сумма чека за месяц
    FROM 
        transactions t
    WHERE 
        t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY 
        month
),
CustomerGenderStats AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        c.Gender,
        COUNT(DISTINCT t.ID_client) AS gender_clients,  -- Количество уникальных клиентов по полу
        SUM(t.Sum_payment) AS gender_sum  -- Сумма операций по полу
    FROM 
        transactions t
    JOIN 
        customers c ON t.ID_client = c.Id_client
    WHERE 
        t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY 
        month, c.Gender
)

SELECT 
    m.month,
    m.avg_check,  -- Средняя сумма чека
    m.total_operations / m.total_clients AS avg_operations_per_client,  -- Среднее количество операций на клиента
    m.total_clients AS avg_clients_per_month,  -- Среднее количество клиентов, совершивших операции
    m.total_operations / (SELECT COUNT(Id_check) FROM transactions WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS operations_share,  -- Доля операций от общего числа за год
    m.total_sum / (SELECT SUM(Sum_payment) FROM transactions WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS sum_share,  -- Доля от общей суммы операций за год
    -- Доля затрат по полу и соотношение M/F/NA
    COALESCE(SUM(CASE WHEN c.Gender = 'M' THEN gender_sum ELSE 0 END) / m.total_sum, 0) AS male_share,
    COALESCE(SUM(CASE WHEN c.Gender = 'F' THEN gender_sum ELSE 0 END) / m.total_sum, 0) AS female_share,
    COALESCE(SUM(CASE WHEN c.Gender = 'NA' THEN gender_sum ELSE 0 END) / m.total_sum, 0) AS na_share,
    -- Процентное соотношение M/F/NA по каждому месяцу
    COALESCE(SUM(CASE WHEN c.Gender = 'M' THEN gender_clients ELSE 0 END) / m.total_clients, 0) AS male_percentage,
    COALESCE(SUM(CASE WHEN c.Gender = 'F' THEN gender_clients ELSE 0 END) / m.total_clients, 0) AS female_percentage,
    COALESCE(SUM(CASE WHEN c.Gender = 'NA' THEN gender_clients ELSE 0 END) / m.total_clients, 0) AS na_percentage
FROM 
    MonthlyStats m
LEFT JOIN 
    CustomerGenderStats cgs ON m.month = cgs.month
LEFT JOIN 
    customers c ON cgs.Gender = c.Gender
GROUP BY 
    m.month
ORDER BY 
    m.month;
