USE AdventureWorks2017;

---- Proposition 1: Santa’s Delivery Map – Cities of Customers and Vendors
/* Combines all customer and vendor cities into one list, removing duplicates. When I run it, 
 I will see a neat table of City | StateName for every location connected to business.*/

SELECT DISTINCT a.City, sp.Name AS StateName
FROM AdventureWorks2017.Person.Address AS a
JOIN AdventureWorks2017.Sales.Customer AS c
  ON c.CustomerID > 0   -- ensures valid rows
JOIN AdventureWorks2017.Person.StateProvince AS sp
  ON a.StateProvinceID = sp.StateProvinceID

UNION
SELECT DISTINCT a.City, sp.Name AS StateName
FROM AdventureWorks2017.Person.Address AS a
JOIN AdventureWorks2017.Purchasing.Vendor AS v
  ON v.BusinessEntityID > 0
JOIN AdventureWorks2017.Person.StateProvince AS sp
  ON a.StateProvinceID = sp.StateProvinceID;


--Proposition 2: Santa’s Helpers – Employees who are also Salespeople
/* Shows employees who also appear in the sales-person table.Returns a short list of 
BusinessEntityID values representing people with both employee and sales roles. */

SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM AdventureWorks2017.HumanResources.Employee AS e
JOIN AdventureWorks2017.Person.Person AS p
  ON e.BusinessEntityID = p.BusinessEntityID

INTERSECT
SELECT sp.BusinessEntityID, p.FirstName, p.LastName
FROM AdventureWorks2017.Sales.SalesPerson AS sp
JOIN AdventureWorks2017.Person.Person AS p
  ON sp.BusinessEntityID = p.BusinessEntityID;


--Proposition 3: Holiday Inventory – Products Sold or Purchased
/* Lists every product that’s either been sold or purchased. Produces product names or IDs 
that appear in sales details or purchase orders—a combined “active items” list. */

SELECT DISTINCT p.Name, 'Sold' AS Source
FROM AdventureWorks2017.Production.Product AS p
JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
  ON p.ProductID = sod.ProductID

UNION
SELECT DISTINCT p.Name, 'Purchased' AS Source
FROM AdventureWorks2017.Production.Product AS p
JOIN AdventureWorks2017.Purchasing.PurchaseOrderDetail AS pod
  ON p.ProductID = pod.ProductID;


--Proposition 4: Christmas Essentials – Products Sold AND Purchased
/* Narrows it down to products that were both purchased and sold. The result is a smaller table
 of core items moving through both sides of supply chain. */
SELECT p.Name, p.ProductNumber
FROM AdventureWorks2017.Production.Product AS p
JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
  ON p.ProductID = sod.ProductID

INTERSECT
SELECT p.Name, p.ProductNumber
FROM AdventureWorks2017.Production.Product AS p
JOIN AdventureWorks2017.Purchasing.PurchaseOrderDetail AS pod
  ON p.ProductID = pod.ProductID;


--Proposition 5: Thanksgiving Churn – Customers Who Stopped Ordering
/* Compares two different years of customer activity. Output: customer IDs that existed
 in Year A (for example 2013) but not in Year B (2014) — of lost shoppers. */

SELECT DISTINCT soh.CustomerID
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
WHERE YEAR(soh.OrderDate) = 2013

EXCEPT
SELECT DISTINCT soh.CustomerID
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
WHERE YEAR(soh.OrderDate) = 2014;


-- Proposition 6: Black Friday Order Types – Online vs In-Store Orders
/* Separates sales into “Online” and “In-Store” orders. I will see SalesOrderID 
 |OrderDate | OrderType, with each row tagged as Online or In-Store. */

SELECT SalesOrderID, OrderDate, 'Online' AS OrderType
FROM AdventureWorks2017.Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1

UNION ALL

SELECT SalesOrderID, OrderDate, 'In-Store' AS OrderType
FROM AdventureWorks2017.Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0;


--Proposition 7: North Pole Product Catalog – Categories & Subcategories
/* Combines product categories and subcategories into one unified list.
Displays a single column of names—categories first, then subcategories—with no repeats.  */

SELECT Name
FROM AdventureWorks2017.Production.ProductCategory

UNION
SELECT Name
FROM AdventureWorks2017.Production.ProductSubcategory;


--Proposition 8: Exclusive Suppliers – Vendors but Not Customers
/* Shows vendors who are not also customers. The result set lists supplier IDs or names
unique to the vendor table, omitting anyone who appears as a buyer. */
SELECT v.BusinessEntityID, v.Name AS VendorName
FROM AdventureWorks2017.Purchasing.Vendor AS v

EXCEPT
SELECT c.CustomerID, 'Customer' AS CustomerName
FROM AdventureWorks2017.Sales.Customer AS c;


--Proposition 9: Loyal Reindeer – Repeat Shoppers Over Holidays
/* Finds customers who bought in multiple holiday seasons. Returns the CustomerID values 
that overlap across the chosen years- repeat shoppers. */

(
  SELECT soh.CustomerID
  FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
  WHERE YEAR(soh.OrderDate) = 2011
  
  UNION
  SELECT soh.CustomerID
  FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
  WHERE YEAR(soh.OrderDate) = 2012
)
INTERSECT
SELECT soh.CustomerID
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
WHERE YEAR(soh.OrderDate) = 2013;


--Proposition 10: Naughty or Nice Names – Shared Last Names
/* Looks for last names shared by employees and customers. Outputs the actual LastName column 
 for people found in both groups—fun to see “family ties” inside the data.  */
SELECT p.LastName
FROM AdventureWorks2017.Person.Person AS p
JOIN AdventureWorks2017.HumanResources.Employee AS e
  ON p.BusinessEntityID = e.BusinessEntityID

INTERSECT
SELECT p.LastName
FROM AdventureWorks2017.Person.Person AS p
JOIN AdventureWorks2017.Sales.Customer AS c
  ON p.BusinessEntityID = c.PersonID;



