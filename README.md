# Amazon Online Shopping Database: DBMS Project

**DE Repository:** DE_Project_2026  
**Course:** Database Management Systems  
**Year:** B.Tech 2nd year  
**Team size:** 4  
**Database:** PostgreSQL 15 or newer  
**Final submission:** 23 November 2026

## Team details
Role	Name	Enrollment No.	GitHub
Group Lead	Yugam Panchal	2501010535	yugam1222
Member 2	Pratyusha Singh	2501010349	partyyusha
Member 3	Yatharth Katta	2501010529	yats0x7
Member 4	Shubham Sharma	2501010444	shubhamsharma0707

**Team No.:**  T0143
**Section:**  D
**Repository URL:** https://github.com/yugam1222/DE_Project_2026

---

## CP4 final results

The 20× faculty dataset loaded 11,113,690 rows across the 11 tables. All 30
optimized queries met their CP4 average-time targets after adding scale-focused
indexes for R05 and W05. The full per-query comparison, storage measurements,
partitioning demo, and limitations are in `docs/05_scalability_report.md`.

For context, the sum of per-query average execution times was 18,831.971 ms for
the CP2 baseline, 888.074 ms for the CP3 optimized run (five runs per query),
458.248 ms for the CP4 seed run, and 9,131.334 ms for the CP4 large run (three
runs per query). These are sums over 30 separate queries; use the report's
per-query table for target checks.

## Reproduce the CP4 large run

1. Download the [faculty large dataset](https://github.com/edusatyaki/DBMS-Amazon-Online-Shopping/releases/download/large-data/large_data.zip) and unzip it in this repository to create `large_data/`.
2. Create a fresh database, then run `sql/01_schema.sql`.
3. Run `sql/02_load_data.sql` with only the `seed_data/` folder name changed to `large_data/`.
4. Run `sql/05_indexes.sql`, then `sql/08_partitioning.sql`, and `ANALYZE`.
5. Run `./benchmarks/run_benchmark.sh <database> large 3 sql/06_optimized_queries.sql`.

The CSV files in `large_data/` and `seed_data/` are excluded from Git.

The project instructions, phases, deliverables, SQL queries and repository structure are maintained below from the original Amazon Online Shopping Database project README.

