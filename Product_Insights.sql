-- 3.	Product & Order Insights
-- 3.1.	What are the top 10 most sold products (by quantity)?
Use Final_Project_Ecommerce;

Select P.productID, P.ProductName, Sum(OD.Quantity) AS TotalQty
From orderdetails OD
JOin Products P On P.productID =OD.ProductID
Group By P.productID, P.ProductName
order by TotalQty DESC
limit 10;



-- 3.2.	What are the top 10 most sold products (by revenue)?
Select P.productID, P.ProductName, Sum(OD.Quantity*P.Price) AS TotalRevenue
From orderdetails OD
JOin Products P On P.productID =OD.ProductID
Group By P.productID, P.ProductName
order by TotalRevenue DESC
limit 10;

-- 3.3.	Which products have the highest return rate? [Return Rate = Return Quantity / Total Quantity

With Sold AS (
		select ProductID, Sum(Quantity) AS TotalQty
        From orderdetails
        Group By ProductID
        ),
Returned AS (
		Select ProductID, Sum(Quantity) AS TotalQtyReturned
        From orderdetails OD
        join Orders O On O. orderID = OD.OrderID
        Where isReturned = 1
        group by ProductID
        )
select ProductName, round((TotalQtyReturned / TotalQty),2) AS Return_rate
From products P 
Join SOld S on S.ProductID = P.ProductID
Join Returned R on R.ProductID = P.ProductID
order by Return_rate DESC
limit 10;

-- 3.4.	Return Rate by Category

With Sold AS
		(Select Category, SUM(Quantity) AS TotalQty
        From Products P 
        Join Orderdetails OD On OD.ProductID = P. ProductID
        Group BY Category
        ),
Returned AS (
		Select Category, SUM(Quantity) AS TotalQtyReturned
        From Products P 
        Join Orderdetails OD On OD.ProductID = P. ProductID
        Join Orders O ON O.OrderID = OD.OrderID
        Where isReturned = 1
        group by Category
)

Select S.Category, ROund((TotalQtyReturned / TotalQty),2) AS Return_rate
From SOld S 
Join Returned R on R.Category = S.Category
order by Return_rate DESC
limit 10;
      
-- 3.5.	What is the average price of products per region? [AvgPrice = TotalRevenue / TotalQTY]

Select RegionName, Round((Sum(OD.Quantity*P.Price))/(SUM(OD.Quantity)),2) AS AvgPrice
From Orders O 
join customers C ON C.CUstomerID = O.CustomerID
JOin OrderDetails OD ON OD. OrderID = O.OrderID
Join Products P ON P.ProductID = OD.ProductID
group by RegionName
Order BY AvgPrice DESC;


-- Q8. Calculate average selling price safel
SELECT
    P.ProductName,
    ROUND(
        SUM(OD.Quantity * P.Price) /
        NULLIF(SUM(OD.Quantity), 0),
        2
    ) AS AvgSellingPrice
FROM OrderDetails OD
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName;

-- 3.6.	What is the sales trend for each product category?
Select Date_format(Orderdate, "%Y-%m")AS Period, Category, Sum(OD.OrderID* P.Price)as Revenue
From Orders O 
Join Orderdetails OD ON OD.OrderID = O.OrderID
Join products P ON P.ProductID = OD. ProductID
Group BY Period, Category
Order BY Period, Category;

-- 4.	Temporal Trends
-- 4.1.	What are the monthly sales trends over the past year?

SELECT Year(OrderDate) AS `Year`, Month(Orderdate) as `Month`, SUM(OD.Quantity*P.price)as Revenue
From Orders O 
Join Orderdetails OD ON OD.OrderID = O.OrderID
join Products P ON P.ProductID = OD.ProductID
Where Orderdate>= current_date() - interval 12 Month
Group By `Year`,`Month`
order by `Year`,`Month`;

-- 4.2.	How does the average order value (AOV) change by month or week?

SELECT date_format(Orderdate, "%Y-%m") AS period, 
			Round(Sum(OD.Quantity*P.price)/ COunt(distinct O.OrderID),2) as AOV
From Orders O 
JOin orderdetails OD ON O.OrderID = OD.OrderID
Join products P ON P.productID = OD.ProductID
group by Period 
order by Period;




-- 5.	Regional Insights
-- 5.1.	Which regions have the highest order volume and which have the lowest?
Select RegionName, Count(OrderID) AS OrderVolume
From Orders O 
JOin Customers C On C. CustomerID = O.CustomerID
JOin regions R ON R.RegionID = C.RegionID
Group BY RegionName
Order BY OrderVOlume DESC;



-- 5.2.	What is the revenue per region and how does it compare across different regions?

Select RegionName, Sum(OD.Quantity * P.Price) AS revenue
From Orders O 
JOin OrderDetails OD ON OD.OrderID = O.OrderID
Join Products P ON P.ProductID = OD.ProductID
Join customers C ON C.CustomerID = O.CustomerID
Join Regions R ON R.RegionID = C.RegionID
group by RegionNAme
Order BY Revenue DESC;

-- Bonus (5.1+5.2)

 With T1 AS (
		Select RegionName, Count(OrderID) AS OrderVolume
From Orders O 
JOin Customers C On C. CustomerID = O.CustomerID
JOin regions R ON R.RegionID = C.RegionID
Group BY RegionName
Order BY OrderVOlume DESC
),
T2 AS (
		Select RegionName, Sum(OD.Quantity * P.Price) AS revenue
		From Orders O 
		JOin OrderDetails OD ON OD.OrderID = O.OrderID
		Join Products P ON P.ProductID = OD.ProductID
		Join customers C ON C.CustomerID = O.CustomerID
		Join Regions R ON R.RegionID = C.RegionID
		group by RegionNAme
		Order BY Revenue DESC
)
Select T1.RegionNAme,OrderVolume, revenue 
From T1
Join T2 ON T2.RegionNAme = T1.RegionNAme;
		
-- 6.	Return & Refund Insights
-- 6.1.	What is the overall return rate by product category?
Select Category,
			Round(Sum(case when isreturned = 1 then 1 else 0 END) / Count(O.OrderID),2) As ReternRate
From Orders O 
Join Orderdetails OD ON OD.OrderID = O.OrderID
Join Products P ON P.productID = OD.ProductID
Group BY Category
Order  BY ReternRate DESC;


-- 6.2.	What is the overall return rate by region?

Select RegionName,
			Round(Sum(case when isreturned = 1 then 1 else 0 END) / Count(O.OrderID),2) As ReternRate
From Orders O 
Join Customers C ON C. CustomerID = O.CustomerID
JOin Regions R ON R. RegionID = C.RegionID
Group BY RegionName
Order  BY ReternRate DESC;

-- 6.3.	Which customers are making frequent returns?
With Returns_Orders AS (
Select C.CustomerID, C.CustomerName, Count(O.OrderID) AS ReturnOrders
From Orders O 
JOin Customers C ON C.CustomerID = o.CustomerID
Where Isreturned = 1
Group BY CustomerID, CustomerName
Order BY ReturnOrders desc
),
Orders_DOne as( 
Select C.CustomerID, C.CustomerName, Count(O.OrderID) AS OrdersDone
From Orders O 
JOin Customers C ON C.CustomerID = o.CustomerID
Group BY CustomerID, CustomerName
Order BY OrdersDone desc
)
Select C.CustomerID, C.CustomerName, OrdersDone,ReturnOrders
From Orders_DOne ODE
JOIN Returns_Orders RDE ON RDE.CustomerID = ODE.CustomerID
Limit 10;

Select*
From Comapany sales; 




-- LAg function analyze- Find month-over-month revenue growth.
SELECT
    DATE_FORMAT(O.OrderDate, '%Y-%m') AS Month,
    SUM(OD.Quantity * P.Price) AS Revenue,
    LAG(SUM(OD.Quantity * P.Price)) OVER (
        ORDER BY DATE_FORMAT(O.OrderDate, '%Y-%m')
    ) AS PrevMonthRevenue
FROM Orders O
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY Month;

-- Q6. Find top 3 products by revenue in each region.

With ProductRevenue AS(
		Select ProductName, RegionName, SUM(OD.Quantity*P.price) AS Revenue,
		Rank () Over(Partition by RegionName order by SUM(OD.Quantity*P.price) DESC) AS RNK
		From Products P 
		Join Orderdetails OD ON OD.ProductID = P.ProductID
		join Orders O ON O.OrderID = OD.OrderID
		Join Customers C ON C.customerID = O.CustomerID
		Join Regions R ON R.RegionID = C.RegionID
        Group BY ProductName, RegionName 
        )
Select ProductName, RegionName, Revenue,RNK
From ProductRevenue
Where RNK<= 3
order by RNK DESC;


WITH ProductRevenue AS (
    SELECT
        R.RegionName,
        P.ProductName,
        SUM(OD.Quantity * P.Price) AS Revenue,
        RANK() OVER (
            PARTITION BY R.RegionName
            ORDER BY SUM(OD.Quantity * P.Price) DESC
        ) AS Rnk
    FROM Orders O
    JOIN Customers C ON O.CustomerID = C.CustomerID
    JOIN Regions R ON C.RegionID = R.RegionID
    JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    JOIN Products P ON OD.ProductID = P.ProductID
    GROUP BY R.RegionName, P.ProductName
)
SELECT RegionName, ProductName, Revenue
FROM ProductRevenue
WHERE Rnk <= 3;


