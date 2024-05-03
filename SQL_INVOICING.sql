use sql_invoicing;

select * from clients;

# Write a query to calculate the average invoice total for each client, alongside the total number of invoices they have.

SELECT 
    client_id,
    AVG(invoice_total) AS average_invoice_total,
    COUNT(*) AS total_invoices
FROM invoices
GROUP BY client_id;


# Identify the top 3 clients who have the highest invoice totals, considering only invoices within the last 3 months from the overall highest invoice data.

SELECT 
    i.client_id,
    SUM(i.invoice_total) AS total_invoice_amount
FROM invoices i
WHERE i.invoice_date >= DATE_SUB(2019-11-25, INTERVAL 3 MONTH)
GROUP BY i.client_id
ORDER BY total_invoice_amount DESC
LIMIT 3;


# Find the most recent invoice for each client, along with the previous invoice date and the difference in days between them.

SELECT 
    prev_invoice.client_id,
    max_invoice.most_recent_invoice_date,
    prev_invoice.previous_invoice_date,
    DATEDIFF(max_invoice.most_recent_invoice_date, prev_invoice.previous_invoice_date) AS days_between_invoices
FROM (SELECT 
          client_id,
          MAX(invoice_date) AS most_recent_invoice_date
      FROM invoices
      GROUP BY client_id) AS max_invoice
LEFT JOIN (SELECT 
               client_id,
               LAG(invoice_date) OVER (PARTITION BY client_id ORDER BY invoice_date) AS previous_invoice_date
           FROM invoices) AS prev_invoice
ON max_invoice.client_id = prev_invoice.client_id;




# Determine the quartile rank of each client based on their total payments, considering both invoice and payment amounts.

WITH combined_payments AS (
    SELECT 
        client_id,
        SUM(invoice_total) AS total_payments
    FROM invoices
    GROUP BY client_id
    UNION ALL
    SELECT 
        p.client_id,
        SUM(p.amount) AS total_payments
    FROM payments p
    GROUP BY p.client_id
)
SELECT 
    client_id,
    NTILE(4) OVER (ORDER BY total_payments DESC) AS quartile_rank
FROM (
    SELECT 
        client_id,
        SUM(total_payments) AS total_payments
    FROM combined_payments
    GROUP BY client_id
) AS combined_payments;




# Write a query to flag invoices as "paid on time" or "late payment" based on the due date and payment date.

SELECT 
    invoice_id,
    CASE 
        WHEN payment_date <= due_date THEN 'Paid on time'
        ELSE 'Late payment'
    END AS payment_status
FROM invoices;



# Create a query to categorize invoices as "high value" or "low value" based on whether the invoice total is above or below the average invoice total.

SELECT 
    invoice_id,
    CASE 
        WHEN invoice_total > (SELECT AVG(invoice_total) FROM invoices) THEN 'High value'
        ELSE 'Low value'
    END AS invoice_category
FROM invoices;
