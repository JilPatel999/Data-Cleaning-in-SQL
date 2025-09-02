select * from "DataClean"."customer_orders";


-- Standardizing the order_status column
select order_status,
case
	when lower(order_status) like '%deliver%' then 'Delivered'
	when lower(order_status) like '%returned%' then 'Returned'
	when lower(order_status) like '%refunded%' then 'Refunded'
	when lower(order_status) like '%pend%' then 'Pending'
	when lower(order_status) like '%delivered%' then 'Delivered'
	when lower(order_status) like '%ship%' then 'Shipped'
end as cleaned_order_status

from "DataClean"."customer_orders";


-- Standardize product_name

select *,
case
	when lower(product_name) like '%apple watch%' then 'Apple Watch'
	when lower(product_name) like '%samsung galaxy s22%' then 'Samsung Galaxy S22'
	when lower(product_name) like '%gooogle pixel%' then 'Google Pixel'
	when lower(product_name) like '%macbook pro%' then 'MacBook Pro'
	when lower(product_name) like '%iphone 14%' then 'iPhone 14'
	else 'Other'
end as clean_product_name
from "DataClean"."customer_orders";

-- clean quanitity field

select *,
case
	when lower(quantity) = 'two' then 2
	else cast (quantity as INT64)
end as clean_quantity
from "DataClean"."customer_orders";

-- cleaning customer_name (fixing null and capitalizing 1st letter of first & last name)
select customer_name,
INITCAP(customer_name) as customer_name
from "DataClean"."customer_orders"
where customer_name is not null;

-- Removing duplicated orders
select *
from(
select *,
	row_number() over (
		partition by lower(email), lower(product_name)
		order by order_id
	) as rn
from "DataClean"."customer_orders"
)
where rn = 1;

