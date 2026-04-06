# 📊 Customer Insights Analysis (SQL Project)

## 🔹 Overview

This project focuses on analyzing customer behavior using SQL to derive meaningful business insights such as top customers, repeat customer rate, and customer segmentation.

---

## 🔹 Objectives

* Identify top 10 customers by revenue
* Calculate repeat customer rate
* Perform customer segmentation based on spending
* Analyze customer lifetime value

---

## 🔹 Tools Used

* SQL (MySQL)
* Excel (for dataset preparation)

---

## 🔹 Key Insights

* Identified top revenue-generating customers
* Calculated repeat customer rate to evaluate retention
* Segmented customers into Platinum, Gold, Silver, and Bronze
* Derived total customer sales for business decision-making

---

## 🔹 Sample SQL Query

```sql
SELECT C.CustomerID, C.CustomerName, 
ROUND(SUM(OD.Quantity*P.Price)) AS Revenue
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN OrderDetails OD ON OD.OrderID = O.OrderID
JOIN Products P ON P.ProductID = OD.ProductID
GROUP BY C.CustomerID, C.CustomerName
ORDER BY Revenue DESC
LIMIT 10;
```

---

## 🔹 Project Outcome

This project demonstrates the ability to clean, analyze, and extract actionable insights from structured data using SQL.

---

## 🔹 Author

Sameer Tamboli
Aspiring Data Analyst
