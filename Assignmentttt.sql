drop table customers
create table customer(
customer_id int,
customer_name varchar,
city varchar
);
select * from customer;
INSERT INTO customer(customer_id,customer_name,city)
	VALUES(1,'Aarav Mehta','Delhi'),
	INSERT INTO customer(customer_id,customer_name,city)
	VALUES(2,'Riya Sharma','Mumbai'),
	INSERT INTO customer(customer_id,customer_name,city)
	VALUES(3,'Kabir Jain','Delhi'),
	INSERT INTO customer(customer_id,customer_name,city)
	VALUES(4,'Neha Verma','Pune');
drop table orders
create table orders(
order_id int,
customer_id int,
order_date date,
total_amount int,
status varchar
	)
	select * from orders;
INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1001,1,'2023-06-01',4500,'Delivered'),
INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1002,1,'2023-06-03',5200,'Delivered'),
INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1003,2,'2023-06-02',3000,'Delivered'),

INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1004,2,'2023-06-10',3000,'Cancelled'),

INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1005,3,'2023-06-05',5200,'Delivered'),

INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1006,3,'2023-06-06',7000,'Delivered'),
INSERT INTO ORDERS(order_id,customer_id,order_date,total_amount,status)
VALUES(1007,4,'2023-06-09',4000,'Delivered')
drop table payments
create table payments(
payment_id int,
order_id int,
payment_date date,
payment_amount int
);
SELECT * FROM PAYMENTS;
INSERT INTO payments(payment_id,order_id,payment_date,payment_amount)
VALUES('01',1001,'2023-06-02',4500),
INSERT INTO payments(payment_id,order_id,payment_date,payment_amount)
VALUES('02',1002,'2023-06-01',5200),
INSERT INTO payments(payment_id,order_id,payment_date,payment_amount)
VALUES('03',1003,'2023-06-05',3000),

INSERT INTO payments(payment_id,order_id,payment_date,payment_amount)
VALUES('04',1006,'2023-06-08',7000),
INSERT INTO payments(payment_id,order_id,payment_date,payment_amount)
VALUES('05',1007,'2023-06-10',4000);

QUESTIONS AND ANSWERS
1.
SELECT order_id, o.customer_id, o.order_date, p.payment_id, p.payment_date, o.total_amount
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_date < o.order_date;

2.
WITH amt_multi_cust AS (
  SELECT total_amount
  FROM orders
  GROUP BY total_amount
  HAVING COUNT(DISTINCT customer_id) > 1
)
SELECT o.order_id, o.customer_id, o.order_date, o.total_amount
FROM orders o
JOIN amt_multi_cust a ON o.total_amount = a.total_amount
ORDER BY o.total_amount, o.order_date;

3.
SELECT c.customer_name, o.order_date, o.total_amount, p.payment_amount
FROM orders o
JOIN customer c ON c.customer_id = o.customer_id
LEFT JOIN payments p ON p.order_id = o.order_id
ORDER BY c.customer_name, o.order_date;

4.
SELECT DISTINCT c.customer_id, c.customer_name, o.order_id, o.order_date, o.status, p.payment_id, p.payment_date, p.payment_amount
FROM orders o
JOIN customer c ON c.customer_id = o.customer_id
JOIN payments p ON p.order_id = o.order_id
WHERE o.status = 'Cancelled';

5.
WITH customer_spend AS (
  SELECT o.customer_id, SUM(o.total_amount) AS total_spent
  FROM orders o
  WHERE o.status = 'Delivered'    
  GROUP BY o.customer_id
),
avg_spend AS (
  SELECT AVG(total_spent) AS avg_spend
  FROM customer_spend
)
SELECT c.customer_id, c.customer_name, cs.total_spent
FROM customer_spend cs
JOIN customer c ON c.customer_id = cs.customer_id
JOIN avg_spend a ON 1=1
WHERE cs.total_spent > a.avg_spend
ORDER BY cs.total_spent DESC;

6.
WITH customer_spend AS (
  SELECT o.customer_id, SUM(o.total_amount) AS total_spent
  FROM orders o
  WHERE o.status = 'Delivered'
  GROUP BY o.customer_id
),
riya AS (
  SELECT total_spent AS riya_spend
  FROM customer_spend cs
  JOIN customer c ON c.customer_id = cs.customer_id
  WHERE c.customer_name = 'Riya Sharma'
)
SELECT c.customer_id, c.customer_name, cs.total_spent
FROM customer_spend cs
JOIN customer c ON c.customer_id = cs.customer_id
JOIN riya r ON 1=1
WHERE cs.total_spent > r.riya_spend
ORDER BY cs.total_spent DESC;

7.
SELECT
  o.order_id,
  o.customer_id,
  o.order_date,
  o.total_amount,
  LAG(o.total_amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS prev_amount,
  o.total_amount - LAG(o.total_amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS diff_amount
FROM orders o
ORDER BY o.customer_id, o.order_date;

8.
SELECT
  o.order_id,
  o.customer_id,
  o.order_date,
  LEAD(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS next_order_date
FROM orders o
ORDER BY o.customer_id, o.order_date;

9.
WITH customer_spend AS (
  SELECT o.customer_id, SUM(o.total_amount) AS total_spent
  FROM orders o
  WHERE o.status = 'Delivered'
  GROUP BY o.customer_id
)
SELECT
  c.customer_id,
  c.customer_name,
  c.city,
  cs.total_spent,
  RANK() OVER (PARTITION BY c.city ORDER BY cs.total_spent DESC) AS rank_in_city
FROM customer  c
LEFT JOIN customer_spend cs ON cs.customer_id = c.customer_id
ORDER BY c.city, rank_in_city;

10.
WITH diffs AS (
  SELECT
    o.customer_id,
    o.order_id,
    o.order_date,
    LAG(o.total_amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS prev_amount,
    o.total_amount AS curr_amount,
    (LAG(o.total_amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) - o.total_amount) AS drop_amount
  FROM orders o
)
SELECT
  c.customer_id,
  c.customer_name,
  MAX(CASE WHEN drop_amount > 0 THEN drop_amount ELSE NULL END) AS max_drop
FROM diffs d
JOIN customer c ON c.customer_id = d.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY max_drop DESC NULLS LAST;
