--select all
 select *
from 
project.dbo.[pizza csv]
order by order_id





--WITH category AS (
--    SELECT
--        pizza_category,
--        SUM(total_price) AS Revenue_per_pizza_category
--    FROM
--        project.dbo.[pizza csv]
--    GROUP BY
--        pizza_category
--),
--sales AS (
--    SELECT
--        pizza_category,
--        SUM(quantity) AS total_pizza_sold
--    FROM
--        project.dbo.[pizza csv]
--    GROUP BY
--        pizza_category
--)

--SELECT
--    c.pizza_category,
--    c.Revenue_per_pizza_category,
--    s.total_pizza_sold,
--    (s.total_pizza_sold * 100.0) / NULLIF(SUM(s.total_pizza_sold) OVER(), 0) AS Percentage_of_Sales
--FROM
--    category c
--JOIN
--    sales s ON c.pizza_category = s.pizza_category;




--kpis
--find total_revenue, total_order and total_pizza_sold
select 
sum (total_price) as total_revenue,
count (distinct order_id) as total_order,
sum (quantity) as total_pizza_sold
from 
project.dbo.[pizza csv] 



--find avg_order_value and avg_pizza_sold_per_order
with avg as(
select 
sum (total_price) as total_revenue,
count (distinct cast(order_id as float)) as total_order,
sum (cast(quantity as float)) as total_pizza_sold

from 
project.dbo.[pizza csv] 
)

select  round(total_revenue/total_order, 3) as avg_order_value,
round(total_pizza_sold/total_order, 3) as avg_pizza_sold_per_order
from avg









--kpis
--find out order per days of week trend first method represent days by names 
select   datename(DW, order_date) as Days_of_Week,  count(distinct order_id) as total_order
from 
project.dbo.[pizza csv]
group by  datename(DW, order_date)



--find out order per days of week trend second method represent days by number
select   datepart(DW, order_date) as Days_of_Week,  count(distinct order_id) as total_order
from 
project.dbo.[pizza csv]
group by  datepart(DW, order_date)
order by datepart(DW, order_date)



--find out hourly trend first method
select  substring( CONVERT(varchar, order_time ), 1,2) as daily_hours, count(distinct order_id) as total_orders
from 
project.dbo.[pizza csv]
group by substring( CONVERT(varchar, order_time ), 1,2)
order by substring( CONVERT(varchar, order_time ), 1,2)



--find out hourly trend second method is better appropraite way
select  datepart(HOUR, order_time) as daily_hours, count(distinct order_id) as total_orders
from 
project.dbo.[pizza csv]
group by  datepart(HOUR, order_time)
order by  datepart(HOUR, order_time)




--find out weekly trend 
select  datepart(week, order_date) as weeks, count(distinct order_id) as total_orders
from 
project.dbo.[pizza csv]
group by datepart(week, order_date)  
order by datepart(week, order_date)



--find Revenue_per_pizza_category first method 
with category as(
select  pizza_category, sum (total_price) as Revenue_per_pizza_category
from
project.dbo.[pizza csv] 
group by pizza_category
),

sales  as (
select   sum(total_price) as total_revenue
from 
project.dbo.[pizza csv]
)

select c.pizza_category, c.Revenue_per_pizza_category, c.Revenue_per_pizza_category/s.total_revenue *100 as Percentage_revenue_per_pizza_category  
from 
category c
join 
sales s 
on 1=1



--find Revenue_per_pizza_category second eaiser method  
--if you want to filter sales by month you have to write code in both inner and outer select statement, bcz the total sales also be from 
--particular month
select pizza_category, sum(total_price) as revenue_for_pizza_category, sum(total_price) *100 / 
(select SUM(total_price) from project.dbo.[pizza csv] where month(order_date) =12)  as percentage_share
from project.dbo.[pizza csv] 
where month(order_date) =12
group by 
pizza_category



