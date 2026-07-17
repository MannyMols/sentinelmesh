# SentinelMesh

Cross-dataset ML transferability evaluation for IoT network intrusion detection.

## Overview
Trains ensemble models (RandomForest, XGBoost, LightGBM) on CICIoT2023, evaluates zero-shot and few-shot transfer to TON_IoT, and writes results to PostgreSQL.

## Structure
- `notebooks/` — Jupyter notebooks 00–05 covering schema setup, EDA, model training, ETL, prediction writeback, and cross-dataset evaluation
- `etl/` — data ingestion and DB connection utilities
- `sql/` — schema DDL and fact/dimension transforms
- `dashboard/` — results visualization app
- `data/processed/` — summary CSVs and evaluation outputs

## Key Finding
Models trained on CICIoT2023 show a ~30% relative F1 drop when evaluated zero-shot on TON_IoT, but few-shot adaptation with just 10% TON_IoT training data recovers benign-class F1 from 0.00 to 0.90.
