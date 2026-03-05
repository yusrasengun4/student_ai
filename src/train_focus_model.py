import os
import pandas as pd
import joblib

from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error

BASE_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_PATH = os.path.join(BASE_DIR, "data", "student.csv")

df = pd.read_csv(DATA_PATH)
df.columns = [c.lower().replace(" ", "_") for c in df.columns]

# --------------------------------------------------
# 🔥 DÜZELTİLDİ: Sadece ham 15 kolon — FE YOK
#    focus_model pipeline'ında FunctionTransformer olmadığı için
#    predict.py'de de ham veri gönderiliyor (tutarlı)
# --------------------------------------------------

FEATURES_TO_USE = [
    'age', 'study_hours', 'self_study_hours', 'online_classes_hours',
    'social_media_hours', 'gaming_hours', 'sleep_hours', 'exercise_minutes',
    'caffeine_intake_mg', 'part_time_job', 'upcoming_deadline',
    'mental_health_score', 'gender', 'academic_level', 'internet_quality'
]

# 🔥 Sadece bu 15 kolonu al — target ve student_id GİRMİYOR
X = df[FEATURES_TO_USE]
y = df["focus_index"]

print("✅ Focus modeli şu kolonlarla eğitiliyor:")
print(X.columns.tolist())

numeric_features     = X.select_dtypes(include=["int64", "float64"]).columns.tolist()
categorical_features = X.select_dtypes(include=["object"]).columns.tolist()

preprocessor = ColumnTransformer(transformers=[
    ("num", StandardScaler(),                       numeric_features),
    ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_features),
])

pipeline = Pipeline([
    ("preprocessor", preprocessor),
    ("model", RandomForestRegressor(
        n_estimators=300,
        max_depth=None,
        random_state=42
    ))
])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
pipeline.fit(X_train, y_train)

y_pred = pipeline.predict(X_test)
print("\n📊 FOCUS MODEL PERFORMANCE")
print(f"R²:   {r2_score(y_test, y_pred):.4f}")
print(f"RMSE: {(mean_squared_error(y_test, y_pred)**0.5):.4f}")
print(f"MAE:  {mean_absolute_error(y_test, y_pred):.4f}")

MODEL_DIR = os.path.join(BASE_DIR, "models")
os.makedirs(MODEL_DIR, exist_ok=True)
joblib.dump(pipeline, os.path.join(MODEL_DIR, "focus_model.pkl"))
print("✅ Focus modeli kaydedildi.")