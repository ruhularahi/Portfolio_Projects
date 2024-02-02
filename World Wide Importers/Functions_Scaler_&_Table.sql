-- Evaluate data
SELECT * FROM Warehouse.ColdRoomTemperatures;
GO

-- Basic function to square a number
CREATE FUNCTION Application.SquareNumber (@InputNumber AS INT)
RETURNS INT
AS
BEGIN
    DECLARE @Output INT;
    SET @Output = @InputNumber * @InputNumber;
    RETURN @Output;
END;
GO

-- Using the function
PRINT Application.SquareNumber(5);
SELECT Application.SquareNumber(3) AS Result;
GO

/* Creating function to describe temperature range
 < 3.5 'too cold'
> 4 'too hot'
everything else 'just right' */

CREATE FUNCTION Warehouse.TempDescription (@Temperature decimal(10,2))
RETURNS char(10)
AS
BEGIN
	DECLARE @Description char(10);
	SET @Description = 
		CASE WHEN @Temperature < 3.5 THEN 'Too Cold'
			WHEN @Temperature > 4 THEN 'Too Hot'
			ELSE 'Just Right'
		END;
	RETURN @Description;
END;
GO

-- Testing Function
SELECT ColdRoomTemperatureID,
	ColdRoomSensorNumber,
	Temperature,
	Warehouse.TempDescription(Temperature) AS 'Temperature Description'
FROM Warehouse.ColdRoomTemperatures;
GO

-- Creating Function to get weeekend using CASE statement
CREATE OR ALTER FUNCTION Application.Weekend (@Day char(10))
RETURNS char(3)
AS
BEGIN
    DECLARE @Output char(3);
    SET @Output =
        CASE WHEN @Day = 'Saturday' THEN 'Yes'
            WHEN @Day = 'Sunday' THEN 'Yes'
            ELSE 'No'
        END;
    RETURN @Output;
END;
GO
-- Using the CASE function
SELECT Application.Weekend('Sunday') AS Sun,
    Application.Weekend('Monday') AS Mon
GO

/* ####Table Valued Function
-- Creating a function to query the most recent order of a customer */
SELECT ColdRoomTemperatureID,
	ColdRoomSensorNumber,
	Temperature
FROM Warehouse.ColdRoomTemperatures
WHERE Warehouse.TempDescription(Temperature) = 'Just Right';
GO

CREATE OR ALTER FUNCTION Sales.LastOrder (@CustomerID AS INT)
RETURNS TABLE
AS RETURN
SELECT
    Orders.OrderID AS [Order Number],
    Orders.CustomerID AS [Customer Number],
    Customers.CustomerName AS [Customer Name],
    Orders.OrderDate AS [Order Date],
    Orders.ExpectedDeliveryDate AS [Delivery Date],
    OrderLines.OrderLineID AS [Line Number],
    OrderLines.Description AS [Product Description]
FROM Sales.Orders
    INNER JOIN Sales.OrderLines ON Orders.OrderID = OrderLines.OrderID
    INNER JOIN Sales.Customers ON Orders.CustomerID = Customers.CustomerID
WHERE Orders.OrderID =
    (SELECT TOP 1 Orders.OrderID
     FROM Sales.Orders
     WHERE Orders.CustomerID = @CustomerID
     ORDER BY Orders.OrderID DESC)
;
GO

-- Testing the table-valued function
SELECT * FROM Sales.Lastorder(123);
SELECT * FROM Sales.LastOrder(828);
GO

