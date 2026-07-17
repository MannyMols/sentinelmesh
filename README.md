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

## Datasets

### CICIoT2023
- **Source:** Canadian Institute for Cybersecurity (CIC), University of New Brunswick
- **Description:** A large-scale, real-time IoT attack dataset captured from 105 IoT devices across 33 attack types (DDoS, DoS, Recon, Web-based, Brute Force, Spoofing, MQTT, and more) plus benign traffic. Features are extracted as network flow statistics (39 columns including header lengths, flag counts, IAT statistics, and protocol flags).
- **Size used in this project:** ~241,527 rows (221,527 attack + 20,000 benign)
- **Format:** CSV (flow-level features extracted via CICFlowMeter/PySpark)
- **Paper:** Neto et al., *CICIoT2023: A Real-Time Dataset and Benchmark for Large-Scale Attacks in IoT Environment*, Sensors (2023)
- **Download:** [https://www.unb.ca/cic/datasets/iotdataset-2023.html](https://www.unb.ca/cic/datasets/iotdataset-2023.html)
- **Also available on Kaggle:** [https://www.kaggle.com/datasets/himadri07/ciciot2023](https://www.kaggle.com/datasets/himadri07/ciciot2023)

### TON_IoT
- **Source:** Cyber Range Lab, UNSW Canberra (University of New South Wales)
- **Description:** A next-generation IoT/IIoT dataset collected from a realistic smart-home and smart-factory testbed. Network traffic was captured using Argus and Bro/Zeek tools, producing connection-log style features (44 columns). Contains 9 attack types (backdoor, DDoS, DoS, injection, MITM, password, ransomware, scanning, XSS) plus normal traffic.
- **Size used in this project:** ~211,043 rows
- **Format:** CSV (Zeek/Bro-style network connection logs)
- **Paper:** Moustafa, N., *TON_IoT Telemetry Dataset: A New Generation Dataset of IoT and IIoT for Data-Driven Intrusion Detection Systems*, IEEE Access (2021)
- **Download:** [https://research.unsw.edu.au/projects/toniot-datasets](https://research.unsw.edu.au/projects/toniot-datasets)
- **Also available on Kaggle:** [https://www.kaggle.com/datasets/arnobbhowmik/ton-iot-network-dataset](https://www.kaggle.com/datasets/arnobbhowmik/ton-iot-network-dataset)

> **Note:** Neither dataset is included in this repository due to file size. Download them separately and place CSVs in the `data/` directory before running the notebooks. See individual notebook headers for exact filename expectations.
