use Northwind
go

--1
--1.1
SELECT * FROM Region
GO

--1.2
SELECT TOP 5 CompanyName, Address, City FROM Suppliers
ORDER BY 1
GO

--1.3
SELECT * FROM Employees WHERE FirstName = 'Robert' AND LastName = 'King'
GO

--1.4
SELECT * FROM Products WHERE Discontinued = 1
GO

--1.5
SELECT ProductName AS 'НАИМЕНОВАНИЕ', UnitPrice AS 'ЦЕНА', UnitsInStock AS 'ОСТАТОК' 
FROM Products
WHERE UnitsInStock > 100
GO

--1.6
SELECT * FROM Employees WHERE MONTH(BirthDate) = 10
GO

--1.7
SELECT * FROM Employees WHERE Notes LIKE 'Ph.D.'
GO

--1.8
SELECT LastName, (case when DATEDIFF(YEAR, BirthDate, GetDate()) > 60 
					THEN 'YES' ELSE 'NO' END)  AS 'Greater then 60'
FROM Employees
GO


--2
--2.1
SELECT dbo.Products.ProductName, dbo.Products.UnitPrice, dbo.Products.UnitsInStock
FROM     dbo.Categories INNER JOIN
                  dbo.Products ON dbo.Categories.CategoryID = dbo.Products.CategoryID
WHERE Categories.CategoryName = 'Beverages' 
		AND Products.UnitsInStock >100
GO

--2.2
SELECT DISTINCT dbo.[Order Details].OrderID, dbo.Orders.OrderDate,
					SUM(dbo.[Order Details].UnitPrice*Quantity)	AS 'ОБЩАЯ СУММА'
FROM     dbo.Employees INNER JOIN
                  dbo.Orders ON dbo.Employees.EmployeeID = dbo.Orders.EmployeeID INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
WHERE FirstName = 'Steven' AND LastName = 'Buchanan' AND YEAR(OrderDate) = 1996 AND MONTH(OrderDate) = 7
GROUP BY dbo.[Order Details].OrderID,  dbo.Orders.OrderDate
GO 

--2.3
SELECT DISTINCT dbo.Orders.OrderID, dbo.Orders.OrderDate
FROM     dbo.Categories INNER JOIN
                  dbo.Products ON dbo.Categories.CategoryID = dbo.Products.CategoryID INNER JOIN
                  dbo.[Order Details] ON dbo.Products.ProductID = dbo.[Order Details].ProductID INNER JOIN
                  dbo.Orders ON dbo.[Order Details].OrderID = dbo.Orders.OrderID
WHERE Categories.CategoryName = 'Seafood'
GO

--2.4
SELECT DISTINCT dbo.Products.ProductName
FROM     dbo.Products INNER JOIN
                  dbo.[Order Details] ON dbo.Products.ProductID = dbo.[Order Details].ProductID INNER JOIN
                  dbo.Orders ON dbo.[Order Details].OrderID = dbo.Orders.OrderID
WHERE ShipCountry = 'Canada' AND YEAR(ShippedDate) = 1997 
GO

--2.5
SELECT DISTINCT dbo.Products.ProductName
FROM     dbo.Products INNER JOIN
                  dbo.[Order Details] ON dbo.Products.ProductID = dbo.[Order Details].ProductID INNER JOIN
                  dbo.Orders ON dbo.[Order Details].OrderID = dbo.Orders.OrderID INNER JOIN
                  dbo.Shippers ON dbo.Orders.ShipVia = dbo.Shippers.ShipperID
WHERE  ShipCountry = 'Canada' AND YEAR(ShippedDate) = 1997 AND CompanyName = 'Speedy Express'
GO

--3
--3.1
SELECT COUNT(*) AS 'количество заказов' FROM Orders
GO

--3.2
-- Под количеством позиций я понимаю число едениц товара, входящих в заказ
SELECT dbo.Orders.OrderID, SUM(dbo.[Order Details].Quantity) AS 'КОЛИЧЕСТВО ШТУЧНЫХ ТОВАРОВ', 
			SUM(dbo.[Order Details].UnitPrice * Quantity) AS 'ОБЩАЯ СТОИМОСТЬ'
FROM     dbo.[Order Details] INNER JOIN
                  dbo.Orders ON dbo.[Order Details].OrderID = dbo.Orders.OrderID
WHERE YEAR(ShippedDate) = 1997 AND MONTH(ShippedDate) = 10 AND DAY(ShippedDate) = 21  
GROUP BY Orders.OrderID
GO

--3.3
SELECT SUM(UnitsInStock) AS 'количествo поставленного на склад товара ' FROM Products
WHERE ProductID = 4 AND SupplierID = 3
GO

--3.4
SELECT SUM(dbo.[Order Details].Quantity*UnitPrice) AS 'общая стоимость поставленной продукции'
FROM     dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
WHERE MONTH(ShippedDate) = 2 AND YEAR(ShippedDate) = 1998
GO

--3.5
SELECT COUNT(ProductID) FROM Products
WHERE Discontinued = 0
GO

--3.6 
SELECT dbo.Employees.FirstName, dbo.Employees.LastName, YEAR(OrderDate), 
				COUNT(dbo.Orders.OrderID) AS 'количествo'
