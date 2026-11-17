# Baseline timings (CP2)

All 30 queries from `queries/workload_30.sql` run unchanged against our schema from `sql/01_schema.sql`, with no indexes added yet (only the primary keys). Each query was run 3 times with `./benchmarks/run_benchmark.sh amazon_cp2 baseline`, which wraps it in `EXPLAIN (ANALYZE, BUFFERS)`. Times below are the `Execution Time` line from each run. Write queries ran inside `BEGIN ... ROLLBACK` so the data stayed the same.

Raw plans for every run are in `benchmarks/results/baseline/<query>.txt` and the summary is in `benchmarks/results/baseline/summary.csv`.

## Setup

| | |
|---|---|
| PostgreSQL | 18.6 (Postgres.app), aarch64 |
| Machine | MacBook (Apple Silicon), macOS |
| Data | `seed_data.zip` loaded with `sql/02_load_data.sql`, then `ANALYZE` |
| Run date | 17 Nov 2026 |

Row counts: orders 120,000, order_items 240,000, customers 30,000, products 30,000, addresses 45,000, cart_items 44,998, product_reviews 38,662, returns 5,374, sellers 1,500, categories 40, cities 10.

## Timings (ms)

| Query | Type | What it does | Run 1 | Run 2 | Run 3 | Average | Scans (last run) |
|---|---|---|---:|---:|---:|---:|---|
| R01 | READ | Search box: active products whose title contains "wireless", best rated first | 27.834 | 27.093 | 26.066 | 26.998 | Seq Scan on products |
| R02 | READ | Category browse: everything under "Electronics" (all sub-levels) priced ₹1,000-₹5,000 | 6.517 | 6.474 | 6.227 | 6.406 | Seq Scan on categories / Seq Scan on products |
| R03 | READ | Product page: rating breakdown (how many 5★, 4★ ...) for product 4321 | 2.978 | 2.648 | 2.696 | 2.774 | Seq Scan on product_reviews |
| R04 | READ | "Your Orders": customer 1042's orders with the number of items in each | 6.871 | 6.917 | 7.143 | 6.977 | Seq Scan on orders / Index Only Scan using order_items_pkey on order_items |
| R05 | READ | Logistics: shipments in transit for more than 10 days (checked on 30 Jun 2026) | 9.768 | 10.060 | 10.058 | 9.962 | Seq Scan on orders |
| R06 | READ | Seller Central: seller 217's order lines in June 2026 | 12.127 | 11.230 | 11.910 | 11.756 | Seq Scan on order_items / Index Scan using orders_pkey on orders |
| R07 | READ | Seller Central: seller 217's products that are low on stock | 3.457 | 3.387 | 3.660 | 3.501 | Seq Scan on products |
| R08 | READ | Merchandising: top 5 best-selling products in every sub-category, last 30 days | 52.077 | 48.582 | 47.722 | 49.460 | Seq Scan on order_items / Seq Scan on orders / Seq Scan on products |
| R09 | READ | Prime team: average order value of Prime vs non-Prime customers per month in 2026 | 46.778 | 46.342 | 47.021 | 46.714 | Seq Scan on orders / Seq Scan on customers |
| R10 | READ | Marketing: carts untouched since May 2026 whose owner has not ordered since then | 32.229 | 34.839 | 33.397 | 33.488 | Seq Scan on orders / Seq Scan on cart_items / Seq Scan on products |
| R11 | READ | Product page: "Frequently bought together" with product 4321 | 9.732 | 8.749 | 8.960 | 9.147 | Seq Scan on order_items / Index Scan using order_items_pkey on order_items |
| R12 | READ | Category managers: return rate per top-level category | 121.871 | 115.968 | 118.658 | 118.832 | Seq Scan on order_items / Seq Scan on products / Seq Scan on categories / Seq Scan on returns |
| R13 | READ | Data clean-up: saved addresses that have never been used for any order | 34.487 | 31.816 | 33.545 | 33.283 | Seq Scan on addresses / Seq Scan on orders |
| R14 | READ | Deals page: active products selling at less than half of MRP, biggest discount first | 9.804 | 8.996 | 9.184 | 9.328 | Seq Scan on products |
| R15 | READ | Seller performance: top 20 sellers by revenue among sellers with at least 50 lines sold in 2026 | 52.949 | 51.317 | 50.654 | 51.640 | Seq Scan on order_items / Seq Scan on orders / Seq Scan on sellers |
| R16 | READ | Review insights: Electronics reviews that mention the battery | 29.723 | 27.545 | 28.895 | 28.721 | Seq Scan on product_reviews / Seq Scan on products / Seq Scan on categories |
| R17 | READ | Trust & safety: "verified purchase" reviews with no delivered order of that product by that customer | 146.654 | 174.159 | 162.900 | 161.238 | Seq Scan on order_items / Seq Scan on orders / Seq Scan on product_reviews |
| R18 | READ | Customer analytics: Mumbai customers split into 4 spending tiers (2026) | 23.601 | 23.349 | 25.229 | 24.060 | Seq Scan on orders / Seq Scan on customers |
| R19 | READ | Category report: every Mobile phone with its last sale date and units sold (all time) | 18374.234 | 18226.143 | 17512.878 | 18037.752 | Seq Scan on categories / Seq Scan on products / Seq Scan on order_items / Index Scan using orders_pkey on orders |
| R20 | READ | Finance: daily sales (GMV) and running total for June 2026 | 12.199 | 11.764 | 11.603 | 11.855 | Seq Scan on orders |
| R21 | READ | Logistics: deliveries in June 2026 that took more than 5 days | 10.060 | 10.550 | 10.175 | 10.262 | Seq Scan on orders |
| R22 | READ | Admin: "All orders", newest first, page 3,001 (25 rows per page) | 51.323 | 48.415 | 50.439 | 50.059 | Seq Scan on orders |
| R23 | READ | Order details page: one order with its lines, products and sellers | 0.157 | 0.152 | 0.153 | 0.154 | Index Scan using order_items_pkey on order_items / Index Scan using orders_pkey on orders / Index Scan using products_pkey on products / Index Scan using sellers_pkey on sellers |
| R24 | READ | Product lookup by ASIN (barcode scanner in the warehouse) | 2.307 | 2.186 | 2.187 | 2.227 | Seq Scan on products |
| W01 | WRITE | Checkout: create a new order (header row) | 1.131 | 0.785 | 0.887 | 0.934 | (no scan) |
| W02 | WRITE | Checkout: reduce stock of product 4322 after a sale | 0.291 | 0.305 | 0.266 | 0.287 | Index Scan using products_pkey on products |
| W03 | WRITE | Seller Central: 10% price cut on all of seller 217's Watches | 2.199 | 2.212 | 2.148 | 2.186 | Seq Scan on categories / Seq Scan on products |
| W04 | WRITE | Big sale: 5,000 "add to cart" events loaded in one batch | 54.563 | 58.681 | 55.967 | 56.404 | (no scan) |
| W05 | WRITE | Logistics: mark the oldest packed order as shipped | 14.867 | 14.895 | 15.206 | 14.989 | Index Scan using orders_pkey on orders |
| W06 | WRITE | Nightly clean-up: remove cart items older than 90 days | 10.081 | 11.292 | 10.357 | 10.577 | Seq Scan on cart_items |

Average = (Run 1 + Run 2 + Run 3) / 3.

## What stands out

R19 is by far the slowest at about 18 seconds per run. It has two correlated subqueries (last sale date and units sold), and with no index on order_items.product_id each one does a full seq scan of order_items for every one of the 937 Mobiles products. That's around 1,900 scans of a 240k row table. Fixing that one query is the biggest win for CP3.

After that the slow ones are R17 (161 ms), R12 (119 ms), W04 (56 ms), R15 (52 ms), R22 (50 ms), R08 (49 ms) and R09 (47 ms). Almost all of them do seq scans on orders or order_items because there are no indexes on the foreign keys or on columns like status, ordered_at, seller_id and product_id.

R23 is already fast (0.15 ms) since it only looks up by primary keys. W02 and W05 are also cheap for the same reason.

R01 and R16 use `ILIKE '%...%'`, so a normal B-tree index won't help them. We'll look at a trigram index for those in CP3.
