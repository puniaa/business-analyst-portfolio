############################################################
# Assignment 4 - Tech Job Openings Forecasting (JOLTS)
# Data: JOLTS Job openings rate, Information sector (NAICS 51),
#       seasonally adjusted, United States.
############################################################

#### 0. Setup ---------------------------------------------------------------

# Optional: set working directory so outputs land in your assignment folder
setwd("C:/Users/Anannya Punia/OneDrive/Desktop/DA/assignment4")

# Install these once if needed:
# install.packages(c("tidyverse", "lubridate", "forecast", "Metrics", "readxl"))

library(tidyverse)
library(lubridate)
library(forecast)
library(Metrics)
library(readxl)

# Folder for plots
plots_dir <- "plots"
if (!dir.exists(plots_dir)) dir.create(plots_dir)


#### 1. Load & tidy JOLTS data from BLS Excel ------------------------------

# Path to your JOLTS Excel file
xls_path <- "C:/Users/Anannya Punia/OneDrive/Desktop/DA/assignment4/dataset.xlsx"

# Data table starts at the row with: Year | Jan | Feb | ... | Dec | Annual
# In this file, that row is 14, so we skip the first 13 lines.
raw <- read_excel(
  xls_path,
  sheet = "BLS Data Series",
  skip  = 13
)

# Long format: Year, month, openings_rate
jolts <- raw %>%
  rename(year = 1) %>%              # first column is Year
  filter(!is.na(year)) %>%          # drop blank rows
  pivot_longer(
    cols      = -year,
    names_to  = "month_name",
    values_to = "openings_rate"
  ) %>%
  # Drop Annual column and any missing rate values
  filter(
    month_name != "Annual",
    !is.na(openings_rate)
  ) %>%
  mutate(
    year   = as.integer(year),
    month  = match(month_name, month.abb),
    date   = as.Date(sprintf("%d-%02d-01", year, month))
  ) %>%
  arrange(date) %>%
  # Drop the single Dec 2000 point; start at Jan 2001
  filter(date >= as.Date("2001-01-01")) %>%
  mutate(
    month_factor = factor(month, levels = 1:12, labels = month.abb)
  ) %>%
  select(date, year, month, month_factor, openings_rate)

# Quick checks
glimpse(jolts)
summary(jolts$openings_rate)


#### 2. Time-Series Object & Basic Plots -----------------------------------

start_year  <- year(min(jolts$date))
start_month <- month(min(jolts$date))

openings_ts <- ts(
  jolts$openings_rate,
  frequency = 12,
  start = c(start_year, start_month)
)

## 2.1 Time series plot (for "Data" slide) ---------------------------------

p_ts <- jolts %>%
  ggplot(aes(x = date, y = openings_rate)) +
  geom_line() +
  labs(
    title = "JOLTS Job Openings Rate - Information Sector",
    x = "Year",
    y = "Job openings rate"
  )

p_ts
ggsave(file.path(plots_dir, "ts_information_openings.png"),
       plot = p_ts, width = 8, height = 4.5, dpi = 300)


## 2.2 STL decomposition (for EDA slide) -----------------------------------

openings_stl <- stl(openings_ts, s.window = "periodic")

png(file.path(plots_dir, "stl_information_openings.png"),
    width = 1000, height = 800, res = 120)
plot(openings_stl,
     main = "STL Decomposition of Information-Sector Job Openings Rate")
dev.off()


## 2.3 Autocorrelation / partial autocorrelation (for EDA slide) -----------

png(file.path(plots_dir, "acf_information_openings.png"),
    width = 800, height = 600, res = 120)
Acf(openings_ts, main = "ACF of Job Openings Rate")
dev.off()

png(file.path(plots_dir, "pacf_information_openings.png"),
    width = 800, height = 600, res = 120)
Pacf(openings_ts, main = "PACF of Job Openings Rate")
dev.off()


## 2.4 Seasonal view: each month across years (optional EDA slide) ---------

p_seasonal <- jolts %>%
  ggplot(aes(x = year, y = openings_rate,
             group = month_factor, color = month_factor)) +
  geom_line() +
  labs(
    title = "Job Openings Rate by Month Across Years (Information Sector)",
    x = "Year",
    y = "Job openings rate",
    color = "Month"
  )

p_seasonal
ggsave(file.path(plots_dir, "seasonal_by_month_information.png"),
       plot = p_seasonal, width = 8, height = 4.5, dpi = 300)


#### 3. Train–Test Split ----------------------------------------------------

# Train: Jan 2001 – Aug 2023
# Test:  Sep 2023 – Aug 2025 (24 months)
train_end_date <- as.Date("2023-08-01")

jolts <- jolts %>%
  mutate(
    in_train = date <= train_end_date,
    in_test  = date > train_end_date
  )

sum(jolts$in_train)  # train months
sum(jolts$in_test)   # should be 24

openings_ts_train <- ts(
  jolts$openings_rate[jolts$in_train],
  frequency = 12,
  start = c(start_year, start_month)
)

h <- sum(jolts$in_test)  # forecast horizon (24 months)


#### 4. Helper for Metrics --------------------------------------------------

compute_metrics <- function(actual, pred, model_name) {
  data.frame(
    model = model_name,
    MAE   = mae(actual, pred),
    MAPE  = mape(actual, pred) * 100
  )
}


#### 5. Baseline Models: Naive & Seasonal Naive -----------------------------

# Naive: y_hat(t+1) = y(t)
fc_naive <- naive(openings_ts_train, h = h)

# Seasonal Naive: y_hat(t+1) = y(t-12)
fc_snaive <- snaive(openings_ts_train, h = h)


