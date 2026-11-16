# 1. Problem Understanding

## 1.1 Project Overview

The project focuses on designing and implementing a relational database
for an Amazon-like online shopping platform using PostgreSQL.

The database manages information related to customers, sellers, products,
categories, addresses, orders, order items, returns, product reviews,
shopping cart items and cities.

The objective is to build a structured database that supports common
e-commerce operations and analytical queries while maintaining data
integrity and minimizing unnecessary data redundancy.

## 1.2 Problem Statement

An online shopping platform generates and manages large amounts of
interconnected data. This includes customer information, product
catalogues, seller details, shopping carts, orders, payments, returns
and customer reviews.

Managing this information without a properly structured database can
lead to data duplication, inconsistent records and difficulties when
retrieving related information.

The project addresses these challenges by developing a relational
database with clearly defined entities, primary keys, foreign keys
and relationships.

## 1.3 Project Objectives

The main objectives are:

1. Design a relational database for an online shopping platform.
2. Identify the major entities and their relationships.
3. Define primary keys and foreign keys to maintain referential integrity.
4. Organize the data into normalized relational tables.
5. Load the provided CSV datasets into PostgreSQL.
6. Support the given workload of 30 SQL queries, consisting of
   24 READ queries and 6 WRITE queries.
7. Prepare the database for query execution, benchmarking and
   future optimization.

## 1.4 Dataset Understanding

The project provides 11 CSV files containing data for the online
shopping database.

| Dataset | Number of Records |
|---|---:|
| cities | 10 |
| categories | 40 |
| sellers | 1,500 |
| products | 30,000 |
| customers | 30,000 |
| addresses | 45,000 |
| orders | 120,000 |
| order_items | 240,000 |
| returns | 5,374 |
| product_reviews | 38,662 |
| cart_items | 44,998 |
| **Total** | **565,584** |

The datasets represent the following information:

- Cities: City and state information.
- Categories: Product categories and parent-category relationships.
- Sellers: Seller details and business information.
- Products: Product catalogue, pricing, inventory and ratings.
- Customers: Customer details and membership information.
- Addresses: Customer delivery addresses.
- Orders: Order details, payment methods and delivery status.
- Order items: Individual products included in each order.
- Returns: Product return requests and refund information.
- Product reviews: Customer ratings and written reviews.
- Cart items: Products currently added to customer shopping carts.

## 1.5 Functional Requirements

The database should support the following operations:

1. Customer and address information retrieval.
2. Product search and category-based browsing.
3. Seller and product inventory management.
4. Order creation and order-history retrieval.
5. Order-item and seller information retrieval.
6. Shopping-cart insertion and cleanup.
7. Product reviews and rating analysis.
8. Product return tracking.
9. Sales, revenue and customer-spending analysis.
10. Query execution and performance benchmarking.

## 1.6 Database Requirements

The database is implemented using PostgreSQL 15 or newer.

The design should:

- Use appropriate data types for each attribute.
- Define primary keys for uniquely identifying records.
- Define foreign keys for relationships between tables.
- Maintain referential integrity.
- Avoid unnecessary data redundancy through normalization.
- Support the supplied SQL workload without modifying its queries.
- Allow READ and WRITE operations to be benchmarked.

## 1.7 Scope of the Project

The scope includes database design, schema creation, CSV data
loading, SQL query execution, performance measurement and
future query optimization.

The project focuses on the database layer of an online shopping
platform rather than developing a complete customer-facing
e-commerce application.

## 1.8 Expected Outcome

The expected outcome is a working PostgreSQL database containing
the supplied e-commerce datasets, with a properly designed
relational schema capable of executing the provided 30-query
workload.

The database will serve as the foundation for subsequent
benchmarking, indexing, query optimization and scalability analysis.
