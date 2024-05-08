select *
from stores_sales;

-- First, the data needs to be cleaned and standardized
-- The date column needs to converted from a string fromat to date

Select `order date`, str_to_date(`order date`, '%m/%d/%Y') as order_date, `ship date`, str_to_date(`ship date`, '%m/%d/%Y') as ship_date
from stores_sales;

update stores_sales
set `order date` =  str_to_date(`order date`, '%m/%d/%Y');

update stores_sales
set `ship date` =  str_to_date(`ship date`, '%m/%d/%Y');

-- Checking for duplicates 
-- Using window function to check for duplicates across all columns

Select*, rank() over(partition by `order id`, `order date`, `ship date`, `ship mode`, `customer id`, `segment`, country, city, state, `postal code`, region, `product id`, category, `sub-category`, `product name`, sales, quantity, discount, profit) as rank_
from stores_sales;

with rank_duplicate as 
(Select*, rank() over(partition by `order id`, `order date`, `ship date`, `ship mode`, `customer id`, `segment`, country, city, state, `postal code`, region, `product id`, category, `sub-category`, `product name`, sales, quantity, discount, profit) as rank_
from stores_sales)

select rank_
from rank_duplicate
where rank_ > 1;

-- There are no duplicates rows found.
-- Next, we explore the data sets. 
-- OVERALL PERFORMANCE:
-- What is the total sales revenue over the given period?
-- How does the sales revenue vary by segment?

select sum(sales)
from stores_sales;

-- Total sales revenue is $733k

Select segment, sum(sales)
from stores_sales
group by segment
order by 2 desc;
-- INSIGHT
-- In the segment classificatiuon of the customer. Consumers played a significant role in boosting sales revenue

-- CUSTOMER ANALYSIS:
-- Who are the top customers in terms of sales revenue?
Select `customer name`, sum(sales)
from stores_sales
group by `customer name`
order by 2 desc limit 10;


-- What is the distribution of customers by city?
Select City, count(`customer id`) as number_of_customers 
from stores_sales
group by city
order by 2 desc;

-- New york city, LA and Philadelphia had the highet numnber of customers 
-- How many new customers were acquired over the years?

Select year(`order date`) as `Year`, count(`customer id`)
from stores_sales
group by `Year`
order by 2 desc;

-- Insight
-- There is a consistent annual growth in the number of cutomers. 

-- PRODUCT ANALYSIS
-- Which products are top sellers in terms of revenue and quantity sold?
SELECT `Product Name`, sum(sales)
from stores_sales
group by `Product Name`
order by 2 desc limit 10;

-- The sub-category products that consistently underperformed over the years
WITH product_rank as 
(select `sub-category`,  Year(`order date`) as `year` , sum(sales) as sum_sales
from stores_sales
group by `sub-category`, Year(`order date`)
),
 
prod_top as
(
select `sub-category`, `year`, sum_sales, dense_rank() over(partition by `year` order by sum_sales desc) as ranking
from product_rank
)

select *
from prod_top;

-- Insight
-- Furnishing products underperfomed over the years from 2014 - 2017 based on sales revenue generated

-- SALES CHANNEL ANALYSIS:
-- How does the shipping mode affect sales revenue and profit?

select `ship mode`, sum(sales), sum(profit)
from stores_sales
group by `ship mode`
order by 2 desc

-- The standard shipping mode is the most used and it had hugh impact on the sales revenue and profit. This is due to it being the basic and economic option. it offers least expensive rates but has longer transit times












