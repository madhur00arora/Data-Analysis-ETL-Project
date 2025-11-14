use sql_practice;
select * from df_orders;

#find top 10 highest revenue generating products

select product_id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

#find top 5 highest selling products in each region
with region_wise_sales as(
select product_id,region,sum(sale_price) as sales
from df_orders
group by product_id, region
order by sales desc),
ranking as(
select *,rank() over(partition by region order by sales desc) as rnk
from region_wise_sales
)
select product_id,region,sales from ranking 
where rnk<=5;

#find month over month growth comparison for 2022 and 2023 sales 
with month_wise_sales as(
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
order by year(order_date),month(order_date)
)
select order_month,sum(case when order_year=2022 then sales end) as 2022_sales,
sum(case when order_year=2023 then sales end) as 2023_sales,
 (sum(case when order_year=2023 then sales end)-sum(case when order_year=2022 then sales end))
/sum(case when order_year=2022 then sales end)*100
from month_wise_sales
group by order_month; 

#for each category which month had highest sales

with category_wise_sales as(
select category, date_format(order_date,'%Y-%m') as order_month,
sum(sale_price) as sales
from df_orders
group by category, date_format(order_date,'%Y-%m')
order by category, date_format(order_date,'%Y-%m')
),
ranking as (
select *, rank() over(partition by category order by sales desc)
as rnk
from category_wise_sales
)
select category,order_month,sales
from ranking
where rnk=1;

# which sub category has highest growth by profit in 2023 compare to 2022
with subcat_sales as(
select sub_category,
sum(case when year(order_date)=2022 then sale_prcie end) as sales_2022,
sum(case when year(order_date)=2023 then sale_price end) as sales_2023
from subcat_sales
group by sub_category
)
select *, (sales_2023-sales_2022)/sales_2022*100
as growth
from subcat_sales
order by growth desc
limit 1;
