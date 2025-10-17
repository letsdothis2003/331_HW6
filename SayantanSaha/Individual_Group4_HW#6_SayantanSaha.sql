/* Chapter 6 Queries – Set Operators */

USE AdventureWorks2022;
GO

/* Query 1 - Customer or Vendor City and Postal Codes (UNION)
Functional Specification
- Combine city and postal codes from customer and vendor addresses.
- Use UNION to remove duplicates and present combined location info.
*/
SELECT a.City, a.PostalCode, sp.Name AS StateProvince
FROM Person.Address AS a
JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE a.AddressID IN (SELECT AddressID FROM Person.BusinessEntityAddress WHERE AddressTypeID = 2)
UNION
SELECT a.City, a.PostalCode, sp.Name
FROM Person.Address AS a
JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE a.AddressID IN (SELECT AddressID FROM Person.BusinessEntityAddress WHERE AddressTypeID = 3)
ORDER BY City, PostalCode;
GO

/* Query 2 - Top-Selling or High-Margin Products (UNION)
Functional Specification
- Combine products that are either top sellers or have above-average profit margins.
- Use UNION to create a unified list of valuable products with sales and cost data.
*/
SELECT p.ProductID, p.Name, SUM(sod.LineTotal) AS TotalSales
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod 
  ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
HAVING SUM(sod.LineTotal) > 50000
UNION
SELECT p.ProductID, p.Name, (p.ListPrice - p.StandardCost) AS ProfitMargin
FROM Production.Product AS p
WHERE (p.ListPrice - p.StandardCost) > 100
ORDER BY p.Name;
GO

/* Query 3 - Products Sold but Never Reordered (EXCEPT)
Functional Specification
- Return ProductID, Name, and StandardCost for products sold once 
  but never reordered in purchasing records.
- Use EXCEPT to identify items sold to customers but never restocked.
*/
SELECT DISTINCT p.ProductID, p.Name, p.StandardCost
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod 
  ON p.ProductID = sod.ProductID
EXCEPT
SELECT DISTINCT p.ProductID, p.Name, p.StandardCost
FROM Production.Product AS p
JOIN Purchasing.PurchaseOrderDetail AS pod 
  ON p.ProductID = pod.ProductID
ORDER BY p.Name;
GO

/* Query 4 - Employees or Salespeople with Extra Compensation (UNION ALL)
Functional Specification
- Combine Employees with high vacation hours and SalesPeople with commissions.
- Include both ID and pay-related attributes; keep duplicates for overlap review.
*/
SELECT e.BusinessEntityID, e.VacationHours AS ExtraMetric, 'Employee' AS Source
FROM HumanResources.Employee AS e
WHERE e.VacationHours > 50
UNION ALL
SELECT s.BusinessEntityID, s.CommissionPct AS ExtraMetric, 'SalesPerson' AS Source
FROM Sales.SalesPerson AS s
WHERE s.CommissionPct > 0
ORDER BY BusinessEntityID;
GO

/* Query 5 - Products Sold and Discounted (INTERSECT)
Functional Specification
- Return ProductID, Name, and average sold UnitPrice for items sold with discounts.
- Demonstrates product overlap between active sales and promotions.
*/
SELECT p.ProductID, p.Name, AVG(sod.UnitPrice) AS AvgSalePrice
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
INTERSECT
SELECT p.ProductID, p.Name, AVG(sod.UnitPrice)
FROM Production.Product AS p
JOIN Sales.SpecialOfferProduct AS sop ON p.ProductID = sop.ProductID
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY p.Name;
GO

/* Query 6 - Online vs Store Orders (EXCEPT)
Functional Specification
- Show online-only orders including OrderID, Date, and CustomerID.
- Use EXCEPT to remove in-store transactions.
*/
SELECT SalesOrderID, OrderDate, CustomerID
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
EXCEPT
SELECT SalesOrderID, OrderDate, CustomerID
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
ORDER BY OrderDate;
GO

/* Query 7 - Top Customers by Purchases (CTE + INTERSECT)
Functional Specification
- CTE finds top 50 customers by total due amount.
- INTERSECT verifies those customers exist in the Customer table.
*/
WITH TopCustomers AS (
  SELECT TOP (50) CustomerID
  FROM Sales.SalesOrderHeader
  GROUP BY CustomerID
  ORDER BY SUM(TotalDue) DESC
)
SELECT CustomerID
FROM TopCustomers
INTERSECT
SELECT CustomerID
FROM Sales.Customer
ORDER BY CustomerID;
GO

/* Query 8 - Employees or Sales Territory Staff (UNION)
Functional Specification
- Combine employees from the HR table with salespeople assigned to territories.
- Use UNION to list all active staff across departments and sales operations.
*/
SELECT BusinessEntityID, 'Employee' AS Role
FROM HumanResources.Employee
UNION
SELECT BusinessEntityID, 'SalesStaff' AS Role
FROM Sales.SalesPerson
ORDER BY BusinessEntityID;
GO

/* Query 9 - Employees Without Sales Role (EXCEPT)
Functional Specification
- Show employee IDs and job titles that are not tied to any SalesPerson entry.
- Demonstrates filtering across related personnel tables.
*/
SELECT e.BusinessEntityID, e.JobTitle
FROM HumanResources.Employee AS e
EXCEPT
SELECT s.BusinessEntityID, 'SalesPerson'
FROM Sales.SalesPerson AS s
ORDER BY e.BusinessEntityID;
GO

/* Query 10 - Unified Product Catalog (Derived Table + UNION)
Functional Specification
- Merge product category and subcategory with their parent group.
- Output multi-column catalog view for browsing classification structure.
*/
SELECT DISTINCT GroupName, CategoryType
FROM (
  SELECT pc.Name AS GroupName, 'Category' AS CategoryType
  FROM Production.ProductCategory AS pc
  UNION
  SELECT ps.Name, 'Subcategory'
  FROM Production.ProductSubcategory AS ps
) AS Unified
ORDER BY GroupName;
GO
