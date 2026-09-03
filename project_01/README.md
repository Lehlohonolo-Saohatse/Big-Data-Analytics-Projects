# Real Estate Valuation, Cement Demand Forecasting & Telecom Churn

## Project Overview

This repository houses the analytical solutions, programmatic data cleaning routines, exploratory data analysis, and predictive modeling scripts for **Project One** of the Big Data Analytics curriculum. The project spans three distinct real-world business scenarios:

* **FxProperty Valuation (Questions 1 & 2):** Developing an automated, data-driven house valuation framework for a Middle Eastern real estate agency using historical listing data (`fxproperty_valuation.csv.csv`).
* **UBM Cement Demand Forecasting (Question 3):** Analyzing seasonal fluctuations and building a time-series forecasting model to optimize logistics and stocking operations for a retail cement company in Western Africa (`UMB_cement_data.csv`).
* **Telecom Churn Analysis (Question 4):** Applying data mining and predictive classification techniques to identify key customer churn drivers, handling numeric feature conversion, data scaling, and evaluating logistic regression feature weights (`customer_churn_dataset.csv`).

---

## Repository Structure

```text
big-data-project-one/
│
├── data/
│   ├── fxproperty_valuation.csv.csv
│   ├── UBM_cement_data.csv
│   └── customer_churn_dataset.csv
│
├── scripts/
│   ├── fxproperty_analysis.R
│   ├── ubm_cement_forecasting.R
│   └── telecom_churn_analysis.R
│
├── outputs/
│   └── plots/
│
└── README.md

```

---

## Technical Implementation & Methodology

### **Part 1: Real Estate Analysis & Valuation (FxProperty)**

1. **Data Preparation & Cleaning (1.1):**
* Inspected raw schema structures, missing values, and variance attributes programmatically.
* Identified and handled missing values in the regulatory permit column (`rera`) via column deletion, as it represents an administrative ID missing ~34% of entries rather than a market-driven variable.
* Detected and removed 57 hidden duplicate listings and eliminated zero-variance attributes (`bathrooms`, `type`, `propertyType`, and system IDs).


2. **Feature Engineering & EDA (1.2):**
* Parsed structured geographic attributes from the text-based `displayAddress` string, extracting specific communities and cities.
* Extracted temporal variables from timestamps (calculating listing age/days listed).
* Generated data distributions (histograms, bar plots) and performed correlation analyses (e.g., evaluating the positive linear relationship between bedrooms and property prices).


3. **Predictive Modelling (Question 2):**
* One-hot encoded categorical community features and normalized continuous numerical predictors via Z-score standardization.
* Built a robust non-linear **Random Forest** predictive model optimized using 5-fold cross-validation.
* Reported statistical variance (RMSE, $R^2$, MAE) across folds and generated Goodness of Fit actual-vs-predicted regression visualisations.
* Assessed feature importance and outlined critical recommendations (such as log-transforming right-skewed prices and integrating square footage).



### **Part 2: Time Series Cement Demand Forecasting (UBM)**

1. **Time-Series Line Chart (3.1):** Loaded monthly records and constructed a fully labeled chronological line chart illustrating historical seasonal sales volume fluctuations.
2. **Model Order Selection (3.2):** Built a seasonal time-series model leveraging **Seasonal ARIMA (SARIMA)**, computationally selecting the optimal parameter configuration using the Akaike Information Criterion (AIC).
3. **Forecasting (3.3):** Appended a 6-month out-of-sample predictive forecast with confidence bounds to the historical time series.

### **Part 3: Telecom Churn Analysis**

1. **Data Loading & Numeric Verification (4.1):** Loaded the telecom dataset and validated/converted all record attributes to numeric types to prepare for downstream mathematical modeling.
2. **Normalization & Data Splitting (4.2):** Standardized numerical features using Z-score scaling and partitioned the dataset into training and test splits.
3. **Predictive Modeling & Evaluation (4.3):** Built a binary classification model (Logistic Regression) justified by its high interpretability and efficiency for binary customer churn outcomes, reporting out-of-sample precision, recall, and classification accuracy.
4. **Feature Discrimination Analysis (4.4):** Extracted logistic regression coefficients, computing absolute values to rank feature contribution strength, and visualized the results in a descending bar graph (y-axis: absolute coefficient, x-axis: coefficient names).

---

## Prerequisites & Installation

Ensure you have R and RStudio installed, along with the following required libraries:

```R
install.packages(c("dplyr", "stringr", "ggplot2", "corrplot", "caret", "randomForest", "forecast", "tseries"))

```

## Running the Scripts

1. Clone or download this repository locally.
2. Place the respective data files into your working directory or `data/` folder.
3. Open and execute the analysis scripts sequentially inside RStudio.
