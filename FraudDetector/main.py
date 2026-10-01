import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, precision_score, recall_score

# 1. Load the data
df = pd.read_csv('creditcard.csv')
df = df.drop(['Time'], axis=1)

# 2. Split FIRST, keeping the raw dollar Amount for each row
X = df.drop('Class', axis=1)
y = df['Class']
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42)

dollars_test = X_test['Amount'].copy()   # raw $ amounts, before scaling

# 3. Scale Amount using the training set only (avoids leaking test info)
scaler = StandardScaler()
X_train = X_train.copy(); X_test = X_test.copy()
X_train['Amount'] = scaler.fit_transform(X_train[['Amount']])
X_test['Amount'] = scaler.transform(X_test[['Amount']])

# 4. Train and evaluate BOTH models
models = {
    'Logistic Regression': LogisticRegression(max_iter=1000),
    'Random Forest': RandomForestClassifier(n_estimators=50, n_jobs=-1, random_state=42),
}

rows = []
for name, model in models.items():
    model.fit(X_train, y_train)
    pred = model.predict(X_test)

    fraud = y_test == 1
    caught = fraud & (pred == 1)          # true positives
    missed = fraud & (pred == 0)          # false negatives
    false_alarm = (~fraud) & (pred == 1)  # false positives

    rows.append({
        'model': name,
        'precision': round(precision_score(y_test, pred), 3),
        'recall': round(recall_score(y_test, pred), 3),
        'fraud_cases_caught': int(caught.sum()),
        'fraud_cases_total': int(fraud.sum()),
        'false_alarms': int(false_alarm.sum()),
        'fraud_$_caught': round(dollars_test[caught].sum(), 2),
        'fraud_$_missed': round(dollars_test[missed].sum(), 2),
        'fraud_$_total': round(dollars_test[fraud].sum(), 2),
        'legit_$_flagged': round(dollars_test[false_alarm].sum(), 2),
    })
    print(f"\n{name}\n{confusion_matrix(y_test, pred)}")

results = pd.DataFrame(rows)
results['pct_fraud_$_caught'] = (100 * results['fraud_$_caught'] / results['fraud_$_total']).round(1)
print("\n", results.T.to_string())
results.to_csv('results.csv', index=False)

# 5. Visualize: fraud dollars caught vs. missed per model
results.set_index('model')[['fraud_$_caught', 'fraud_$_missed']].plot(
    kind='bar', stacked=True, color=['#2a9d8f', '#e76f51'])
plt.ylabel('Fraud dollars in test set ($)')
plt.title('Fraud dollars caught vs. missed')
plt.xticks(rotation=0)
plt.tight_layout()
plt.savefig('fraud_dollars.png', dpi=150)
plt.show()
