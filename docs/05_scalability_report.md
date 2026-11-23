# CP4 — Scalability Report

**Project:** Amazon Online Shopping Database  
**Schema:** `amazon`  
**Benchmark date:** 23 November 2026; **PostgreSQL:** 18.6 (Postgres.app), Apple silicon MacBook

## 1. Method and dataset

The faculty `large_data.zip` release was loaded into a fresh `amazon_large`
database using `sql/01_schema.sql`, `sql/02_load_data.sql` with only the CSV
folder changed from `seed_data/` to `large_data/`, then `sql/05_indexes.sql`
and `ANALYZE`. The original `orders` and `order_items` tables were left intact
for the benchmark. Phase 5-only indexes and the separate partitioning demo are
in `sql/08_partitioning.sql`.

The 30 optimized queries in `sql/06_optimized_queries.sql` were run three times
each with `EXPLAIN (ANALYZE, BUFFERS)`. Writes ran in a transaction and were
rolled back by `benchmarks/run_benchmark.sh`. The seed comparison was rerun on
the same machine with the same CP4 indexes and three runs per query; its raw
plans are in `benchmarks/results/seed_cp4/`. The large run's summary and plans
are in `benchmarks/results/large/`. The scale fixes were measured before and
after; the original failing plans are retained in
`benchmarks/results/large_before_fixes/`.

| Table | Seed rows | Large rows |
|---|---:|---:|
| cities | 10 | 10 |
| categories | 40 | 40 |
| sellers | 1,500 | 30,000 |
| customers | 30,000 | 600,000 |
| addresses | 45,000 | 900,000 |
| products | 30,000 | 600,000 |
| orders | 120,000 | 2,400,000 |
| order_items | 240,000 | 4,800,000 |
| returns | 5,374 | 106,493 |
| product_reviews | 38,662 | 777,147 |
| cart_items | 44,998 | 900,000 |
| **Total** | **555,584** | **11,113,690** |

The dataset grew by about 20× overall. The CSV files are excluded from Git.

## 2. Results and targets

Each cell is the average of three runs, in milliseconds. Growth is the large
average divided by the seed average. A query passes when it is below its group
target from the project brief.

| Query | Type | Seed avg (ms) | Large avg (ms) | Growth | Target | Result |
|---|---|---:|---:|---:|---:|---|
| R01 | READ | 3.997 | 41.861 | 10.47× | <250 ms | Pass |
| R02 | READ | 3.604 | 53.931 | 14.96× | <250 ms | Pass |
| R03 | READ | 0.177 | 0.229 | 1.29× | <5 ms | Pass |
| R04 | READ | 0.376 | 0.401 | 1.07× | <5 ms | Pass |
| R05 | READ | 0.133 | 0.658 | 4.95× | <5 ms | Pass |
| R06 | READ | 2.508 | 8.264 | 3.30× | <250 ms | Pass |
| R07 | READ | 0.132 | 0.156 | 1.18× | <5 ms | Pass |
| R08 | READ | 21.119 | 277.902 | 13.16× | <5,000 ms | Pass |
| R09 | READ | 16.152 | 445.920 | 27.61× | <5,000 ms | Pass |
| R10 | READ | 14.779 | 297.018 | 20.10× | <5,000 ms | Pass |
| R11 | READ | 0.728 | 0.819 | 1.12× | <5 ms | Pass |
| R12 | READ | 63.397 | 1,278.290 | 20.16× | <5,000 ms | Pass |
| R13 | READ | 14.546 | 243.501 | 16.74× | <250 ms | Pass, near limit |
| R14 | READ | 3.968 | 31.655 | 7.98× | <250 ms | Pass |
| R15 | READ | 22.478 | 679.415 | 30.23× | <5,000 ms | Pass |
| R16 | READ | 6.650 | 59.598 | 8.96× | <250 ms | Pass |
| R17 | READ | 162.655 | 3,923.647 | 24.12× | <5,000 ms | Pass, near limit |
| R18 | READ | 8.617 | 102.019 | 11.84× | <5,000 ms | Pass |
| R19 | READ | 56.880 | 1,293.447 | 22.74× | <5,000 ms | Pass |
| R20 | READ | 1.387 | 32.104 | 23.15× | <5,000 ms | Pass |
| R21 | READ | 0.977 | 19.278 | 19.73× | <250 ms | Pass |
| R22 | READ | 7.088 | 7.099 | 1.00× | <250 ms | Pass |
| R23 | READ | 0.352 | 0.411 | 1.17× | <5 ms | Pass |
| R24 | READ | 0.144 | 0.287 | 1.99× | <5 ms | Pass |
| W01 | WRITE | 0.705 | 1.105 | 1.57× | <5 ms | Pass |
| W02 | WRITE | 1.072 | 1.485 | 1.39× | <5 ms | Pass |
| W03 | WRITE | 0.529 | 0.703 | 1.33× | <5 ms | Pass |
| W04 | WRITE | 39.552 | 55.829 | 1.41× | <2,000 ms | Pass |
| W05 | WRITE | 0.294 | 0.442 | 1.50× | <5 ms | Pass |
| W06 | WRITE | 3.252 | 273.860 | 84.21× | <2,000 ms | Pass |

