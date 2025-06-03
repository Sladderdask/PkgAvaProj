import pickle
import shap
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Load the SHAP object from the pickle file
with open("source_code/shap_values.pickle", "rb") as f:
    shap_values = pickle.load(f)
print(shap_values)


shap.summary_plot(shap_values.values, shap_values.data, plot_type="bar")
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
mean_abs_shap = all_values.mean(axis=0)
feature_importance = pd.DataFrame({
    "Feature": feature_names,
    "Importance": mean_abs_shap
}).sort_values("Feature")

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
