-- Fahim Tanvir
--Group_1045_4
-- CSCI-331
-- HW6
-- intro: These are 10 queries using set operators along with previously established knowledge from other chapters.

USE AdventureWorks2022 --We need this to run the queries in the right db
GO
--
-- 1.
/** This is to identify our customer base for data tracking. This is crucial for
teams to segment customers who have placed orders before  and
for delivery teams to link active customers to their area. Think of it like a manifest or
statement for past orders**/
SELECT T1.CustomerID, T1.AccountNumber, T1.TerritoryID 
FROM Sales.Customer AS T1
INNER JOIN 
(
    SELECT CustomerID FROM Sales.Customer    
    INTERSECT 
    SELECT CustomerID FROM Sales.SalesOrderHeader
) AS T2
ON T1.CustomerID = T2.CustomerID
ORDER BY T1.TerritoryID ASC;



-- 2. 
/**This one is to find all our sales people based on all the orders(which is 
what the intersect operator is for) and find our most profiting sales people to see
our best employees**/

WITH TopSalesPeople AS (
    SELECT TOP 10 SalesPersonID
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
    ORDER BY SUM(TotalDue) DESC
)
SELECT DISTINCT SalesPersonID
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL

INTERSECT

SELECT DISTINCT SalesPersonID
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IN (SELECT SalesPersonID FROM TopSalesPeople);


-- 3. 
/**This query will check for customer sales based on both their online orders
and in person orders. Union operator is used to match it per customer while CTES
are used to demark online and retail orders separately**/
WITH OnlineOrders AS (
    SELECT SalesOrderID, CustomerID, OrderDate, 'Online' AS Channel
    FROM Sales.SalesOrderHeader
    WHERE OnlineOrderFlag = 1
),
RetailOrders AS (
    SELECT SalesOrderID, CustomerID, OrderDate, 'Retail' AS Channel
    FROM Sales.SalesOrderHeader
    WHERE OnlineOrderFlag = 0
)
SELECT * FROM OnlineOrders
UNION
SELECT * FROM RetailOrders;



--4.
/*This will find addresses within our DB which is only used for shipping and billing but 
not both. This is done by a series of except operators met with a union to select each type separately
and bring them together in the end. Purpose is to identify possible gift-givers, distributors or even
fraudsters*/

SELECT ShipToAddressID AS AddressID
FROM Sales.SalesOrderHeader
EXCEPT
SELECT BillToAddressID AS AddressID
FROM Sales.SalesOrderHeader

UNION


SELECT BillToAddressID AS AddressID
FROM Sales.SalesOrderHeader
EXCEPT
SELECT ShipToAddressID AS AddressID
FROM Sales.SalesOrderHeader;

-- 5. 
/*This one finds IDS of bussinesses from 3 different tables and only shows the ones
that are not affiliated with our DB. This is simply used to keep track of external affairs 
and it would make sense for any database systems to keep internal and external information or information
about employees/management and about suppliers or customers separate.*/

    SELECT BusinessEntityID FROM Sales.Store
    UNION
    SELECT BusinessEntityID FROM Person.Person
EXCEPT
SELECT BusinessEntityID FROM HumanResources.Employee;






--6.)
/*Finds customers who buy a lot and separates them from customers who buy only 1 item.
This is done by a union between customers after looking at the ammount of purchases
they made*/

SELECT CustomerID, 'PotentialRegular' AS BuyerType
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(SalesOrderID) > 1

UNION

SELECT CustomerID, 'Onlybuysonething' AS BuyerType
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(SalesOrderID) = 1;

--7
/*This one compares products that sell very well and the ones that sell poorly. This is done
by unioning 2 subqueries, which finds top 3 items that find the best and worst selling
items respectively.This is special as it allows management to see which items are selling like
hotcakes and which items need to be 86'd or put into clearance immediately*/
SELECT ProductID, Revenue, 'BestSeller' AS Tag
FROM (
    SELECT TOP 3 ProductID, SUM(LineTotal) AS Revenue
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
    ORDER BY Revenue DESC
) AS Best

UNION 
SELECT ProductID, Revenue, 'WorstSeller' AS Tag
FROM (
    SELECT TOP 3 ProductID, SUM(LineTotal) AS Revenue
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
    ORDER BY Revenue ASC
) AS Worst;



--8.
/**Apply half off discount to all id'd 911 items. This is because
item numbers with that id are selling horribly, so a reduced price
can maybe help incentivize it. This is done through an inner join
and an intersect to mark every purchase of item number 911**/

SELECT
    Sales.SalesOrderID,
    Sales.SalesOrderDetailID,
    Sales.ProductID,
    Sales.LineTotal AS OriginalLineTotal,
    Sales.LineTotal * (1 - 0.50) AS DiscountedLineTotal, 
    'NEEDS 50% Discount' AS DiscountStatus
FROM
    Sales.SalesOrderDetail AS Sales
INNER JOIN
    (
        SELECT DISTINCT SalesOrderID FROM Sales.SalesOrderDetail
        INTERSECT
        SELECT SalesOrderID FROM Sales.SalesOrderDetail WHERE ProductID = 911
    ) AS QualifyingOrders ON Sales.SalesOrderID = QualifyingOrders.SalesOrderID
ORDER BY
    Sales.SalesOrderID;




-- 9. 
/*We will find all orders with out best profitng item, item 782, and see how many times
It was ordered in more than one in terms of quantity. This is just for basic data tracking related
to a product which is bestselling. This is done by unioning/intersecting(video initially had me use intersection but union was just used to show all sales) all sales order ids with only to a SalesOrderID where Product 782 appears on more than one line. The output will be blank
as item has only been bought once.*/

SELECT SalesOrderID, ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE ProductID = 782

INTERSECT --UNION will show all sales(not repeated) 

SELECT SalesOrderID, ProductID, LineTotal
FROM Sales.SalesOrderDetail AS Sales
WHERE ProductID = 782
  AND EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS Sales2
    WHERE Sales2.SalesOrderID = Sales.SalesOrderID
      AND Sales2.ProductID = 782
    GROUP BY Sales2.SalesOrderID
    HAVING COUNT(ProductID) > 1
  );



-- 10. 
/**This will create a sales report from years 2011 to 2014. 2011 is the earliest i found
within the database and 2014 is the latest year. This is just to keep track of sales data
throughout the duration of the company and this is done by a union all to avoid repeated rows being 
outputted.**/
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2011

UNION 

SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2014

ORDER BY OrderDate;



