USE WideWorldImporters;
GO

/* 
Write a stored procedure to:
1) view information from Sales.Customers
2) view information from Sales.Orders
3) write a row to Sales.CustomerAccountAudit to log activity
*/

-- Creating an audit table for customer accounts
CREATE TABLE Sales.CustomerAccountAudit (
    AuditID INT IDENTITY PRIMARY KEY,
    CustomerID INT,
    ReviewDate datetime2
);
GO

-- Creating a stored procedure
CREATE OR ALTER PROCEDURE Sales.SalesInfo (@Customer AS INT)
AS
SELECT CustomerID, CustomerName, PhoneNumber
	FROM Sales.Customers
	WHERE CustomerID = @Customer;
SELECT OrderID, CustomerID, OrderDate
	FROM Sales.Orders
	WHERE CustomerID = @Customer;
INSERT INTO Sales.CustomerAccountAudit (CustomerID, ReviewDate)
	VALUES (@Customer, GETDATE());
;
GO

-- Testing the stored procedure
EXEC Sales.SalesInfo 915;
EXEC Sales.SalesInfo 874;

-- Reviewing the audit table
SELECT * FROM Sales.CustomerAccountAudit;
GO

/*
Write a Stored Procedures to insert and delete a new raw into and from Warehouse.Colors table. 
New raw should consists of ColorID, ColorName, and LastEditedBy columns.
*/

-- Creating a procedure to insert new rows
CREATE OR ALTER PROCEDURE Warehouse.uspInsertColor (@Color AS nvarchar(100))
AS
    DECLARE @ColorID INT
    SET @ColorID = (SELECT MAX(ColorID) FROM Warehouse.Colors)+1;
    INSERT INTO Warehouse.Colors (ColorID, ColorName, LastEditedBy)
        VALUES (@ColorID, @Color, 1);
    SELECT * FROM Warehouse.Colors
        WHERE ColorID = @ColorID
        ORDER BY ColorID DESC;
;
GO

-- Testing the stored procedure
EXEC Warehouse.uspInsertColor @Color = 'Periwinkle Blue';

SELECT * FROM Warehouse.Colors
ORDER BY ColorID DESC;
GO

-- Creating another procedure to remove the last color
CREATE OR ALTER PROCEDURE Warehouse.uspRemoveLastColor
AS
    DELETE FROM Warehouse.Colors
    WHERE ColorID = (SELECT MAX(ColorID) FROM Warehouse.Colors);
    -- plus additional database actions to maintain data integrity
;
GO

-- Testing the row removal
EXEC Warehouse.uspRemoveLastColor;

SELECT * FROM Warehouse.Colors
ORDER BY ColorID DESC;
GO