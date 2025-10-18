Use AdventureWorks2022

/*
 * 1. Customers who Ordered in 2011 and 2014
 *  The CTE uses INTERSECT to retrieve the customer IDs that are present in both years
 *  The outer query joins with the customers table to retrieve the person ID,
 *  then joins the person ID with the persons table to retrieve the first and last name
 */
WITH LoyalCustomers AS (
SELECT
	CustomerID
FROM
	Sales.SalesOrderHeader
WHERE
	YEAR(OrderDate) = 2011
INTERSECT
SELECT
	CustomerID
FROM
	Sales.SalesOrderHeader
WHERE
	YEAR(OrderDate) = 2014
)
SELECT
	c.CustomerID,
	p.FirstName,
	p.LastName
FROM
	Sales.Customer c
JOIN LoyalCustomers lc ON
	c.CustomerID = lc.CustomerID
JOIN Person.Person p ON
	c.PersonID = p.BusinessEntityID
ORDER BY
	c.CustomerID;

/*
 * 2. The top 5 items sold in 2013 that were also top items in 2014
 *  The query groups by the product ID and filters by the dates of each year
 *  The INTERSECT between the queries will return the common top 5 items from years
 */
SELECT
	ProductID
FROM
	(
	SELECT
		TOP 5 sod.ProductID
	FROM
		Sales.SalesOrderDetail sod
	JOIN Sales.SalesOrderHeader soh ON
		sod.SalesOrderID = soh.SalesOrderID
	WHERE
		YEAR(CAST(soh.OrderDate as Date)) = 2013
	GROUP BY
		sod.ProductID
	ORDER BY
		COUNT(*) DESC
) AS Top2013
INTERSECT
SELECT
	ProductID
FROM
	(
	SELECT
		TOP 5 sod.ProductID
	FROM
		Sales.SalesOrderDetail sod
	JOIN Sales.SalesOrderHeader soh ON
		sod.SalesOrderID = soh.SalesOrderID
	WHERE
		YEAR(CAST(soh.OrderDate as Date)) = 2014
	GROUP BY
		sod.ProductID
	ORDER BY
		COUNT(*) DESC
) AS Top2014
ORDER BY
	ProductID;

/*
 *  3. Products sold in the US and Canada
 *  The queries search for orders that have been placed in the US and Canada
 *  The INTERSECT between the queries will return the items that have been ordered in both places
 */
SELECT
	DISTINCT sod.ProductID
FROM
	Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON
	sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.SalesTerritory st ON
	soh.TerritoryID = st.TerritoryID
WHERE
	st.CountryRegionCode IN ('US')
INTERSECT 
SELECT
	DISTINCT sod.ProductID
FROM
	Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON
	sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.SalesTerritory st ON
	soh.TerritoryID = st.TerritoryID
WHERE
	st.CountryRegionCode NOT IN ('CA');

/*
 * 4. Customers who have placed orders in the first two quarters in 2014
 *  The queries search for customers that have placed orders during q1 and q2
 *  The UNION between the queries will combine the customerIDs and remove duplicates
 */
SELECT
	DISTINCT CustomerID
FROM
	Sales.SalesOrderHeader
WHERE
	YEAR(OrderDate) = 2014
	AND DATEPART(Quarter, OrderDate) = 1
UNION
SELECT
	DISTINCT CustomerID
FROM
	Sales.SalesOrderHeader
WHERE
	YEAR(OrderDate) = 2014
	AND DATEPART(Quarter, OrderDate) = 2;

/*
 * 5. Discount Mountain and Road Bike Accessories
 *  The CTE searches for products that contain Mountain or Road
 *  The UNION between the queries will show all eligible products
 *  The outer query applies a 20% discount to all items
 */
With MountainAndRoadItems AS(
SELECT 
    Name,
    ListPrice AS OriginalPrice
FROM Production.Product
WHERE Name LIKE '%Road%'

UNION

SELECT
	Name,
	ListPrice AS OriginalPrice
FROM
	Production.Product
WHERE
	Name LIKE '%Mountain%'
)
SELECT
	Name,
	mari.OriginalPrice,
	mari.OriginalPrice * 0.80 AS DiscountedPrice
FROM
	MountainAndRoadItems mari;

/*
 * 6. All online and retail (offline) orders
 *  The query filters and labels each order if they are placed online
 *  The UNION ALL between the queries will combine all orders, even if a customer has an order placed online and offline
 */
SELECT
	SalesOrderID,
	CustomerID,
	'Online' AS Channel
FROM
	Sales.SalesOrderHeader
WHERE
	OnlineOrderFlag = 1
UNION ALL
SELECT
	SalesOrderID,
	CustomerID,
	'Retail' AS Channel
FROM
	Sales.SalesOrderHeader
WHERE
	OnlineOrderFlag = 0;

/*
 * 7. Products with reviews
 *  The INTERSECT combines all product IDs with the ones that are present in the ProductReview table
 */
SELECT
	ProductID
FROM
	Production.Product
INTERSECT
SELECT
	ProductID
FROM
	Production.ProductReview;

/*
 * 8. Customers who have used ShipMethodID 5 (Cargo Transport 5) and but not 1 (XRQ Truck Ground)
 *  The EXCEPT removes any customer that has used ShipmentMethodID 1
 */

SELECT
	DISTINCT CustomerID
FROM
	Sales.SalesOrderHeader
WHERE
	ShipMethodID = 5
EXCEPT
SELECT
	DISTINCT CustomerID
FROM
	Sales.SalesOrderHeader
WHERE
	ShipMethodID = 1;


/*
 * 9. Items that are not on a shelf but have inventory over 250
 *  The query gets products with stocks over 250 and products that have an assigned shelf location
 *  The EXCEPT clause will remove any product that is on a shelf and stock > 250
 */
SELECT
	DISTINCT ProductID
FROM
	Production.ProductInventory
WHERE
	Quantity > 250
EXCEPT
SELECT
	DISTINCT ProductID
FROM
	Production.ProductInventory
WHERE
	Shelf <> N'N/A';

/*
 * 10. Customer emails that did not order on Black Friday
 *  The first query selects all customer emails.
 *  The second query selects emails of customers who ordered on Black Friday.
 *  The EXCEPT operator removes any customers who placed an order that day.
 */

SELECT
	DISTINCT ea.EmailAddress
FROM
	Person.EmailAddress AS ea
JOIN Sales.Customer AS c
    ON
	ea.BusinessEntityID = c.PersonID
EXCEPT
SELECT
	DISTINCT ea.EmailAddress
FROM
	Person.EmailAddress AS ea
JOIN Sales.Customer AS c
    ON
	ea.BusinessEntityID = c.PersonID
JOIN Sales.SalesOrderHeader AS soh
    ON
	c.CustomerID = soh.CustomerID
WHERE
	CAST(soh.OrderDate AS DATE) = '2014-11-28';
