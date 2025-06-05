import pickle
import shap
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from source_code.Machine_learning import X_val_classifier, X_val_regression


# Load the SHAP object from the pickle file
with open("source_code/shap_values.pickle", "rb") as f:
    shap_values = pickle.load(f)

lista = ["nt1", "nt2", "nt3", "nt4", "nt5", "nt6", "nt7", "nt8", "nt9", "nt10", "nt11", "nt12", "nt13", "nt14", "nt15", "nt16" ,"nt17" ,"nt18", "nt19", "nt20", "gc_content"]

# For classifier Machine learning code
X_val_classifier = np.array(X_val_classifier)
# Rearrange to (samples, features) if using classifier -> Not when using regression
shap_values_class0 = shap_values.values[:, :, 0]  # class 0 SHAP values
shap_values_class1 = shap_values.values[:, :, 1]  # class 1 SHAP values

# Summary plot
shap.summary_plot(shap_values_class1, features=shap_values.data, feature_names=lista, max_display=21, plot_size=(5, 10))
plt.gcf().suptitle("SHAP Summary Plot - Class 1", fontsize=16)
plt.subplots_adjust(top=0.9)  # adjust so title doesn't overlap
plt.show()
shap.summary_plot(shap_values_class0, features=shap_values.data, feature_names=lista, max_display=21, plot_size=(5, 10))
plt.gcf().suptitle("SHAP Summary Plot - Class 0", fontsize=16)
plt.subplots_adjust(top=0.9)  # adjust so title doesn't overlap
plt.show()

# Regression plot
shap.summary_plot(shap_values, features=shap_values.data, feature_names=lista, max_display=21, plot_size=(5, 10))
plt.gcf().suptitle("SHAP Summary Plot - Regression", fontsize=16)
plt.subplots_adjust(top=0.9)  # adjust so title doesn't overlap
plt.show()


shap.summary_plot(shap_values.values, features = shap_values.data, feature_names= lista)
# Step 1: Handle SHAP object
if isinstance(shap_values, list):
    all_values = np.mean([np.abs(sv.values) for sv in shap_values], axis=0)
    try:
        feature_names = shap_values[0].feature_names
    except:
        feature_names = [f"Feature_{i}" for i in range(all_values.shape[1])]
else:
    all_values = np.abs(shap_values.values)
    try:
        feature_names = shap_values.feature_names
        if feature_names is None or any(f is None for f in feature_names):
            raise ValueError
    except:
        try:
            feature_names = shap_values.data.columns.tolist()
        except:
            feature_names = [f"Feature_{i}" for i in range(all_values.shape[1])]



# Step 2: Compute and plot
mean_abs_shap = np.array(all_values).mean(axis=0)
feature_names = np.array(feature_names).flatten()
mean_abs_shap = np.array(mean_abs_shap).flatten()
feature_importance = pd.DataFrame({
    "Feature": feature_names,
    "Importance": mean_abs_shap
})

feature_importance = feature_importance.sort_values("Feature")


plt.figure(figsize=(14, 6))
plt.bar(feature_importance["Feature"], feature_importance["Importance"])
plt.xticks(rotation=90)
plt.ylabel("Mean |SHAP Value|")
plt.title("SHAP Feature Importance (Sorted by Feature Name)")
plt.tight_layout()
plt.show()


# Assume 'feature_names' and 'mean_abs_shap' were properly generated

feature_importance = pd.DataFrame({
    "Feature": feature_names,
    "Importance": mean_abs_shap
})
 
# ✅ Properly sort alphabetically by feature name
feature_importance = feature_importance.sort_values(by="Feature")

# ✅ Plot
plt.figure(figsize=(14, 6))
plt.bar(feature_importance["Feature"], feature_importance["Importance"])
plt.xticks(rotation=90)
plt.ylabel("Mean |SHAP Value|")
plt.title("SHAP Feature Importance (Sorted Alphabetically!)")
plt.tight_layout()
plt.show()

# Extract numeric suffix for sorting
feature_importance["FeatureNum"] = feature_importance["Feature"].str.extract(r'(\d+)$').astype(int)

# Sort by numeric part
feature_importance = feature_importance.sort_values(by="FeatureNum")

# Plot with original names
plt.figure(figsize=(14, 6))
plt.bar(feature_importance["Feature"], feature_importance["Importance"])
plt.xticks(rotation=90)
plt.ylabel("Mean |SHAP Value|")
plt.title("SHAP Feature Importance (Sorted by Feature Index)")
plt.tight_layout()
plt.show()

print(feature_importance.head())
