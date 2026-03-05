import os
import pandas as pd
import joblib

from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder, FunctionTransformer
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

from feature_engineering import add_burnout_features

BASE_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_PATH = os.path.join(BASE_DIR, "data", "student.csv")

df = pd.read_csv(DATA_PATH)
df.columns = [c.lower().replace(" ", "_") for c in df.columns]

df["burnout_category"] = pd.cut(
    df["burnout_level"], bins=[0, 35, 55, 100], labels=["Low", "Medium", "High"]
)

FEATURES_TO_USE = [
    'age', 'study_hours', 'self_study_hours', 'online_classes_hours',
    'social_media_hours', 'gaming_hours', 'sleep_hours', 'exercise_minutes',
    'caffeine_intake_mg', 'part_time_job', 'upcoming_deadline',
    'mental_health_score', 'gender', 'academic_level', 'internet_quality'
]

X = df[FEATURES_TO_USE]
y = df["burnout_category"]

# FE sonrası kolon tiplerini otomatik tespit et
X_sample             = add_burnout_features(X.head(1))
numeric_features     = X_sample.select_dtypes(include=["int64", "float64"]).columns.tolist()
categorical_features = X_sample.select_dtypes(include=["object", "category"]).columns.tolist()

print("\n📥 Numeric features: ", numeric_features)
print("📥 Categorical features:", categorical_features)

preprocessor = ColumnTransformer(transformers=[
    ("num", StandardScaler(),                       numeric_features),
    ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_features),
])

pipeline = Pipeline([
    ("fe",    FunctionTransformer(add_burnout_features)),
    ("pre",   preprocessor),
    ("model", RandomForestClassifier(n_estimators=300, random_state=42))
])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
pipeline.fit(X_train, y_train)

print("\n📊 BURNOUT MODEL PERFORMANCE")
print(classification_report(y_test, pipeline.predict(X_test)))

MODEL_DIR = os.path.join(BASE_DIR, "models")
os.makedirs(MODEL_DIR, exist_ok=True)
joblib.dump(pipeline, os.path.join(MODEL_DIR, "burnout_classifier.pkl"))
print("✅ Burnout modeli kaydedildi.")