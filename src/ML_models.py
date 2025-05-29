
# Ta in rätt paket
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

import sqlite3
import pandas as pd
import numpy as np

# Importera datan från databasen och dela upp i x och y.
connect = sqlite3.connect("src/DatabasLite.db")

cursor = connect.cursor()

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
              SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18 nt19, nt20
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgRNAid=GeCKO.UID
              ''')

X = cursor.fetchall()
X
connect.close()



# Dela upp datan i train, validation, test.
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42)

X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42)


# Definera modellen.
model_regression = RandomForestRegressor(criterion='squared_error', random_state = 42)

# fit the model to the data, define loss function.
model_regression.fit(X_train, y_train)

# Make predicitons and test-val-loss-plot.
from sklearn import metrics

pred = model_regression.predict(X_val)

print('MAE:', metrics.mean_absolute_error(y_val, pred))
# MAE: 0.8115066452524208
print('MSE:', metrics.mean_squared_error(y_val, pred))
# MSE: 1.3258870201410273
print('RMSE:', np.sqrt(metrics.mean_squared_error(y_val, pred)))
# RMSE: 1.1514716757875667
print('R-squared:', metrics.r2_score(y_val, pred))
# R-squared: 0.03514443786530563



#####################################RandomForestClassifier##############################################


# Ta in rätt paket
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

import sqlite3
import pandas as pd
import numpy as np

# Importera datan från databasen och dela upp i x och y.
connect = sqlite3.connect("src/DatabasLite.db")

cursor = connect.cursor()

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
              SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18 nt19, nt20
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgRNAid=GeCKO.UID
              ''')

X = cursor.fetchall()
X[1:1]
connect.close()


# Dela upp datan i train, validation, test.
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42, stratify=y)
X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42, stratify=y_train)


# Definera modellen.
model_classifier = RandomForestClassifier(criterion='gini', random_state = 42)

# fit the model to the data, define loss function.
model_classifier.fit(X_train, y_train)

# Make predicitons and test-val-loss-plot.
from sklearn import metrics

pred = model_classifier.predict(X_val)

print('Accuracy:', metrics.accuracy_score(y_val, pred))
# Accuracy 0.5971826527382083
print('f1 score:', metrics.f1_score(y_val, pred))
# f1 score: 0.5901991304814557
print('Confusion:', metrics.confusion_matrix(y_val, pred))
# Confusion: [[5821 3682]
#            [3953 5498]]






#####################################Neural network############################################
#from tensorflow.keras.models import Sequential
#from tensorflow.keras.layers import SimpleRNN, Dense

#model = Sequential()
#model.add(SimpleRNN(units=50, activation='tanh', input_shape=(20, 4)))
#model.add(Dense(1, activation='sigmoid'))  # Binary classification

#model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
#model.summary()


####### Plots #######
import matplotlib.pyplot as plt

plt.figure(figsize=(5,5))
plt.scatter(y_val,pred)
plt.plot([-1,2],
        [-1,2],
        color="r",
        linestyle="-",
        linewidth=2)
plt.ylabel("Predicted", size=20)
plt.xlabel("Actual", )
plt.title ("Random Forest Classifier 1")
plt.show()


######### SHAP ########


import shap
explainer = shap.Explainer(model)
shap_values = explainer(np.array(X_val))


np.shape(shap_values.values)

# shap.plot.summary -> Snygg plott

shap.plots.waterfall(shap_values[0])






  




