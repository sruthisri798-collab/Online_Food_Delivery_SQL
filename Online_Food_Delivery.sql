CREATE DATABASE FoodDeliveryDB;
GO
USE FoodDeliveryDB;
GO

--customer Table--
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Gender VARCHAR(10),
    Age INT,
    City VARCHAR(50)
);
--Restaurant Table --
CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY,
    RestaurantName VARCHAR(100),
    CuisineType VARCHAR(50),
    City VARCHAR(50)
);
--Orders Table--
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    RestaurantID INT,
    OrderDate DATE,
    DeliveryTime INT,  -- in minutes
    OrderStatus VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);
--OrderItem Table--
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ItemName VARCHAR(100),
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
--Payments Table--
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    Amount DECIMAL(10,2),
    PaymentMethod VARCHAR(20),
    PaymentDate DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
--Customers--
INSERT INTO Customers VALUES
(1, 'Aarav Sharma', 'Male', 25, 'New York'),
(2, 'Priya Patel', 'Female', 29, 'Chicago'),
(3, 'John Carter', 'Male', 35, 'Houston'),
(4, 'Emma Wilson', 'Female', 31, 'Seattle'),
(5, 'David Kim', 'Male', 22, 'Boston');

--Restaurants--
INSERT INTO Restaurants VALUES
(1, 'Tasty Bites', 'Indian', 'New York'),
(2, 'Pizza Hub', 'Italian', 'Chicago'),
(3, 'Sushi Express', 'Japanese', 'Houston'),
(4, 'Burger King', 'American', 'Seattle'),
(5, 'Green Bowl', 'Healthy', 'Boston');
--Orders--
INSERT INTO Orders VALUES
(101, 1, 1, '2024-01-10', 35, 'Delivered'),
(102, 2, 2, '2024-01-12', 45, 'Delivered'),
(103, 3, 3, '2024-01-12', 50, 'Cancelled'),
(104, 1, 4, '2024-01-13', 30, 'Delivered'),
(105, 4, 5, '2024-01-13', 40, 'Delivered');
--OrderItems--
INSERT INTO OrderItems VALUES
(1, 101, 'Paneer Curry', 2, 12.50),
(2, 101, 'Butter Naan', 4, 3.00),
(3, 102, 'Pepperoni Pizza', 1, 15.00),
(4, 103, 'Sushi Roll', 2, 10.00),
(5, 104, 'Cheeseburger', 2, 8.00),
(6, 105, 'Salad Bowl', 1, 11.00);
--Payments--
INSERT INTO Payments VALUES
(1, 101, 36.00, 'Card', '2024-01-10'),
(2, 102, 15.00, 'UPI', '2024-01-12'),
(3, 104, 16.00, 'Cash', '2024-01-13'),
(4, 105, 11.00, 'Card', '2024-01-13');

------------------------------------------------------------------------------------------
--Project KPIS--
------------------------------------------------------------------------------------------
--Total Orders--
SELECT COUNT(*) AS TotalOrders FROM Orders;
--Total Revenue--
SELECT SUM(Amount) AS TotalRevenue FROM Payments;
--Total Customers--
SELECT COUNT(*) AS TotalCustomers FROM Customers;
--Average Delivery Time--
SELECT AVG(DeliveryTime) AS AvgDeliveryTime FROM Orders;
--Most Ordered Item--
SELECT TOP 1 ItemName, SUM(Quantity) AS TotalQty
FROM OrderItems
GROUP BY ItemName
ORDER BY TotalQty DESC;

--Revenue By Restaurant--

SELECT r.RestaurantName, SUM(p.Amount) AS Revenue
FROM Payments p
JOIN Orders o ON p.OrderID = o.OrderID
JOIN Restaurants r ON o.RestaurantID = r.RestaurantID
GROUP BY r.RestaurantName;

--Order By Cuisine--

SELECT r.CuisineType, COUNT(*) AS TotalOrders
FROM Orders o
JOIN Restaurants r ON o.RestaurantID = r.RestaurantID
GROUP BY r.CuisineType;

--Top Customers by Spending--
SELECT c.CustomerName, SUM(p.Amount) AS TotalSpent
FROM Payments p
JOIN Orders o ON p.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC;

--Restaurant with Fastest Delivery--
SELECT TOP 1 RestaurantID, AVG(DeliveryTime) AS AvgTime
FROM Orders
GROUP BY RestaurantID
ORDER BY AvgTime;

--Cancelled Orders--
SELECT o.OrderID, c.CustomerName, r.RestaurantName, o.OrderDate
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Restaurants r ON o.RestaurantID = r.RestaurantID
WHERE o.OrderStatus = 'Cancelled';

