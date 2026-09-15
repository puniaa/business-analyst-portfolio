## Credit Card Fraud Detection

A machine learning project to detect fraudulent credit card transactions using scikit-learn and Python. This project uses the publicly available dataset from Kaggle and demonstrates how models like Logistic Regression and Random Forest can help identify fraud.

## Overview

This dataset contains 284,807 transactions, including only 492 cases of fraud. The features are anonymized (V1–V28) using PCA. The goal is to build a classification model that can accurately identify fraudulent transactions.

## Project Structure
fraudDetector/ 
    ├── main.py # Python script for model training & evaluation 
    ├── README.md # Project overview 
    ├── requirements.txt # Dependencies for the project 
    ├── .gitignore # Ignored files (e.g. venv, dataset) 
    └── creditcard.csv # (not included in repo, download via Kaggle)


## Techniques Used
- Data preprocessing with pandas and StandardScaler
- Logistic Regression
- Random Forest (with n_estimators and parallel training)
- Confusion Matrix, Precision, Recall, and F1-score
- Seaborn heatmap for visualization

## How to Run
1. Clone this repository
2. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud) and place `creditcard.csv` in the root folder
3. Create and activate a virtual environment:
    ```bash
    python -m venv venv
    .\venv\Scripts\activate
    ```
4. Install required packages:
    ```bash
    pip install -r requirements.txt
    ```
5. Run the script:
    ```bash
    python main.py
    ```

## Sample Output

✅ Data loaded!
📊 Random Forest Results:
[[56860     4]
 [   18    80]]
              precision    recall  f1-score   support

           0       1.00      1.00      1.00     56864
           1       0.95      0.82      0.88        98

    accuracy                           1.00     56962
   macro avg       0.98      0.91      0.94     56962
weighted avg       1.00      1.00      1.00     56962

Precision: 0.9523809523809523
Recall: 0.8163265306122449

## Future Improvements

- Use SMOTE to oversample the minority class
- Add more models (XGBoost, SVM)
- Plot ROC curve, PR curve
- Save model using `joblib`
- Streamlit or Flask web app for real-time predictions

## Dataset

This project uses the [Kaggle Credit Card Fraud Dataset](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud).  
**Note**: The dataset is not included in the repo due to file size. Please download it manually or using the Kaggle API.
