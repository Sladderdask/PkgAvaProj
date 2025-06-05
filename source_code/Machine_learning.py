
# Ta in rätt paket
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn import metrics
import matplotlib.pyplot as plt
import sqlite3
import pandas as pd
import numpy as np
import shap


# Connect to database
connect = sqlite3.connect("source_code/DatabasLite.db")

cursor = connect.cursor()
# Import data from database and divide up in X and y
cursor.execute(
              f'''
              SELECT LFC 
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgRNAid=GeCKO.UID
              ''')

y = cursor.fetchall()

y = np.ravel(y)

cursor.execute(
              f'''
              SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18, nt19, nt20, gc_content
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgRNAid=GeCKO.UID
              ''')

X = cursor.fetchall()
connect.close()

# Divide the data into train, validation and test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42)
X_train, X_val_regression, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42)

# Define the model
model_regression = RandomForestRegressor(criterion='squared_error', random_state = 42)

# fit the model to the data, define loss function.
model_regression.fit(X_train, y_train)

# Make predicitons and test-val-loss-plot.
pred = model_regression.predict(X_val_regression)
print('MAE:', metrics.mean_absolute_error(y_val, pred))
print('MSE:', metrics.mean_squared_error(y_val, pred))
print('RMSE:', np.sqrt(metrics.mean_squared_error(y_val, pred)))
print('R-squared:', metrics.r2_score(y_val, pred))


#####################################RandomForestClassifier##############################################

# Connect to database
connect = sqlite3.connect("source_code/DatabasLite.db")

cursor = connect.cursor()
# Import data from database and divide up in X and y
cursor.execute(
              f'''
              SELECT LFC_binary
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgRNAid=GeCKO.UID

              ''')

y = cursor.fetchall()

y = np.ravel(y)


cursor.execute(
              f'''
              SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18, nt19, nt20, gc_content
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgRNAid=GeCKO.UID
              ''')

X = cursor.fetchall()
connect.close()

# Divide the data into train, validation and test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42, stratify=y)
X_train, X_val_classifier, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42, stratify=y_train)

# Define the model
model_classifier = RandomForestClassifier(criterion='gini', random_state = 42)

# fit the model to the data, define loss function.
model_classifier.fit(X_train, y_train)

# Make predicitons and test-val-loss-plot.
pred = model_classifier.predict(X_val_classifier)
print('Accuracy:', metrics.accuracy_score(y_val, pred))
print('f1 score:', metrics.f1_score(y_val, pred))
print('Confusion:', metrics.confusion_matrix(y_val, pred))


####### Plots #######

plt.figure(figsize=(5, 5))
plt.scatter(y_val, pred, alpha=0.6)
plt.plot([-1, 2], [-1, 2], color="r", linestyle="-", linewidth=2)
plt.ylabel("Predicted", size=15)
plt.xlabel("Actual", size=15)
plt.title("Random Forest Regression", fontsize=16)
plt.tight_layout()
plt.show()


######### SHAP ########

explainer = shap.TreeExplainer(model_regression)
shap_values = explainer(np.array(X_val))

# Save to a pickle file for visualization
with open("shap_values.pickle", "wb") as handle:
    pickle.dump(shap_values, handle, protocol=pickle.HIGHEST_PROTOCOL)







  




