USE AdventureWorks2022;

--proposition 1: select the names and ID's of employees hired after january 2, 2009, and with the job senior design engineer
SELECT e.BusinessEntityID,CONCAT(p.FirstName, ' ',p.LastName), e.HireDate, e.JobTitle
FROM HumanResources.Employee as e
INNER JOIN Person.Person p 
ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.HireDate > '2009-01-02'
INTERSECT
SELECT e.BusinessEntityID,CONCAT(p.FirstName, ' ',p.LastName), e.HireDate, e.JobTitle 
FROM HumanResources.Employee as e
INNER JOIN Person.Person p 
ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.JobTitle = 'Senior Design Engineer';
/*-The query outputs the employee full  name, their hire date, and their job title. 
 * It intersects rows where the person's job title is senior design engineer, with rows that have a hire date hire date after January 2 2009
 * *This query can be used by businesses to assess how long employees have been employed.*/

--proposition 2: select the names and ID's of employees who has greater than 90 vacation hours, or employees that have greater than 50 sick hours
SELECT e.BusinessEntityID , e.VacationHours, e.SickLeaveHours
FROM HumanResources.Employee as e
WHERE e.VacationHours > 90
UNION
SELECT e.BusinessEntityID, e.VacationHours, e.SickLeaveHours
FROM HumanResources.Employee as e
WHERE e.SickLeaveHours  > 50;

/*this query outputs the ID, vacation hours, and sick leave hours of each employee.
 * the output combines the list of employees who have greater than 90 hours, and the list of employees who have greater than 50 sick hours.
 * This query can be used by businesses as a means of checkign which employees have an unusually high amount of sick hours.*/

--Proposition 3: select the product ID's that have a list price greater than 3500 except products that have a weight less than 14.5
SELECT p.ProductID 
FROM Production.Product p
WHERE p.ListPrice > 3500
EXCEPT
SELECT p.ProductID 
FROM Production.Product p
WHERE p.Weight < 14.5;
/*This query outputs the ID of products with a list price greater than 3500, and excludes products with a weight less than 14.5
 *This query can be used by businesses to ensure that the price of their prodcuts are consistent with the products weights.*/

--Proposition 4: Select the ID of special offers that start in the year 2012 except offers in April
SELECT so.SpecialOfferID, so.StartDate, so.Description 
FROM Sales.SpecialOffer so
WHERE YEAR(so.StartDate) = '2012'
EXCEPT 
SELECT so.SpecialOfferID, so.StartDate, so.Description 
FROM Sales.SpecialOffer so
WHERE MONTH(so.StartDate) = '04';

/*this query outputs the ID and description of special offers that start at January 2012, and excludes offers that start in april
 * this query can be used by businesses for keeping track of monthly offers.*/

--Proposition 5: Get the list of ID's of employee departments that start at 2010, except for those that have a shift ID of 1.
SELECT edh.BusinessEntityID , edh.StartDate, edh.ShiftID 
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE YEAR(edh.StartDate) = 2010
EXCEPT
SELECT edh.BusinessEntityID , edh.StartDate, edh.ShiftID 
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE edh.ShiftID = 1;
/*This query outputs the ID, start date, and shift id of employees who started in 2010, and excludes employees who has a shift ID of 1.
 * This can be used by businesses to keep track of the employees or departments that are assigned to specific shifts.*/

--proposition 6: Select the employees' business entity IDs that have a rate thats higher than the average, except for employees with a pay frequency of 1
SELECT eph.BusinessEntityID, eph.Rate, eph.PayFrequency
FROM HumanResources.EmployeePayHistory eph
WHERE  eph.Rate > (
	SELECT AVG(innerQuery.Rate)
	FROM HumanResources.EmployeePayHistory innerQuery
)
EXCEPT
SELECT eph.BusinessEntityID, eph.Rate, eph.PayFrequency
FROM HumanResources.EmployeePayHistory eph
WHERE eph.PayFrequency = 1;
/*this query can be used by businesses to ensure that each employee is paid a sufficient amount.
 * 
 */

--Proposition 7 list the ID, minimum order quantity, and business entity ID of products that have a minimum order quantity of atleast 51, except for products with a business entity ID of 1580
SELECT pv.ProductID,  pv.MinOrderQty ,  pv.BusinessEntityID 
FROM Purchasing.ProductVendor pv
WHERE pv.MinOrderQty > 50
EXCEPT
SELECT pv.ProductID,  pv.MinOrderQty ,  pv.BusinessEntityID
FROM Purchasing.ProductVendor pv
WHERE pv.BusinessEntityID = 1580;
/*The query outputs the ID, minimum order quantity, and business entity ID of each product.
 *The output only includes products having a minimum order quantity of 50, and excludes products whose business entity is 1580.
 * This query can be used by businesses to identify suppliers that needa  higher minimum orderf quantity.
 */

--Proposition 8 List the business ids of business that have an email or a phone number in the database
SELECT pp.BusinessEntityID, 'Phone Number' AS Phone
FROM Person.PersonPhone pp 
UNION ALL
SELECT ea.BusinessEntityID, 'Email' AS Email
FROM Person.EmailAddress ea;

/* The query outputs the business entity ID of businesses that have an email or phone number in the database.
 * This query can be used by businesses as a means of ensuring that all businesses in the databse have a way to contact them.*/

--Proposition 9 List provinces that have an address in the system.
SELECT a.StateProvinceID 
FROM Person.Address a
INTERSECT
SELECT sp.StateProvinceID 
FROM Person.StateProvince sp;

/* The query outputs a list of state province IDS from the address table, and intersects it with the list of state province IDS from the state province table.
 * This query can be usde by businesses to identify  what provinces have atleast one address in the system.
 */

--Proposition 10 list out products that are red, or have a style of U. 

SELECT p.ProductID, p.Color, p.[Style] 
FROM  Production.Product p
WHERE p.Color = 'Red'
UNION
SELECT p.ProductID, p.Color, p.[Style] 
FROM  Production.Product p
WHERE p.Style = 'U'
/*The resulting query outputs products that either have the color red, or have the style U.
 * This query can be used by businesses to identify which products to sell for upcoming promotions.
 */