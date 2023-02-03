create database dannys_diner;
use dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);
INSERT INTO sales
  (customer_id, order_date, product_id)
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
  select * from sales;
  -------------------------------------------
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
  );
  INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  select * from menu;
  --------------------------
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE);
  
  INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from members;
  
  --- QUESTIONS
  --- 1. What is the total amount each customer spent at the restaurant?
--- 2. How many days has each customer visited the restaurant?
--- 3. What was the first item from the menu purchased by each customer?
--- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
--- 5. Which item was the most popular for each customer?
--- 6. Which item was purchased first by the customer after they became a member?
--- 7. Which item was purchased just before the customer became a member?
--- 8. What is the total items and amount spent for each member before they became a member?
--- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--- ANS🤩🤩

--- 1 
select s.customer_id,sum(m.price) from sales as s join   menu as m on s.product_id = m.product_id group by s.customer_id;
--- 2
select  (customer_id),   count(distinct(order_date)) from sales group by customer_id;
--- 3
with prime_1 as
( select s.customer_id,m.product_name,dense_rank() over(partition by s.customer_id order by s.order_date)as rank_11   from sales as s join   menu as m on s.product_id = m.product_id )
  select customer_id,product_name from prime_1 where rank_11 =1 group by customer_id,product_name;
  
--- 4
select m.product_name,count(s.product_id) from sales as s join   menu as m on s.product_id = m.product_id group by m.product_name order by count(s.product_id) desc limit 1;

--- 5
WITH fav_item_cte AS
( SELECT s.customer_id, m.product_name, 
  COUNT(m.product_id) AS order_count,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY COUNT(s.customer_id) DESC) AS rank_99
FROM menu AS m
JOIN sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM fav_item_cte 
WHERE rank_99 = 1;  
--- 6
with order_by as
(select s.customer_id,m.join_date,s.order_date,s.product_id, dense_rank() over(partition by s.customer_id order by s.order_date) as rank_order from sales as s join  members as m on s.customer_id = m.customer_id where s.order_date>= m.join_date) 
select customer_id,order_by.product_id,menu.product_name  from order_by join menu on order_by. product_id=menu.product_id where rank_order = 1;

--- 7
with order_after as
(select s.customer_id,m.join_date,s.order_date,s.product_id, dense_rank() over(partition by s.customer_id order by s.order_date desc) as rank_order from sales as s join  members as m on s.customer_id = m.customer_id where s.order_date < m.join_date)
select customer_id,menu.product_name  from order_after join menu on order_after. product_id=menu.product_id where rank_order = 1;

--- 8
with money as
(select s.customer_id,s.product_id from sales as s join  members as m on s.customer_id = m.customer_id where s.order_date < m.join_date) 
select m.customer_id,count(m.product_id) as total_item,sum(p.price) as total_spend from money as m join menu as p on m.product_id = p.product_id group by m.customer_id;

--- 9
SELECT customer_id,
SUM(CASE WHEN product_id = 1 THEN 20*price ELSE 10*price END) AS points
FROM sales s JOIN menu m USING(product_id)
GROUP BY customer_id;

