drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,
						driver_id integer,
						pickup_time datetime,
						distance VARCHAR(7),
						duration VARCHAR(10),
						cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,
						driver_id,
						pickup_time,
						distance,
						duration,
						cancellation) 
VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,
							customer_id integer,
							roll_id integer,
							not_include_items VARCHAR(4),
							extra_items_included VARCHAR(4),
							order_date datetime);
INSERT INTO customer_orders(order_id,
							customer_id,
							roll_id,
							not_include_items,
							extra_items_included,
							order_date)
Values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

--How many rolls ordered?
select COUNT(roll_id)
from customer_orders

--How many unique customer orders were made?
Select Count(Distinct(customer_id))
from customer_orders

--How many successfull orders were delivered by each driver?
SELECT driver_id, COUNT(*) AS successful_orders
FROM driver_order
WHERE cancellation IS NULL OR cancellation = '' OR cancellation NOT IN ('cancellation', 'Customer Cancellation')
GROUP BY driver_id;


--Data Cleaning (Driver Order)
--Correcting Cancellation column
select * from driver_order;

Select cancellation,
CASE 
	When cancellation in ('Cancellation', 'Customer Cancellation') Then 'Cancelled'
	Else 'Delievered'
End
from driver_order

Update driver_order
Set cancellation = (CASE 
	When cancellation in ('Cancellation', 'Customer Cancellation') Then 'Cancelled'
	Else 'Delievered'
End
)


----Correcting duration column
select * from driver_order;


Select duration,
SUBSTRING(duration, 1,2)
from driver_order

Update driver_order
Set duration = Cast(SUBSTRING(duration, 1,2) as int)
from driver_order

Update driver_order
Set duration = Convert(int, duration)
from driver_order


--Correcting duration column
Select distance,
REPLACE(distance,'km','')
from driver_order

Update driver_order
Set distance = Cast(REPLACE(distance,'km','') as float)
from driver_order

Select SUM(CAST(distance as float))
from driver_order

Select SUM(CAST(duration as int))
from driver_order

--Data Cleaning (Customer Order)
--Correcting extra items included column

select * from customer_orders;

Select extra_items_included,
REPLACE(extra_items_included, 'NaN',''),
Coalesce(extra_items_included, '')
from customer_orders

Update customer_orders
SET extra_items_included = REPLACE(extra_items_included, 'NaN','')

Update customer_orders
Set extra_items_included =
Coalesce(extra_items_included, '')

--Correcting not included items column
Update customer_orders
Set not_include_items =
Coalesce(not_include_items, '')

select * from customer_orders;
select * from rolls

--How many of each type of roll was delivered
Select roll_name, Count(customer_orders.roll_id)
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
join rolls
	on customer_orders.roll_id = rolls.roll_id
where cancellation = 'Delievered'
Group By roll_name

--How many veg and Non veg rolls were delivered by drivers individually
Select roll_name, 
		driver_id,
		Count(customer_orders.roll_id)
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
join rolls
	on customer_orders.roll_id = rolls.roll_id
where cancellation = 'Delievered'
Group By driver_id, roll_name


--How many veg and Non veg rolls were ordered by customers
Select customer_id,
		customer_orders.roll_id,
		roll_name,
		COUNT(rolls.roll_id) as Rolls_Ordered
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
join rolls
	on rolls.roll_id = customer_orders.roll_id
GROUP BY customer_id, roll_name,customer_orders.roll_id
ORDER BY roll_id

--What was the max num of rolls delivered in a single order
Select customer_orders.order_id, 
		COUNT(roll_id) as Total_Rolls_in_Order,
		Rank() Over(Order by COUNT(roll_id) desc) as Rank_O
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
WHERE cancellation = 'Delievered'
GROUP BY customer_orders.order_id
ORDER BY Total_Rolls_in_Order desc

--For each customer, how many delivered rolls had at least 1 change and how many had no changes
select *,
CASE	
	When not_include_items = '' and extra_items_included = '' then 'No change'
	Else 'Change made'
END as Changes_in_Rolls
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
where cancellation = 'Delievered'

--How many rolls were delievered which had both exclusions and extra items added
With CTE_Chan as(
select  customer_orders.order_id,
CASE	
	When not_include_items != '' and extra_items_included != '' then 'Both Excluded'
	Else 'Either 1 incl or excl'
END as Changes_in_Rolls
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
where cancellation = 'Delievered'
)
Select Changes_in_Rolls, COUNT(Changes_in_Rolls) as Count
from CTE_Chan
group by Changes_in_Rolls


--Total rolls ordered for each hour of the day?
Select *, 
		Concat(Cast(DATEPART(Hour, order_date) as varchar) , '-',
		Cast(DATEPART(Hour, order_date) as varchar) +1 ) as hours_range
	from customer_orders


Select hours_range, Count(order_id) as Rolls_ordered_every_hour from
(	Select *, 
		Concat(Cast(DATEPART(Hour, order_date) as varchar) , '-',
		Cast(DATEPART(Hour, order_date) as varchar) +1 ) as hours_range
	from customer_orders) a
Group By hours_range

--Total orders placed for each day of the week?
Select DATENAME(weekday, order_date)
from customer_orders

Select Week_Day, Count(Distinct order_id) from
(	Select *, DATENAME(weekday, order_date) as Week_Day 
	from customer_orders
) a
group By Week_day


--What was the average time in mins for driver to arriver at HQ to pick up the order and deliver
Select driver_id, Sum(Diff)/Count(order_id) from
(Select * from
(Select *, Row_number() Over(Partition by order_id order by Diff) as Rnk from
(Select driver_id, customer_orders.order_id, roll_id, DATEDIFF(MINUTE, order_date,pickup_time) as Diff
from customer_orders
join driver_order
	on customer_orders.order_id = driver_order.order_id
Where pickup_time is not null) a)b
where Rnk = 1) c
Group By driver_id

--What was the Average distance travelled for each customer?
--Select customer_id, COUNT(driver_order.driver_id)
--from
--(Select * from
--(Select * , Row_Number() Over (Partition By Order_id order by roll_id) as Rnk from
--(Select customer_id, roll_id,customer_orders.order_id, distance, duration
--from customer_orders
--join driver_order
--	on customer_orders.order_id = driver_order.order_id
--Where pickup_time is not null) a) b WHERE Rnk = 1) c
--Group By customer_id


--What was the difference between longest and the shortest time duration times to deliver orders
Select CAST(MAX(duration) as int) - CAST(Min(duration) as int)
from driver_order
where distance is not null

--What was the average speed of the driver for each delivery
Select order_id, driver_id, distance, duration, CAST(distance as float)/CAST(duration as int)
from driver_order
where distance is not null

--What is the success % of delivery drivers?
With CTE_Percent as (
Select cancellation, driver_order.driver_id,
CASE
	When cancellation like '%Delievered' then 1
	else 0
	END as Conversion
from driver_order
)
select driver_id, sum(Conversion), COUNT(driver_id), (sum(Conversion)*1.0/COUNT(driver_id))*100 as Percentage_Success
from CTE_Percent
group by driver_id