#### 6. Time-Series Models: ARIMA & ETS ------------------------------------

# Automatic ARIMA with seasonal terms
fit_arima <- auto.arima(openings_ts_train, seasonal = TRUE)
summary(fit_arima)

fc_arima <- forecast(fit_arima, h = h)

# ETS (error-trend-seasonality) model
fit_ets <- ets(openings_ts_train)
summary(fit_ets)

fc_ets <- forecast(fit_ets, h = h)


#### 7. Lagged Linear Regression Model -------------------------------------

# Build lagged features: target at t, lags t-1..t-12
jolts_reg <- jolts %>%
  arrange(date) %>%
  mutate(
    target = openings_rate,
    lag1   = lag(target, 1),
    lag2   = lag(target, 2),
    lag3   = lag(target, 3),
    lag4   = lag(target, 4),
    lag5   = lag(target, 5),
    lag6   = lag(target, 6),
    lag7   = lag(target, 7),
    lag8   = lag(target, 8),
    lag9   = lag(target, 9),
    lag10  = lag(target, 10),
    lag11  = lag(target, 11),
    lag12  = lag(target, 12)
  ) %>%
  # Drop first 12 months (no full set of lags)
  filter(!if_any(starts_with("lag"), is.na))

# Recompute train/test flags after dropping early rows
jolts_reg <- jolts_reg %>%
  mutate(
    in_train = date <= train_end_date,
    in_test  = date > train_end_date
  )

train_reg <- jolts_reg %>% filter(in_train)
test_reg  <- jolts_reg %>% filter(in_test)

# Linear regression with lagged features + month-of-year dummies
lm_fit <- lm(
  target ~ lag1 + lag2 + lag3 + lag4 + lag5 + lag6 +
    lag7 + lag8 + lag9 + lag10 + lag11 + lag12 +
    month_factor,
  data = train_reg
)

summary(lm_fit)

pred_lm   <- predict(lm_fit, newdata = test_reg)
actual_ts <- test_reg$target   # ground truth in test window


#### 8. Collect Predictions for All Models ---------------------------------

test_dates <- test_reg$date

pred_naive  <- as.numeric(fc_naive$mean)
pred_snaive <- as.numeric(fc_snaive$mean)
pred_arima  <- as.numeric(fc_arima$mean)
pred_ets    <- as.numeric(fc_ets$mean)

# Sanity check lengths
stopifnot(
  length(pred_naive)  == length(actual_ts),
  length(pred_snaive) == length(actual_ts),
  length(pred_arima)  == length(actual_ts),
  length(pred_ets)    == length(actual_ts),
  length(pred_lm)     == length(actual_ts)
)

results_df <- tibble(
  date   = test_dates,
  actual = actual_ts,
  naive  = pred_naive,
  snaive = pred_snaive,
  arima  = pred_arima,
  ets    = pred_ets,
  lm     = pred_lm
)


#### 9. Metrics Table -------------------------------------------------------

metrics_table <- bind_rows(
  compute_metrics(results_df$actual, results_df$naive,  "Naive"),
  compute_metrics(results_df$actual, results_df$snaive, "Seasonal Naive"),
  compute_metrics(results_df$actual, results_df$arima,  "ARIMA"),
  compute_metrics(results_df$actual, results_df$ets,    "ETS"),
  compute_metrics(results_df$actual, results_df$lm,     "Lagged Linear Regression")
)

print(metrics_table)

# Save metrics to CSV for your report
write_csv(metrics_table, "assignment4_metrics_table.csv")


#### 10. Actual vs Forecast Plot (for Results slide) -----------------------

results_long <- results_df %>%
  pivot_longer(
    cols = -c(date, actual),
    names_to = "model",
    values_to = "prediction"
  )

p_fc <- ggplot() +
  geom_line(data = results_df, aes(x = date, y = actual),
            linewidth = 1, linetype = "solid") +
  geom_line(data = results_long,
            aes(x = date, y = prediction, color = model),
            linewidth = 0.8) +
  labs(
    title = "Information-Sector Job Openings: Actual vs Forecasts (Test Window)",
    x = "Date",
    y = "Job openings rate",
    color = "Model"
  )

p_fc
ggsave(file.path(plots_dir, "assignment4_actual_vs_forecast.png"),
       plot = p_fc, width = 8, height = 4.5, dpi = 300)


#### 11. Residual Diagnostics (ARIMA, saved as PNGs) -----------------------

arima_resid <- residuals(fit_arima)

# 11.1 Time series of residuals
png(file.path(plots_dir, "arima_residuals_ts.png"),
    width = 800, height = 600, res = 120)
plot(arima_resid, type = "l",
     main = "ARIMA Residuals (Training Period)",
     xlab = "Time", ylab = "Residual")
dev.off()

# 11.2 ACF of residuals
png(file.path(plots_dir, "arima_residuals_acf.png"),
    width = 800, height = 600, res = 120)
Acf(arima_resid, main = "ACF of ARIMA Residuals")
dev.off()

# 11.3 PACF of residuals
png(file.path(plots_dir, "arima_residuals_pacf.png"),
    width = 800, height = 600, res = 120)
Pacf(arima_resid, main = "PACF of ARIMA Residuals")
dev.off()

# 11.4 Normal Q-Q plot of residuals
png(file.path(plots_dir, "arima_residuals_qq.png"),
    width = 800, height = 600, res = 120)
qqnorm(arima_resid, main = "Q-Q Plot of ARIMA Residuals")
qqline(arima_resid, col = 2)
dev.off()

############################################################
# End of script
############################################################
