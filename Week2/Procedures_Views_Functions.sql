--Task 1
 --Created Table Sales.OrderDetails

Create Procedure InsertOrderDetails
   @OrderID int,
   @ProductID int,
   @UnitPrice Money = NULL,
   @Quantity int,
   @Discount Float = Null
As
 Begin
    Set NoCount On;
	Declare @StockQty Int, 
	        @ReOrderLevel Int, 
			@ProductPrice Money;

	Select
	  @StockQty = pi.Quantity,
	  @ReOrderLevel = p.ReorderPoint,
	  @ProductPrice = p.ListPrice
	From Production.Product p
	Join Production.ProductInventory pi On p.ProductID = pi.ProductID
	Where p.ProductID = @ProductID
	And pi.LocationID = 1;

	If @StockQty Is NULL
	Begin 
	  Print 'Product not found or no inventory record';
	  Return;
	End

	If @UnitPrice Is NULL
	 Set @UnitPrice = @ProductPrice;

	If @Discount Is NULL
	 Set @Discount = 0;

	Insert Into Sales.OrderDetails(OrderID, ProductID, UnitPrice, Quantity,Discount)
	Values(@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

	If @@ROWCOUNT = 0
	Begin
	   Print 'Failed to place order. Please try again';
	End

	Update Production.ProductInventory
	Set Quantity = Quantity - @Quantity
	Where ProductID = @ProductID
	And LocationID = 1;

	If (@StockQty - @Quantity) < @ReOrderLevel
	Begin
	 Print 'Warning Stock for ProductID' + Cast(@ProductID as Varchar) + 'is below Reorder level';
	 End

End;

Exec InsertOrderDetails
@OrderID = 101,
@ProductID = 343,
@Quantity = 1;

Exec InsertOrderDetails
@OrderID = 102,
@ProductID = 342,
@Quantity = 2;

Select * from Production.ProductInventory
Select * from Sales.OrderDetails

--Task 2 

Create Procedure UpdateOrderDetails
  @OrderDetailID int,
  @Quantity int = NULL,
  @Discount float = NULL

AS
Begin
   Set NoCount On;

   If Not Exists(
     Select 1 From Sales.OrderDetails Where OrderDetailID = @OrderDetailID
	 )
	 Begin
	   Print 'Order not found';
	   Return;
	 End

	Update Sales.OrderDetails 
	Set
	   Quantity = ISNULL(@Quantity,Quantity),
	   Discount = ISNULL(@Discount, Discount)
	Where OrderDetailID = @OrderDetailID;

	Print 'Order updated Successfully';
End;

Exec UpdateOrderDetails
  @OrderDetailID = 1,
  @Quantity = 10,
  @Discount = NULL;


--Task 3

Create Procedure GetOrderDetails 
  @OrderID int
As
  Begin
    Set NoCount On;
	 If Not Exists (
	   Select 1 From Sales.OrderDetails Where OrderID = @OrderID
	 )
	 Begin
	   Print 'The OrderID' + CAST(@OrderID As Varchar)+ 'Does not exist';
	   Return 1;
	 End

	 Select * From Sales.OrderDetails
	 Where OrderID = @OrderID;

  End;

  Exec GetOrderDetails @OrderID = 101;
  Exec GetOrderDetails @OrderID = 104; -

  
--Task 4 

Create Procedure DeleteOrderDetails
   @OrderID int,
   @ProductID int
As
Begin
   Set NoCount On;

   If Not Exists (
      Select 1 From Sales.OrderDetails Where OrderID = @OrderID
	)

	Begin
	   Print 'Invalid OrderID:' + CAST(@OrderID As Varchar);
	   Return -1;
	End

	If Not Exists (
	   Select 1 From Sales.OrderDetails
	   Where OrderID = @OrderID And ProductID = @ProductID
	)

	Begin
	   Print 'ProductID ' + CAST(@ProductID AS Varchar) +
              ' does not exist in OrderID ' + CAST(@OrderID AS Varchar);
       Return -1;
	End

	Delete From Sales.OrderDetails
	Where OrderID = @OrderID And ProductID = @ProductID;

	Print 'Order Deleted Successfully';
End;

Select * from Sales.OrderDetails
Exec DeleteOrderDetails @OrderID = 101, @ProductID = 343;

-- Functions

--Task 1 
--Creating Example Schema

Create Schema Example;

Create Function Example.fn_Format_MMDDYYYY(
  @InputDate Datetime
)
Returns Varchar(10)
as
Begin
 return Convert(Varchar(10),@InputDate, 101);
End;

Select Example.fn_Format_MMDDYYYY('2006-11-21 23:35:06.920') as Formated_date;

--Task 2 

Create Function Example.fn_Format_YYYYMMDD(
 @InputDate Datetime
)
Returns Varchar(10)
As
Begin
 Return Convert(Varchar(10), @InputDate, 112);
End;

Select Example.fn_Format_YYYYMMDD('2006-11-21 23:34:05.920') as Formated_date;

--Views

--Task 1

Create View vwCustomerOrders as
Select 
  Coalesce(p.FirstName, s.Name) as CompanyName,
  soh.SalesOrderID as OrderID,
  soh.OrderDate,
  sod.ProductID,
  pr.Name as ProductName,
  sod.Orderqty as Quantity,
  sod.UnitPrice
From Sales.SalesOrderHeader as soh
Join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
Join Production.Product as pr on sod.ProductID = pr.ProductID
Left Join Sales.Customer as c on soh.CustomerID = c.CustomerID
Left Join Person.Person as p On c.PersonID = p.BusinessEntityID
Left Join Sales.Store as s on c.StoreID = s.BusinessEntityID

--Task 2

Create View vwCustomerOrders_Yesterday as
Select 
  Coalesce(p.FirstName, s.Name) as CompanyName,
  soh.SalesOrderID as OrderID,
  soh.OrderDate,
  sod.ProductID,
  pr.Name as ProductName,
  sod.Orderqty as Quantity,
  sod.UnitPrice
From Sales.SalesOrderHeader as soh
Join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
Join Production.Product as pr on sod.ProductID = pr.ProductID
Left Join Sales.Customer as c on soh.CustomerID = c.CustomerID
Left Join Person.Person as p On c.PersonID = p.BusinessEntityID
Left Join Sales.Store as s on c.StoreID = s.BusinessEntityID
Where CAST(soh.OrderDate as Date) = CAST(DATEADD(DAY, -1, GETDATE()) as DATE);



--Task 3
 Create View My_Products as
 select
     p.ProductID,
	 p.Name as ProductName,
	 ISNULL(CAST(p.Size AS NVARCHAR(MAX)), CAST(p.Weight AS NVARCHAR(MAX))) AS QuantityPerUnit,
	 p.ListPrice AS UnitPrice,
     v.Name AS CompanyName,
     pc.Name AS CategoryName
From Production.Product as p
Left Join Purchasing.ProductVendor As pv On p.ProductID = pv.ProductID
Left Join Purchasing.Vendor As v On pv.BusinessEntityID = v.BusinessEntityID
Left Join Production.ProductSubcategory As psc On p.ProductSubcategoryID = psc.ProductSubcategoryID
Left Join Production.ProductCategory As pc On psc.ProductCategoryID = pc.ProductCategoryID
WHERE p.SellEndDate IS NULL OR p.SellEndDate > GETDATE();

Select * from My_Products