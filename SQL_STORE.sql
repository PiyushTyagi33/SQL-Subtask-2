use sql_store;

# Calculate the total quantity of products ordered by each customer, along with their total spending:

SELECT 
    o.customer_id,
    SUM(oi.quantity) AS total_quantity_ordered,
    SUM(oi.quantity * p.unit_price) AS total_spending
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.customer_id;


# Identify the top 5 customers who have accumulated the highest number of points:

SELECT 
    customer_id,
    points
FROM customers
ORDER BY points DESC
LIMIT 5;


# Determine the month-over-month growth rate in the total quantity of products ordered

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity) AS total_quantity_ordered
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;



# Calculate the average time taken to ship orders for each shipper:

SELECT 
    s.name AS shipper_name,
    AVG(DATEDIFF(shipped_date, order_date)) AS avg_shipping_time
FROM orders o
JOIN shippers s ON o.shipper_id = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY s.name;


# Identify orders with unusually high or low total spending compared to the average order value:

SELECT 
    o.order_id,
    SUM(oi.quantity * p.unit_price) AS total_spending,
    AVG(oi.quantity * p.unit_price) AS average_order_value,
    CASE 
        WHEN SUM(oi.quantity * p.unit_price) > AVG(oi.quantity * p.unit_price) * 1.5 THEN 'High spending'
        WHEN SUM(oi.quantity * p.unit_price) < AVG(oi.quantity * p.unit_price) * 0.5 THEN 'Low spending'
        ELSE 'Normal spending'
    END AS spending_category
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;