--Top 3 Restaurants by Revenue--
SELECT RestaurantName, Revenue
FROM (
    SELECT r.RestaurantName,
           SUM(p.Amount) AS Revenue,
           RANK() OVER (ORDER BY SUM(p.Amount) DESC) AS RevenueRank
    FROM Payments p
    JOIN Orders o ON p.OrderID = o.OrderID
    JOIN Restaurants r ON o.RestaurantID = r.RestaurantID
    GROUP BY r.RestaurantName
) AS Ranked
WHERE RevenueRank <= 3;

--Customer Spending Percentile--
SELECT CustomerName, TotalSpent,
       PERCENT_RANK() OVER (ORDER BY TotalSpent DESC) AS SpendingPercentile
FROM (
    SELECT c.CustomerName, SUM(p.Amount) AS TotalSpent
    FROM Payments p
    JOIN Orders o ON p.OrderID = o.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY c.CustomerName
) AS CustomerTotals;

--Most Popular Item by Restaurant--

WITH ItemTotals AS (
    SELECT o.RestaurantID, oi.ItemName, SUM(oi.Quantity) AS TotalQuantity
    FROM OrderItems oi
    JOIN Orders o ON oi.OrderID = o.OrderID
    GROUP BY o.RestaurantID, oi.ItemName
),
MaxPerRestaurant AS (
    SELECT RestaurantID, MAX(TotalQuantity) AS MaxQuantity
    FROM ItemTotals
    GROUP BY RestaurantID
)
SELECT r.RestaurantName, it.ItemName, it.TotalQuantity
FROM ItemTotals it
JOIN MaxPerRestaurant mp
    ON it.RestaurantID = mp.RestaurantID AND it.TotalQuantity = mp.MaxQuantity
JOIN Restaurants r
    ON it.RestaurantID = r.RestaurantID
ORDER BY r.RestaurantName;

--Average Order Value per Customer Using CTE--
WITH CustomerOrders AS (
    SELECT o.CustomerID, SUM(p.Amount) AS TotalSpent, COUNT(o.OrderID) AS OrdersCount
    FROM Orders o
    JOIN Payments p ON o.OrderID = p.OrderID
    GROUP BY o.CustomerID
)
SELECT c.CustomerName, TotalSpent, OrdersCount, 
       ROUND(TotalSpent*1.0/OrdersCount, 2) AS AvgOrderValue
FROM CustomerOrders co
JOIN Customers c ON co.CustomerID = c.CustomerID;

--Top 3 Items by Total Quantity Ordered (Across All Restaurants)--
SELECT TOP 3 ItemName, SUM(Quantity) AS TotalOrdered
FROM OrderItems
GROUP BY ItemName
ORDER BY TotalOrdered DESC;

--Orders Per Day (Trend Analysis Using Date Functions)--
SELECT CAST(OrderDate AS DATE) AS OrderDay, COUNT(*) AS OrdersCount, SUM(p.Amount) AS Revenue
FROM Orders o
JOIN Payments p ON o.OrderID = p.OrderID
GROUP BY CAST(OrderDate AS DATE)
ORDER BY OrderDay;

--Customers Who Ordered More Than Average Orders--
WITH CustomerOrderCounts AS (
    SELECT CustomerID, COUNT(OrderID) AS TotalOrders
    FROM Orders
    GROUP BY CustomerID
)
SELECT c.CustomerName, coc.TotalOrders
FROM CustomerOrderCounts coc
JOIN Customers c ON coc.CustomerID = c.CustomerID
WHERE TotalOrders > (SELECT AVG(TotalOrders) FROM CustomerOrderCounts);

--Restaurants with Above-Average Delivery Time--
-- Step 1: Calculate average delivery per restaurant
WITH RestaurantDelivery AS (
    SELECT RestaurantID, AVG(DeliveryTime) AS AvgDeliveryTime
    FROM Orders
    GROUP BY RestaurantID
)

-- Step 2: Calculate overall average delivery time
, OverallAvg AS (
    SELECT AVG(AvgDeliveryTime) AS OverallAvgTime
    FROM RestaurantDelivery
)

-- Step 3: Select restaurants above the overall average
SELECT r.RestaurantName, rd.AvgDeliveryTime
FROM RestaurantDelivery rd
JOIN OverallAvg oa ON 1=1
JOIN Restaurants r ON rd.RestaurantID = r.RestaurantID
WHERE rd.AvgDeliveryTime > oa.OverallAvgTime
ORDER BY rd.AvgDeliveryTime DESC;

















