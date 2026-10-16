-- Remove Duplicates 

select 
    Transactionid, 
    count(*)
from sales_transaction
group by transactionid
having count(*) > 1;

create table tmp_1 as
select distinct * from sales_transaction;

drop table sales_transaction;

rename table tmp_1 to sales_transaction;

select * from sales_transaction;
----------------------------------------------

-- Fix incorrect prices

select 
    st.TransactionID, st.Price as TransactionPrice,
    pi.price as InventoryPrice
from sales_transaction st 
join product_inventory pi 
on st.productid = pi.productid
where st.price <> pi.price;

update sales_transaction st 
join product_inventory pi 
on st.productid = pi.productid
set st.price = pi.price
where st.price <> pi.price
or st.price is null;

select * from sales_transaction;
----------------------------------------------

-- Fixing Null values

select count(*) from customer_profiles
where location = '' or trim(location) = '';

update customer_profiles
set location = 'unknown'
where location = '' or trim(location) = '';

select 
    CustomerID,
    Age,
    Gender,
    Location,
    JoinDate
 from customer_profiles;
----------------------------------------------

-- Cleaning data

create table tmp_1 as
select * from sales_transaction;

alter table tmp_1
add column TransactionDate_updated date;

update tmp_1
set TransactionDate_updated = str_to_date(transactiondate, '%d/%m/%y');

drop table sales_transaction;

rename table tmp_1 to sales_transaction;

select * from sales_transaction;
----------------------------------------------

-- Total Sales summary

select
    ProductID,
    sum(quantityPurchased) as TotalUnitsSold,
    sum(quantityPurchased * price) as TotalSales
from sales_transaction
group by productid
order by TotalSales desc;
----------------------------------------------

-- Customer Purchase Frequency

select CustomerID,
count(transactionid) as NumberOfTransactions
from sales_transaction
group by customerid
order by NumberOfTransactions desc;
----------------------------------------------

-- Product Categories Performance

select
    pi.Category,
    sum(st.quantitypurchased) as TotalUnitsSold,
    sum(st.quantitypurchased * st.price) as TotalSales
from product_inventory pi 
join sales_transaction st 
on pi.productid = st.productid
group by pi.Category
order by TotalSales desc;
----------------------------------------------

-- High Sales Products

select
    ProductID,
    sum(quantitypurchased * price) as TotalRevenue
from sales_transaction
group by productid
order by TotalRevenue desc
limit 10;
----------------------------------------------

-- Low Sales Products

select
ProductID,
sum(quantitypurchased) as TotalUnitsSold
from sales_transaction
group by productid
having sum(quantitypurchased) >= 1
order by TotalUnitsSold asc
limit 10;
----------------------------------------------

-- Sales Trend

select 
    transaction_date_updated as DATETRANS,
    count(transactionid) as Transaction_count,
    sum(quantitypurchased) as TotalUnitsSold,
    round(sum(quantitypurchased * price), 2) as TotalSales
from sales_transaction
group by transaction_date_updated
order by DATETRANS desc;
----------------------------------------------

-- Growth Rate by Sales

with monthly_sales as (
    select
    month(transaction_date_updated) as month,
    round(sum(quantitypurchased * price),2) as total_sales
    from sales_transaction
    group by month
    order by month asc
)

select
    month,
    total_sales,
    round(lag(total_sales) over(order by month asc), 2) as previous_month_sales,
    round((total_sales - lag(total_sales) over(order by month asc)) / 
    lag(total_sales) over(order by month asc) * 100, 2) as mom_growth_percentage
from monthly_sales;
----------------------------------------------

-- High Purchase Frequency

select
    CustomerID,
    count(transactionid) as NumberOfTransactions,
    sum(quantitypurchased * price) as TotalSpent
from sales_transaction
group by customerid
having
    count(transactionid) > 10
    and sum(quantitypurchased * price) > 1000
order by TotalSpent desc;
----------------------------------------------

-- Occasional Customers

select
    CustomerID,
    count(transactionid) as NumberOfTransactions,
    sum(quantitypurchased * price) as TotalSpent
from sales_transaction
group by customerid
having
    count(transactionid) <= 2
order by 
NumberOfTransactions asc,
TotalSpent desc;
----------------------------------------------

-- Repeat Customers

select
    CustomerID,
    ProductID,
    count(transactionid) as TimesPurchased
from sales_transaction
group by 
    CustomerID,
    ProductID
having 
    count(transactionid) > 1
order by TimesPurchased desc;
----------------------------------------------

-- Loyalty Indicators

select
    CustomerID,
    min(transaction_date_updated) as FirstPurchase,
    max(transaction_date_updated) as LastPurchase,
    datediff(max(transaction_date_updated), min(transaction_date_updated)) as DaysBetweenPurchases
from sales_transaction
group by 
    CustomerID
having
    max(transaction_date_updated) - min(transaction_date_updated) > 0
order by DaysBetweenPurchases desc;
----------------------------------------------

-- Customer Segmentation

with customer_segment as (
    select
        cp.customerid,
        case
            when sum(quantitypurchased) >= 1 and sum(quantitypurchased) <=  10 then 'Low'
            when sum(quantitypurchased) <= 30 then 'Med'
            when sum(quantitypurchased) > 30 then 'High'
        end as CustomerSegment
    from customer_profiles cp 
    join sales_transaction st 
    on cp.customerid = st.customerid
    group by cp.customerid
)

select 
    CustomerSegment,
    COUNT(*)
from customer_segment
group by
    CustomerSegment;
----------------------------------------------
