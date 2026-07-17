import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sqlalchemy import create_engine, text

# ── Page setup ────────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="SentinelMesh Dashboard",
    page_icon="🛡️",
    layout="wide"
)

st.title("🛡️ SentinelMesh — IoT Attack Command Centre")
st.caption("Phase 2 dashboard powered by PostgreSQL tables: stg_harmonized, fact_device_risk_daily, fact_attack_timeline")

# ── Database connection ───────────────────────────────────────────────────────
@st.cache_resource
def get_engine():
    return create_engine("postgresql://sentinel_user:sentinel_pass@localhost:5432/sentinelmesh_db")

engine = get_engine()

# ── Load data ─────────────────────────────────────────────────────────────────
@st.cache_data(ttl=60)
def load_data():
    with engine.connect() as con:
        df_risk = pd.read_sql("SELECT * FROM fact_device_risk_daily", con)
        df_timeline = pd.read_sql("SELECT * FROM fact_attack_timeline", con)

        summary = con.execute(text("""
            SELECT
                COUNT(*) AS total_flows,
                SUM(CASE WHEN is_attack THEN 1 ELSE 0 END) AS attack_flows,
                SUM(CASE WHEN NOT is_attack THEN 1 ELSE 0 END) AS benign_flows,
                COUNT(DISTINCT unified_label) AS unique_labels
            FROM stg_harmonized
        """)).mappings().first()

    return df_risk, df_timeline, summary

df_risk, df_timeline, summary = load_data()

df_risk["risk_date"] = pd.to_datetime(df_risk["risk_date"])
df_timeline["event_date"] = pd.to_datetime(df_timeline["event_date"])

# ── Sidebar filters ───────────────────────────────────────────────────────────
st.sidebar.header("Filters")

sources = ["All"] + sorted(df_risk["dataset_source"].dropna().unique().tolist())
selected_source = st.sidebar.selectbox("Dataset Source", sources)

tiers = sorted(df_risk["risk_tier"].dropna().unique().tolist())
selected_tiers = st.sidebar.multiselect("Risk Tier", tiers, default=tiers)

families = ["All"] + sorted(df_timeline["attack_family"].dropna().unique().tolist())
selected_family = st.sidebar.selectbox("Attack Family", families)

min_date = df_risk["risk_date"].min().date()
max_date = df_risk["risk_date"].max().date()
date_range = st.sidebar.date_input("Date Range", value=(min_date, max_date), min_value=min_date, max_value=max_date)

# ── Apply filters ─────────────────────────────────────────────────────────────
if len(date_range) == 2:
    start_date, end_date = pd.to_datetime(date_range[0]), pd.to_datetime(date_range[1])
else:
    start_date, end_date = df_risk["risk_date"].min(), df_risk["risk_date"].max()

risk_filtered = df_risk[
    (df_risk["risk_date"] >= start_date) &
    (df_risk["risk_date"] <= end_date)
]

timeline_filtered = df_timeline[
    (df_timeline["event_date"] >= start_date) &
    (df_timeline["event_date"] <= end_date)
]

if selected_source != "All":
    risk_filtered = risk_filtered[risk_filtered["dataset_source"] == selected_source]
    timeline_filtered = timeline_filtered[timeline_filtered["dataset_source"] == selected_source]

if selected_tiers:
    risk_filtered = risk_filtered[risk_filtered["risk_tier"].isin(selected_tiers)]

if selected_family != "All":
    timeline_filtered = timeline_filtered[timeline_filtered["attack_family"] == selected_family]

# ── KPI row ───────────────────────────────────────────────────────────────────
k1, k2, k3, k4 = st.columns(4)
k1.metric("Total Flows", f"{int(summary['total_flows']):,}")
k2.metric("Attack Flows", f"{int(summary['attack_flows']):,}")
k3.metric("Benign Flows", f"{int(summary['benign_flows']):,}")
k4.metric("Unique Attack Labels", f"{int(summary['unique_labels']):,}")

st.divider()

# ── Panel 1: Risk Tier Overview ───────────────────────────────────────────────
# ── Panel 2: Attack Timeline ──────────────────────────────────────────────────
col1, col2 = st.columns(2)

