# ==============================================================================
# SCRIPT 2: MACHINE LEARNING & FORECASTING
# ==============================================================================
pacman::p_load(tidyverse, randomForest, xgboost, caret, glmnet)

df_educ <- read.csv("data/Final_Panel_Education.csv")

# 1. PREPARE DATA
data_ml <- df_educ %>%
  filter(Year >= 2003, Country_Code != "UK") %>%
  select(Income_Share_S80S20, Robot_Density_Proxy, Employment_Thousands, Year) %>%
  na.omit()

set.seed(123)
index <- createDataPartition(data_ml$Income_Share_S80S20, p = 0.8, list = FALSE)
train_data <- data_ml[index, ]
test_data  <- data_ml[-index, ]

# 2. RANDOM FOREST & FEATURE IMPORTANCE
rf_model <- randomForest(Income_Share_S80S20 ~ ., data = train_data, importance = TRUE)
var_imp <- importance(rf_model)
df_imp <- data.frame(Variable = row.names(var_imp), Importance = var_imp[, "%IncMSE"])

p5 <- ggplot(df_imp, aes(x = reorder(Variable, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + labs(title = "Figure 5: Drivers of Inequality")
ggsave("figures/Fig5_ML_Importance.png", plot=p5, width=8, height=5)

# 3. XGBOOST & MODEL COMPARISON
dtrain <- xgb.DMatrix(data = x_train, label = y_train)
dtest  <- xgb.DMatrix(data = x_test, label = y_test)
xgb_model <- xgboost(data = dtrain, nrounds = 100, objective = "reg:squarederror", verbose = 0)
pred_xgb <- predict(xgb_model, dtest)
rmse_xgb <- sqrt(mean((y_test - pred_xgb)^2))

# 4. LASSO REGRESSION (Regularized Linear)
# Alpha = 1 for LASSO
lasso_model <- cv.glmnet(x_train, y_train, alpha = 1)
pred_lasso <- predict(lasso_model, s = lasso_model$lambda.min, newx = x_test)
rmse_lasso <- sqrt(mean((y_test - pred_lasso)^2))

# 5. RIDGE REGRESSION (Regularized Linear)
# Alpha = 0 for Ridge
ridge_model <- cv.glmnet(x_train, y_train, alpha = 0)
pred_ridge <- predict(ridge_model, s = ridge_model$lambda.min, newx = x_test)
rmse_ridge <- sqrt(mean((y_test - pred_ridge)^2))

# FINAL COMPARISON GRAPH (FIGURE 8)
comparison <- data.frame(
  Method = c("Random Forest", "XGBoost", "LASSO", "Ridge"),
  RMSE = c(rmse_rf, rmse_xgb, rmse_lasso, rmse_ridge)
)

p_comp <- ggplot(comparison, aes(x = reorder(Method, RMSE), y = RMSE, fill = Method)) +
  geom_bar(stat = "identity", width = 0.6) +
  labs(title = "Figure 7: Linear vs Non-Linear ML Forecasting Accuracy",
       subtitle = "Comparison of RMSE",
       y = "Root Mean Square Error (RMSE)", x = "Model Type") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2") +
  theme(legend.position = "none")

