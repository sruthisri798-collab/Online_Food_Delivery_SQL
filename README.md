# Online Food Delivery SQL Project

## 🔹 Project Overview
This project simulates an **Online Food Delivery platform** and demonstrates **SQL database management, data analysis, and query optimization**. It is designed to showcase advanced SQL skills such as joins, CTEs, window functions, subqueries, and aggregations.  

The dataset includes **customers, restaurants, orders, order items, and payments**. Using this database, we can perform KPIs, trends analysis, and generate business insights for a food delivery platform.

---

## 🔹 Project Scope
- Create a **SQL database** for an online food delivery platform.
- Design **5 normalized tables**: Customers, Restaurants, Orders, OrderItems, Payments.
- Insert **sample data** for realistic scenarios.
- Analyze the data to generate **business KPIs** and insights.
- Demonstrate **complex SQL queries** using joins, window functions, CTEs, and subqueries.
- Prepare the project to be **resume- and GitHub-ready**.

---

## 🔹 Goal
- Provide a **fully functional SQL project** for learners and recruiters.
- Show **hands-on SQL skills** including:
  - Data modeling
  - Joins and relationships
  - Aggregations and KPIs
  - Advanced queries using window functions, CTEs, and subqueries
- Offer **realistic insights** for a food delivery platform.



## 🔹 Database Design

### Tables & Description

| Table Name   | Columns (Key ones) | Purpose |
| ------------ | ----------------- | ------- |
| Customers    | CustomerID (PK), CustomerName, Gender, Age, City | Stores customer information |
| Restaurants  | RestaurantID (PK), RestaurantName, CuisineType, City | Stores restaurant details |
| Orders       | OrderID (PK), CustomerID (FK), RestaurantID (FK), OrderDate, DeliveryTime, OrderStatus | Stores orders |
| OrderItems   | OrderItemID (PK), OrderID (FK), ItemName, Quantity, Price | Stores items for each order |
| Payments     | PaymentID (PK), OrderID (FK), Amount, PaymentMethod, PaymentDate | Stores payment information |

---

## 🔹 Sample Data
- 5 customers, 5 restaurants, multiple orders, order items, and payments.
- Covers scenarios like **delivered and cancelled orders**, multiple cuisines, and varying order values.

---

## 🔹 Key SQL Queries / KPIs
1. **Total Orders**  
```sql
SELECT COUNT(*) AS TotalOrders FROM Orders;