All 30 large-data averages meet their target after the two scale fixes below.
R13 is 6.499 ms below its 250 ms target and R17 is 1,076.353 ms below its
5,000 ms target, so both deserve monitoring if the workload grows further.
W06's three runs were 139.648, 286.012, and 395.921 ms; the variation reflects
the cost of deleting and rolling back 224,089 rows, while remaining well under
the 2,000 ms batch target.

## 3. Growth analysis

Comparing the per-query three-run averages:

- **Nearly flat, under 2× (12 queries):** R03, R04, R07, R11, R22, R23, R24,
  W01, W02, W03, W04, W05. Point lookups and fixed-size result pages continue
  to touch a small part of the data; the added scale indexes also keep W05
  selective. R22's fixed offset of 75,000 remains a small part of the 2.4M
  order index.
- **Grew 2× to under 20× (10 queries):** R01, R02, R05, R06, R08, R13, R14,
  R16, R18, R21. These use selective indexes or process only part of a table,
  so their growth stays below the full data growth.
- **Grew about 20× to 30× (6 queries):** R09, R10, R12, R17, R19, R20. These
  read or aggregate a substantial share of orders, order lines, carts, or
  reviews. The increase is close to the corresponding row growth.
- **Grew over 30× (2 queries):** R15 and W06. R15 aggregates seller revenue
  across the 4.8M order lines. W06 deletes 224,089 old cart rows on the large
  dataset, compared with 11,324 on the seed run; its write and rollback work is
  substantially larger even though the average remains within target.

## 4. Scale-only plan fixes

The first large-data run exposed two target misses. The before plans and
three-run measurements are preserved under
`benchmarks/results/large_before_fixes/`; the final plans are under
`benchmarks/results/large/`.

| Query | Before avg | Before plan issue | CP4 change | After avg |
|---|---:|---|---|---:|
| R05 | 15.886 ms | Partial index scan fetched 6,713 heap rows; first run read 6,001 pages | Covering partial index on `shipped_at` including `order_id, customer_id` | 0.658 ms |
| W05 | 186.060 ms | Primary-key scan removed 2,397,600 rows while searching for the oldest `PACKED` order | Partial index on `order_id WHERE status = 'PACKED'` | 0.442 ms |

R05 changed to an index-only scan with zero heap fetches. W05 changed to an
index-only lookup of the oldest packed order, then a primary-key update of that
single order. Both CP4 indexes are in `sql/08_partitioning.sql` and are added
after the CP3 indexes. The index definitions and before/after raw plans are
committed so the changes can be reproduced and reviewed.

## 5. Storage

Sizes were measured with `pg_database_size`, `pg_relation_size`, and
`pg_indexes_size` after `ANALYZE`/`VACUUM`, excluding the temporary partition
demo table.

