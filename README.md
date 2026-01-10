# 📰 Bharat Herald: Legacy Media Digital Transformation Strategy
> **Quantifying a 53% circulation drop to engineer a data-backed relaunch roadmap.**

[![SQL](https://img.shields.io/badge/Language-MySQL-orange.svg)](https://www.mysql.com/)
[![BI Tool](https://img.shields.io/badge/Visualization-Power_BI-yellow.svg)](https://powerbi.microsoft.com/)
[![DAX](https://img.shields.io/badge/Logic-DAX-blue.svg)](#)
[![Status](https://img.shields.io/badge/Project-Strategic_Analysis-green.svg)](#)

## 🏢 Business Context
Bharat Herald, a 70-year-old legacy newspaper, faced an existential crisis between 2019 and 2024. Print circulation plummeted from **1.2M to 560K** daily copies. This project provides a phased recovery roadmap for the Executive Director, Tony Sharma, focusing on identifying recovery potential and digital readiness.

## 🛠️ Technical Implementation

### 1. Data Engineering (SQL)
Aggregated 6 years of fragmented operational data. Key technical challenges included:
* **Time-Series Logic:** Utilizing `LAG()` and `PARTITION BY` to detect strictly decreasing sequences in multi-year circulation.
* **Granularity Reconciliation:** Joining city-specific print sales (monthly) with market-wide ad revenue (quarterly).

### 2. Advanced Analytics (DAX)
Engineered a **Priority Index** to rank cities for digital migration:

```dax
Priority Score = 
VAR Readiness = [Avg_Digital_Readiness]
VAR Decline = [YoY_Print_Decline_Rate]
VAR EngagementGap = 1 - [Digital_Pilot_Engagement]
RETURN
DIVIDE(Readiness + Decline + EngagementGap, 3)
```

## 🔍 Strategic Insights

**The Kanpur Paradox:** Identified **Kanpur** as the #1 relaunch candidate (**53.07% Priority Score**). Despite a current UX gap, it boasts the highest infrastructure readiness (**75.10%**), representing the greatest "unlocked" potential.

**Revenue Anchor:** Ad revenue (**1.60bn**) remains heavily reliant on **Government (478M)** and **Real Estate (472M)**). Conversely, high-growth sectors like FMCG show a rapid exit from print, signaling a need for digital-native ad units.

**Efficiency Audit:** 2024 analysis revealed a **17.53% Print Efficiency** ratio. This audit identified massive capital waste in physical distribution, providing a clear fiscal justification for the digital pivot.

## 📊 Project Deliverables

| Module | Key Metrics Analyzed | Business Impact |
| :--- | :--- | :--- |
| **Print Performance** | Net Circulation, Print Efficiency | Identified distribution waste & "bleeding" cities. |
| **Ad Revenue** | Category-wise Concentration | Risk assessment of ad-spend & revenue stability. |
| **Digital Pilot** | Bounce Rate, User Adaptation | Diagnosed 2021 failure as a Product/UX issue. |
| **Relaunch Priority** | Readiness vs. Decline Matrix | Data-backed strategy for phased market entry. |

## 🚀 Final Roadmap

* **Phase 1 (Immediate):** Digital-first relaunch in **Kanpur & Ranchi** to capture high-readiness markets.
* **Phase 2 (UX Fix):** Comprehensive overhaul of the **Mobile App Beta** to combat the **65.77%** average bounce rate.
* **Phase 3 (Cost Recovery):** Phased shutdown of physical print bureaus in cities with **<15% efficiency** to reallocate capital to digital infrastructure.
