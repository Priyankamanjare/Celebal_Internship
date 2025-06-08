-- Task 1 List of all Customers

Select c.CustomerID, 
      p.FirstName,
	  p.LastName,
	  NULL as Storename,
	  'Individual' as Type
From Sales.Customer c
Join Person.Person p On c.PersonID = p.BusinessEntityID
Where c.PersonID is NOT Null

Union

Select c.CustomerID,
       NULL as FirstName,
	   NULL as LastName,
       s.Name As Storename,
	   'Company' as Type
From Sales.Customer c 
Join Sales.Store s On c.CustomerID = s.BusinessEntityID;

-- Task 2 List of all customers where company name ending with N

Select s.BusinessEntityID ,
      s.Name 
From Sales.Store s
Where Name Like '%n';


-- Task 3 List of all customers who live in Berlin or London

Select c.PersonID,
	   ISNULL(p.FirstName,s.Name) as CustomerName,
	   a.City
From Sales.Customer c 
Left Join Person.Person p on c.PersonID = p.BusinessEntityID
Left Join Sales.Store s on c.StoreID = s.BusinessEntityID
Join Person.BusinessEntityAddress b On 
b.BusinessEntityID = ISNULL(c.PersonID,c.StoreID)
Join Person.Address a on b.AddressID = a.AddressID
Where a.City In ('Berlin', 'London');
       
-- Task 4 List of all customers who livve in UK or USA


Select c.CustomerID,
       ISNULL(p.FirstName,s.Name) as Name,
	   cr.Name
From Sales.Customer c
Left Join Person.Person p on c.PersonID = p.BusinessEntityID
Left Join Sales.Store s on c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress b ON b.BusinessEntityID = ISNULL(c.PersonID, c.StoreID)
Join Person.Address a on b.AddressID = a.AddressID
Join Person.StateProvince sp on a.StateProvinceID = sp.StateProvinceID
Join Person.CountryRegion cr on sp.CountryRegionCode = cr.CountryRegionCode
Where cr.Name IN ('United States', 'United Kingdom');

-- Task 5 List of all Products Sorted by Product name

Select *
From Production.Product
Order By Name ASC;

-- Task 6 List of all Products where Name starts with an A

Select * from Production.Product
Where Name Like 'A%';

-- Task 7 List of customers who ever placed an order


Select c.CustomerID,
      ISNULL(p.FirstName+' '+p.LastName,s.Name) as Name,
      sod.SalesOrderID
From Sales.Customer c
Left join Person.Person p On c.PersonID = p.BusinessEntityID
Left Join Sales.Store s On c.StoreID = s.BusinessEntityID
Join Sales.SalesOrderHeader sod on c.CustomerID = sod.CustomerID


-- Task 9 List of customer who never placed an order


Select c.CustomerID,
       ISNULL(p.FirstName+' '+p.LastName,s.Name) As Name,
       c.PersonID, 
	   c.StoreID
from Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
Left Join Sales.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
Where soh.CustomerID is NULL


-- Task 11 Details of first order of the system

Select Top 1 * from Sales.SalesOrderHeader
Order by OrderDate


-- Task 12 Find details of most expensive order date


Select TOP 1 SalesOrderID, OrderDate, CustomerID,SubTotal,TaxAmt,Freight,TotalDue
from Sales.SalesOrderHeader
Order By TotalDue DESC


-- Task 13 For each Order get the OrderID and Average quantity of items in that order


Select SalesOrderID ,
      AVG(OrderQty) As AverageQuantity
From Sales.SalesOrderDetail
Group by SalesOrderID;


-- Task 14 For each Order get OrderID, minimum quantity and maximum quantiy for that order

Select SalesOrderID ,
      Min(OrderQty) AS MinimumQty,
	  Max(OrderQty) AS MaximumQty
From Sales.SalesOrderDetail
Group by SalesOrderID;


-- Task 15 Get a list of all managers and total number of employees who report to them

Select
    mgr.BusinessEntityID As ManagerID,
    p.FirstName + ' ' + p.LastName As ManagerName,
    COUNT(emp.BusinessEntityID) As NumberOfEmployees
