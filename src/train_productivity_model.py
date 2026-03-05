import os
import pandas as pd
import joblib

from sklearn.linear_model import LinearRegression
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder, FunctionTransformer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error

BASE_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_PATH = os.path.join(BASE_DIR, "data", "student.csv")

df = pd.read_csv(DATA_PATH)
df.columns = [c.lower().replace(" ", "_") for c in df.columns]

FEATURES_TO_USE = [
    'age', 'study_hours', 'self_study_hours', 'online_classes_hours',
    'social_media_hours', 'gaming_hours', 'sleep_hours', 'exercise_minutes',
    'caffeine_intake_mg', 'part_time_job', 'upcoming_deadline',
    'mental_health_score', 'gender', 'academic_level', 'internet_quality'
]

def add_engineered_features(df):
    df = df.copy()
    df["total_leisure_screen_time"] = df["social_media_hours"] + df["gaming_hours"]
    df["self_study_ratio"]          = df["self_study_hours"] / (df["study_hours"] + 1)
    df["sleep_deficit"]             = 8 - df["sleep_hours"]
    df["study_screen_ratio"]        = df["study_hours"] / (df["total_leisure_screen_time"] + 1)
    df["high_caffeine"]             = (df["caffeine_intake_mg"] > 200).astype(int)
    df["high_stress"]               = (df["mental_health_score"] < 5).astype(int)
    df["focus_per_study_hour"]      = df["mental_health_score"] / (df["study_hours"] + 1)
    return df  # 🔥 Sadece ham + türetilen, target YOK

feature_engineering = FunctionTransformer(add_engineered_features)

# 🔥 DÜZELTİLDİ: X'e sadece ham feature kolonları giriyor
X = df[FEATURES_TO_USE]
y = df["productivity_score"]

numeric_features     = X.select_dtypes(include=["int64", "float64"]).columns.tolist()
categorical_features = X.select_dtypes(include=["object"]).columns.tolist()

preprocessor = ColumnTransformer(transformers=[
    ("num", StandardScaler(),                          numeric_features),
    ("cat", OneHotEncoder(handle_unknown="ignore"),    categorical_features),
])

pipeline = Pipeline([
    ("feature_engineering", feature_engineering),
    ("preprocessor",        preprocessor),
    ("model",               LinearRegression())
])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
pipeline.fit(X_train, y_train)

y_pred = pipeline.predict(X_test)
print("\n📊 PRODUCTIVITY MODEL PERFORMANCE")
print(f"R²:   {r2_score(y_test, y_pred):.4f}")
print(f"RMSE: {(mean_squared_error(y_test, y_pred)**0.5):.4f}")
print(f"MAE:  {mean_absolute_error(y_test, y_pred):.4f}")

MODEL_DIR = os.path.join(BASE_DIR, "models")
os.makedirs(MODEL_DIR, exist_ok=True)
joblib.dump(pipeline, os.path.join(MODEL_DIR, "productivity_model.pkl"))
print("✅ Productivity modeli kaydedildi.")