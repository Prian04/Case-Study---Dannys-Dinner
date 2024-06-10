# Case-Study---Dannys-Dinner
Danny wants to analyze his customer data to understand visiting patterns, spending habits, and favorite menu items to improve customer experience and decide on expanding the loyalty program.   Using sql extracted the answer and insights of the problem statment which was mentioned in word document and readme.

## SQL Statment Insights Of Dannys Dinner

1)	What is the total amount each customer spent at the restaurant? <br />
   Select customer_id , sum(price) From menu join sales on menu.product_id = sales.product_id group by sales.customer_id;

2) How many days has each customer visited the restaurant? <br />
   Select customer_id, count(distinct(order_date)) From Sales Group by customer_id;

3) What was the first item from the menu purchased by each customer? <br />
  With cte As
(
Select sales.customer_id, menu.product_name,
Row_Number() OVER(Partition By sales.customer_id Order By sales.order_date) As rownumber
from sales join menu on sales.product_id = menu.product_id
)
Select customer_id, product_name From cte Where rownumber = 1;

4) What is the most purchased item on the menu and how many times was it purchased by all customers? <br />
  Select  menu.product_name, count(menu.product_name) As order_count
from sales join menu on sales.product_id = menu.product_id
Group By menu.product_name
Order By Count(menu.product_name) Desc Limit 1;

5) Which item was the most popular for each customer? <br />
  With popular_item as (
Select sales.customer_id, menu.product_name,
Count(*) as order_count,
DENSE_RANk() OVER(partition by sales.customer_id Order By Count(*) DESC) as ranks
From sales 
join menu on sales.product_id = menu.product_id
group by sales.customer_id, menu.product_name
)
Select customer_id, product_name From popular_item where ranks = 1;

6) Which item was purchased first by the customer after they became a member? <br />
  With orders As (
Select sales.customer_id, menu.product_name, sales.order_date, members.join_date,
DENSE_RANk() OVER(Partition By sales.customer_id Order By order_date) As ranks
From menu join sales On menu.product_id = sales.product_id
join members On sales.customer_id = members.customer_id
Where sales.order_date > members.join_date
)
Select customer_id, product_name From orders Where ranks = 1; 

7) Which item was purchased just before the customer became a member? <br />
  With orders As (
Select sales.customer_id, menu.product_name, sales.order_date, members.join_date,
DENSE_RANk() OVER(Partition By sales.customer_id Order By order_date Desc) As ranks
From menu join sales On menu.product_id = sales.product_id
join members On sales.customer_id = members.customer_id
Where sales.order_date < members.join_date
)
Select customer_id, product_name From orders Where ranks = 1;

8) What is the total items and amount spent for each member before they became a member? <br />
   Select sales.customer_id, sales.order_date, members.join_date,
COUNT(sales.product_id) as total_items_ordered, 
SUM(menu.price) as total_amount_spent
From menu join sales on menu.product_id = sales.product_id
join members on sales.customer_id = members.customer_id
Where sales.order_date < members.join_date
group by sales.customer_id, sales.order_date, members.join_date;

9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? <br />
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

10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? <br />
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

11) Determine the name and price of the product ordered by each customer on all order dates & find out whether the customer was a member on the order date or not? <br />
  Select sales.customer_id, sales.order_date, menu.product_name, menu.price,
CASE
    When members.join_date <= sales.order_date Then 'Y'
    else 'N'
    END as members
from menu 
join sales on menu.product_id = sales.product_id
left join members on sales.customer_id = members.customer_id;

12) Rank the  previous output based the order_date  for each customer. Display null if customer was not a member  when dis was ordered?
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

## Documentation Reference
For a comprehensive understanding of Danny's Dinner case study, including detailed SQL queries and step-by-step processes, please refer to the attached documents in the repository. The "Case Study - Danny's Dinner.docx" provides a thorough overview, accompanied by relevant image screenshots. Additionally, for data creation, consult the "dataset_queries.txt" file. For a step-by-step guide on SQL queries, refer to the SQL text file also uploaded in the repository. These resources offer a complete solution to Danny's data analysis needs. Problem statment is mentioned in word as well as in dannys_dinner_case_study_problem_statment.txt file.

    
   
