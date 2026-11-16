# 2. Database Schema Design

## 2.1 Introduction

The database is designed using the relational model in PostgreSQL.
The design consists of 11 entities representing the major components
of an online shopping platform.

Each entity is stored in a separate table. Primary keys uniquely
identify records, while foreign keys establish relationships
between related tables.

## 2.2 Entities and Their Attributes

### 1. Cities

Stores city and state information.

- city_id (Primary Key)
- city_name
- state

### 2. Categories

Stores product categories and their hierarchical structure.

- category_id (Primary Key)
- category_name
- parent_category_id (Self-referencing Foreign Key)
- is_digital

### 3. Sellers

Stores seller and business information.

- seller_id (Primary Key)
- business_name
- gstin
- city_id (Foreign Key)
- joined_on
- seller_rating
- status

### 4. Customers

Stores customer information and membership details.

- customer_id (Primary Key)
- full_name
- email
- phone
- city_id (Foreign Key)
- signup_date
- is_prime
- prime_since

### 5. Addresses

Stores delivery addresses associated with customers.

- address_id (Primary Key)
- customer_id (Foreign Key)
- label
- line1
- city_id (Foreign Key)
- pincode
- is_default

### 6. Products

Stores product catalogue and inventory information.

- product_id (Primary Key)
- asin
- seller_id (Foreign Key)
- category_id (Foreign Key)
- title
- brand
- mrp
- price
- stock_qty
- is_prime_eligible
- avg_rating
- review_count
- listed_on
- status

### 7. Orders

Stores order-level information.

- order_id (Primary Key)
- customer_id (Foreign Key)
- address_id (Foreign Key)
- ordered_at
- payment_method
- total_amount
- status
- shipped_at
- delivered_at

### 8. Order Items

Stores individual products belonging to an order.

- order_id (Composite Primary Key, Foreign Key)
- line_no (Composite Primary Key)
- product_id (Foreign Key)
- seller_id (Foreign Key)
- quantity
- unit_price

The combination of order_id and line_no uniquely identifies
an item within an order.

### 9. Returns

Stores return requests associated with order items.

- return_id (Primary Key)
- order_id (Composite Foreign Key)
- line_no (Composite Foreign Key)
- reason
- requested_at
- status
- refund_amount

The combination of order_id and line_no references the
corresponding record in order_items.

### 10. Product Reviews

Stores customer reviews and ratings.

- review_id (Primary Key)
- product_id (Foreign Key)
- customer_id (Foreign Key)
- rating
- title
- body
- verified_purchase
- helpful_votes
- created_at

### 11. Cart Items

Stores products added to customer shopping carts.

- customer_id (Composite Primary Key, Foreign Key)
- product_id (Composite Primary Key, Foreign Key)
- quantity
- added_at

The combination of customer_id and product_id uniquely
identifies a cart entry.

## 2.3 Primary Key Design

Primary keys are selected to uniquely identify each record.

| Table | Primary Key |
|---|---|
| cities | city_id |
| categories | category_id |
| sellers | seller_id |
| customers | customer_id |
| addresses | address_id |
| products | product_id |
| orders | order_id |
| order_items | order_id, line_no |
| returns | return_id |
| product_reviews | review_id |
| cart_items | customer_id, product_id |

Composite primary keys are used in order_items and cart_items
because their records are identified by combinations of attributes.

## 2.4 Foreign Key Relationships

The following relationships maintain referential integrity:

1. sellers.city_id references cities.city_id.
2. customers.city_id references cities.city_id.
3. addresses.customer_id references customers.customer_id.
4. addresses.city_id references cities.city_id.
5. categories.parent_category_id references categories.category_id.
6. products.seller_id references sellers.seller_id.
7. products.category_id references categories.category_id.
8. orders.customer_id references customers.customer_id.
9. orders.address_id references addresses.address_id.
10. order_items.order_id references orders.order_id.
11. order_items.product_id references products.product_id.
12. order_items.seller_id references sellers.seller_id.
13. returns (order_id, line_no) references order_items.
14. product_reviews.product_id references products.product_id.
15. product_reviews.customer_id references customers.customer_id.
16. cart_items.customer_id references customers.customer_id.
17. cart_items.product_id references products.product_id.

## 2.5 Relationship Cardinality

The major relationships are:

| Relationship | Cardinality |
|---|---|
| Cities to Customers | One-to-Many |
| Cities to Sellers | One-to-Many |
| Cities to Addresses | One-to-Many |
| Customers to Addresses | One-to-Many |
| Categories to Categories | One-to-Many |
| Categories to Products | One-to-Many |
| Sellers to Products | One-to-Many |
| Customers to Orders | One-to-Many |
| Addresses to Orders | One-to-Many |
| Orders to Order Items | One-to-Many |
| Products to Order Items | One-to-Many |
| Sellers to Order Items | One-to-Many |
| Order Items to Returns | One-to-Many |
| Products to Product Reviews | One-to-Many |
| Customers to Product Reviews | One-to-Many |
| Customers to Cart Items | One-to-Many |
| Products to Cart Items | One-to-Many |

## 2.6 Normalization

The schema is designed with the principles of normalization
in mind.

### First Normal Form (1NF)

- Each table has a primary key.
- Each column stores a single attribute value.
- Repeating groups and multivalued attributes are avoided.
- Individual order items are stored as separate records.

### Second Normal Form (2NF)

- Tables with single-column primary keys satisfy the
  requirement of having no partial dependency.
- In order_items, non-key attributes depend on the complete
  composite key (order_id, line_no).
- In cart_items, quantity and added_at depend on the
  complete composite key (customer_id, product_id).

### Third Normal Form (3NF)

- City information is stored separately from customer and
  seller information.
- Category information is stored separately from product details.
- Customer, seller, product and order information are maintained
  in separate tables.
- Non-key attributes are intended to depend on their table's
  key rather than unrelated non-key attributes.

The final normalization assumptions should be validated against
the functional dependencies of the supplied dataset.

## 2.7 Data Types

Appropriate PostgreSQL data types are selected:

- INTEGER and BIGINT for identifiers and counts.
- TEXT for names, descriptions and status fields.
- DATE for date-only attributes.
- TIMESTAMPTZ for timestamps with timezone information.
- NUMERIC for prices, ratings and monetary values.
- BOOLEAN for true/false attributes.
- SMALLINT for compact numeric ratings.

## 2.8 Design Decisions

1. A separate cities table avoids repeating city and state
   information across customers, sellers and addresses.
2. Categories use a self-referencing foreign key to support
   hierarchical category browsing.
3. Order items are separated from orders to support multiple
   products within one order.
4. Returns reference order items through a composite foreign key.
5. Cart items use a composite primary key to prevent duplicate
   entries for the same customer and product.
6. Product reviews reference both products and customers.
7. Monetary attributes use NUMERIC to avoid floating-point
   precision errors.

## 2.9 Conclusion

The proposed schema organizes the online shopping data into
11 related relational tables.

Primary keys, foreign keys and composite keys establish the
relationships between entities and help maintain data integrity.

The design provides the foundation for importing the supplied
CSV datasets and executing the required 30 SQL workload queries.
