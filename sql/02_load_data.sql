\set ON_ERROR_STOP on

SET search_path TO amazon;

\echo 'Loading cities...'
\copy cities FROM 'seed_data/cities.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading categories...'
\copy categories FROM 'seed_data/categories.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading sellers...'
\copy sellers FROM 'seed_data/sellers.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading customers...'
\copy customers FROM 'seed_data/customers.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading addresses...'
\copy addresses FROM 'seed_data/addresses.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading products...'
\copy products FROM 'seed_data/products.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading orders...'
\copy orders FROM 'seed_data/orders.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading order_items...'
\copy order_items FROM 'seed_data/order_items.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading returns...'
\copy returns FROM 'seed_data/returns.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading product_reviews...'
\copy product_reviews FROM 'seed_data/product_reviews.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading cart_items...'
\copy cart_items FROM 'seed_data/cart_items.csv' WITH (FORMAT csv, HEADER true);

\echo 'All CSV files loaded successfully.'
