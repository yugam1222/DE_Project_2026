-- CP4: order partitioning design demonstration for the 100x architecture.
-- Run after loading amazon.orders. This creates a separate demo table, so the
-- measured large-data workload remains on the original schema.
-- The monthly query below demonstrates pruning across yearly RANGE partitions.

SET search_path TO amazon;

-- CP4 scale-only fixes based on the large-data plans:
-- R05 needs the projected columns in the partial index for index-only scans.
-- W05 finds min(order_id) among PACKED orders; this partial index avoids
-- scanning millions of non-PACKED entries in the primary-key index.
DROP INDEX IF EXISTS amazon.idx_orders_shipped_at;
CREATE INDEX IF NOT EXISTS idx_orders_shipped_covering
    ON amazon.orders (shipped_at) INCLUDE (order_id, customer_id)
    WHERE status = 'SHIPPED';
CREATE INDEX IF NOT EXISTS idx_orders_packed_order_id
    ON amazon.orders (order_id)
    WHERE status = 'PACKED';

-- Clean up an earlier demonstration run, if present.
DROP TABLE IF EXISTS amazon.orders_partitioned_demo;

CREATE TABLE amazon.orders_partitioned_demo (
    order_id BIGINT NOT NULL,
    customer_id INTEGER NOT NULL,
    address_id INTEGER,
    ordered_at TIMESTAMPTZ NOT NULL,
    payment_method TEXT NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    status TEXT NOT NULL,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    -- PostgreSQL requires a partition key to be included in every unique key.
    PRIMARY KEY (order_id, ordered_at)
) PARTITION BY RANGE (ordered_at);

CREATE TABLE amazon.orders_partitioned_demo_2025
    PARTITION OF amazon.orders_partitioned_demo
    FOR VALUES FROM ('2025-01-01 00:00:00+05:30')
             TO ('2026-01-01 00:00:00+05:30');
CREATE TABLE amazon.orders_partitioned_demo_2026
    PARTITION OF amazon.orders_partitioned_demo
    FOR VALUES FROM ('2026-01-01 00:00:00+05:30')
             TO ('2027-01-01 00:00:00+05:30');
CREATE TABLE amazon.orders_partitioned_demo_default
    PARTITION OF amazon.orders_partitioned_demo DEFAULT;

INSERT INTO amazon.orders_partitioned_demo
    (order_id, customer_id, address_id, ordered_at, payment_method,
     total_amount, status, shipped_at, delivered_at)
SELECT order_id, customer_id, address_id, ordered_at, payment_method,
       total_amount, status, shipped_at, delivered_at
FROM amazon.orders;

ANALYZE amazon.orders_partitioned_demo;

-- Expected plan: only orders_partitioned_demo_2026 appears below.
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, ordered_at, status
FROM amazon.orders_partitioned_demo
WHERE ordered_at >= TIMESTAMPTZ '2026-06-01 00:00:00+05:30'
  AND ordered_at <  TIMESTAMPTZ '2026-07-01 00:00:00+05:30';

-- Keep the benchmark database's schema and storage unchanged after the demo.
DROP TABLE amazon.orders_partitioned_demo;
