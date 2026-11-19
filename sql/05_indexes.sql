SET search_path TO amazon;

-- R01: Product title substring search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_title_trgm
ON products USING GIN (title gin_trgm_ops);

-- R02, R07, R14: Product filters
CREATE INDEX idx_products_category_status_price
ON products (category_id, status, price);

CREATE INDEX idx_products_seller_status_stock
ON products (seller_id, status, stock_qty);

-- W03: Seller and category price update
CREATE INDEX idx_products_seller_category
ON products (seller_id, category_id);

-- R03: Product rating breakdown
CREATE INDEX idx_reviews_product_rating
ON product_reviews (product_id, rating);

-- R16: Review substring search
CREATE INDEX idx_reviews_body_trgm
ON product_reviews USING GIN (body gin_trgm_ops);

-- R17: Verified purchase reviews
CREATE INDEX idx_reviews_verified_customer_product
ON product_reviews (customer_id, product_id)
WHERE verified_purchase = TRUE;

-- R04, R09, R10, R18: Customer order lookup
CREATE INDEX idx_orders_customer_ordered_at
ON orders (customer_id, ordered_at);

-- R05: Shipped orders
CREATE INDEX idx_orders_shipped_at
ON orders (shipped_at)
WHERE status = 'SHIPPED';

-- R06, R08, R09, R15, R18, R20, R21: Order date filtering
CREATE INDEX idx_orders_ordered_at
ON orders (ordered_at);

-- R17: Delivered/returned order checks
CREATE INDEX idx_orders_customer_status
ON orders (customer_id, status);

-- R19: Product sales aggregation
CREATE INDEX idx_order_items_product_order
ON order_items (product_id, order_id)
INCLUDE (quantity);

-- R15: Seller order lines
CREATE INDEX idx_order_items_seller_order
ON order_items (seller_id, order_id);

-- R12: Return lookup
CREATE INDEX idx_returns_order_line
ON returns (order_id, line_no);

-- R22: Newest orders can scan idx_orders_ordered_at backwards; a second
-- index with the same leading key would duplicate storage and write overhead.

-- W06: Old cart cleanup
CREATE INDEX idx_cart_items_added_at
ON cart_items (added_at);

-- R24: Product lookup by ASIN
CREATE INDEX idx_products_asin ON products (asin);
