--*************************************************************************--
-- Title: Assignment06
-- Author: Mele Winn
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-21,MWinn,Created File, set up tables, relationships
--	and all necessary constraints related to the entities Categories, 
--	Products, Employees, and Inventories.
-- 2021-02-22,MWinn, Worked on Questions #1-10, commented out queries 
-- that did not work, wrote final queries to submit as answers.
-- 2021-02-23,MWinn, Added default  back to master at the end of 
-- the script, reviewed file for any code 
-- errors and cleaned up queries so that the file is ready to submit for 
-- grading. 
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MeleWinn')
	 Begin 
	  Alter Database [Assignment06DB_MeleWinn] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MeleWinn;
	 End
	Create Database Assignment06DB_MeleWinn;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MeleWinn;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create view for Categories table
Use Assignment06DB_MeleWinn;
GO
Create -- Drop
View vCategories
WITH SCHEMABINDING
As
 Select
  CategoryID
  , CategoryName
  From dbo.Categories;
GO

Select * From Categories;
Select * From vCategories;
GO

-- Create view for Products table
Use Assignment06DB_MeleWinn;
GO
Create -- Drop
View vProducts
WITH SCHEMABINDING
As
 Select
  ProductID
  , ProductName
  , CategoryID
  , UnitPrice
  From dbo.Products;
GO

Select * From Products;
Select * From vProducts;
GO

-- Create view for Employees table
Use Assignment06DB_MeleWinn;
GO
Create -- Drop
View vEmployees
WITH SCHEMABINDING
As
 Select
  EmployeeID
  , EmployeeFirstName
  , EmployeeLastName
  , ManagerID
  From dbo.Employees;
GO

Select * From Employees;
Select * From vEmployees;
GO

-- Create view for Inventories table
Use Assignment06DB_MeleWinn;
GO
Create -- Drop
View vInventories
WITH SCHEMABINDING
As
 Select
  InventoryID
  , InventoryDate
  , EmployeeID
  , ProductID
  , Count
  From dbo.Inventories;
GO

Select * From Inventories;
Select * From vInventories;
GO

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On v.Categories to Public;

Deny Select On Products to Public;
Grant Select On v.Products to Public;

Deny Select On Employees to Public;
Grant Select On v.Employees to Public;

Deny Select On Inventories to Public;
Grant Select On v.Inventories to Public;


-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

GO
Create -- Drop
View vProductsByCategories
As
  Select Top 1000
  CategoryName
  , ProductName
  , UnitPrice
From Assignment06DB_MeleWinn.dbo.Categories as c
Inner Join Assignment06DB_MeleWinn.dbo.Products as p
 On c.CategoryID = p.CategoryID
Order By CategoryName, ProductName;
GO

Select * From vProductsByCategories; 

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

GO
Create -- Drop
View vInventoriesByProductsByDates
As
  Select Top 1000
  ProductName
  , InventoryDate
  , COUNT
From Assignment06DB_MeleWinn.dbo.Products as p
Inner Join Assignment06DB_MeleWinn.dbo.Inventories as i
 On p.ProductID = i.ProductID
Order By ProductName, InventoryDate, COUNT;
GO

Select * From vInventoriesByProductsByDates;

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

