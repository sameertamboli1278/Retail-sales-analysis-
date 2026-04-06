-- 1.	General Sales Insights
-- 1.1.	What is the total revenue generated over the entire period? [ Revenue = Quantity * PRice]

select Sum(Quantity * Price) as Total_Revenue
From Orderdetails OD
Join Products aS P on P.ProductID = OD.ProductID;

-- 1.2.	Revenue Excluding Returned Orders
select Sum(OD.Quantity * P.Price) as Revenue_Excluding_returns
From Orders O
JOin Orderdetails OD ON OD.OrderID = O.OrderID
Join Products aS P on P.ProductID = OD.ProductID
Where O.Isreturned = False; 

-- 1.3.	Total Revenue per Year / Month
select Date_Format(Orderdate, '%Y-%m-01') as Order_Month, SUM(OD.Quantity*P.Price) As Monthly_Revenue
From Orders O 
Join Orderdetails OD On OD.OrderID = O.OrderID
JOin Products P On P.ProductID = OD.ProductID
Group BY  Order_Month
Order BY Order_Month;

-- 1.4.	Revenue by Product / Category

select  Category,ProductName, Sum(OD. Quantity * P.Price) as Product_Revenue
From Orders O 
Join Orderdetails OD On OD.OrderID = O.OrderID
JOin Products P On P.ProductID = OD.ProductID
group by  Category, ProductName
order by Category,ProductName,Product_Revenue DESC;

-- 1.5.	What is the average order value (AOV) across all orders?

select AVG(Total_Order_Value) as AVG_Total
From (SELECT O.OrderID,
			 SUM(OD.Quantity * P.Price) AS Total_Order_Value
		From Orders O 
		Join Orderdetails OD On OD.OrderID = O.OrderID
		JOin Products P On P.ProductID = OD.ProductID
		GROUP BY O.OrderID) T;

-- 1.6.	AOV per Year / Month
select year(OrderDate) as Order_Year, Month(OrderDate) as Order_Month, AVG(Total_Order_Value) as AVG_Total
From (SELECT O.OrderID,SUM(OD.Quantity * P.Price) AS Total_Order_Value
		From Orders O 
		Join Orderdetails OD On OD.OrderID = O.OrderID
		JOin Products P On P.ProductID = OD.ProductID
		GROUP BY O.OrderID) T
group by Order_year,Order_Month;

select Year(OrderDate) as Order_Year,Month(Orderdate) as Order_Month, AVG(Total_Order_Value) as AVG_Total
From (SELECT O.OrderID,O.Orderdate,SUM(OD.Quantity * P.Price) AS Total_Order_Value
		From Orders O 
		Join Orderdetails OD On OD.OrderID = O.OrderID
		JOin Products P On P.ProductID = OD.ProductID
		GROUP BY O.OrderID) T
group by Order_year,Order_Month
order by Order_year,Order_Month;


-- 1.7.	What is the average order size by region?


SELECT
    R.RegionName,
    AVG(OS.Total_Order_Size) AS Avg_Order_Size
FROM (
    SELECT
        O.OrderID,
        C.RegionID,
        SUM(OD.Quantity) AS Total_Order_Size
    FROM Orders O
    JOIN Customers C ON C.CustomerID = O.CustomerID
    JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    GROUP BY O.OrderID, C.RegionID
) AS OS
JOIN Regions R ON R.RegionID = OS.RegionID
GROUP BY R.RegionName
ORDER BY Avg_Order_Size DESC;
