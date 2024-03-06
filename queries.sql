--count of unique customers

select count(customer_id) as customers_count
from customers c 
;




--sellers with less than avg income

with tab as (
	select 
	*,
	s.quantity * p.price as income,
	concat_ws(' ', e.first_name, e.last_name) as seller_full
	from sales s
	left join employees e ON s.sales_person_id = e.employee_id
	left join products p on s.product_id = p.product_id)

select 
	seller_full as seller,
	floor(avg(income)) as average_income
from tab
group by seller_full
having avg(income) < (
	select 
	avg(income)
	from tab
	)
order by average_income
;
 
 



--top 10 sellers by income

with tab as (
	select *,
	concat_ws(' ', e.first_name, e.last_name) as seller_full
	from sales s
	left join employees e on s.sales_person_id = e.employee_id
	left join products p on s.product_id = p.product_id
	)

select 
	seller_full as seller,
	count(sales_id) as operations,
	floor(sum(price * quantity)) as income
from tab
group by seller_full
order by income desc
limit 10
;





-- sales by day of week

with dow_income as (
	select
		concat_ws(' ', e.first_name, e.last_name) as seller_full,
		extract(dow from s.sale_date + 6) as n_day_of_week,
		to_char(s.sale_date, 'day') as day_of_week,
		s.quantity * p.price as income
	from sales s
	left join employees e on s.sales_person_id = e.employee_id
	left join products p on s.product_id = p.product_id
	)

select 
	seller_full as seller,
	day_of_week,
	floor(sum(income)) as income
from dow_income
group by day_of_week, seller_full, n_day_of_week
order by n_day_of_week
;






-- customers age groups

select 
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category,
count(customer_id)	
from customers c
group by age_category
order by age_category
;


-- unique buyers by months

select
	to_char(s.sale_date, 'YYYY-MM') as selling_month,
	count(distinct s.customer_id) as total_customers,
	floor(sum(p.price * s.quantity)) as income
from sales s
left join products p using(product_id)
group by selling_month
order by selling_month
;


--first purchase for 0 customers

with full_names as (
	select 
		*,
		concat_ws(' ', c.first_name, c.last_name) as customer,
		concat_ws(' ', e.first_name, e.last_name) as seller,
		p.price * s.quantity as income
	from sales s
	left join customers c using(customer_id)
	left join products p using(product_id)
	left join employees e on e.employee_id = s.sales_person_id
    ),
rowed as (
	select 
		sales_id,
		customer,
		customer_id,
		seller,
		sale_date,
		income,
		row_number() over(partition by customer order by income)
from full_names
	)

select customer, sale_date, seller
from rowed
where row_number = 1 and income = 0
order by customer_id
;