| Storage measure | Seed database | Large database |
|---|---:|---:|
| Whole database | 98.9 MiB | 1,777.2 MiB |
| Table heap | 41.6 MiB | 827.3 MiB |
| Indexes | 48.8 MiB | 941.2 MiB |
| Tables + indexes | 90.8 MiB | 1,769.0 MiB |

Indexes use about 54% of the measured table-plus-index storage in each
database. The database size also includes PostgreSQL catalogs and other
database overhead.

## 6. Partitioning design and pruning evidence

`sql/08_partitioning.sql` builds a temporary demonstration table partitioned
by `RANGE (ordered_at)` with one partition per year and a default partition.
The June 2026 query produced this actual plan on the large dataset:

```text
Seq Scan on orders_partitioned_demo_2026 orders_partitioned_demo
  Filter: ordered_at >= '2026-06-01 00:00:00+05:30'
      AND ordered_at < '2026-07-01 00:00:00+05:30'
  Rows Removed by Filter: 663736
  Execution Time: 26.044 ms
```

Only the 2026 child appears in the plan; the 2025 and default partitions were
pruned. The query returned 131,868 rows from the 2026 partition. The script
drops the demonstration table after printing the plan, leaving the measured
benchmark tables unchanged.

PostgreSQL requires every primary or unique key on a partitioned table to
include its partition key, so the demo primary key is `(order_id, ordered_at)`.
The current `order_items` foreign key references `orders(order_id)` alone;
therefore the demo does not replace the live `orders` table. A production
migration would need to propagate `ordered_at` into the referencing key and
foreign key, or retain a separate unpartitioned order-ID registry. That
referential-integrity change needs to be designed and measured before adopting
partitioning in the application schema.

## 7. Architecture at 100×

- **Partitioning:** use monthly `RANGE` partitions on `orders.ordered_at` for
  time-bounded order and logistics access. The June plan above shows pruning
  with the current data. Keep the partition key in the unique key and redesign
  the `order_items` reference before migrating production tables. Add future
  partitions ahead of time and detach/archive old ones by retention policy.
- **Sharding:** shard order history by `customer_id` to keep customer order
  views and customer-scoped cart/order work local. Large-data R04 averaged
  0.401 ms. Seller views such as R06 (8.264 ms) and revenue R15 (679.415 ms)
  become cross-shard, as do product/category and whole-period reports. Use a
  seller/product secondary lookup for targeted operations and scatter/gather
  with partial aggregation for reports. Replicate small reference tables such
  as categories and cities to each shard.
- **Read replicas and cache:** route analytics and long-running read reports
  (R08–R20, R22) to a replica when small replica lag is acceptable. Cache
  catalog/category reads (R01, R02, R07, R14, R24) with short TTLs. Keep
  read-your-own-write order views (R04), operational shipment queries (R05,
  R21), and all writes (W01–W06) on the primary unless the application has an
  explicit consistency policy.
- **Maintenance:** run `ANALYZE` after bulk loads and keep autovacuum active on
  write-heavy orders and carts. Start with a lower orders vacuum scale factor
  (for example 0.02) and tune from dead-tuple and vacuum-duration measurements.
  Archive detached old partitions to cheaper storage, and refresh reporting
  summaries with `REFRESH MATERIALIZED VIEW CONCURRENTLY` where a unique key
  permits it.

## 8. Conclusion and limitations

On this MacBook, the 11.1M-row release met all 30 stated average-time targets
after adding two selective indexes for R05 and W05. The main scale pressure is
the work that reads a large fraction of order lines, orders, reviews, and cart
rows; those queries remain within their broad reporting/batch targets, but
their absolute times continue to rise with data volume.

The measurements are single-user local runs, not concurrent production load
tests. They do not establish 100× capacity or replica/shard behavior. The
partitioning DDL is a tested design demonstration, and the production foreign
key adjustment, concurrency tests, and a larger-scale workload remain future
work.