FROM     dbo.Orders INNER JOIN
                  dbo.Employees ON dbo.Orders.EmployeeID = dbo.Employees.EmployeeID
WHERE YEAR(OrderDate) BETWEEN 1997 AND 1998
GROUP BY dbo.Employees.FirstName, YEAR(OrderDate), dbo.Employees.LastName
GO

--3.7
SELECT dbo.Categories.CategoryName, SUM(dbo.Products.UnitsInStock) AS 'остатoк'
FROM     dbo.Categories INNER JOIN
                  dbo.Products ON dbo.Categories.CategoryID = dbo.Products.CategoryID
WHERE dbo.Products.UnitsInStock < 100
GROUP BY dbo.Categories.CategoryName
GO

--3.9
SELECT dbo.Employees.LastName, dbo.Employees.FirstName
FROM     dbo.Employees INNER JOIN
                  dbo.Orders ON dbo.Employees.EmployeeID = dbo.Orders.EmployeeID INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
WHERE YEAR(OrderDate) = 1996
GROUP BY dbo.Employees.LastName, dbo.Employees.FirstName
HAVING SUM(dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity) > 5000.0
GO

--3.10
SELECT ShipCountry, SUM(dbo.[Order Details].UnitPrice * Quantity) AS 'стоимость заказов'
FROM     dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
WHERE YEAR(ShippedDate) = 1997
GROUP BY ShipCountry
GO

--3.11

 DECLARE @cols NVARCHAR(MAX), @sql NVARCHAR(MAX)

SET @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(dbo.Orders.ShipCountry)
FROM dbo.Orders
order by 1
FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'),1,1,'')

SET @sql = 'SELECT ' + @cols + '
FROM
(
SELECT ShipCountry, SUM(dbo.[Order Details].UnitPrice * Quantity) AS CostOfOrders
FROM dbo.Orders INNER JOIN
dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
WHERE YEAR(ShippedDate) = 1997
GROUP BY ShipCountry
) r
PIVOT
(
SUM(CostOfOrders) FOR ShipCountry IN (' + @cols + ')
) countr'

EXECUTE(@sql)
--3.12
SELECT  YEAR(OrderDate) AS 'Год',
		ISNULL(CAST(MONTH(OrderDate) AS VARCHAR(30)), 
                 CASE WHEN GROUPING(MONTH(OrderDate))=1 AND GROUPING(YEAR(OrderDate))=0
                      THEN 'SUBTOTAL' 
                      ELSE 'TOTAL' END) AS 'Месяц'
					  ,SUM(dbo.[Order Details].UnitPrice * Quantity) AS N'стоимость заказов'
FROM     dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
GROUP BY 
   ROLLUP (YEAR(OrderDate), MONTH(OrderDate))
GO

--3.13
SELECT SUM(dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity) AS 'стоимость'
FROM     dbo.Customers INNER JOIN
                  dbo.Orders ON dbo.Customers.CustomerID = dbo.Orders.CustomerID INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
WHERE CompanyName = 'HILARION-Abastos' AND YEAR(OrderDate) = 1997
GO

--4
--4.1
SELECT ProductName, UnitsInStock FROM Products 
WHERE UnitsInStock BETWEEN 5 AND 10 OR UnitsInStock >= 25
GO

--4.2
SELECT dbo.Orders.OrderID, COUNT(*) AS 'КОЛИЧЕСТВО ТОВАРОВ'
FROM     dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
GROUP BY dbo.Orders.OrderID
HAVING COUNT(*) > 2
GO

--4.3
SELECT ShipCity, COUNT(*) AS 'КОЛИЧЕСТВО ЗАКАЗОВ' FROM Orders
GROUP BY ShipCity
HAVING COUNT(*) > 3
GO

--5
--5.1
SELECT * FROM (
	SELECT AVG(SR) AS '1996' FROM(

	SELECT SUM(Quantity*UnitPrice) AS SR FROM dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
				  WHERE MONTH(OrderDate) = 11 AND YEAR(OrderDate) = 1996
				  GROUP BY dbo.[Order Details].OrderID
	)T1) T3 CROSS JOIN (
	SELECT AVG(SR) AS '1997' FROM(

	SELECT SUM(Quantity*UnitPrice) AS SR FROM dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
				  WHERE MONTH(OrderDate) = 11 AND YEAR(OrderDate) = 1997
				  GROUP BY dbo.[Order Details].OrderID
	)T2) T4
GO

--5.2
SELECT * FROM (
	SELECT TOP (1) Percentile_Disc (0.5) 
           WITHIN GROUP (ORDER BY Price)
           OVER() AS 'МЕДИАНА' FROM(
	SELECT SUM(Quantity*UnitPrice) AS Price FROM dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
				  WHERE MONTH(OrderDate) = 11 AND YEAR(OrderDate) = 1996
				  GROUP BY dbo.[Order Details].OrderID
	)T1) T3 CROSS JOIN (
	SELECT AVG(SR) AS 'СРЕДНЕЕ' FROM(

	SELECT SUM(Quantity*UnitPrice) AS SR FROM dbo.Orders INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID
				  WHERE MONTH(OrderDate) = 11 AND YEAR(OrderDate) = 1997
				  GROUP BY dbo.[Order Details].OrderID
	)T2) T4
GO