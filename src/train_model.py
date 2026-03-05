import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

import pandas as pd
import joblib
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder, FunctionTransformer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error
from feature_engineering import add_exam_features

BASE_DIR  = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
df = pd.read_csv(os.path.join(BASE_DIR, "data", "student.csv"))
df.columns = [c.lower().replace(" ", "_") for c in df.columns]

FEATURES_TO_USE = ['age','study_hours','self_study_hours','online_classes_hours',
    'social_media_hours','gaming_hours','sleep_hours','exercise_minutes',
    'caffeine_intake_mg','part_time_job','upcoming_deadline',
    'mental_health_score','gender','academic_level','internet_quality']

X = df[FEATURES_TO_USE]
y = df["exam_score"]

X_sample = add_exam_features(X.head(1))
num_f = X_sample.select_dtypes(include=["int64","float64"]).columns.tolist()
cat_f = X_sample.select_dtypes(include=["object","category"]).columns.tolist()

pre = ColumnTransformer([("num",StandardScaler(),num_f),("cat",OneHotEncoder(handle_unknown="ignore"),cat_f)])
pipeline = Pipeline([("fe",FunctionTransformer(add_exam_features)),("pre",pre),("model",RandomForestRegressor(n_estimators=200,random_state=42))])

X_train,X_test,y_train,y_test = train_test_split(X,y,test_size=0.2,random_state=42)
pipeline.fit(X_train,y_train)
y_pred = pipeline.predict(X_test)
print(f"R²: {r2_score(y_test,y_pred):.4f} | RMSE: {mean_squared_error(y_test,y_pred)**0.5:.4f}")

os.makedirs(os.path.join(BASE_DIR,"models"),exist_ok=True)
joblib.dump(pipeline,os.path.join(BASE_DIR,"models","exam_model.pkl"))
print("✅ exam_model.pkl kaydedildi.")