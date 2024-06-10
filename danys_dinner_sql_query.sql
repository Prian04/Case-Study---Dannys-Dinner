create database dannys_dinner;
use dannys_dinner;

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
  
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from members;
select * from menu;
select * from sales;

-- What is the total amount each customer spent at the restaurant?
Select customer_id , sum(price) From menu join sales on menu.product_id = sales.product_id group by sales.customer_id;

-- How many days has each customer visited the restaurant?
Select customer_id, count(distinct(order_date)) From Sales
Group by customer_id;

-- What was the first item from the menu purchased by each customer?
With cte As
(
Select sales.customer_id, menu.product_name,
Row_Number() OVER(Partition By sales.customer_id Order By sales.order_date) As rownumber
from sales join menu on sales.product_id = menu.product_id
)
Select customer_id, product_name From cte Where rownumber = 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
Select  menu.product_name, count(menu.product_name) As order_count
from sales join menu on sales.product_id = menu.product_id
Group By menu.product_name
Order By Count(menu.product_name) Desc Limit 1;

-- Which item was the most popular for each customer?
With popular_item as (
Select sales.customer_id, menu.product_name,
Count(*) as order_count,
DENSE_RANk() OVER(partition by sales.customer_id Order By Count(*) DESC) as ranks
From sales 
join menu on sales.product_id = menu.product_id
group by sales.customer_id, menu.product_name
)
Select customer_id, product_name From popular_item where ranks = 1;

-- Which item was purchased first by the customer after they became a member?
With orders As (
Select sales.customer_id, menu.product_name, sales.order_date, members.join_date,
DENSE_RANk() OVER(Partition By sales.customer_id Order By order_date) As ranks
From menu join sales On menu.product_id = sales.product_id
join members On sales.customer_id = members.customer_id
Where sales.order_date > members.join_date
)
Select customer_id, product_name From orders Where ranks = 1;

-- Which item was purchased just before the customer became a member?
With orders As (
Select sales.customer_id, menu.product_name, sales.order_date, members.join_date,
DENSE_RANk() OVER(Partition By sales.customer_id Order By order_date Desc) As ranks
From menu join sales On menu.product_id = sales.product_id
join members On sales.customer_id = members.customer_id
Where sales.order_date < members.join_date
)
Select customer_id, product_name From orders Where ranks = 1;

-- What is the total items and amount spent for each member before they became a member?
Select sales.customer_id, sales.order_date, members.join_date,
COUNT(sales.product_id) as total_items_ordered, 
SUM(menu.price) as total_amount_spent
From menu join sales on menu.product_id = sales.product_id
join members on sales.customer_id = members.customer_id
Where sales.order_date < members.join_date
group by sales.customer_id, sales.order_date, members.join_date;
 
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
With points as(
Select sales.customer_id, menu.product_name, menu.price,
CASE 
    WHEN menu.product_name = 'sushi' Then menu.price*10*2
    ELSE menu.price*10
    END as points
From sales join menu 
on sales.product_id = menu.product_id
)
Select customer_id, sum(points) as total_points from points group by customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
With points as(
Select sales.customer_id, menu.product_name, menu.price, sales.order_date, members.join_date,
CASE
    WHEN sales.order_date BETWEEN members.join_date AND DATE_ADD(members.join_date, INTERVAL 7 DAY) THEN menu.price*10*2
    WHEN menu.product_name - 'sushi' Then menu.price*10*2
    ELSE menu.price*10
    END as points
FROM menu
join sales on menu.product_id = sales.product_id
join members on sales.customer_id = members.customer_id
Where  order_date < '2021-02-01'
)
Select customer_id, sum(points) as total_points
from points group by customer_id;

-- Determine the name and price of the product ordered by each customer on all order dates & find out whether the customer was a member on the order date or not
Select sales.customer_id, sales.order_date, menu.product_name, menu.price,
CASE
    When members.join_date <= sales.order_date Then 'Y'
    else 'N'
    END as members
from menu 
join sales on menu.product_id = sales.product_id
left join members on sales.customer_id = members.customer_id;

-- Rank the  previous output based the order_date  for each customer. Display null if customer was not a member  when dis was ordered
with ranks as(
Select sales.customer_id, sales.order_date, menu.product_name, menu.price,
CASE
    When members.join_date <= sales.order_date Then 'Y'
    else 'N'
    END as member_status
from menu 
join sales on menu.product_id = sales.product_id
left join members on sales.customer_id = members.customer_id
)
Select *,
CASE
    WHEN ranks.member_status = 'Y' THEN RANK() OVER(Partition By ranks.customer_id, ranks.member_status Order By order_date)
    ELSE NULL
    END As ranking
from ranks;


select * from members;
select * from menu;
select * from sales;
  