-- =============================================================================
-- SentinelMesh: Full SQL DDL
-- PostgreSQL 15+ | sentinelmesh_db
-- Run as: psql -U sentinel_user -d sentinelmesh_db -h localhost -f sql/04_sql_ddl.sql
-- =============================================================================

-- ─────────────────────────────────────────────
-- STAGING TABLES
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS stg_cic_raw (
    id                      BIGSERIAL PRIMARY KEY,
    flow_duration           DOUBLE PRECISION,
    protocol                INTEGER,
    tot_fwd_pkts            DOUBLE PRECISION,
    tot_bwd_pkts            DOUBLE PRECISION,
    totlen_fwd_pkts         DOUBLE PRECISION,
    totlen_bwd_pkts         DOUBLE PRECISION,
    fwd_pkt_len_max         DOUBLE PRECISION,
    fwd_pkt_len_min         DOUBLE PRECISION,
    fwd_pkt_len_mean        DOUBLE PRECISION,
    fwd_pkt_len_std         DOUBLE PRECISION,
    bwd_pkt_len_max         DOUBLE PRECISION,
    bwd_pkt_len_min         DOUBLE PRECISION,
    bwd_pkt_len_mean        DOUBLE PRECISION,
    bwd_pkt_len_std         DOUBLE PRECISION,
    flow_byts_s             DOUBLE PRECISION,
    flow_pkts_s             DOUBLE PRECISION,
    flow_iat_mean           DOUBLE PRECISION,
    flow_iat_std            DOUBLE PRECISION,
    flow_iat_max            DOUBLE PRECISION,
    flow_iat_min            DOUBLE PRECISION,
    fwd_iat_tot             DOUBLE PRECISION,
    fwd_iat_mean            DOUBLE PRECISION,
    fwd_iat_std             DOUBLE PRECISION,
    fwd_iat_max             DOUBLE PRECISION,
    fwd_iat_min             DOUBLE PRECISION,
    bwd_iat_tot             DOUBLE PRECISION,
    bwd_iat_mean            DOUBLE PRECISION,
    bwd_iat_std             DOUBLE PRECISION,
    bwd_iat_max             DOUBLE PRECISION,
    bwd_iat_min             DOUBLE PRECISION,
    fwd_psh_flags           DOUBLE PRECISION,
    bwd_psh_flags           DOUBLE PRECISION,
    fwd_urg_flags           DOUBLE PRECISION,
    bwd_urg_flags           DOUBLE PRECISION,
    fin_flag_cnt            DOUBLE PRECISION,
    syn_flag_cnt            DOUBLE PRECISION,
    rst_flag_cnt            DOUBLE PRECISION,
    psh_flag_cnt            DOUBLE PRECISION,
    ack_flag_cnt            DOUBLE PRECISION,
    urg_flag_cnt            DOUBLE PRECISION,
    cwe_flag_count          DOUBLE PRECISION,
    ece_flag_cnt            DOUBLE PRECISION,
    fwd_header_len          DOUBLE PRECISION,
    bwd_header_len          DOUBLE PRECISION,
    fwd_pkts_s              DOUBLE PRECISION,
    bwd_pkts_s              DOUBLE PRECISION,
    fwd_byts_b_avg          DOUBLE PRECISION,
    fwd_pkts_b_avg          DOUBLE PRECISION,
    fwd_blk_rate_avg        DOUBLE PRECISION,
    bwd_byts_b_avg          DOUBLE PRECISION,
    bwd_pkts_b_avg          DOUBLE PRECISION,
    bwd_blk_rate_avg        DOUBLE PRECISION,
    subflow_fwd_pkts        DOUBLE PRECISION,
    subflow_fwd_byts        DOUBLE PRECISION,
    subflow_bwd_pkts        DOUBLE PRECISION,
    subflow_bwd_byts        DOUBLE PRECISION,
    active_mean             DOUBLE PRECISION,
    active_std              DOUBLE PRECISION,
    active_max              DOUBLE PRECISION,
    active_min              DOUBLE PRECISION,
    idle_mean               DOUBLE PRECISION,
    idle_std                DOUBLE PRECISION,
    idle_max                DOUBLE PRECISION,
    idle_min                DOUBLE PRECISION,
    label                   VARCHAR(100),
    source_file             VARCHAR(255),
    ingest_timestamp        TIMESTAMP DEFAULT NOW(),
    dq_has_nulls            BOOLEAN DEFAULT FALSE,
    dq_has_inf              BOOLEAN DEFAULT FALSE,
    dq_label_raw            VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_stg_cic_label    ON stg_cic_raw(label);
CREATE INDEX IF NOT EXISTS idx_stg_cic_protocol ON stg_cic_raw(protocol);


CREATE TABLE IF NOT EXISTS stg_ton_raw (
    id                      BIGSERIAL PRIMARY KEY,
    src_ip                  VARCHAR(45),
    dst_ip                  VARCHAR(45),
    src_port                INTEGER,
    dst_port                INTEGER,
    proto                   VARCHAR(10),
    duration                DOUBLE PRECISION,
    src_bytes               DOUBLE PRECISION,
    dst_bytes               DOUBLE PRECISION,
    src_pkts                DOUBLE PRECISION,
    dst_pkts                DOUBLE PRECISION,
    conn_state              VARCHAR(20),
    missed_bytes            DOUBLE PRECISION,
    src_ip_bytes            DOUBLE PRECISION,
    dst_ip_bytes            DOUBLE PRECISION,
    dns_query               VARCHAR(255),
    dns_qclass              DOUBLE PRECISION,
    dns_qtype               DOUBLE PRECISION,
    dns_rcode               DOUBLE PRECISION,
    dns_AA                  BOOLEAN,
    dns_RD                  BOOLEAN,
    dns_RA                  BOOLEAN,
    dns_rejected            BOOLEAN,
    ssl_version             VARCHAR(20),
    ssl_cipher              VARCHAR(100),
    ssl_resumed             BOOLEAN,
    ssl_established         BOOLEAN,
    ssl_subject             VARCHAR(255),
    ssl_issuer              VARCHAR(255),
    http_trans_depth        DOUBLE PRECISION,
    http_method             VARCHAR(10),
    http_uri                TEXT,
    http_referrer           TEXT,
    http_version            VARCHAR(10),
    http_request_body_len   DOUBLE PRECISION,
    http_response_body_len  DOUBLE PRECISION,
    http_status_code        DOUBLE PRECISION,
    http_orig_mime_types    VARCHAR(100),
    http_resp_mime_types    VARCHAR(100),
    weird_name              VARCHAR(100),
    weird_addl              VARCHAR(255),
    weird_notice            BOOLEAN,
    label                   INTEGER,
    type                    VARCHAR(50),
    source_file             VARCHAR(255),
    ingest_timestamp        TIMESTAMP DEFAULT NOW(),
    dq_label_raw            VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_stg_ton_label ON stg_ton_raw(label);
CREATE INDEX IF NOT EXISTS idx_stg_ton_proto ON stg_ton_raw(proto);


CREATE TABLE IF NOT EXISTS stg_harmonized (
    id                      BIGSERIAL PRIMARY KEY,
    dataset_source          VARCHAR(20) NOT NULL,
    source_file             VARCHAR(255),
    sample_seed             INTEGER DEFAULT 42,
    phase                   SMALLINT DEFAULT 1,
    protocol                VARCHAR(10),
    duration                DOUBLE PRECISION,
    src_bytes               DOUBLE PRECISION,
    dst_bytes               DOUBLE PRECISION,
    total_bytes             DOUBLE PRECISION,
    src_pkts                DOUBLE PRECISION,
    dst_pkts                DOUBLE PRECISION,
    total_pkts              DOUBLE PRECISION,
    flow_rate_byts_s        DOUBLE PRECISION,
    flow_rate_pkts_s        DOUBLE PRECISION,
    syn_flag                DOUBLE PRECISION,
    ack_flag                DOUBLE PRECISION,
    fin_flag                DOUBLE PRECISION,
    rst_flag                DOUBLE PRECISION,
    cic_iat_mean            DOUBLE PRECISION,
    cic_iat_std             DOUBLE PRECISION,
    cic_flow_pkts_s         DOUBLE PRECISION,
    cic_active_mean         DOUBLE PRECISION,
    cic_idle_mean           DOUBLE PRECISION,
    ton_conn_state          VARCHAR(20),
    ton_dns_query           VARCHAR(255),
    ton_http_method         VARCHAR(10),
    label_raw               VARCHAR(100),
    unified_label           VARCHAR(100),
    attack_family           VARCHAR(50),
    is_attack               BOOLEAN,
    ingest_timestamp        TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_harm_unified_label ON stg_harmonized(unified_label);
CREATE INDEX IF NOT EXISTS idx_harm_family        ON stg_harmonized(attack_family);
CREATE INDEX IF NOT EXISTS idx_harm_is_attack     ON stg_harmonized(is_attack);
CREATE INDEX IF NOT EXISTS idx_harm_source        ON stg_harmonized(dataset_source);
CREATE INDEX IF NOT EXISTS idx_harm_phase         ON stg_harmonized(phase);


-- ─────────────────────────────────────────────
-- DIMENSION TABLES
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS dim_dataset_source (
    source_id       SMALLSERIAL PRIMARY KEY,
    source_name     VARCHAR(30) NOT NULL UNIQUE,
    source_org      VARCHAR(100),
    source_year     SMALLINT,
    description     TEXT
);

INSERT INTO dim_dataset_source (source_name, source_org, source_year, description)
VALUES
    ('CICIoT2023', 'Canadian Institute for Cybersecurity, UNB', 2023,
     '105 IoT devices, 33 attack types across 7 families. 309 CSV files.'),
    ('TON_IoT', 'UNSW Canberra Cyber Range Lab', 2020,
     'Heterogeneous IoT/IIoT dataset. Network + Telemetry traces. 9 attack types.')
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS dim_attack_type (
    attack_id       SMALLSERIAL PRIMARY KEY,
    unified_label   VARCHAR(100) NOT NULL UNIQUE,
    attack_family   VARCHAR(50)  NOT NULL,
    is_attack       BOOLEAN      NOT NULL DEFAULT TRUE,
    severity        SMALLINT     CHECK (severity BETWEEN 0 AND 5),
    description     TEXT
);

INSERT INTO dim_attack_type (unified_label, attack_family, is_attack, severity) VALUES
    ('BenignTraffic',      'Benign',     FALSE, 0),
    ('DDoS-UDP_Flood',     'DDoS',       TRUE,  4),
    ('DDoS-TCP_Flood',     'DDoS',       TRUE,  4),
    ('DDoS-SYN_Flood',     'DDoS',       TRUE,  4),
    ('DDoS-HTTP_Flood',    'DDoS',       TRUE,  4),
    ('DDoS-ICMP_Flood',    'DDoS',       TRUE,  3),
    ('DDoS-SlowLoris',     'DDoS',       TRUE,  3),
    ('DDoS-PSHACK',        'DDoS',       TRUE,  3),
    ('DDoS-RSTFIN',        'DDoS',       TRUE,  3),
    ('DDoS-ACK_Frag',      'DDoS',       TRUE,  3),
    ('DDoS-Generic',       'DDoS',       TRUE,  4),
    ('DoS-HTTP_Flood',     'DoS',        TRUE,  3),
    ('DoS-SYN_Flood',      'DoS',        TRUE,  3),
    ('DoS-TCP_Flood',      'DoS',        TRUE,  3),
    ('DoS-UDP_Flood',      'DoS',        TRUE,  3),
    ('DoS-Generic',        'DoS',        TRUE,  3),
    ('Recon-PortScan',     'Recon',      TRUE,  2),
    ('Recon-HostDisc',     'Recon',      TRUE,  2),
    ('Recon-OSScan',       'Recon',      TRUE,  2),
    ('Recon-PingSweep',    'Recon',      TRUE,  1),
    ('Recon-VulnScan',     'Recon',      TRUE,  2),
    ('Recon-Scanning',     'Recon',      TRUE,  2),
    ('Mirai-Greeth',       'Mirai',      TRUE,  5),
    ('Mirai-Greip',        'Mirai',      TRUE,  5),
    ('Mirai-UDPPlain',     'Mirai',      TRUE,  5),
    ('BruteForce-Dict',    'BruteForce', TRUE,  3),
    ('BruteForce-Passwd',  'BruteForce', TRUE,  3),
    ('Spoofing-DNS',       'Spoofing',   TRUE,  3),
    ('Spoofing-ARP',       'Spoofing',   TRUE,  3),
    ('Spoofing-MITM',      'Spoofing',   TRUE,  4),
    ('Web-SQLi',           'Web',        TRUE,  4),
    ('Web-XSS',            'Web',        TRUE,  3),
    ('Web-CMDi',           'Web',        TRUE,  5),
    ('Web-BrowserHij',     'Web',        TRUE,  3),
    ('Web-Upload',         'Web',        TRUE,  4),
    ('Web-Injection',      'Web',        TRUE,  4),
    ('Malware-Backdoor',   'Malware',    TRUE,  5),
    ('Malware-Ransomware', 'Malware',    TRUE,  5),
    ('Unknown',            'Unknown',    TRUE,  NULL)
ON CONFLICT DO NOTHING;


CREATE TABLE IF NOT EXISTS dim_protocol (
    protocol_id     SMALLSERIAL PRIMARY KEY,
    protocol_code   SMALLINT    NOT NULL UNIQUE,
    protocol_name   VARCHAR(10) NOT NULL
);

INSERT INTO dim_protocol (protocol_code, protocol_name) VALUES
    (0,  'OTHER'),
    (1,  'ICMP'),
    (6,  'TCP'),
    (17, 'UDP')
ON CONFLICT DO NOTHING;


-- ─────────────────────────────────────────────
-- FACT TABLES
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS fact_network_flow (
    flow_id          BIGSERIAL PRIMARY KEY,
    source_id        SMALLINT  REFERENCES dim_dataset_source(source_id),
    attack_id        SMALLINT  REFERENCES dim_attack_type(attack_id),
    protocol_id      SMALLINT  REFERENCES dim_protocol(protocol_id),
    phase            SMALLINT  DEFAULT 1,
    duration         DOUBLE PRECISION,
    src_bytes        DOUBLE PRECISION,
    dst_bytes        DOUBLE PRECISION,
    total_bytes      DOUBLE PRECISION,
    src_pkts         DOUBLE PRECISION,
    dst_pkts         DOUBLE PRECISION,
    total_pkts       DOUBLE PRECISION,
    flow_rate        DOUBLE PRECISION,
    syn_flag         DOUBLE PRECISION,
    ack_flag         DOUBLE PRECISION,
    fin_flag         DOUBLE PRECISION,
    rst_flag         DOUBLE PRECISION,
    cic_iat          DOUBLE PRECISION,
    cic_magnitude    DOUBLE PRECISION,
    cic_weight       DOUBLE PRECISION,
    ton_conn_state   VARCHAR(20),
    ton_dns_query    VARCHAR(255),
    unified_label    VARCHAR(100),
    attack_family    VARCHAR(50),
    is_attack        BOOLEAN,
    ingest_timestamp TIMESTAMP DEFAULT NOW(),
    source_file      VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_fact_attack    ON fact_network_flow(attack_id);
CREATE INDEX IF NOT EXISTS idx_fact_source    ON fact_network_flow(source_id);
CREATE INDEX IF NOT EXISTS idx_fact_protocol  ON fact_network_flow(protocol_id);
CREATE INDEX IF NOT EXISTS idx_fact_family    ON fact_network_flow(attack_family);
CREATE INDEX IF NOT EXISTS idx_fact_is_attack ON fact_network_flow(is_attack);
CREATE INDEX IF NOT EXISTS idx_fact_phase     ON fact_network_flow(phase);


CREATE TABLE IF NOT EXISTS fact_ml_predictions (
    pred_id              BIGSERIAL PRIMARY KEY,
    flow_id              BIGINT REFERENCES fact_network_flow(flow_id),
    model_name           VARCHAR(50),
    model_version        VARCHAR(20),
    train_dataset        VARCHAR(20),
    test_dataset         VARCHAR(20),
    true_label           VARCHAR(100),
    predicted_label      VARCHAR(100),
    predicted_family     VARCHAR(50),
    confidence           DOUBLE PRECISION,
    is_correct           BOOLEAN,
    binary_true          BOOLEAN,
    binary_pred          BOOLEAN,
    binary_correct       BOOLEAN,
    prediction_timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pred_model   ON fact_ml_predictions(model_name);
CREATE INDEX IF NOT EXISTS idx_pred_correct ON fact_ml_predictions(is_correct);


-- ─────────────────────────────────────────────
-- ANALYTICS VIEWS
-- ─────────────────────────────────────────────

CREATE OR REPLACE VIEW vw_attack_distribution AS
SELECT
    d.source_name,
    f.attack_family,
    f.unified_label,
    f.phase,
    COUNT(*) AS flow_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY d.source_name), 2) AS pct_of_source
FROM fact_network_flow f
JOIN dim_dataset_source d ON f.source_id = d.source_id
GROUP BY d.source_name, f.attack_family, f.unified_label, f.phase
ORDER BY d.source_name, flow_count DESC;


CREATE OR REPLACE VIEW vw_protocol_distribution AS
SELECT
    p.protocol_name,
    f.attack_family,
    COUNT(*) AS flow_count
FROM fact_network_flow f
JOIN dim_protocol p ON f.protocol_id = p.protocol_id
GROUP BY p.protocol_name, f.attack_family
ORDER BY flow_count DESC;


CREATE OR REPLACE VIEW vw_top_attacks AS
SELECT
    unified_label,
    attack_family,
    phase,
    COUNT(*) AS total_flows,
    ROUND(AVG(total_bytes)::numeric, 2) AS avg_bytes,
    ROUND(AVG(duration)::numeric, 6)   AS avg_duration
FROM fact_network_flow
WHERE is_attack = TRUE
GROUP BY unified_label, attack_family, phase
ORDER BY total_flows DESC
LIMIT 10;


CREATE OR REPLACE VIEW vw_model_performance AS
SELECT
    model_name,
    train_dataset,
    test_dataset,
    COUNT(*) AS total_predictions,
    SUM(CASE WHEN binary_correct THEN 1 ELSE 0 END) AS binary_correct_count,
    ROUND(AVG(CASE WHEN binary_correct THEN 1.0 ELSE 0.0 END) * 100, 2) AS binary_accuracy_pct,
    ROUND(AVG(CASE WHEN is_correct    THEN 1.0 ELSE 0.0 END) * 100, 2) AS multiclass_accuracy_pct
FROM fact_ml_predictions
GROUP BY model_name, train_dataset, test_dataset
ORDER BY binary_accuracy_pct DESC;
