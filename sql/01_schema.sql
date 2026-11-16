CREATE SCHEMA IF NOT EXISTS amazon;
SET search_path TO amazon;

-- 1. Cities
CREATE TABLE cities (
    city_id INTEGER PRIMARY KEY,
    city_name TEXT NOT NULL,
    state TEXT NOT NULL
);

-- 2. Categories
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL,
    parent_category_id INTEGER REFERENCES categories(category_id),
    is_digital BOOLEAN NOT NULL
);

-- 3. Sellers
CREATE TABLE sellers (
    seller_id INTEGER PRIMARY KEY,
    business_name TEXT NOT NULL,
    gstin TEXT,
    city_id INTEGER NOT NULL REFERENCES cities(city_id),
    joined_on DATE NOT NULL,
    seller_rating NUMERIC(3,1),
    status TEXT NOT NULL
);

-- 4. Customers
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    city_id INTEGER NOT NULL REFERENCES cities(city_id),
    signup_date DATE NOT NULL,
    is_prime BOOLEAN NOT NULL,
    prime_since DATE
);

-- 5. Addresses
CREATE TABLE addresses (
    address_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    label TEXT NOT NULL,
    line1 TEXT NOT NULL,
    city_id INTEGER NOT NULL REFERENCES cities(city_id),
    pincode TEXT NOT NULL,
    is_default BOOLEAN NOT NULL
);

-- 6. Products
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    asin TEXT NOT NULL,
    seller_id INTEGER NOT NULL REFERENCES sellers(seller_id),
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    title TEXT NOT NULL,
    brand TEXT,
    mrp NUMERIC(12,2) NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    stock_qty INTEGER NOT NULL,
    is_prime_eligible BOOLEAN NOT NULL,
    avg_rating NUMERIC(3,1),
    review_count INTEGER NOT NULL,
    listed_on DATE NOT NULL,
    status TEXT NOT NULL
);

-- 7. Orders
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    address_id INTEGER REFERENCES addresses(address_id),
    ordered_at TIMESTAMPTZ NOT NULL,
    payment_method TEXT NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    status TEXT NOT NULL,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ
);

-- 8. Order Items
CREATE TABLE order_items (
    order_id BIGINT NOT NULL REFERENCES orders(order_id),
    line_no INTEGER NOT NULL,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    seller_id INTEGER NOT NULL REFERENCES sellers(seller_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (order_id, line_no)
);

-- 9. Returns
CREATE TABLE returns (
    return_id BIGINT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    line_no INTEGER NOT NULL,
    reason TEXT NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL,
    refund_amount NUMERIC(12,2),
    FOREIGN KEY (order_id, line_no)
        REFERENCES order_items(order_id, line_no)
);

-- 10. Product Reviews
CREATE TABLE product_reviews (
    review_id BIGINT PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    rating SMALLINT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    verified_purchase BOOLEAN NOT NULL,
    helpful_votes INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

-- 11. Cart Items
CREATE TABLE cart_items (
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    added_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (customer_id, product_id)
);
