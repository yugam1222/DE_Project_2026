-- CP4: migrate the largest fact table to eight hash partitions.
-- Run once after loading/scaling the dataset and before the large benchmark.
-- This is a one-time migration; run it in a maintenance window because it
-- copies order_items and briefly requires space for both table copies.

BEGIN;
SET search_path TO amazon;

-- Keep order_id in the primary key so existing order_id/line_no references
-- remain valid on the partitioned table.
CREATE TABLE amazon.order_items_partitioned (
    order_id BIGINT NOT NULL REFERENCES amazon.orders(order_id),
    line_no INTEGER NOT NULL,
    product_id INTEGER NOT NULL REFERENCES amazon.products(product_id),
    seller_id INTEGER NOT NULL REFERENCES amazon.sellers(seller_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    CONSTRAINT order_items_partitioned_pkey PRIMARY KEY (order_id, line_no)
) PARTITION BY HASH (order_id);

CREATE TABLE amazon.order_items_p0 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE amazon.order_items_p1 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE amazon.order_items_p2 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE amazon.order_items_p3 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE amazon.order_items_p4 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE amazon.order_items_p5 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE amazon.order_items_p6 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE amazon.order_items_p7 PARTITION OF amazon.order_items_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 7);

INSERT INTO amazon.order_items_partitioned
    (order_id, line_no, product_id, seller_id, quantity, unit_price)
SELECT order_id, line_no, product_id, seller_id, quantity, unit_price
FROM amazon.order_items;

-- Remove all foreign keys that point at the old table before replacing it.
DO $$
DECLARE
    fk RECORD;
BEGIN
    FOR fk IN
        SELECT conrelid::regclass AS referencing_table, conname
        FROM pg_constraint
        WHERE contype = 'f'
          AND confrelid = 'amazon.order_items'::regclass
    LOOP
        EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %I',
                       fk.referencing_table, fk.conname);
    END LOOP;
END
$$;

DROP TABLE amazon.order_items;
ALTER TABLE amazon.order_items_partitioned RENAME TO order_items;

-- Restore the CP3 indexes on the new partitioned parent. PostgreSQL creates
-- corresponding indexes on all eight partitions.
CREATE INDEX idx_order_items_product_order
    ON amazon.order_items (product_id, order_id) INCLUDE (quantity);
CREATE INDEX idx_order_items_seller_order
    ON amazon.order_items (seller_id, order_id);

-- Restore the returns -> order_items relationship removed above.
ALTER TABLE amazon.returns
    ADD CONSTRAINT returns_order_items_fk
    FOREIGN KEY (order_id, line_no)
    REFERENCES amazon.order_items (order_id, line_no);

COMMIT;

-- Verify partition counts after migration:
-- SELECT tableoid::regclass AS partition, count(*)
-- FROM amazon.order_items GROUP BY tableoid ORDER BY partition;
