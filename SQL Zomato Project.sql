--Zomato Data Analysis--
--First Child Tables are created-
--First Parent tables are dropped

Drop Table if exists Orders;
Drop Table if exists Customers;
Drop Table if exists Restaurants;
Drop Table if exists Riders;
Drop Table if exists Deliveries;

Create Table Customers
(
		customer_id int primary key,
	    customer_name varchar(25),
	    reg_date date
);

Create Table Restaurants
(restaurant_id int primary key,
 restaurant_name varchar(55),
 city varchar(15),
 opening_hours varchar(55)
);
 
 Create Table Orders
 (
  order_id int primary key,	
  customer_id int,	
  restaurant_id	int,
  order_item varchar(55),	
  order_date date,	
  order_time time,	
  order_status varchar(25),	
  total_amount float
);
 
 Alter Table Orders
 Add Constraint fk_customers
 Foreign key (customer_id)
 References customers(customer_id);
 
 Alter Table Orders
 Add Constraint fk_restaurants
 Foreign key (restaurant_id)
 References Restaurants(restaurant_id);
 
 Create Table Riders 
 (
	 rider_id int primary key,
	 rider_name varchar(55),
	 sign_up date
);

Create Table Deliveries
(delivery_id int primary key,
 order_id int,
 delivery_status varchar(55),
 delivery_time time,	
 rider_id int,
 Constraint fk_orders foreign key (order_id) references orders(order_id),
 Constraint fk_riders foreign key (rider_id) references riders(rider_id)
);

--End of Schemas--

--Exploratory Data Analysis--
--import datasets

Select * from Customers;
Select * from Restaurants;
Select * from Orders;
Select * from Riders;
Select * from Deliveries;

--Follow hierarchy to import data

--Handling null values
Select * from Customers
where customer_name is null
or reg_date is null;

Select * from restaurants
where restaurant_name is null
or city is null
or opening_hours is null;

Select * from Orders
where order_item is null
or order_date is null
or order_time is null
or order_status is null
or total_amount is null;

Select * from riders
where rider_name is null
or sign_up is null;

Select * from deliveries 
where delivery_status is null
or delivery_time  is null;

Delete from deliveries 
where delivery_status is null
or delivery_time  is null;

--Analysis and Reports
--Q1 Write a query to find the top 5 most frequently ordered dishes by
--customer called "Arjun Mehta" in the last 1 year.
With t1 as
(
Select c.customer_id,c.customer_name,o.order_item,count(*) as tot_orders,
dense_rank() over(order by count(*) desc) as ranking
from customers as c 
join orders as o
on c.customer_id = o.customer_id
where c.customer_name = 'Arjun Mehta'
and o.order_date >= current_date - interval '1 year'
group by 1,2,3
order by 4 DESC
)
Select * from t1
where ranking <=5;
--order by 2 DESC;


--Q2 Popular time slots
--Identify the time slots during which most orders are placed
--based on two hour interval
Select
case
 when extract(hour from order_time) between 0 and 1 then '00:00 - 02:00'
 when extract(hour from order_time) between 2 and 3 then '02:00 - 04:00'
 when extract(hour from order_time) between 4 and 5 then '04:00 - 06:00'
 when extract(hour from order_time) between 6 and 7 then '06:00 - 08:00'
 when extract(hour from order_time) between 8 and 9 then '08:00 - 10:00'
 when extract(hour from order_time) between 10 and 11 then '10:00 - 12:00'
 when extract(hour from order_time) between 12 and 13 then '12:00 - 14:00'
 when extract(hour from order_time) between 14 and 15 then '14:00 - 16:00'
 when extract(hour from order_time) between 16 and 17 then '16:00 - 18:00'
 when extract(hour from order_time) between 18 and 19 then '18:00 - 20:00'
 when extract(hour from order_time) between 20 and 21 then '20:00 - 22:00'
 when extract(hour from order_time) between 22 and 23 then '22:00 - 24:00'
end as time_slot,
count(order_id) as no_orders
from Orders
group by time_slot
order by no_orders DESC;

--00:59:59 --0
--01:59:59 --1

--3. Order Value Analysis
--Find the average order value per customer who has placed more then 750 order
--Return customer name and aov
Select c.customer_id,c.customer_name,
avg(o.total_amount) as aov,
count(order_id) as total_order
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1,2
having count(order_id) > 750;

--4.High Value Customers 
--List the customers who have spent more than 100K in total on food orders
--return customer_name,Customer_id
Select c.customer_id,c.customer_name,
sum(o.total_amount) as tot_spent
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1,2
having sum(o.total_amount) > 100000;

