# Technology, Automation, and Inequality: A Forecasting Comparison

## Project Summary
This research investigates the relationship between **Robot Density** (ICT Capital Share) and **Income Inequality** (S80/S20 ratio) across Europe. I compare traditional **Fixed Effects Econometrics** with **Machine Learning ensembles** (Random Forest, XGBoost, LASSO) to determine which methodology better captures non-linear displacement effects.

## Key Findings
- **Job Polarization:** Evidence of a "U-shaped" shift where middle-skilled employment declines relative to high and low-skilled tiers.
- **Predictive Performance:** Non-linear models (XGBoost) outperformed linear benchmarks in RMSE, suggesting complex threshold effects in technological adoption.

## Methodology Preview
![Digital Divide](figures/Fig1_Digital_Divide.png)
*Figure 1: Visualizing the gap between Tech Leaders (North) and Laggards (South).*

## How to Reproduce
1. Clone this repo.
2. Ensure R packages `pacman`, `tidyverse`, and `randomForest` are installed.
3. Run `scripts/01_descriptive_analysis.R`.
