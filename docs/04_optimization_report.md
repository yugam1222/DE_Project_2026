# CP3 — Query Optimization Report

**Project:** Amazon Online Shopping Database  
**Database:** amazon_db  
**Schema:** amazon  
**Date:** 19 November 2026

## 1. Objective

The objective of CP3 is to optimize the 30-query workload using suitable PostgreSQL indexes and selected SQL rewrites. The work focuses on read performance, query correctness, index storage, and write overhead.

The original workload at `queries/workload_30.sql` remains unchanged. Optimized queries are maintained in `sql/06_optimized_queries.sql`, and index definitions are in `sql/05_indexes.sql`.

## 2. Database and benchmark setup

The local database contains 565,584 rows across 11 tables.

| Table | Rows |
|---|---:|
| cities | 10 |
| categories | 40 |
| sellers | 1,500 |
| customers | 30,000 |
| addresses | 45,000 |
| products | 30,000 |
| orders | 120,000 |
| order_items | 240,000 |
| returns | 5,374 |
| product_reviews | 38,662 |
| cart_items | 44,998 |
| **Total** | **565,584** |

Baseline timings are from `benchmarks/results/local_before/` and optimized timings are from `benchmarks/results/optimized/`.

- Baseline measurements: 3 runs per query.
- Final optimized measurements: 5 runs per query.
- Write queries are rolled back by the benchmark script.
- All timings are in milliseconds.
- Both measurements were taken on the same local machine and database, but the run counts differ. Small differences should therefore be interpreted cautiously.

## 3. Before-and-after timings

Improvement percentage = ((baseline average − optimized average) / baseline average) × 100.

| Query | Type | Baseline (ms) | Optimized (ms) | Improvement |
|---|---|---:|---:|---:|
| R01 | READ | 25.942 | 4.332 | 83.3% |
| R02 | READ | 5.839 | 3.534 | 39.5% |
| R03 | READ | 2.311 | 0.090 | 96.1% |
| R04 | READ | 6.493 | 0.168 | 97.4% |
| R05 | READ | 9.762 | 0.677 | 93.1% |
| R06 | READ | 9.525 | 1.684 | 82.3% |
| R07 | READ | 3.589 | 0.059 | 98.4% |
| R08 | READ | 45.822 | 41.552 | 9.3% |
| R09 | READ | 47.198 | 30.313 | 35.8% |
| R10 | READ | 34.760 | 27.544 | 20.8% |
| R11 | READ | 8.424 | 0.171 | 98.0% |
| R12 | READ | 113.362 | 116.941 | -3.2% |
| R13 | READ | 28.861 | 28.631 | 0.8% |
| R14 | READ | 8.156 | 7.994 | 2.0% |
| R15 | READ | 42.825 | 41.265 | 3.6% |
| R16 | READ | 26.101 | 13.227 | 49.3% |
| R17 | READ | 109.782 | 329.648 | -200.3% |
| R18 | READ | 20.063 | 15.814 | 21.2% |
| R19 | READ | 17,868.610 | 106.131 | 99.4% |
| R20 | READ | 11.286 | 2.755 | 75.6% |
| R21 | READ | 10.013 | 1.990 | 80.1% |
| R22 | READ | 50.996 | 13.875 | 72.8% |
| R23 | READ | 0.137 | 0.157 | -14.6% |
| R24 | READ | 2.162 | 0.054 | 97.5% |
| W01 | WRITE | 1.014 | 0.867 | 14.5% |
| W02 | WRITE | 0.334 | 1.059 | -217.1% |
| W03 | WRITE | 2.231 | 1.004 | 55.0% |
| W04 | WRITE | 79.990 | 75.442 | 5.7% |
| W05 | WRITE | 15.269 | 15.246 | 0.2% |
| W06 | WRITE | 11.381 | 5.850 | 48.6% |

