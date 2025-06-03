# Download required libraries and packages
library(reticulate)

py_run_string("
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn import metrics
import matplotlib.pyplot as plt
import sqlite3
import pandas as pd
import numpy as np
import shap
")


################################# Reression Model ##############################


# Connect to database
conn <- dbConnect(SQLite(), dbname = "src/DatabasLite.db")

# Importera data from database and divide up in X and y
y <- dbGetQuery(conn, "SELECT LFC
                       FROM GeCKO
                       INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                       INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                       WHERE fpkm_binary = 1
                       ")

X <- dbGetQuery(conn, "SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18, nt19, nt20, gc_content
                       FROM GeCKO
                       INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                       INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                       WHERE fpkm_binary = 1
                       ")
# Disconnect from database
dbDisconnect(conn)

# Reticulate data from R to python (python equivalents that is Pandas DataFrame)
y <- r_to_py(y)
X <- r_to_py(X)

# Make the variables accessibly
py$y <- y
py$X <- X

# Flatten y -> Accessing Python attributes using $
py_run_string("y = np.ravel(y)")

# Divide the data into train, validation and test
py_run_string ("X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42)")
py_run_string ("X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42)")

# Define the model
py_run_string("model_regression = RandomForestRegressor(criterion='squared_error', random_state = 42)")
# fit the model to the data, define loss function.
py_run_string("model_regression.fit(X_train, y_train)")
# Make predicitons and test-val-loss-plot.
py_run_string("pred = model_regression.predict(X_val)")

py_run_string("print('MAE:', metrics.mean_absolute_error(y_val, pred))")
py_run_string("print('MSE:', metrics.mean_squared_error(y_val, pred))")
py_run_string("print('RMSE:', np.sqrt(metrics.mean_squared_error(y_val, pred)))")
py_run_string("print('R-squared:', metrics.r2_score(y_val, pred))")




#####################################RandomForestClassifier##############################################

# Connect to database
conn <- dbConnect(SQLite(), dbname = "src/DatabasLite.db")

# Importera data from database and divide up in X and y
y <- dbGetQuery(conn, "SELECT LFC_binary
                       FROM GeCKO
                       INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                       INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                       WHERE fpkm_binary = 1
                       ")

X <- dbGetQuery(conn, "SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18, nt19, nt20, gc_content
                       FROM GeCKO
                       INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                       INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                       WHERE fpkm_binary = 1
                       ")
# Disconnect from database
dbDisconnect(conn)

# Reticulate data from R to python (python equivalents that is Pandas DataFrame)
y <- r_to_py(y)
X <- r_to_py(X)

# Make the variables accessibly
py$y <- y
py$X <- X

# Flatten y -> Accessing Python attributes using $
py_run_string("y = np.ravel(y)")

# Divide the data into train, validation and test
py_run_string ("X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state = 42, stratify=y)")
py_run_string ("X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42, stratify=y_train)")

# Define the model
py_run_string("model_classifier = RandomForestClassifier(criterion='gini', random_state = 42)")
# fit the model to the data, define loss function.
py_run_string("model_classifier.fit(X_train, y_train)")
# Make predicitons and test-val-loss-plot.
py_run_string("pred = model_classifier.predict(X_val)")

py_run_string("print('MAE:', metrics.mean_absolute_error(y_val, pred))")
py_run_string("print('MSE:', metrics.mean_squared_error(y_val, pred))")
py_run_string("print('RMSE:', np.sqrt(metrics.mean_squared_error(y_val, pred)))")
py_run_string("print('R-squared:', metrics.r2_score(y_val, pred))")

py_run_string("print('Accuracy:', metrics.accuracy_score(y_val, pred))")
py_run_string("print('f1 score:', metrics.f1_score(y_val, pred))")
py_run_string("print('Confusion:', metrics.confusion_matrix(y_val, pred))")


######### SHAP ########

py_run_string("explainer = shap.Explainer(model_regression)")
py_run_string("shap_values = explainer(np.array(X_val))")
py_run_string("np.shape(shap_values.values)")



# shap.plot.summary -> Snygg plott

#shap.plots.waterfall(shap_values[0])



