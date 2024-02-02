-- Save a query as a view object
USE WideWorldImporters;
GO

-- Data Review
SELECT TOP 1 * FROM Purchasing.Suppliers;
SELECT * FROM Purchasing.SupplierCategories
    WHERE SupplierCategoryID = 2;
SELECT * FROM Application.People
    WHERE PersonID = 21 OR PersonID = 22;
GO

-- Creating two VIEWS to explore supplier details in different ways
CREATE VIEW Purchasing.SupplierDetailColumns
AS
SELECT
    Suppliers.SupplierName,
    SupplierCategories.SupplierCategoryName,
    PrimaryContact.FullName AS PrimaryContact,
    PrimaryContact.PhoneNumber AS PrimaryPhone,
    PrimaryContact.EmailAddress AS PrimaryEmail,
    AlternateContact.FullName AS AlternateContact,
    AlternateContact.PhoneNumber AS AlternatePhone,
    AlternateContact.EmailAddress AS AlternateEmail
FROM Purchasing.Suppliers
    INNER JOIN Purchasing.SupplierCategories
        ON Suppliers.SupplierCategoryID = SupplierCategories.SupplierCategoryID
    INNER JOIN Application.People AS PrimaryContact
        ON Suppliers.PrimaryContactPersonID = PrimaryContact.PersonID
    INNER JOIN Application.People AS AlternateContact
        ON Suppliers.AlternateContactPersonID = AlternateContact.PersonID
;
GO

CREATE VIEW Purchasing.SupplierDetailRows
AS
SELECT
    Suppliers.SupplierName,
    SupplierCategories.SupplierCategoryName,
    'Primary Contact' AS ContactType,
    People.FullName AS Contact,
    People.PhoneNumber AS Phone,
    People.EmailAddress AS Email
FROM Purchasing.Suppliers
    INNER JOIN Purchasing.SupplierCategories
        ON Suppliers.SupplierCategoryID = SupplierCategories.SupplierCategoryID
    INNER JOIN Application.People
        ON Suppliers.PrimaryContactPersonID = People.PersonID
UNION
SELECT
    Suppliers.SupplierName,
    SupplierCategories.SupplierCategoryName,
    'Alternate Contact' AS ContactType,
    People.FullName AS Contact,
    People.PhoneNumber AS Phone,
    People.EmailAddress AS Email
FROM Purchasing.Suppliers
    INNER JOIN Purchasing.SupplierCategories
        ON Suppliers.SupplierCategoryID = SupplierCategories.SupplierCategoryID
    INNER JOIN Application.People
        ON Suppliers.AlternateContactPersonID = People.PersonID
;
GO

-- Testing the views
SELECT * FROM Purchasing.SupplierDetailColumns;
SELECT * FROM Purchasing.SupplierDetailRows;

-- #### Leveraging view objects with indexes


-- Reviewing stock item information
SELECT * FROM Warehouse.StockItems;
SELECT * FROM Purchasing.Suppliers;
GO

-- Creating a schemabound view
CREATE VIEW Warehouse.StockItemDetails
WITH SCHEMABINDING
AS
SELECT
    StockItemStockGroups.StockItemStockGroupID,
    StockItems.StockItemName,
    StockItemHoldings.QuantityOnHand,
    StockGroups.StockGroupName,
    Colors.ColorName,
    StockItems.UnitPrice,
    StockItems.SupplierID
  FROM Warehouse.StockItemStockGroups
    INNER JOIN Warehouse.StockItems
        ON StockItemStockGroups.StockItemID = StockItems.StockItemID
    INNER JOIN Warehouse.StockGroups
        ON StockItemStockGroups.StockGroupID = StockGroups.StockGroupID
    INNER JOIN Warehouse.Colors
        ON StockItems.ColorID = Colors.ColorID
    INNER JOIN Warehouse.StockItemHoldings
        ON StockItems.StockItemID = StockItemHoldings.StockItemID
;
GO

-- Testing the view
SELECT * FROM Warehouse.StockItemDetails;
GO

-- Adding an index to the view
CREATE UNIQUE CLUSTERED INDEX IDX_StockItemDetails
   ON Warehouse.StockItemDetails (StockItemStockGroupID, StockItemName, SupplierID);
GO

-- Query the view
SELECT *
    FROM Warehouse.StockItemDetails
      INNER JOIN Purchasing.Suppliers
        ON Suppliers.SupplierID = StockItemDetails.SupplierID
WHERE StockItemDetails.SupplierID = 5;
