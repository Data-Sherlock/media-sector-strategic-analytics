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
