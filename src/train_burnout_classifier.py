import os
import pandas as pd
import joblib
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix

# 1️⃣ Veriyi yükle
data_path = os.path.join(os.path.dirname(__file__), "../data/student.csv")
df = pd.read_csv(data_path)

df.columns = [c.lower().replace(" ", "_") for c in df.columns]

# 2️⃣ Risk kategorisi oluştur
df["burnout_risk"] = df["burnout_level"].apply(
    lambda x: "High" if x > 70 else ("Medium" if x > 40 else "Low")
)

# 3️⃣ Feature seçimi (exam modeli ile aynı olmalı!)
features_to_use = [
    'age', 'study_hours', 'self_study_hours', 'online_classes_hours', 
    'social_media_hours', 'gaming_hours', 'sleep_hours', 'exercise_minutes', 
    'caffeine_intake_mg', 'part_time_job', 'upcoming_deadline', 
    'mental_health_score', 'gender', 'academic_level', 'internet_quality'
]

X = df[features_to_use]
y = df["burnout_risk"]

print("Sınıf dağılımı:\n", y.value_counts())

# 4️⃣ Preprocessing
numeric_features = X.select_dtypes(include=["int64", "float64"]).columns.tolist()
categorical_features = X.select_dtypes(include=["object"]).columns.tolist()

preprocessor = ColumnTransformer(
    transformers=[
        ("num", StandardScaler(), numeric_features),
        ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_features)
    ]
)

# 5️⃣ Pipeline
pipeline = Pipeline([
    ("preprocessor", preprocessor),
    ("model", RandomForestClassifier(
        n_estimators=300,
        max_depth=None,
        random_state=42,
        class_weight="balanced"
    ))
])

# 6️⃣ Train/Test Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# 7️⃣ Eğit
pipeline.fit(X_train, y_train)

# 8️⃣ Değerlendirme
y_pred = pipeline.predict(X_test)

print("\nClassification Report:\n")
print(classification_report(y_test, y_pred))

print("\nConfusion Matrix:\n")
print(confusion_matrix(y_test, y_pred))

# 9️⃣ Kaydet
model_dir = os.path.join(os.path.dirname(__file__), "../models")
os.makedirs(model_dir, exist_ok=True)

joblib.dump(pipeline, os.path.join(model_dir, "burnout_classifier.pkl"))

print("✅ burnout_classifier.pkl kaydedildi.")