GO
Create -- Drop
View vInventoriesByEmployeesByDates
As
  Select Top 10000
  InventoryDate
  , [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
From Assignment06DB_MeleWinn.dbo.Inventories as i
Inner Join Assignment06DB_MeleWinn.dbo.Employees as e
 On i.EmployeeID = e.EmployeeID
Group by InventoryDate, EmployeeFirstName, EmployeeLastName
Order By InventoryDate;
GO

Select * From vInventoriesByEmployeesByDates;

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

GO
Create -- Drop
View vInventoriesByProductsByCategories
As
  Select Top 1000
  CategoryName
  , ProductName
  , InventoryDate
  , Count
From Assignment06DB_MeleWinn.dbo.Categories as c
Inner Join Assignment06DB_MeleWinn.dbo.Products as p
 On c.CategoryID = p.CategoryID
Inner Join Assignment06DB_MeleWinn.dbo.Inventories as i
 On p.ProductID = i.ProductID
Order By CategoryName, ProductName, InventoryDate, COUNT;
GO

Select * From vInventoriesByProductsByCategories;

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

GO
Create -- Drop
View vInventoriesByProductsByEmployees
As
  Select Top 1000
  CategoryName
  , ProductName
  , InventoryDate
  , Count
  , [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
From Assignment06DB_MeleWinn.dbo.Categories as c
Inner Join Assignment06DB_MeleWinn.dbo.Products as p
 On c.CategoryID = p.CategoryID
Inner Join Assignment06DB_MeleWinn.dbo.Inventories as i
 On p.ProductID = i.ProductID
Inner Join Assignment06DB_MeleWinn.dbo.Employees as e
 On i.EmployeeID = e.EmployeeID
Order By InventoryDate, CategoryName, ProductName, [Employee Name];
GO

Select * From vInventoriesByProductsByEmployees;

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- Join between the views (office hours notes)

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

GO
Create -- Drop
View vInventoriesForChaiAndChangByEmployees
As
  Select Top 1000
  CategoryName
  , ProductName
  , InventoryDate
  , Count
  , [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
From Assignment06DB_MeleWinn.dbo.Categories as c
Inner Join Assignment06DB_MeleWinn.dbo.Products as p
 On c.CategoryID = p.CategoryID
Inner Join Assignment06DB_MeleWinn.dbo.Inventories as i
 On p.ProductID = i.ProductID
Inner Join Assignment06DB_MeleWinn.dbo.Employees as e
 On i.EmployeeID = e.EmployeeID
Where p.ProductID IN
 (Select ProductID
  From Products
   Where ProductName IN ('Chai', 'Chang'))
Order By InventoryDate, CategoryName, ProductName, [Employee Name];
GO

Select * From vInventoriesForChaiAndChangByEmployees;

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

GO
Create -- Drop
View vEmployeesByManager
As 
  Select Top 1000
  [Manager] =  Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName
  , [Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
From Employees as Emp
Inner Join  Employees Manager
  On Manager.EmployeeID = Emp.ManagerID
Order By [Manager];
GO

Select * From vEmployeesByManager;


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- MW notes from office hours. Use joins betweens the views. 

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

GO
Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
As
  Select Top 1000 
  c.CategoryID
  , CategoryName
  , p.ProductID
  , ProductName
  , UnitPrice
  , InventoryID
  , InventoryDate
  , Count
  , e.EmployeeID
  , [Employee Name] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
  , [Manager] =  Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName
From Assignment06DB_MeleWinn.dbo.Categories as c
Inner Join Assignment06DB_MeleWinn.dbo.Products as p
 On c.CategoryID = p.CategoryID
Inner Join Assignment06DB_MeleWinn.dbo.Inventories as i
 On p.ProductID = i.ProductID
Inner Join Assignment06DB_MeleWinn.dbo.Employees as e
 On i.EmployeeID = e.EmployeeID
Inner Join  Employees Manager
  On Manager.EmployeeID = e.ManagerID 
Order By CategoryID, CategoryName, ProductID;
GO

Select * From vInventoriesByProductsByCategoriesByEmployees;


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From vCategories
Select * From vProducts
Select * From vInventories
Select * From vEmployees

Select * From vProductsByCategories
Select * From vInventoriesByProductsByDates
Select * From vInventoriesByEmployeesByDates
Select * From vInventoriesByProductsByCategories
Select * From vInventoriesByProductsByEmployees
Select * From vInventoriesForChaiAndChangByEmployees
Select * From vEmployeesByManager
Select * From vInventoriesByProductsByCategoriesByEmployees


-- Switch back to master
Use master;
GO
/***************************************************************************************/