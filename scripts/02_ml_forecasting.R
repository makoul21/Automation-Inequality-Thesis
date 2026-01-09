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
# (The rest of your comparison code goes here, using ggsave to "figures/")