FRom HumanResources.Employee emp
Join HumanResources.Employee mgr
    On emp.OrganizationNode.GetAncestor(1) = mgr.OrganizationNode
Join Person.Person p On mgr.BusinessEntityID = p.BusinessEntityID
Group by mgr.BusinessEntityID, p.FirstName, p.LastName
Order by NumberOfEmployees Desc;



-- Task 16 Get the OrderID and the total quantity for each order that has a total quantity of greater than 300

Select SalesOrderID,
SUM(OrderQty) as TotalQuantity
from Sales.SalesOrderDetail
Group By SalesOrderID 
Having Sum(OrderQty) > 300;

-- Task 17 list of all order placed on or after 1996/12/31

Select SalesOrderID 
From Sales.SalesOrderHeader
Where OrderDate >='1996-12-31';


-- Task 18 List of allorders shipped to Canada

SELECT soh.SalesOrderID
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';


-- Task1 19 List of all orders with total order > 200

Select SalesOrderID,
SUM(OrderQty) as Totalqty
from Sales.SalesOrderDetail
Group By SalesOrderID 
Having SUM(OrderQty) > 200;



-- Task 20 List of countries and sales made in each country
Select
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
From Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

-- Task 21 List of Customer COntactName and number of orders they placed

Select 
     ISNULL(p.FirstName + ' ' + p.LastName, s.Name) as ContactName,
	 Count(soh.SalesOrderID) as TotalOrders
From Sales.Customer c
Left Join Person.Person p ON c.PersonID = p.BusinessEntityID
Left join Sales.Store s ON c.StoreID = s.BusinessEntityID
Join Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
Group by ISNULL(p.FirstName + ' ' + p.LastName, s.Name);


-- Task 22 List of customer ContactName who have placed more than 3 orders

Select 
     ISNULL(p.FirstName + ' ' + p.LastName, s.Name) as ContactName,
	 Count(soh.SalesOrderID) as TotalOrders
From Sales.Customer c
Left Join Person.Person p ON c.PersonID = p.BusinessEntityID
Left join Sales.Store s ON c.StoreID = s.BusinessEntityID
Join Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
Group by ISNULL(p.FirstName + ' ' + p.LastName, s.Name)
Having COUNT(soh.SalesOrderID) > 3;

-- Task 23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998

Select Distinct p.ProductID, p.Name as ProductName
From Production.Product p
Join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
Join Sales.SalesOrderHeader soh on sod.SalesOrderID= soh.SalesOrderID
Where p.DiscontinuedDate is NOT NULL
And soh.OrderDate>= '1997-01-01'
And soh.OrderDate< '1998-01-01';


-- Task 24 List of employee firsname, lastName, superviser FirstName, LastName

Select
 e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName,
    m.FirstName AS SupervisorFirstName,
    m.LastName AS SupervisorLastName
From HumanResources.Employee emp
Join Person.Person e ON emp.BusinessEntityID = e.BusinessEntityID
Left Join  HumanResources.Employee mgr ON emp.OrganizationNode.GetAncestor(1) = mgr.OrganizationNode
LEFT JOIN Person.Person m ON mgr.BusinessEntityID = m.BusinessEntityID;


-- Task 25 List of Employees id and total sale condcuted by employee

