# CP4 — Scalability Report

**Project:** Amazon Online Shopping Database  
**Schema:** `amazon`  
**Date:** 23 November 2026

## 1. Scope

CP4 evaluates how the order-line fact table behaves as data volume grows. The
partitioning migration is in `sql/08_partitioning.sql`. It converts
`amazon.order_items` to eight hash partitions on `order_id` while preserving
the `(order_id, line_no)` primary key, references to orders, products, and
sellers, the returns foreign key, and the CP3 product and seller indexes.

The large dataset and the three-run benchmark summary still need to be produced
before measured scalability claims can be reported. Fill in the results below
from `benchmarks/results/large/summary.csv`; do not treat the CP3 timings as
large-dataset results.

## 2. Partitioning design

`order_items` is the largest table in the CP3 dataset (240,000 rows) and is
joined to `orders` by `order_id`. Hash partitioning on `order_id` routes each
order's lines to one of eight partitions and allows PostgreSQL to prune to a
partition when a query filters on an order ID. The partition key is part of
the existing primary key, so uniqueness remains enforceable on the partitioned
table and the `(order_id, line_no)` relationship used by `returns` is retained.

The choice distributes order IDs evenly without relying on date boundaries.
Queries that do not constrain `order_id` may still scan all partitions, so
partitioning is not expected to improve every query. The migration preserves
CP3 indexes used for product and seller lookups; it does not claim that those
indexes or partitioning improve queries without a matching filter.

## 3. Benchmark method

Run the original 30-query workload against the scaled dataset after applying
`sql/08_partitioning.sql`. Use three runs per query and record the average and
scan nodes in `benchmarks/results/large/summary.csv`. Use the same PostgreSQL
version, machine, and query workload as the CP3 run where possible. Record the
row counts before and after scaling and the PostgreSQL version in this report.

## 4. Dataset size and measurements

| Measure | Before scaling | Large dataset / partitioned |
|---|---:|---:|
| `orders` rows | 120,000 | Pending large-data load |
| `order_items` rows | 240,000 | Pending large-data load |
| PostgreSQL version | Pending | Pending |

Add representative three-run averages from the large benchmark here:

| Query | Type | Large run average (ms) | Scan / partition behavior |
|---|---|---:|---|
| R04 | READ | Pending benchmark | Pending benchmark |
| R06 | READ | Pending benchmark | Pending benchmark |
| R19 | READ | Pending benchmark | Pending benchmark |

## 5. Findings and limitations

Measured before/after scalability findings must be added after the large-data
benchmark completes. The expected benefit is partition pruning for queries
that identify an order by `order_id`; scans without that predicate can visit
all eight partitions and may not become faster. Partitioning also adds
planning and maintenance overhead. Compare actual plans and timings before
claiming an improvement.

The migration copies the existing table inside a transaction, so it needs
temporary disk space for a second copy and should run during a maintenance
window. It is a one-time migration; do not rerun it after the table has been
converted.
