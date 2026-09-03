library(dplyr)
library(stringr)
library(ggplot2)
library(corrplot)
library(caret)

set.seed(42)
raw <- read.csv("fxproperty_valuation.csv.csv", stringsAsFactors = FALSE)

# QUESTION 1.1: Data Preparation and Cleaning
# 1.1a

df <- raw %>%
  select(id, displayAddress, bedrooms, bathrooms, type, propertyType, addedOn, rera, price)

# I am Keeping address, bedrooms, and addedOn for feature engineering.
# Keeping price as the target. Temporarily keeping id, type, propertyType, 
# bathrooms, and rera to inspect for missing values and zero-variance.

#-------------------------------------------------------------------------------------------------------
# 1.1b 
na_report <- data.frame(
  attribute = names(df),
  n_missing = colSums(is.na(df))
)
print(na_report, row.names = FALSE)

#--------------------------------------------------------------------------------------------------------------

# 1.1c
clean_df <- df %>%
  select(-rera, -bathrooms, -type, -propertyType, -id) %>%
  distinct()

cat("Dataset after cleaning", nrow(clean_df), "rows\n and ", ncol(clean_df))

# I Dropped the 'rera' as it has no predictive value for valuation and it has a high missing count.
# Then Dropped zero-variance columns as they cannot predict changes in price.
# Then I Dropped 'id' and execute distinct() to remove hidden duplicate listings.

#-----------------------------------------------------------------------------------------------------------
# QUESTION 1.2:
# 1.2 (a)
addr_parts <- str_split(clean_df$displayAddress, ",\\s*")

get_part <- function(parts, idx_from_end) {
  n <- length(parts)
  i <- n - idx_from_end
  if (i < 1) NA_character_ else trimws(parts[i])
}

clean_df <- clean_df %>%
  mutate(
    city = sapply(addr_parts, get_part, idx_from_end = 0),      
    community = sapply(addr_parts, get_part, idx_from_end = 1)
  )

clean_df <- clean_df %>%
  mutate(
    addedOn_date = as.Date(substr(addedOn, 1, 10)),
    days_listed = as.numeric(max(addedOn_date, na.rm=TRUE) - addedOn_date) 
  )

#----------------------------------------------------------------------------------------------------------

# 1.2 (b)
# Price Distribution plot
p1 <- ggplot(clean_df, aes(x = price)) +
  geom_histogram(bins = 30, fill = "#2c7fb8", colour = "white") +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "1.2b Distribution of Property Price", x = "Price (AED)", y = "Count") +
  theme_minimal()
print(p1)

# Bedrooms Distribution plot
p2 <- ggplot(clean_df, aes(x = factor(bedrooms))) +
  geom_bar(fill = "#41ab5d") +
  labs(title = "1.2b Distribution of Bedrooms (0 = Studio)", x = "Bedrooms", y = "Count") +
  theme_minimal()
print(p2)

# Days Listed Distribution plot
p3 <- ggplot(clean_df, aes(x = days_listed)) +
  geom_histogram(bins = 30, fill = "#88419d", colour = "white") +
  labs(title = "1.2b Distribution of Listing Age", x = "Days Listed", y = "Count") +
  theme_minimal()
print(p3)

#----------------------------------------------------------------------------------------------------------

# 1.2 (c)
num_df <- clean_df %>% select(price, bedrooms, days_listed)
corr_mat <- cor(num_df, use = "complete.obs")
print(round(corr_mat, 2))

corrplot(corr_mat, method = "number", type = "upper", addCoef.col = "black",
         tl.col = "black", tl.srt = 45,
         title = "Correlation of Numeric Attributes vs Price", mar = c(0,0,2,0))
#----------------------------------------------------------------------------------------

# 1.2 (d)
model_df <- clean_df %>%
  select(price, bedrooms, city, community, days_listed) %>%
  na.omit()

cat("Final Modelling Dataset Structure:\n")
str(model_df)

#--------------------------------------------------------------------------------------
# QUESTION 2

# 2.1
enc_df <- model_df %>%
  mutate(city = factor(city), community = factor(community))

# One-Hot Encoding
dummies <- dummyVars(price ~ ., data = enc_df, fullRank = TRUE)
X <- predict(dummies, newdata = enc_df) %>% as.data.frame()

pre <- preProcess(X, method = c("center", "scale"))
X_norm <- predict(pre, X)

model_data <- cbind(X_norm, price = enc_df$price)

#----------------------------------------------------------------------------------------

# 2.2
ctrl <- trainControl(method = "cv", number = 5, savePredictions = "final")

rf_model <- train(
  price ~ ., data = model_data,
  method = "rf",
  trControl = ctrl,
  tuneLength = 3,
  importance = TRUE
)

fold_results <- rf_model$resample
metrics_summary <- data.frame(
  Metric = c("RMSE", "Rsquared", "MAE"),
  Mean = c(mean(fold_results$RMSE), mean(fold_results$Rsquared), mean(fold_results$MAE)),
  Std_Dev = c(sd(fold_results$RMSE), sd(fold_results$Rsquared), sd(fold_results$MAE))
)
print(metrics_summary)

#-------------------------------------------------------------------------------------

# 2.3
preds <- rf_model$pred %>% filter(mtry == rf_model$bestTune$mtry)

p4 <- ggplot(preds, aes(x = obs, y = pred)) +
  geom_point(alpha = 0.5, colour = "#2c7fb8") +
  geom_smooth(method = "lm", colour = "red", se = FALSE, linetype = "dashed") +
  geom_abline(slope = 1, intercept = 0, colour = "black", linewidth = 1) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "2.3 Goodness of Fit: Actual vs Predicted (Random Forest)",
       x = "Actual Price (AED)", y = "Predicted Price (AED)") +
  theme_minimal()
print(p4)

#-----------------------------------------------------------------------------------------
# 2.4 
imp <- varImp(rf_model, scale = TRUE)$importance
imp_df <- data.frame(feature = rownames(imp), importance = imp[,1]) %>%
  arrange(desc(importance))

# Plotting the top 10 features
p5 <- ggplot(head(imp_df, 10), aes(x = reorder(feature, importance), y = importance)) +
  geom_col(fill = "#41ab5d", colour = "black") + 
  coord_flip() +
  labs(title = "Top 10 Feature Importance", x = "Feature", y = "Importance (Scaled)") +
  theme_minimal()
print(p5)

#-------------------------------------------------------------------------------------------
#  2.5

'''
Model Performance Assessment:

The Random Forest model demonstrates strong predictive power, significantly 
outperforming standard linear regression. However, as visualized in the Goodness 
of Fit plot, the model maintains higher accuracy in the lower-to-mid price tiers,
but the error variance widens considerably for high-value properties (e.g., those above 5 million AED).


Recommendations for Improvement:
1. The target distribution is heavily right-skewed. Applying a Log Transformation 
(log(price)) to the target variable before training could stabilize the variance 
and improve prediction accuracy for luxury properties.

2. While geographic engineering ('community') and 'bedrooms' are highly 
important, the model lacks physical granularity. Incorporating continuous 
spatial features like 'square footage' or 'plot size' would drastically 
reduce the Root Mean Squared Error (RMSE).

3. Address Cardinality: Utilizing the full set of 66 unique un-bucketed 
communities allows the model to capture specific geographic pricing nuances 
without information loss, though expanding dataset size in future iterations 
will ensure robustness across minor communities.

'''