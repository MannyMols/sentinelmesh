import os
import glob
import pandas as pd
from sqlalchemy import text
import sys
sys.path.insert(0, os.path.expanduser("~/sentinelmesh"))
from etl.utils.db_connect import get_engine

PHASE1_PATH    = os.path.expanduser("~/sentinelmesh/data/raw/cic_iot_2023/phase1")
OUTPUT_CSV     = os.path.expanduser("~/sentinelmesh/data/processed/phase1_cic_sampled.csv")
ROWS_PER_CLASS = 20_000
SEED           = 42

LABEL_MAP = {
    "BenignTraffic":           ("BenignTraffic",    "Benign",     False),
    "Benign_Final":            ("BenignTraffic",    "Benign",     False),
    "Benign":                  ("BenignTraffic",    "Benign",     False),
    "DDoS-UDP_Flood":          ("DDoS-UDP_Flood",   "DDoS",       True),
    "DDoS-TCP_Flood":          ("DDoS-TCP_Flood",   "DDoS",       True),
    "DDoS-SYN_Flood":          ("DDoS-SYN_Flood",   "DDoS",       True),
    "DDoS-HTTP_Flood":         ("DDoS-HTTP_Flood",  "DDoS",       True),
    "DDoS-ICMP_Flood":         ("DDoS-ICMP_Flood",  "DDoS",       True),
    "DDoS-SlowLoris":          ("DDoS-SlowLoris",   "DDoS",       True),
    "DDoS-PSHACK_Flood":       ("DDoS-PSHACK",      "DDoS",       True),
    "DDoS-RSTFIN_Flood":       ("DDoS-RSTFIN",      "DDoS",       True),
    "DDoS-ACK_Fragmentation":  ("DDoS-ACK_Frag",    "DDoS",       True),
    "DoS-HTTP_Flood":          ("DoS-HTTP_Flood",   "DoS",        True),
    "DoS-SYN_Flood":           ("DoS-SYN_Flood",    "DoS",        True),
    "DoS-TCP_Flood":           ("DoS-TCP_Flood",    "DoS",        True),
    "DoS-UDP_Flood":           ("DoS-UDP_Flood",    "DoS",        True),
    "Recon-PortScan":          ("Recon-PortScan",   "Recon",      True),
    "Recon-HostDiscovery":     ("Recon-HostDisc",   "Recon",      True),
    "Recon-OSScan":            ("Recon-OSScan",     "Recon",      True),
    "Recon-PingSweep":         ("Recon-PingSweep",  "Recon",      True),
    "Recon-VulnerabilityScan": ("Recon-VulnScan",   "Recon",      True),
    "Mirai-greeth_flood":      ("Mirai-Greeth",     "Mirai",      True),
    "Mirai-greip_flood":       ("Mirai-Greip",      "Mirai",      True),
    "Mirai-udpplain":          ("Mirai-UDPPlain",   "Mirai",      True),
    "DictionaryBruteForce":    ("BruteForce-Dict",  "BruteForce", True),
    "DNS_Spoofing":            ("Spoofing-DNS",     "Spoofing",   True),
    "MITM-ArpSpoofing":        ("Spoofing-ARP",     "Spoofing",   True),
    "SqlInjection":            ("Web-SQLi",         "Web",        True),
    "Backdoor_Malware":        ("Malware-Backdoor", "Malware",    True),
}

def map_label(raw):
    return LABEL_MAP.get(raw, ("Unknown", "Unknown", True))

def load_phase1():
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)
    frames = []
    folders = sorted([f for f in os.listdir(PHASE1_PATH)
                      if os.path.isdir(os.path.join(PHASE1_PATH, f))])

    if not folders:
        print(f"ERROR: No folders found in {PHASE1_PATH}")
        return

    print(f"Found {len(folders)} folders in Phase 1\n")

    for folder in folders:
        folder_path = os.path.join(PHASE1_PATH, folder)
        csv_files   = sorted(glob.glob(os.path.join(folder_path, "*.csv")))

        if not csv_files:
            print(f"  SKIP {folder}: no CSV files found")
            continue

        csv_file = csv_files[0]
        try:
            df = pd.read_csv(csv_file, low_memory=False)
        except Exception as e:
            print(f"  ERROR reading {csv_file}: {e}")
            continue

        df.columns = df.columns.str.strip()

        # Use folder name as label (CICIoT2023 standard structure)
        df["label_raw"] = folder

        n          = min(ROWS_PER_CLASS, len(df))
        df_sampled = df.sample(n=n, random_state=SEED).copy()

        df_sampled["unified_label"]  = df_sampled["label_raw"].apply(lambda x: map_label(x)[0])
        df_sampled["attack_family"]  = df_sampled["label_raw"].apply(lambda x: map_label(x)[1])
        df_sampled["is_attack"]      = df_sampled["label_raw"].apply(lambda x: map_label(x)[2])
        df_sampled["source_file"]    = os.path.basename(csv_file)
        df_sampled["dataset_source"] = "CICIoT2023"
        df_sampled["phase"]          = 1

        print(f"  {folder}: {len(df):>8,} rows → sampled {n:,} | unified: {df_sampled['unified_label'].iloc[0]}")
        frames.append(df_sampled)

    if not frames:
        print("\nNo data loaded.")
        return

    df_final = pd.concat(frames, ignore_index=True)
    df_final.to_csv(OUTPUT_CSV, index=False)

    print(f"\n{'='*55}")
    print(f"Phase 1 sample saved : {len(df_final):,} rows")
    print(f"Output               : {OUTPUT_CSV}")
    print(f"Unique classes       : {df_final['unified_label'].nunique()}")
    print(f"\nClass distribution:")
    print(df_final['unified_label'].value_counts().to_string())
    print(f"{'='*55}")

    print("\nLoading into PostgreSQL stg_harmonized...")
    engine = get_engine()

    col_map = {
        "Protocol Type":   "protocol",
        "Flow Duration":   "duration",
        "Tot Fwd Pkts":    "src_pkts",
        "Tot Bwd Pkts":    "dst_pkts",
        "TotLen Fwd Pkts": "src_bytes",
        "TotLen Bwd Pkts": "dst_bytes",
        "Rate":            "flow_rate_byts_s",
        "flow_iat_mean":   "cic_iat_mean",
        "flow_iat_std":    "cic_iat_std",
        "active_mean":     "cic_active_mean",
        "idle_mean":       "cic_idle_mean",
        "syn_flag_number": "syn_flag",
        "ack_flag_number": "ack_flag",
        "fin_flag_number": "fin_flag",
        "rst_flag_number": "rst_flag",
    }

    core_cols = ["dataset_source", "source_file", "phase",
                 "label_raw", "unified_label", "attack_family", "is_attack"]

    df_harm = df_final[core_cols].copy()
    for src_col, tgt_col in col_map.items():
        if src_col in df_final.columns:
            df_harm[tgt_col] = df_final[src_col].values

    df_harm["sample_seed"] = SEED

    df_harm.to_sql("stg_harmonized", engine,
                   if_exists="append", index=False,
                   method="multi", chunksize=1000)

    with engine.connect() as conn:
        count = conn.execute(text("SELECT COUNT(*) FROM stg_harmonized")).scalar()

    print(f"Done. stg_harmonized now has {count:,} rows.")

if __name__ == "__main__":
    load_phase1()
