# Retail-Analytics-Case-Study
Analysing customer engagement to over come growth stagnation level using MySQL

### Analyze the Data

```
desc customers;
desc products;
desc orders;
desc orderdetails;
```

### Market Segmentation Analysis

```
select
  location,
  count(customer_id) as number_of_customers
from customers
group by location
order by number_of_customers desc
limit 3;
```

### Engagement Depth Analysis 

```
with order_count as (
    select
        customer_id,
        count(order_id) as NumberOfOrders
    from orders
    group by customer_id
)

select
    NumberOfOrders,
    count(customer_id) as CustomerCount
from order_count
group by NumberOfOrders
order by NumberOfOrders asc;
```

### Purchase High-Value Products
```
select
  Product_Id,
  avg(quantity) as AvgQuantity,
  sum(quantity * price_per_unit) as TotalRevenue
from orderdetails
group by Product_Id
having AvgQuantity = 2
order by TotalRevenue desc;
```

### Category-wise Customer Reach
```
select
  p.category,
  count(distinct o.customer_id) as unique_customers
from products p 
join orderdetails od 
on p.product_id = od.product_id
join orders o 
on od.order_id = o.order_id
group by p.category
order by 
    unique_customers desc;
```

### Sales Trend Analysis
```
with monthly_sales as (
    select
        date_format(str_to_date(order_date, '%Y-%m-%d'), '%Y-%m') as Month,
        sum(total_amount) as TotalSales
    from orders
    group by date_format(str_to_date(order_date, '%Y-%m-%d'), '%Y-%m')
)

select
    Month,
    TotalSales,
    round((TotalSales - lag(TotalSales) over(order by Month)) / lag(TotalSales) over(order by Month) * 100, 2)
    as PercentChange
from monthly_sales;
```

### Average Order Value Fluctuation
```
with monthly_avg_sales as (
    select
        date_format(str_to_date(order_date, '%Y-%m-%d'), '%Y-%m') as Month,
        round(avg(total_amount), 2) as AvgOrderValue
    from orders
    group by Month
)

select
    Month,
    AvgOrderValue,
    round((AvgOrderValue - lag(AvgOrderValue) over(order by Month)), 2)
    as changeInValue
from monthly_avg_sales
order by changeInValue desc;
```

### Inventory Refresh Rate
```
select
  product_id,
  count(*) as salesFrequency
from orderdetails
group by product_id
order by salesFrequency desc
limit 5;
```

### Low Engagement Products
```
select
    p.Product_id,
    p.Name,
    count(distinct o.customer_id) as UniqueCustomerCount
from products p 
join orderdetails od 
on p.product_id = od.product_id
join orders o 
on od.order_id = o.order_id
group by
    p.product_id,
    p.name
having
    UniqueCustomerCount < 
	  0.4 * (select count(distinct customer_id) from customers);
```

### Customer Acquisition Trends
```
with customer_first_purchase as (
    select
      customer_id,
      min(date_format(str_to_date(order_date, '%Y-%m-%d'), '%Y-%m')) as FirstPurchaseMonth
    from orders
    group by customer_id
)
 
select
    FirstPurchaseMonth,
    count(customer_id) as TotalNewCustomers
from customer_first_purchase
group by FirstPurchaseMonth
order by FirstPurchaseMonth asc;
```

### Peak Sales Period Identification
```
select
  date_format(str_to_date(order_date, '%Y-%m-%d'), '%Y-%m') as Month,
  sum(total_amount) as TotalSales
from orders
group by Month
order by TotalSales desc
limit 3;
```
