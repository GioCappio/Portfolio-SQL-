-- Revenue View

CREATE VIEW RevenueTable as
SELECT ord.OrderID, ord.OrderDate, ord.RequiredDate, 
	ord.ShippedDate, ord.Freight, ord.CustomerID, 
	ord.ShipCity, ord.ShipCountry, Odet.ProductID, 
	Odet.UnitPrice, Odet.Quantity, Odet.Discount,
	pro.ProductName, cust.CompanyName, cat.CategoryName,
	ord.EmployeeID,
	(Odet.UnitPrice*Odet.Quantity) as Revenue,
	((Odet.UnitPrice*Odet.Quantity)-ord.Freight -(Odet.Discount*Odet.UnitPrice*Odet.Quantity)) as Net_revenue
FROM Northwind..Orders ord
JOIN Northwind..[Order Details] Odet
on Odet.OrderID = ord.OrderID
JOIN Northwind..Products pro
on Odet.ProductID=pro.ProductID
JOIN Northwind..Customers cust
on cust.CustomerID=ord.CustomerID
JOIN Northwind..Categories cat
on cat.CategoryID= pro.CategoryID
ORDER BY ShippedDate 

GO

Select pro.ProductID, pro.ProductName, odet.UnitPrice
From Northwind..Products pro
JOIN Northwind..[Order Details] odet
on odet.ProductID = pro.ProductID
Group by pro.ProductID, pro.ProductName, odet.UnitPrice

Select *
From Northwind..Orders ord
JOIN Northwind..[Order Details] odet 
on ord.OrderID= odet.OrderID
Go

-- Employee view

SELECT EmployeeID, LastName, FirstName, Title, BirthDate, ReportsTo
From Northwind..Employees



-- Logistics view

SELECT pro.ProductID, pro.SupplierID, pro.UnitsInStock, 
pro.UnitsOnOrder, pro.ReorderLevel, pro.Discontinued, --
sup.CompanyName as Supplier_name, sup.Phone as supplier_phone,--
odet.OrderID,--
ord.OrderDate, ord.RequiredDate, ord.ShippedDate, 
ord.ShipVia,--
ship.*
FROM Northwind..Products pro
JOIN Northwind..Suppliers sup
on pro.SupplierID=sup.SupplierID
JOIN Northwind..[Order Details] odet
on odet.ProductID=pro.ProductID
JOIN Northwind..Orders ord
on ord.OrderID= odet.OrderID
JOIN Northwind..Shippers ship
on ship.ShipperID=ord.ShipVia