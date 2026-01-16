# 🏥 Healthcare Operations, Financial & Risk Analytics

## 📌 Project Overview
Hospitals manage complex operations involving patient flow, billing, insurance claims, and critical care resources. However, decision-making is often fragmented across operational, financial, and administrative teams, making it difficult to clearly identify resource bottlenecks, revenue exposure, and high-risk patient segments.

This project builds an end-to-end analytics solution using SQL and Power BI to analyze hospital operations, financial performance, and patient risk. The focus is on operational efficiency, revenue risk, and resource utilization rather than clinical diagnosis.

---

## 🎯 Business Problems Solved
This project addresses the following key business challenges:

- Identifying departments with high operational strain due to longer length of stay and ICU usage  
- Quantifying revenue at risk from pending and partial payments  
- Analyzing insurance dependency and payment behavior affecting cash flow  
- Segmenting patients into risk categories based on operational and utilization factors  
- Detecting billing anomalies that may require audit review  

---

## 📊 Dataset Description
The analysis uses a synthetic healthcare dataset designed to simulate real-world hospital operations and billing workflows.

### Tables Included:
- `patients` – demographics, lifestyle factors, chronic conditions  
- `admissions` – department, severity, ICU requirement, length of stay  
- `treatment` – treatment type, outcome, cost  
- `billing` – total cost, payment status, insurance coverage  

> **Note:** No real patient data is used. The dataset is synthetic and privacy-safe.

---

## 🧠 Analytical Approach

### SQL (PostgreSQL)
- Schema design and table creation  
- Complex joins, CTEs, and window functions  
- Department-level and patient-level metrics  
- SQL views for reusable business logic  
- Rule-based patient risk scoring implemented at the data layer  

### Power BI
- Interactive dashboards  
- KPI tracking and drill-down analysis  
- Risk-focused visual storytelling  
- Clear separation of operational, financial, and patient risk views  

---

## ⚠️ Risk Analysis Framework
The project evaluates three major types of risk:

### 1️⃣ Operational Risk
- Length of stay (LOS)  
- ICU utilization  
- Department-wise patient load  
- Admission trends over time  

### 2️⃣ Financial & Insurance Risk
- Revenue at risk (Pending and Partial payments)  
- Payment status distribution  
- Insurance coverage dependency  
- Collection efficiency by department  

### 3️⃣ Patient & Resource Utilization Risk
- Rule-based patient risk scoring using:
  - Age  
  - Chronic disease  
  - BMI  
  - Smoking status  
  - ICU history  
- Segmentation into Low, Medium, and High risk categories  
- ICU usage and LOS analysis by risk group  

---

## 📈 Dashboard Structure

### Page 1 – Hospital Operations Overview
- Admissions trend  
- Average length of stay  
- Department-wise patient load  
- ICU utilization overview  

### Page 2 – Financial & Insurance Risk
- Total revenue vs revenue at risk  
- Payment status distribution  
- Insurance coverage analysis  
- Revenue leakage identification  

### Page 3 – Patient Risk & Resource Utilization
- Patient risk category distribution  
- ICU usage by risk group  
- Admissions and LOS by age group  
- High-risk patient concentration  

---

## 🔍 Key Insights
- A small group of high-risk patients consumes a disproportionate share of ICU and hospital resources  
- Significant revenue remains exposed due to pending and partial payments  
- Certain departments consistently show higher operational strain, indicating capacity planning needs  
- Risk-based segmentation supports proactive intervention and better resource allocation  

---

## 🛠️ Tools & Technologies
- SQL (PostgreSQL)  
- Power BI  
- Excel  

---

## 📎 Disclaimer
This project focuses on operational, financial, and utilization risk.  
It does not perform clinical diagnosis, medical prediction, or AI-based health outcomes.

---

## 🚀 Why This Project Matters
This analysis demonstrates how healthcare data can be leveraged to improve operational efficiency, reduce revenue leakage, identify high-risk patient segments, and support data-driven hospital management and consulting decisions.

---

## 📷 Dashboard Preview
Dashboard screenshots are available in the `/screenshots` folder.


## Rohith Pawar
Linkedin : https://www.linkedin.com/in/rohith-pawar-557293346/
mail : rohitvilaspawar1@gmail.com