--sales by pizza size
 select pizza_size, round(sum(total_price), 2) as revenue, round(sum(total_price) *100 / 
 (select sum(total_price) from project.dbo.[pizza csv] where month(order_date) = 7 ), 2) as percentage_share 
from 
project.dbo.[pizza csv] 
where month(order_date) = 7 
--displays revenue on Sundays in month july and how much SUndays sales contributed to total sales of month by each pizza size
--if you want to see total sales on Sunday(or any day of weeks) that how much each pizza size generates revenue of total sales on 
--particular day copy and paste this (and datename(dw, order_date)  = 'Sunday') after where clause in above statement.

and datename(DW, order_date)  = 'Sunday'
group by pizza_size 
order by percentage_share desc


--sales by pizza size, to round figure you can use cast function and decimal
 select pizza_size, round(sum(total_price), 2) as revenue, cast(sum(total_price) *100 / 
 (select sum(total_price) from project.dbo.[pizza csv] where datepart(quarter, order_date) = 3
)as decimal (10,2) ) as percentage_share
from 
project.dbo.[pizza csv] 
where 
datepart(quarter, order_date) = 3 
group by pizza_size 
order by percentage_share desc










--filter by month
select sum(quantity) total_pizza_sold
from project.dbo.[pizza csv] 
where year(order_date) = 2015
and month(order_date) = 5
--this will give you total pizza sold on particular date of month like 7,12,29
and day(order_date) =17 

--both this month(order_date) = 5 and this datepart(dw, order_date) = 3 will givev different results

--this will give you total pizza sold on particular day of the week like mon, fri and in this situation it will sum up all quantity of all weds
--of weeks in a month of may
select sum(quantity) total_pizza_sold
from project.dbo.[pizza csv] 
where year(order_date) = 2015 
and month(order_date) = 5
and datepart(dw, order_date) = 3

--to find number from date datepart is used to and for names datename function is used
-- sales by quarter of the year 2015
select datepart(QUARTER, order_date) as quater, datename(dw, order_date) as day, sum(quantity) total_pizza_sold 
from project.dbo.[pizza csv] 
where year(order_date) = 2015
and datepart(QUARTER, order_date) = 4
and datepart(dw, order_date) =1
group by datename(dw, order_date),  datepart(QUARTER, order_date)









--seperate year,month and date from order_date
 select substring(CONVERT(varchar(10), order_date),1,4) as Year,
 substring(CONVERT(varchar(10), order_date),6,2) as Month,
 substring(CONVERT(varchar(10), order_date),9,2) as Day
from 
project.dbo.[pizza csv]

 select datepart(year, order_date) as Year,
 DATENAME(Month, order_date)  as Month,
 datepart(DAY, order_date) as Day
 from 
 project.dbo.[pizza csv]









--but if you want to look at how much a aprticular  month contribute to total sales of a year by each pizza category
select pizza_category, sum(total_price) as revenue_for_pizza_category, sum(total_price) *100 / 
(select SUM(total_price) from project.dbo.[pizza csv])  as percentage_share
from project.dbo.[pizza csv] 
where month(order_date) =12
group by 
pizza_category



--but if you want to look at how much each month contribute to sales of a year by each pizza category
--with cte as(
select datename(month, order_date)as months, sum(total_price) as revenue, sum(total_price) *100 / 
(select SUM(total_price) from project.dbo.[pizza csv])  as percentage_share
from project.dbo.[pizza csv] 
group by 
datename(month, order_date) 
--)select sum(percentage_share) from cte






--total pizza sold by pizza category
 select pizza_category, sum(quantity) as pizza_sold
from 
project.dbo.[pizza csv]
group by pizza_category



--select top 5 best selling pizzas     
select top 5 pizza_name, sum(quantity) as pizza_sold
from 
project.dbo.[pizza csv]
group by pizza_name  
order by  pizza_sold desc



--select top 5 worst selling pizzas     
select top 5 pizza_name, round(sum(quantity), 2) pizza_sold
from 
project.dbo.[pizza csv]
group by pizza_name  
order by  pizza_sold