Select soh.SalesPersonID As EmployeeID,
 SUM(soh.TotalDue) as TotalSales
 From Sales.SalesOrderHeader soh
 Where soh.SalesPersonID IS NOT NULL
 Group by soh.SalesPersonID
 Order by TotalSales Desc;

 -- Task 26 list of employees whose FirstName contains character a

 Select p.BusinessEntityID, p.FirstName, p.LastName
 From Person.Person p
 Join HumanResources.Employee e On p.BusinessEntityID = e.BusinessEntityID
 Where p.FirstName Like '%a%';

 -- Task 27 List of managers who have more than four people reporting to them.

 Select mgr.BusinessEntityID as ManagerID,
 COUNT(emp.BusinessEntityID) as NumberOfReports
 From HumanResources.Employee emp
 Join HumanResources.Employee mgr
 on emp.OrganizationNode.GetAncestor(1)=mgr.OrganizationNode
 Group by mgr.BusinessEntityID
 Having COUNT(emp.BusinessEntityID) > 4;

 -- Task 28 List of Orders and ProductNames

 Select sod.SalesOrderID,
 p.Name as ProductName
 From Sales.SalesOrderDetail sod
 Join Production.Product p on sod.ProductID=p.ProductID;
 

 -- Task 29 List of orders place by the best customer

 WITH CustomerTotals AS (
    SELECT CustomerID, SUM(TotalDue) AS TotalSpent
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue, soh.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN CustomerTotals ct ON soh.CustomerID = ct.CustomerID
WHERE ct.TotalSpent = (
    SELECT MAX(TotalSpent) FROM CustomerTotals
)
ORDER BY soh.OrderDate;

-- Task 30 List of orders placed by customers who do not have a Fax number

Select soh.SalesOrderID,
       c.CustomerID,
       ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName
FROM Sales.SalesOrderHeader soh
Join Sales.Customer c ON soh.CustomerID = c.CustomerID
Left Join Person.Person p ON c.PersonID = p.BusinessEntityID
Left Join Sales.Store s ON c.StoreID = s.BusinessEntityID
Left Join Person.PersonPhone pp 
  on p.BusinessEntityID = pp.BusinessEntityID
Left Join Person.PhoneNumberType pnt 
  ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID 
  AND pnt.Name = 'Fax'
  Where pp.BusinessEntityID is NULL
  Or pnt.PhoneNumberTypeID is NULL;

  -- Task 32 List of product Names that were shipped to france

 Select Distinct p.Name as ProductName
From Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod On soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p On sod.ProductID = p.ProductID
JOIN Person.Address a On soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp On a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr On sp.CountryRegionCode = cr.CountryRegionCode
Where cr.Name = 'France';

-- Task 34 List of products that were never ordered

Select p.ProductID, p.Name as ProductName
From Production.Product p
Left Join Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
Where sod.ProductID Is NULL;


-- Task 35 List of products where units in stock is less than 10 and units on order are 0

Select p.ProductID, p.Name, pi.Quantity AS UnitsInStock
From Production.Product p
Join Production.ProductInventory pi ON p.ProductID = pi.ProductID
where pi.Quantity < 10;

-- Task 36 List of top 10 countries by sales

Select Top 10
cr.Name As Country,
SUM(soh.TotalDue) As TotalSales
FROM Sales.SalesOrderHeader soh
Join Person.Address a On soh.ShipToAddressID = a.AddressID
JOin Person.StateProvince sp On a.StateProvinceID = sp.StateProvinceID
Join Person.CountryRegion cr On sp.CountryRegionCode = cr.CountryRegionCode
Group By cr.Name
Order By TotalSales DESC;

-- Task 37 Number of orders each employee has taken for customers with CustomerIDs between A and AO

SELECT e.BusinessEntityID AS EmployeeID,
 p.FirstName,
 p.LastName,
 COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE soh.CustomerID BETWEEN 1 AND 41
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY NumberOfOrders DESC;


-- Task 38 Orderdate of most expensive order

Select Top 1 OrderDate, TotalDue, SalesOrderID
From Sales.SalesOrderHeader
Order By TotalDue Desc;

-- Task 39 Product name and total revenue from that product

Select
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalRevenue
From Sales.SalesOrderDetail sod
Join Production.Product p On sod.ProductID = p.ProductID
Group By p.Name
Order By TotalRevenue DESC;



-- Task 40 Supplierid and number of products offered

Select 
    pv.BusinessEntityID As VendorID,
    COUNT(pv.ProductID) As NumberOfProducts
From Purchasing.ProductVendor pv
Group by pv.BusinessEntityID
Order by NumberOfProducts Desc;





-- Task 41 Top ten customers based on their business

SELECT TOP 10 
 c.CustomerID,
 ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
 SUM(soh.TotalDue) AS TotalBusiness
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName, s.Name
ORDER BY TotalBusiness DESC;




-- Task 42  What is the total revenue of the company

Select SUM(TotalDue) As TotalRevenue
From Sales.SalesOrderHeader;