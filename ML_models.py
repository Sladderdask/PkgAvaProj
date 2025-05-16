# Ta in rätt paket
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

import sqlite3
import pandas as pd
import numpy as np

# Importera datan från databasen och dela upp i x och y.
connect = sqlite3.connect("DatabasLite.db")

cursor = connect.cursor()

cursor.execute(
              f'''
              SELECT LFC 
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgrna=GeCKO.UID
              ''')

y = cursor.fetchall()

y = np.ravel(y)

cursor.execute(
              f'''
              SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18 nt19, nt20
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgrna=GeCKO.UID
              ''')

X = cursor.fetchall()

connect.close()


# Dela upp datan i train, validation, test.
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42)

X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42)


# Definera modellen.
model = RandomForestRegressor(criterion='squared_error', random_state = 42)

# fit the model to the data, define loss function.
model.fit(X_train, y_train)

# Make predicitons and test-val-loss-plot.
from sklearn import metrics

pred = model.predict(X_val)

print('MAE:', metrics.mean_absolute_error(y_val, pred))
# MAE: 0.8115066452524208
print('MSE:', metrics.mean_squared_error(y_val, pred))
# MSE: 1.3258870201410273
print('RMSE:', np.sqrt(metrics.mean_squared_error(y_val, pred)))
# RMSE: 1.1514716757875667
print('R-squared:', metrics.r2_score(y_val, pred))
# R-squared: 0.03514443786530563

###################################################################################


# Ta in rätt paket
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

import sqlite3
import pandas as pd
import numpy as np

# Importera datan från databasen och dela upp i x och y.
connect = sqlite3.connect("DatabasLite.db")

cursor = connect.cursor()

cursor.execute(
              f'''
              SELECT LFC 
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgrna=GeCKO.UID

              ''')

y = cursor.fetchall()

y = np.ravel(y)

cursor.execute(
              f'''
              SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18 nt19, nt20
              FROM sgRNA_data 
              INNER JOIN GeCKO
              WHERE sgRNA_data.sgrna=GeCKO.UID
              ''')

X = cursor.fetchall()

connect.close()


# Dela upp datan i train, validation, test.
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42)

X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42)


# Definera modellen.
model = RandomForestRegressor(criterion='squared_error', random_state = 42)

# fit the model to the data, define loss function.
model.fit(X_train, y_train)

# Make predicitons and test-val-loss-plot.
from sklearn import metrics

pred = model.predict(X_val)

print('MAE:', metrics.mean_absolute_error(y_val, pred))
# MAE: 0.8115066452524208
print('MSE:', metrics.mean_squared_error(y_val, pred))
# MSE: 1.3258870201410273
print('RMSE:', np.sqrt(metrics.mean_squared_error(y_val, pred)))
# RMSE: 1.1514716757875667
print('R-squared:', metrics.r2_score(y_val, pred))
# R-squared: 0.03514443786530563







