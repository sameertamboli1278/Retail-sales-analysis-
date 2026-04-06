-- 2.	Customer Insights
-- 2.1.	Who are the top 10 customers by total revenue spent?

Select C.CustomerID, C.CustomerName, ROund(SUM(OD.Quantity*P.Price))AS Revenue
From customers C
JOin  Orders O on C.CustomerID = O.CustomerID
Join orderdetails OD On OD.OrderID = O. OrderID
JOin Products P ON P.ProductID = OD.ProductID
group by C.CustomerID, C.CustomerName
order by Revenue DESC
Limit 10;

With T as (select C.CustomerID, C.CustomerName, SUM(OD.Quantity*P.Price)AS Revenue 
From customers C
JOin  Orders O on C.CustomerID = O.CustomerID
Join orderdetails OD On OD.OrderID = O. OrderID
JOin Products P ON P.ProductID = OD.ProductID)
Select 
	Rank() over(Partition by CustomerID Order by Revenue DESC) as RNK
From T
order by Revenue DESC
Limit 10;


-- 2.2.	What is the repeat customer rate?
SELECT ROUND(COUNT(DISTINCT CASE WHEN Order_count >1 THEN CustomerID END) / COUNT(DISTINCT CustomerID),2) AS Repeate_Customer_Rate
From(SELECT CustomerID, count(OrderID) AS Order_Count
		From Orders
		group by CustomerID) T;





-- 2.3.	What is the average time between two consecutive orders for the same customer Region-wise?
-- 2.4.	Customer Segment (based on total spend)
-- •	Platinum: Total Spend > 1500
-- •	Gold: 1000–1500
-- •	Silver: 500–999
-- •	Bronze: < 500

With CustomerSpends AS
					(SELECT O.CustomerID, SUM(OD.Quantity*P.Price) as totalSpend
					From Orders O 
					join orderdetails OD on OD.OrderID = O.OrderID
					JOin products P ON OD.ProductID = P.ProductID
					group by O.CustomerID)
SELECT CustomerName,
	case 
       when totalSpend >1500 then `Platinum`
       when totalSpend between 1000 and 1500  then `Gold`
       when totalSpend between 500 and 999  then `Silver`
       when totalSpend <500 then `Bronz`
	End AS Segments
From CustomerSpends CS
Join Customers C ON C.CustomerID = CS. CustomerID
Group By Segments;

-- 2.5.	What is the customer lifetime value (CLV)?

-- Q9. Find customers who placed at least one order.
SELECT CustomerName
FROM Customers C
WHERE EXISTS (
    SELECT 1
    FROM Orders O
    WHERE O.CustomerID = C.CustomerID
)
Group BY CUstomerNAme;


-- Find total sales by customer where total > 5000

Select Sum(OD.Quantity*P.price) AS total_sale
From orders O 
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P ON P.ProductID = OD.ProductID
having Sum(OD.Quantity*P.price) > 10000

;

Select Sum(OD.Quantity*P.price) AS total_sale
From orders O 
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P ON P.ProductID = OD.ProductID
;
SELECT
    C.CustomerID,
    C.CustomerName,
    SUM(OD.Quantity * P.Price) AS Total_Sales
FROM Customers C
JOIN Orders O
    ON O.CustomerID = C.CustomerID
JOIN OrderDetails OD
    ON OD.OrderID = O.OrderID
JOIN Products P
    ON P.ProductID = OD.ProductID
GROUP BY
    C.CustomerID,
    C.CustomerName
HAVING
    SUM(OD.Quantity * P.Price) > 10000
Order BY Total_Sales;