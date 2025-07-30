/* 1) Which customers generated the highest total revenue in 2016? */

select RevenueTable.account_id as CompanyID, accounts.name as CompanyName, RevenueTable.total_revenue
from
(select account_id, SUM(total_amt_usd) as total_revenue 
from orders
WHERE YEAR(occurred_at) = 2016
group by account_id
) AS RevenueTable
join accounts on RevenueTable.account_id = accounts.id
order by total_revenue desc
LIMIT 5;

/* 2) Which sales reps handled accounts that placed more than 5 orders? */

SELECT sales_reps.name AS SalesRepName, ORDER_COUNT.account_id as CompanyID, accounts.name as CompanyName, ORDER_COUNT.NumberOfOrder
FROM ( SELECT account_id, count(account_id) as NumberOfOrder FROM orders 
group by account_id) AS ORDER_COUNT
join accounts on ORDER_COUNT.account_id = accounts.id
join sales_reps on accounts.sales_rep_id = sales_reps.id
WHERE NumberOfOrder > 5
order by NumberOfOrder desc;

/* 3) What is the average revenue per web event channel (e.g., organic, paid, etc.)? */

Select channel, avg(total_amt_usd) as average_revenue
from
(SELECT w.account_id, w.occurred_at, w.channel, o.total_amt_usd
from web_events w
join orders o
on w.account_id = o.account_id
and date(w.occurred_at) = date(o.occurred_at)) as web_revenue
group by channel;

/* 4) Which industry brought in the highest revenue from poster paper in 2015? */

Select accounts.id as CompanyID ,accounts.name as CompanyName, PosterRevenue.PosterRevenue 
from (select account_id, sum(poster_amt_usd) as PosterRevenue from orders
where year(occurred_at) = 2015
group by account_id
order by sum(poster_amt_usd) desc
limit 1) as PosterRevenue
join accounts 
on PosterRevenue.account_id = accounts.id;

/* 5)  Which account had the longest gap between their first and last order? 
resoucre: https://www.youtube.com/watch?v=mMejizFiibI */

select FirstLastOrder.account_id as CompanyID, accounts.name as CompanyName, TIMESTAMPDIFF(day, first_order, last_order) as FirstLastOrderGap
from (SELECT distinct account_id, min(occurred_at) OVER(PARTITION BY account_id ROWS between unbounded preceding AND unbounded following) first_order,
max(occurred_at) OVER(PARTITION BY account_id ORDER BY occurred_at ROWS between unbounded preceding AND unbounded following) last_order
FROM orders) as FirstLastOrder
JOIN accounts on FirstLastOrder.account_id = accounts.id
order by FirstLastOrderGap desc;

/* 6) What's the total quantity and revenue of gloss paper sold by each region? */

select region.name as Region, sum(orders.gloss_qty) as GlossQty, sum(orders.gloss_amt_usd) as GlossRevenue  from orders
join accounts on orders.account_id = accounts.id
join sales_reps on accounts.sales_rep_id = sales_reps.id
join region on sales_reps.region_id = region.id
group by Region;

/* 7) Which accounts had web events but never placed any orders? */

SELECT distinct(account_id) as CompanyID, accounts.name from web_events
join accounts on web_events.account_id = accounts.id
where account_id not in (SELECT distinct(account_id) from orders);

/* 8) What's the total revenue generated each quarter in 2016
first quarter 1 - 3 (January to March)
second quarter 4 - 6 (April to June)
third quarter 7 - 9 (July to September)
forth quarter 10 - 12 (October to December) */

select quarter(occurred_at), sum(total_amt_usd) as Total_Revenue
from orders
where YEAR(occurred_at) = 2016
group by quarter(occurred_at)
order by quarter(occurred_at);