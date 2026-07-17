-- ============================================================
-- SentinelMesh | Step 3: Facts, Dimensions & KPI Views
-- ============================================================

-- ============================================================
-- DIMENSION: dim_attack_type
-- ============================================================
DROP TABLE IF EXISTS dim_attack_type CASCADE;
CREATE TABLE dim_attack_type AS
SELECT
    ROW_NUMBER() OVER (ORDER BY unified_label) AS attack_type_id,
    unified_label,
    attack_family,
    CASE
        WHEN unified_label = 'BenignTraffic' THEN FALSE
        ELSE TRUE
    END AS is_malicious,
    CASE
        WHEN attack_family = 'DDoS'        THEN 'High'
        WHEN attack_family = 'DoS'         THEN 'High'
        WHEN attack_family = 'Malware'     THEN 'Critical'
        WHEN attack_family = 'Brute Force' THEN 'Medium'
        WHEN attack_family = 'Recon'       THEN 'Low'
        WHEN attack_family = 'Spoofing'    THEN 'Medium'
        WHEN attack_family = 'Web'         THEN 'High'
        WHEN attack_family = 'Mirai'       THEN 'Critical'
        ELSE 'Unknown'
    END AS severity
FROM stg_harmonized
GROUP BY unified_label, attack_family;

-- ============================================================
-- DIMENSION: dim_protocol
-- ============================================================
DROP TABLE IF EXISTS dim_protocol CASCADE;
CREATE TABLE dim_protocol AS
SELECT
    ROW_NUMBER() OVER (ORDER BY protocol) AS protocol_id,
    protocol,
    CASE
        WHEN protocol ILIKE '%tcp%' THEN 'TCP'
        WHEN protocol ILIKE '%udp%' THEN 'UDP'
        WHEN protocol ILIKE '%icmp%' THEN 'ICMP'
        WHEN protocol ILIKE '%arp%' THEN 'ARP'
        ELSE 'Other'
    END AS protocol_group
FROM stg_harmonized
GROUP BY protocol;

-- ============================================================
-- FACT TABLE: fact_network_events
-- ============================================================
DROP TABLE IF EXISTS fact_network_events CASCADE;
CREATE TABLE fact_network_events AS
SELECT
    s.id                          AS event_id,
    d.attack_type_id,
    p.protocol_id,
    s.phase,
    s.dataset_source,
    s.is_attack,
    s.attack_family,
    s.unified_label,
    s.flow_rate_byts_s,
    s.flow_rate_pkts_s,
    s.syn_flag,
    s.ack_flag,
    s.fin_flag,
    s.rst_flag,
    s.ingest_timestamp
FROM stg_harmonized s
LEFT JOIN dim_attack_type d USING (unified_label)
LEFT JOIN dim_protocol    p USING (protocol);

-- ============================================================
-- KPI VIEW 1: vw_attack_trend_by_family
-- ============================================================
DROP VIEW IF EXISTS vw_attack_trend_by_family;
CREATE VIEW vw_attack_trend_by_family AS
SELECT
    attack_family,
    unified_label,
    COUNT(*)                          AS total_events,
    SUM(is_attack::int)               AS attack_count,
    ROUND(AVG(is_attack::int) * 100, 2) AS attack_pct
FROM fact_network_events
GROUP BY attack_family, unified_label
ORDER BY attack_count DESC;

-- ============================================================
-- KPI VIEW 2: vw_protocol_risk
-- ============================================================
DROP VIEW IF EXISTS vw_protocol_risk;
CREATE VIEW vw_protocol_risk AS
SELECT
    p.protocol,
    p.protocol_group,
    COUNT(*)                              AS total_flows,
    SUM(f.is_attack::int)                 AS attack_flows,
    ROUND(SUM(f.is_attack::int) * 100.0
          / COUNT(*), 2)                  AS attack_rate_pct
FROM fact_network_events f
JOIN dim_protocol p USING (protocol_id)
GROUP BY p.protocol, p.protocol_group
ORDER BY attack_rate_pct DESC;

-- ============================================================
-- KPI VIEW 3: vw_severity_summary
-- ============================================================
DROP VIEW IF EXISTS vw_severity_summary;
CREATE VIEW vw_severity_summary AS
SELECT
    d.severity,
    d.attack_family,
    COUNT(*)           AS total_events,
    SUM(f.is_attack::int) AS confirmed_attacks
FROM fact_network_events f
JOIN dim_attack_type d USING (attack_type_id)
WHERE f.is_attack = TRUE
GROUP BY d.severity, d.attack_family
ORDER BY
    CASE d.severity
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 2
        WHEN 'Medium'   THEN 3
        WHEN 'Low'      THEN 4
        ELSE 5
    END;
