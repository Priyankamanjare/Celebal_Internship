--Triggers
--Used Northwind database

--Task 1 

Create Trigger trg_InsteadofDeleteOrder
on Orders
Instead Of Delete
As 
Begin
    Set NoCount on;

	Delete From [Order Details]
	Where OrderID In (Select OrderID From deleted);

	Delete From Orders
	Where OrderID in (Select OrderID From deleted);
End;

--Task 2

Create Trigger trg_CheckStockBeforeInsert
On [Order Details]
Instead Of Insert
As
Begin
    Set NoCount On;

	If Exists (
	   Select 1 From inserted i 
	   Join Products p On i.ProductID = p.ProductID
	   Where i.Quantity > p.UnitsInStock
	)

	Begin
	     RAISERROR('Order could not be placed : Insufficient stock', 16, 1);
		 RollBack Transaction;
		 Return;
	End

	Insert into [Order Details](OrderID, ProductID, UnitPrice, Quantity, Discount)
	Select OrderID, ProductID, UnitPrice, Quantity, Discount
	From inserted;

	Update p 
	Set UnitsInStock = UnitsInStock - i.Quantity
	From Products p
	Join inserted i on p.ProductID = i.ProductID;
End;