with col1:
    st.subheader("1. Risk Tier Overview")
    tier_counts = risk_filtered["risk_tier"].value_counts().reset_index()
    tier_counts.columns = ["risk_tier", "records"]

    fig1 = px.pie(
        tier_counts,
        names="risk_tier",
        values="records",
        hole=0.45,
        color="risk_tier",
        color_discrete_map={
            "Critical": "#ef4444",
            "High": "#f97316",
            "Medium": "#eab308",
            "Low": "#22c55e"
        }
    )
    st.plotly_chart(fig1, use_container_width=True)

with col2:
    st.subheader("2. Attack Timeline")
    timeline_daily = (
        timeline_filtered.groupby(["event_date", "attack_family"])["flow_count"]
        .sum()
        .reset_index()
    )

    fig2 = px.line(
        timeline_daily,
        x="event_date",
        y="flow_count",
        color="attack_family",
        markers=False
    )
    fig2.update_layout(xaxis_title="Date", yaxis_title="Attack Flows")
    st.plotly_chart(fig2, use_container_width=True)

# ── Panel 3: Top Risk Devices ────────────────────────────────────────────────
# ── Panel 4: Attack Family by Source ──────────────────────────────────────────
col3, col4 = st.columns(2)

with col3:
    st.subheader("3. Top 10 Highest Risk Devices")
    top_devices = (
        risk_filtered.groupby("device_id")
        .agg(avg_risk_score=("risk_score", "mean"))
        .reset_index()
        .sort_values("avg_risk_score", ascending=False)
        .head(10)
    )

    fig3 = px.bar(
        top_devices,
        x="avg_risk_score",
        y="device_id",
        orientation="h",
        color="avg_risk_score",
        color_continuous_scale="Reds"
    )
    fig3.update_layout(xaxis_title="Average Risk Score", yaxis_title="Device ID", yaxis=dict(autorange="reversed"))
    st.plotly_chart(fig3, use_container_width=True)

with col4:
    st.subheader("4. Attack Family Breakdown by Source")
    family_source = (
        timeline_filtered.groupby(["dataset_source", "attack_family"])["flow_count"]
        .sum()
        .reset_index()
    )

    fig4 = px.bar(
        family_source,
        x="attack_family",
        y="flow_count",
        color="dataset_source",
        barmode="stack"
    )
    fig4.update_layout(xaxis_title="Attack Family", yaxis_title="Flow Count")
    st.plotly_chart(fig4, use_container_width=True)

# ── Panel 5: Top Attack Labels ────────────────────────────────────────────────
# ── Panel 6: Device Risk Trend ────────────────────────────────────────────────
col5, col6 = st.columns(2)

with col5:
    st.subheader("5. Top Attack Labels")
    top_labels = (
        timeline_filtered.groupby("unified_label")["flow_count"]
        .sum()
        .reset_index()
        .sort_values("flow_count", ascending=False)
        .head(12)
    )

    fig5 = px.bar(
        top_labels,
        x="flow_count",
        y="unified_label",
        orientation="h",
        color="flow_count",
        color_continuous_scale="Viridis"
    )
    fig5.update_layout(xaxis_title="Flow Count", yaxis_title="Attack Label", yaxis=dict(autorange="reversed"))
    st.plotly_chart(fig5, use_container_width=True)

with col6:
    st.subheader("6. Device Risk Trend")
    selected_device = st.selectbox(
        "Select device",
        sorted(risk_filtered["device_id"].dropna().unique().tolist())
    )

    device_trend = (
        risk_filtered[risk_filtered["device_id"] == selected_device]
        .sort_values("risk_date")
    )

    fig6 = go.Figure()
    fig6.add_trace(go.Scatter(
        x=device_trend["risk_date"],
        y=device_trend["risk_score"],
        mode="lines+markers",
        name=selected_device
    ))
    fig6.update_layout(
        xaxis_title="Date",
        yaxis_title="Risk Score",
        yaxis_range=[0, 100]
    )
    st.plotly_chart(fig6, use_container_width=True)

# ── Optional raw table ────────────────────────────────────────────────────────
st.divider()
st.subheader("Filtered Device Risk Records")

show_cols = [
    "device_id", "risk_date", "dataset_source", "risk_tier",
    "risk_score", "attack_flows", "benign_flows",
    "attack_ratio", "top_attack_family", "dominant_protocol"
]

st.dataframe(
    risk_filtered[show_cols].sort_values("risk_score", ascending=False),
    use_container_width=True,
    height=350
)