--5. Orders without delivery
--Write a query to find orders that were placed but not delivered.
--Return restaurant name,city and number of not delivered orders.
Select r.restaurant_name,r.city,count(o.order_id)
from orders as o 
left join restaurants as r
on o.restaurant_id = r.restaurant_id
left join deliveries as d
on o.order_id = d.order_id
where d.delivery_id IS NULL
group by 1,2;


--Approach 2

Select * from orders as o
left join restaurants as r
on o.restaurant_id=r.restaurant_id
where
o.order_id not in (select order_id from deliveries);

--6. Rank restaurants by their total revenue from the last year,including
--their name,total revenue,and rank within the city
With t3 as
(
Select r.city,r.restaurant_name,sum(o.total_amount),
rank() over(partition by r.city order by sum(o.total_amount) DESC) as ranking
from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
where o.order_date >= current_date - interval '1 year'
group by 1,2
order by 1,3 DESC
)
Select * from t3
where ranking = 1;

--7. Most popular dish by city
--Identify the most popular dish in each city based on the number of orders
With t4 as
(
Select r.city,o.order_item,count(o.order_id),
rank() over(partition by r.city order by count(o.order_id) DESC) as ranking
from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
group by 1,2
order by 1,3 DESC
)
Select * from t4
where ranking = 1;

--8. Customer churn
--Find the customers who haven't placed an order in 2024 but did in 2023.
Select Distinct customer_id 
from orders
where 
extract(year from order_date) = 2023
and customer_id not in (Select Distinct customer_id 
                         from orders
                         where 
                        extract(year from order_date) = 2024)
						
--9. Cancellation rate comparison
--Calculate and compare the order cancellation rate for each restaurant
--between current year and the previous year.

With cancel_ratio23 as
(
Select o.restaurant_id,count(o.order_id) as total_orders,
count(case when d.delivery_id is null then 1 end) as not_del
from orders as o
left join
deliveries as d
on o.order_id = d.order_id
where extract(year from o.order_date) = 2023
group by 1
),
last_year as
(
Select restaurant_id,total_orders,not_del,
round(not_del::numeric/total_orders::numeric *100,2) as rat23
From cancel_ratio23
),
cancel_ratio24 as
(
Select o.restaurant_id,count(o.order_id) as total_orders,
count(case when d.delivery_id is null then 1 end) as not_del
from orders as o
left join
deliveries as d
on o.order_id = d.order_id
where extract(year from o.order_date) = 2024
group by 1
),
current_year as
(
Select restaurant_id,total_orders,not_del,
round(not_del::numeric/total_orders::numeric *100,2) as rat24
From cancel_ratio24
)
Select current_year.restaurant_id,last_year.rat23,current_year.rat24
from current_year
join last_year
on last_year.restaurant_id = current_year.restaurant_id


--Q-10 Rider Average time
--Determine each riders average delivery time
With avg_del_time as
(
Select 
d.rider_id as riders_id,
o.order_id, o.order_time,d.delivery_time,
d.delivery_time - o.order_time as time_diff,
extract(epoch from (d.delivery_time - o.order_time + case when
				   d.delivery_time< o.order_time then interval'1 day'
				   else interval'0 day' end))/60 as time_diff_inmin
from orders as o
join deliveries as d
on o.order_id = d.order_id
where d.delivery_status = 'Delivered'
)
Select riders_id,
avg(time_diff_inmin)
from avg_del_time
group by 1

--Q-11 Monthly restaurant growth ratio
--Calculate each restaurant's growth ratio based on the total number
--of delivered orders since its joining
With growth_ratio as
(
Select o.restaurant_id,
to_char(o.order_date,'mm-yy') as month,
count(o.order_id) as curr_mon_orders,
lag(count(o.order_id),1) over(partition by o.restaurant_id order by
			to_char(o.order_date,'mm-yy')) as prev_mon_orders
from deliveries as d 
join 
orders as o
on d.order_id = o.order_id
where d.delivery_status = 'Delivered'
group by 1,2
order by 1,2
)
Select restaurant_id, month,
(curr_mon_orders::numeric - prev_mon_orders::numeric)/prev_mon_orders::numeric *100 as ratio
from growth_ratio;

--Q-12 Customer Segmentation analysis
--Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups
--based on their total spending compared to the average order value(AOV)
--If a customer's total spending exceeds the AOV,label them as 'Gold',otherwise
--label them as 'silver' Write an SQL query to determine each segment's
--total number of orders and total revenue

