--Q1. List top 5 customers by total order amount.

--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, 
--CustomerName, and TotalSpent.

SELECT TOP 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(sod.TotalAmount) AS TotalSpent
FROM Customer c
JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
JOIN SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
GROUP BY
    c.CustomerID,
    c.Name
ORDER BY TotalSpent DESC;



--Q2. Number of products supplied by each supplier (more than 10)

SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT pod.ProductID) AS ProductCount
FROM Supplier s
JOIN PurchaseOrder po
    ON s.SupplierID = po.SupplierID
JOIN PurchaseOrderDetail pod
    ON po.OrderID = pod.OrderID
GROUP BY
    s.SupplierID,
    s.Name
HAVING COUNT(DISTINCT pod.ProductID) > 10;



-- Q3. Products ordered but never returned


SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM Product p
JOIN SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
LEFT JOIN ReturnDetail rd
    ON p.ProductID = rd.ProductID
WHERE rd.ProductID IS NULL
GROUP BY
    p.ProductID,
    p.Name;


    --Q4. Most expensive product per category (using subquery)

SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM Product p
JOIN Category c
    ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM Product p2
    WHERE p2.CategoryID = p.CategoryID
);


--Q5. Sales orders with customer, product, category & supplier

SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM SalesOrder so
JOIN Customer c
    ON so.CustomerID = c.CustomerID
JOIN SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
JOIN Product p
    ON sod.ProductID = p.ProductID
JOIN Category cat
    ON p.CategoryID = cat.CategoryID
JOIN PurchaseOrderDetail pod
    ON p.ProductID = pod.ProductID
JOIN PurchaseOrder po
    ON pod.OrderID = po.OrderID
JOIN Supplier s
    ON po.SupplierID = s.SupplierID;


    --Q6. Shipments with warehouse, manager & products

SELECT
    sh.ShipmentID,
    w.WarehouseID,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM Shipment sh
JOIN Warehouse w
    ON sh.WarehouseID = w.WarehouseID
LEFT JOIN Employee e
    ON w.ManagerID = e.EmployeeID
JOIN ShipmentDetail sd
    ON sh.ShipmentID = sd.ShipmentID
JOIN Product p
    ON sd.ProductID = p.ProductID;




-- Q7. Top 3 highest-value orders per customer (RANK)


WITH OrderTotals AS (
    SELECT
        so.OrderID,
        so.CustomerID,
        c.Name AS CustomerName,
        SUM(sod.TotalAmount) AS TotalAmount
    FROM SalesOrder so
    JOIN SalesOrderDetail sod
        ON so.OrderID = sod.OrderID
    JOIN Customer c
        ON so.CustomerID = c.CustomerID
    GROUP BY
        so.OrderID,
        so.CustomerID,
        c.Name
)
SELECT *
FROM (
    SELECT *,
        RANK() OVER (
            PARTITION BY CustomerID
            ORDER BY TotalAmount DESC
        ) AS OrderRank
    FROM OrderTotals
) r
WHERE OrderRank <= 3;


--Q8. Product sales history with previous & next quantities

SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS NextQuantity
FROM SalesOrderDetail sod
JOIN SalesOrder so
    ON sod.OrderID = so.OrderID
JOIN Product p
    ON sod.ProductID = p.ProductID;



--Q9. Create view vw_CustomerOrderSummary


SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(DISTINCT so.OrderID) AS TotalOrders,
    SUM(sod.TotalAmount) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
LEFT JOIN SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
GROUP BY
    c.CustomerID,
    c.Name;







  --Q10. Stored procedure: total sales by supplier
SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    SUM(sod.TotalAmount) AS TotalSalesAmount
FROM Supplier s
JOIN PurchaseOrder po
    ON s.SupplierID = po.SupplierID
JOIN PurchaseOrderDetail pod
    ON po.OrderID = pod.OrderID
JOIN SalesOrderDetail sod
    ON pod.ProductID = sod.ProductID
WHERE s.SupplierID = 1
GROUP BY
    s.SupplierID,
    s.Name;
