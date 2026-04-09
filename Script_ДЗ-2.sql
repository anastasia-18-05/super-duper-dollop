-- #1
select distinct product.brand from product 
inner join order_items on product.product_id = order_items.product_id
inner join orders on order_items.order_id = orders.order_id
where product.standard_cost > 1500
group by product.brand 
having sum(order_items.quantity) >= 1000

-- #2
select order_date as day, 
	count(order_id) as confirmed_online_orders_count,
	count(distinct customer_id) as unique_customers_count
from orders
where order_date between '2017-04-01' and '2017-04-09' and online_order = true and order_status = 'Approved'
group by order_date
order by order_date

-- #3
select 
    job_title,
    job_industry_category,
    date_part('year', age(current_date, case when "DOB" != '' then "DOB"::date end)) as age
from customer
where job_industry_category = 'IT'
and job_title like 'Senior%'
and case when "DOB" != '' then "DOB"::date end is not null
and date_part('year', age(current_date, case when "DOB" != '' then "DOB"::date end)) > 35
union all
select 
    job_title,
    job_industry_category,
    date_part('year', age(current_date, case when "DOB" != '' then "DOB"::date end)) as age
from customer
where job_industry_category = 'Financial Services'
and job_title like 'Lead%'
and case when "DOB" != '' then "DOB"::date end is not null
and date_part('year', age(current_date, case when "DOB" != '' then "DOB"::date end)) > 35

-- #4
select distinct product.brand
from product
inner join order_items on product.product_id = order_items.product_id
inner join orders on order_items.order_id = orders.order_id
inner join customer on orders.customer_id = customer.customer_id
where customer.job_industry_category = 'Financial Services'
except
select distinct product.brand
from product
inner join order_items on product.product_id = order_items.product_id
inner join orders on order_items.order_id = orders.order_id
inner join customer on orders.customer_id = customer.customer_id
where customer.job_industry_category = 'IT'

-- #5
select 
    customer.customer_id,
    customer.first_name, 
    customer.last_name,
    count(orders.order_id) as total_orders
from customer
inner join orders on customer.customer_id = orders.customer_id
inner join order_items on orders.order_id = order_items.order_id
inner join product on order_items.product_id = product.product_id
where orders.online_order = true
    and product.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
    and customer.deceased_indicator = 'N'
    and customer.property_valuation > (
        select avg(sub_customer.property_valuation)
        from customer as sub_customer
        where sub_customer.state = customer.state
    )
group by 
    customer.customer_id,
    customer.first_name, 
    customer.last_name
order by total_orders desc
limit 10

-- #6
select 
    customer.customer_id,
    customer.first_name,
    customer.last_name
from customer
where customer.owns_car = 'Yes'
    and customer.wealth_segment != 'Mass Customer'
    and customer.customer_id not in (
        select distinct orders.customer_id
        from orders
        where orders.online_order = true
            and orders.order_status = 'Approved'
            and orders.order_date::date >= current_date - interval '1 year'
    )
    
    -- #7
    with top_road_products as (
    select product_id
    from product
    where product_line = 'Road'
    order by list_price desc
    limit 5
),
customer_purchases as (
    select 
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        count(distinct product.product_id) as purchased_top_products
    from customer
    inner join orders on customer.customer_id = orders.customer_id
    inner join order_items on orders.order_id = order_items.order_id
    inner join product on order_items.product_id = product.product_id
    where customer.job_industry_category = 'IT'
        and product.product_id in (select product_id from top_road_products)
    group by 
        customer.customer_id,
        customer.first_name,
        customer.last_name
)
select 
    customer_id,
    first_name,
    last_name
from customer_purchases
where purchased_top_products >= 2

-- #8
select 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.job_industry_category,
    count(distinct orders.order_id) as order_count,
    sum(order_items.quantity * order_items.item_list_price_at_sale) as total_revenue
from customer
inner join orders on customer.customer_id = orders.customer_id
inner join order_items on orders.order_id = order_items.order_id
where customer.job_industry_category = 'IT'
    and orders.order_status = 'Approved'
    and orders.order_date::date between '2017-01-01' and '2017-03-01'
group by 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.job_industry_category
having count(distinct orders.order_id) >= 3
    and sum(order_items.quantity * order_items.item_list_price_at_sale) > 10000
union
select 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.job_industry_category,
    count(distinct orders.order_id) as order_count,
    sum(order_items.quantity * order_items.item_list_price_at_sale) as total_revenue
from customer
inner join orders on customer.customer_id = orders.customer_id
inner join order_items on orders.order_id = order_items.order_id
where customer.job_industry_category = 'Health'
    and orders.order_status = 'Approved'
    and orders.order_date::date between '2017-01-01' and '2017-03-01'
group by 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.job_industry_category
having count(distinct orders.order_id) >= 3
    and sum(order_items.quantity * order_items.item_list_price_at_sale) > 10000