--cx total spend
--aov
--gold
--silver
--each category and total orders and total rev
With cust_seg as
(
Select customer_id,sum(total_amount) as total_spent,
count(order_id) as tot_orders,
case when sum(total_amount)> (Select avg(total_amount) from orders) then 'Gold'
else 'Silver' end as cust_category
from orders
group by 1
)
Select cust_category,sum(tot_orders),sum(total_spent)
from cust_seg
group by 1

Select avg(total_amount) from orders --322

--Q-13 Rider's monthly earnings
--Calculate each rider's monthly earnings, assuming they earn 8% of the order
--amount.

Select d.rider_id,to_char(o.order_date,'mm-yy'),
sum(o.total_amount) as revenue,
sum(o.total_amount) * 0.08 as rider_earn
From orders as o
join deliveries as d
on o.order_id= d.order_id
group by 1,2
order by 1,3 DESC

--Q-14 Riders rating analysis
-- Find the number of 5-star, 4-star and 3-star ratings each rider has
--Riders receive this rating based on delivery time
--if orders are delivered in less than 15 min of order received time 
--the rider gets 5-star rating
-- if they deliver 15 and 20 minute they get 4 star rating
--if they deliver 20 min they get 3 star rating
With star_tot as
(
With rider_rate as
(
Select o.order_id,
o.order_time,d.delivery_time,d.rider_id,
Extract(epoch from (d.delivery_time - o.order_time + case when
	d.delivery_time < o.order_time then interval '1 day' else 
	interval '0 day' end))/60 as time_min
From orders as o join
deliveries as d
on o.order_id = d.order_id
where delivery_status = 'Delivered'
)
Select rider_id, time_min,
case when time_min::numeric < 15 then '5-star'
when time_min::numeric between 15 and 20 then '4-Star'
else '3-Star'
end as Stars
from rider_rate
)
Select rider_id, stars,count(*)
from star_tot
group by 1,2
order by 1

--Q-15 Order frequency by day:
--Analyse order frequency per day of the week and identify the peak day 
--for each restaurant
With order_fre as
(
Select r.restaurant_name,
to_char(o.order_date,'Day') as day_name,
count(o.order_id) as ord_frequency,
rank() over(partition by r.restaurant_name order by count(o.order_id) DESC) as ranking
from orders as o join 
restaurants as r
on o.restaurant_id = r.restaurant_id
group by 1,2
order by 1,3 DESC
)
Select * from order_fre 
where ranking = 1

--Q-16 Customer lifetime value(CLV)
--Calculate the total revenue generated by each customer over all
--their orders.

Select c.customer_id,c.customer_name,sum(o.total_amount) as clv
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1,2

--Q-17 Monthly Sales trends
--Identify sales trends by comparing each month's total sales to the 
--previous month.

Select extract(year from order_date) as year,
extract(month from order_date) as month,
sum(total_amount) as tot_sales,
lag(sum(total_amount),1) over(order by extract(year from order_date),
extract(month from order_date)) as pre_month
from orders
group by 1,2


--Q-18 Rider Efficiency
--Evaluate rider efficiency by determining average delivery times
--and identifying those with the lowest and highest average.
With rider_eff as
(
Select d.rider_id as riders_id,
o.order_id,d.delivery_time,o.order_time,
d.delivery_time - o.order_time as time_diff,
extract(epoch from (d.delivery_time - o.order_time + case when
				   d.delivery_time< o.order_time then interval'1 day'
				   else interval'0 day' end))/60 as time_diff_inmin
from orders as o 
join deliveries as d
on o.order_id = d.order_id
where d.delivery_status = 'Delivered'
),
average_time as
(
Select riders_id,
avg(time_diff_inmin) as avg_time
from rider_eff
group by 1
)
Select max(avg_time),min(avg_time)
from average_time

--Q-19 Order item popularity
--Track the popularity of specific order items over time and identify 
--seasonal demand spikes.
With item_pop as
(
Select *,
Extract (month from order_date) as month,
Case 
when extract(month from order_date) between 3 and 5 then 'Spring'
when extract(month from order_date) between 6 and 8 then 'Summer'
when extract(month from order_date) between 9 and 11 then 'Fall'
Else 'Winter'
End as Seasons
from orders
)
Select order_item,Seasons,count(order_item)
from item_pop
group by 1,2
order by 1,3 desc

--Q-20 Rank each city based on the total revenue for last year 2023.

Select r.city,sum(o.total_amount) as tot_rev,
rank() over(order by sum(o.total_amount) DESC) as ranking
from orders as o 
join restaurants as r
on o.restaurant_id = r.restaurant_id
group by 1
