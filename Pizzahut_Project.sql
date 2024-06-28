

create table pizzahut.orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

# Retrieve the total number of orders placed. #

use pizzahut;
select count(order_id) as "Total number of orders"
from pizzahut.orders;



# Calculate the total revenue generated from pizza sales.

select round(sum(price*quantity)) as "Total Revenue generated"
from pizzas p inner join order_details d
on p.pizza_id=d.pizza_id;


#Identify the highest-priced pizza.

select name,pizza_id,size,price as "Max priced Pizza"
from pizzas p inner join pizza_types t 
on p.pizza_type_id = t.pizza_type_id
where price = (select max(price) from pizzas);



-- List the top 5 most ordered pizza types along with their quantities.

select name,sum(quantity) as Quantity
from order_details o inner join pizzas p
on o.pizza_id=p.pizza_id
join pizza_types t 
on p.pizza_type_id=t.pizza_type_id
group by name
order by Quantity desc limit 5;


#Identify the most common pizza size ordered.

select size,count(order_details_id) as order_count
from pizzas p inner join order_details t 
on p.pizza_id = t.pizza_id
group by size
order by order_count desc limit 1;



-- Join the necessary tables to find the total quantity of each pizza category ordered.
select category,sum(quantity) "Total quantity of pizza ordered"
from pizzas p inner join order_details t 
on p.pizza_id = t.pizza_id 
join pizza_types y
on y.pizza_type_id=p.pizza_type_id
group by category
order by "Total quantity of pizza ordered";


-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hour,count(order_id)
from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) as "pizza type"
from pizza_types
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity)) as "Avg Pizza Ordered per day"
from (select order_date,(sum(quantity)) as quantity
from orders o join order_details d
on o.order_id=d.order_id
group by order_date) as qty;


-- Determine the top 3 most ordered pizza types based on revenue.

select name,round(sum(price*quantity)) as Revenue
from pizzas p inner join order_details t 
on p.pizza_id = t.pizza_id 
join pizza_types y
on y.pizza_type_id=p.pizza_type_id
group by name
order by Revenue desc limit 3;



-- Calculate the percentage contribution of each pizza type to total revenue.

select category,round((round(sum(price*quantity))/(select round(sum(price*quantity))
from pizzas p inner join order_details d
on p.pizza_id=d.pizza_id))* 100) as revenue
from pizzas p inner join order_details t 
on p.pizza_id = t.pizza_id 
join pizza_types y
on y.pizza_type_id=p.pizza_type_id
group by category;

-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over (order by order_date) as cum_revenue
from (select order_date,round(sum(price*quantity)) as revenue 
from pizzas p inner join order_details t 
on p.pizza_id = t.pizza_id 
join orders y
on y.order_id=t.order_id
group by order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

select name, revenue 
from (select category,name, revenue, rank() over (partition by category order by revenue desc) as rn
from 
(select category,name,round(sum(price* quantity)) as revenue
from pizzas p inner join order_details t 
on p.pizza_id = t.pizza_id 
join pizza_types y
on y.pizza_type_id=p.pizza_type_id
group by category , name) as a) as b
where rn<=3;





