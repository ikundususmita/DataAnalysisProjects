 use sys;
 SELECT host FROM mysql.user WHERE User = 'root'; 
 select * from df_orders; 
 
 -- 1. find top 10 highest revenue generating products
 select product_id, sum(sale_price) as sales from df_orders 
 group by product_id order by sales desc limit 10;
 
 -- 2. find top 5 highest selling products in each region
 with cte as(
 select region, product_id, sum(sale_price) as sales from df_orders 
 group by region,product_id )
 select * from 
 (select * , row_number() over(partition by region order by sales desc) as rn from cte) a
 where rn<=5;

-- 3. find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as(
select year(order_date) as order_year , month(order_date) as order_month,
 sum(sale_price) as sales from df_orders
group by year(order_date) ,month(order_date)
 order by order_year, order_month 
)
select order_month , 
sum(case  when order_year = 2022 then sales else 0 end ) as sales_2022,
sum(case  when order_year = 2023 then sales else 0 end )as sales_2023
 from cte 
 group by order_month ;

-- 4. for each category which month had highest sale
with cte as (
select category, sum(sale_price) as sales , month(order_date) as order_month ,  year(order_date) as order_year
from df_orders group by category,month(order_date),year(order_date)
order by category, order_month,order_year )
select * from(select *, row_number() over(partition by category order by sales desc) as rn from cte ) a
where rn = 1;

-- 5. which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category, sum(profit) as sub_category_profit , 
year(order_date) as order_year from df_orders
group by sub_category, order_year
order by sub_category_profit desc)
select *, (order_2023-order_2022) as growth from (select sub_category,
sum(case when order_year = 2022 then sub_category_profit else 0 end) as order_2022,
sum(case when order_year = 2023 then sub_category_profit else 0 end) as order_2023
from cte
group by sub_category) a
order by growth desc limit 1;

-- 6. which sub category had highest growth by profit % in 2023 compare to 2022.
with cte as (
select sub_category, sum(profit) as sub_category_profit , 
year(order_date) as order_year from df_orders
group by sub_category, order_year
order by sub_category_profit desc)
select *, (order_2023-order_2022)*100/order_2022 as growth_percent from (select sub_category,
sum(case when order_year = 2022 then sub_category_profit else 0 end) as order_2022,
sum(case when order_year = 2023 then sub_category_profit else 0 end) as order_2023
from cte
group by sub_category) a
order by growth_percent desc limit 1;

 
 
 


