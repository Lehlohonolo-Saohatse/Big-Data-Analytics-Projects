library(tidyverse)
library(caret)

set.seed(42)

churn <- read.csv("customer_churn_dataset.csv",stringsAsFactors = FALSE)

# Question 4
# 4.1

head(churn)
str(churn)
sapply(churn, class)

# 4.2

table(churn$Churn)
prop.table(table(churn$Churn)) * 100

churn$Churn <- factor(
  churn$Churn,
  levels = c(0, 1)
)

# 80/20 split
train_index <- createDataPartition(
  churn$Churn,
  p = 0.80,
  list = FALSE
)

train <- churn[train_index, ]
test  <- churn[-train_index, ]

predictor_names <- setdiff(names(churn), "Churn")

train_means <- sapply(train[predictor_names], mean)
train_sds   <- sapply(train[predictor_names], sd)

train_scaled <- train
train_scaled[predictor_names] <- scale(
  train[predictor_names],
  center = train_means,
  scale = train_sds
)

test_scaled <- test

test_scaled[predictor_names] <- sweep(
  test[predictor_names],
  2,
  train_means,
  FUN = "-"
)

test_scaled[predictor_names] <- sweep(
  test_scaled[predictor_names],
  2,
  train_sds,
  FUN = "/"
)

dim(train_scaled)
dim(test_scaled)

# 4.3
# logistic regression model
log_model <- glm(
  Churn ~ .,
  data = train_scaled,
  family = binomial(link = "logit")
)

summary(log_model)

pred_prob <- predict(
  log_model,
  newdata = test_scaled,
  type = "response"
)

pred_class <- ifelse(
  pred_prob >= 0.5,
  1,
  0
)

pred_class <- factor(
  pred_class,
  levels = c(0, 1)
)

actual_class <- test_scaled$Churn

confusionMatrix(
  data = pred_class,
  reference = actual_class,
  positive = "1"
)

accuracy <- mean(pred_class == actual_class)

precision <- sum(
  pred_class == "1" & actual_class == "1"
) / sum(pred_class == "1")

recall <- sum(
  pred_class == "1" & actual_class == "1"
) / sum(actual_class == "1")

accuracy
precision
recall

'''
The model achieves an overall classification accuracy of approximately 89.05%. This means that about 89 out of every 100 test customers are classified correctly.

The precision of 78.85% means that among customers predicted to churn, approximately 79% actually churned.

The recall of 41.41% is considerably lower. This means the model identifies only about 41% of the customers who actually churn.

This distinction is important. A model can achieve relatively high accuracy simply because the dataset contains many non-churned customers. Since only 15.71% of the customers actually churn, accuracy alone does not provide a sufficient assessment of a churn-prediction system.

For a telecom company, recall is particularly important because failing to identify a customer who is about to churn may result in lost revenue and a missed retention opportunity.


'''

# 4.4
coefficients <- coef(log_model)

coefficients <- coefficients[-1]

importance_df <- data.frame(
  Variable = names(coefficients),
  Coefficient = as.numeric(coefficients)
)

importance_df$Absolute_Coefficient <-
  abs(importance_df$Coefficient)

importance_df <- importance_df[
  order(
    importance_df$Absolute_Coefficient,
    decreasing = TRUE
  ),
]

importance_df

ggplot(
  importance_df,
  aes(
    x = reorder(Variable, Absolute_Coefficient),
    y = Absolute_Coefficient
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Feature Importance Based on Absolute Logistic Regression Coefficients",
    x = "Predictor Variable",
    y = "Absolute Logistic Regression Coefficient"
  ) +
  theme_minimal()

ggplot(
  importance_df,
  aes(
    x = reorder(
      Variable,
      Absolute_Coefficient
    ),
    y = Absolute_Coefficient
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Feature Contribution to Customer Churn",
    x = "Coefficient Name",
    y = "Absolute Coefficient"
  ) +
  theme_minimal()
