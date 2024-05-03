use sql_hr;

SELECT 
	office_id, 
	SUM(salary) AS total_salary_payout
FROM 
	employees e
GROUP BY 
	1
ORDER BY 
	total_salary_payout DESC
LIMIT 
	1;


WITH ranked_employees AS (
    SELECT employee_id, office_id, salary, 
           ROW_NUMBER() OVER (PARTITION BY office_id ORDER BY salary DESC) AS ranking
    FROM employees
)
SELECT employee_id, office_id, salary
FROM ranked_employees
WHERE ranking <= 3;

