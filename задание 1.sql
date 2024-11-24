SELECT 
    c.Id_client,
    c.Gender,
    c.Age,
    c.Count_city,
    c.Response_communcation,
    c.Communication_3month,
    c.Tenure,
    COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) AS months_active,  -- Количество месяцев, в которые были транзакции
    AVG(t.Sum_payment) AS avg_check,  -- Средний чек за период
    AVG(monthly_amount.total_monthly_amount) AS avg_monthly_spent,  -- Средняя сумма покупок за месяц
    COUNT(t.Id_check) AS total_transactions  -- Общее количество операций
FROM 
    customers c
JOIN 
    transactions t ON c.Id_client = t.ID_client
JOIN (
    SELECT 
        ID_client, 
        DATE_FORMAT(date_new, '%Y-%m') AS month, 
        SUM(Sum_payment) AS total_monthly_amount
    FROM 
        transactions
    WHERE 
        date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY 
        ID_client, month
) monthly_amount ON t.ID_client = monthly_amount.ID_client 
AND DATE_FORMAT(t.date_new, '%Y-%m') = monthly_amount.month
WHERE 
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 
    c.Id_client, c.Gender, c.Age, c.Count_city, c.Response_communcation, c.Communication_3month, c.Tenure
HAVING 
    months_active = 12  -- Убедимся, что транзакции были каждый месяц в течение года
ORDER BY 
    c.Id_client;
