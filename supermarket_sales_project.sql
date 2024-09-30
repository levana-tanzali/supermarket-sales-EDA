# use the supermarket_sales schema/database
use supermarket_sales;

desc sales;

select * from sales;
select * from customers;

# rename columns for clarity 
alter table sales
rename column `Invoice ID` to invoice_id,
rename column `Product line` to product_line,
rename column `Unit price` to unit_price,
rename column `Tax 5%` to tax_5pct,
rename column `gross income` to gross_income,
rename column `gross margin percentage` to gross_margin_pct;

alter table customers
rename column `Invoice ID` to invoice_id,
rename column `Customer type` to customer_type;

# check is there any duplicate rows 
SELECT 
    (SELECT COUNT(*) FROM sales) AS total_rows,
    (SELECT COUNT(DISTINCT invoice_id) FROM sales) AS unique_rows;

# calculate avg, min, and max quantities sold for each product line
select product_line,
  AVG(quantity) AS Avg_Sold,
  MIN(quantity) AS Min_Sold,
  MAX(quantity) AS Max_Sold
FROM sales
GROUP BY product_line;

# do different payment methods impact average revenue
select payment, avg(total) as avg_revenue
from sales
group by payment
order by avg_revenue desc;

# customers segmentation based on spending level
select invoice_id, total as total_spent,
case when total > 1000 then 'High Spender'
when total between 500 and 1000 then 'Medium Spender'
else 'Low Spender'
end as spending_category
from sales
order by total_spent desc;

# how do product ratings correlate with sales volumes?
select product_line, avg(rating) as avg_rating, sum(quantity) as total_sold,
case when avg(rating) >= 8 then 'High'
when avg(rating) between 6 and 8 then 'Moderate'
else 'Low'
end as rating_category
from sales
group by product_line
order by avg_rating desc, total_sold desc;

# does customer type impact revenue?
select c.customer_type, sum(s.total) as total_revenue 
from sales s
join customers c
on s.invoice_id = c.invoice_id
group by c.customer_type
order by total_revenue desc;

# which product has the highest rating in each city?
select distinct city, product_line, rating
from (
select  c.city, s.product_line, s.rating,
rank() over (partition by c.city order by s.rating desc) as rating_rank
from sales s 
join customers c
on s.invoice_id = c.invoice_id
) as ranked_products
where rating_rank = 1;

# which products are often brought together?
select s1.product_line as product_1, s2.product_line as product_2, 
count(*) as times_purchase_together
from sales s1
join sales s2
on s1.invoice_id = s2.invoice_id and s1.product_line <> s2.product_line
group by product_1, product_2
order by times_purchase_together desc;

# how does sales performance vary by branch and product line?
select c.branch, s.product_line, sum(s.total) as total_revenue,
rank() over (partition by branch order by sum(s.total) desc) as revenue_rank
from sales s 
join customers c
on s.invoice_id = c.invoice_id
group by c.branch, s.product_line;