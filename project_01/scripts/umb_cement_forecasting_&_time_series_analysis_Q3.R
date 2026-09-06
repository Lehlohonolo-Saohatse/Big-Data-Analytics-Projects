library(dplyr)
library(ggplot2)
library(forecast)
library(tseries)
set.seed(42)

cement_raw <- read.csv("UMB_cement_data.csv", stringsAsFactors = FALSE)

# Question 3
# 3.1
cement_raw$Period <- as.Date(cement_raw$Period)
cement_raw <- cement_raw %>% arrange(Period)

cement_ts <- ts(cement_raw$Sales_quantity, 
                start = c(as.numeric(format(min(cement_raw$Period), "%Y")), 
                          as.numeric(format(min(cement_raw$Period), "%m"))), 
                frequency = 12)

p1 <- ggplot(cement_raw, aes(x = Period, y = Sales_quantity)) +
  geom_line(color = "#2c7fb8", linewidth = 1) +
  geom_point(color = "#1d91c0", size = 1.5) +
  labs(
    title = "Monthly Cement Sales Quantity Over Time",
    subtitle = "UBM Retail Cement Operations (Western Africa)",
    x = "Time Period (Years)",
    y = "Sales Quantity (Units)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(face = "bold")
  )

print(p1)

# 3.2
best_sarima <- auto.arima(
  cement_ts, 
  seasonal = TRUE, 
  stepwise = FALSE, 
  approximation = FALSE, 
  ic = "aic"
)

print(best_sarima)
cat(sprintf("\nModel Selection Metric Used: Akaike Information Criterion (AIC)\n"))
cat(sprintf("Best Model Order Selected (p,d,q)(P,D,Q)[s]: ARIMA%s\n", 
            paste0(as.character(best_sarima$arma[c(1,6,2,3,7,4,5)]), collapse=",")))
cat(sprintf("Final AIC Value: %.2f\n", AIC(best_sarima)))

# 3.3
forecast_horizon <- 6
cement_forecast <- forecast(best_sarima, h = forecast_horizon)

autoplot(cement_forecast) +
  labs(
    title = "UBM Cement Sales Demand: Historical & 6-Month Forecast",
    subtitle = "Seasonal ARIMA Model Projection",
    x = "Time Period",
    y = "Sales Quantity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(face = "bold")
  )