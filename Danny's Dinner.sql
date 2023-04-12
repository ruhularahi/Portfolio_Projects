--Creating Table for analysis

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, 
		sum(price) as Total_Spent
	FROM sales as s
	INNER JOIN menu as m
	ON s.product_id = m.product_id
	GROUP BY customer_id
	ORDER BY customer_id;
	
--2. How many days has each customer visited the restaurant?
SELECT customer_id, 
	   count(distinct(order_date))
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?

WITH row_number as (
		SELECT customer_id,
		s.product_id,
		order_date,
		product_name,
		row_number() over(partition by customer_id order by order_date, s.product_id) as rn
	FROM sales as s
	Inner join menu as m
	ON s.product_id = m.product_id
)

Select customer_id,
	product_name as Menu
FROM row_number
WHERE rn=1;

--4.What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, 
	count(s.product_id) as number_of_times_purchased
FROM menu as m
INNER JOIN sales as s
ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY number_of_times_purchased desc
LIMIT 1;

--5. Which item was the most popular for each customer?
WITH cte_rank as (Select s.customer_id,
	m.product_name,
	rank() over(partition by s.customer_id order by count(s.product_id)) as rank
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
Group by s.customer_id, m.product_name)

SELECT customer_id,
	product_name as most_popular
FROM cte_rank
WHERE rank = 1;

--6. Which item was purchased first by the customer after they became a member?
WITH cte_rank as 
(SELECT s.customer_id,
	m.product_name,
	rank() over(partition by s.customer_id order by s.order_date) as rn
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
INNER JOIN members as m2
ON s.customer_id = m2.customer_id
WHERE order_date >= join_date)

SELECT customer_id, product_name
FROM cte_rank
WHERE rn =1;

--7. Which item was purchased just before the customer became a member?
WITH cte_rank as (SELECT s.customer_id,
	m.product_name,
	rank() over(partition by s.customer_id order by s.order_date) as rn
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
INNER JOIN members as m2
ON s.customer_id = m2.customer_id
WHERE order_date < join_date)

SELECT customer_id, product_name
FROM cte_rank
WHERE rn =1;

--8. What is the total items and amount spent for each member before they became a member?
WITH cte_table as (SELECT s.customer_id,
	count(m.product_id) as total_items,
	sum(m.price) as total_amount
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
INNER JOIN members as m2
ON s.customer_id = m2.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id)

SELECT customer_id, total_items, total_amount
FROM cte_table
ORDER BY total_items;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH cte_table AS (
	SELECT customer_id,
			SUM(CASE 
					WHEN m.product_name = 'sushi' THEN (price*20)
					ELSE (price*10)
				END
			) as Total_Points
	FROM sales as s
	INNER JOIN menu as m
	ON s.product_id = m.product_id
	GROUP BY customer_id
)
SELECT *
FROM cte_table
ORDER BY customer_id;

/*10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January?*/

WITH cte_table as(
	SELECT s.customer_id,
    SUM(
			CASE 
				WHEN s.order_date < m.join_date THEN 
					CASE
						WHEN m2.product_name = 'sushi' THEN (m2.price*20)
						ELSE (m2.price*10)
					END
				WHEN s.order_date > (m.join_date+6) THEN 
					CASE
						WHEN m2.product_name = 'sushi' THEN (m2.price*20)
						ELSE (m2.price*10)
					END
				ELSE (m2.price*20)
			END
		)as Total_Points
	FROM sales as s
	INNER JOIN members as m
	ON s.customer_id =m.customer_id
	INNER JOIN menu as m2
	ON s.product_id = m2.product_id
	WHERE order_date <= '2021-01-31'
	GROUP BY s.customer_id

)
SELECT *
FROM cte_table;

