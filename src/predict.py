import os
import sys
import joblib
import pandas as pd
import __main__  # Bu çok önemli!

# 1. Modül Yolunu ve Fonksiyonları Tanımla
from src import feature_engineering
from src.feature_engineering import add_exam_features, add_burnout_features

# 2. PICKLE/JOBLIB İÇİN KRİTİK EŞLEŞTİRME
# Model dosyası eğitilirken 'add_engineered_features' ismini kaydetmiş.
# Biz o ismi senin dosmandaki add_exam_features fonksiyonuna yönlendiriyoruz.
sys.modules['feature_engineering'] = feature_engineering
__main__.add_engineered_features = add_exam_features 

# Eğer diğer modeller farklı isimler ararsa diye güvenli eşleştirmeler:
__main__.add_exam_features = add_exam_features
__main__.add_burnout_features = add_burnout_features

# 3. Klasör Yollarını Ayarla
BASE_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_DIR = os.path.join(BASE_DIR, "models")

# 4. Modelleri Yükle
try:
    exam_model         = joblib.load(os.path.join(MODEL_DIR, "exam_model.pkl"))
    burnout_model      = joblib.load(os.path.join(MODEL_DIR, "burnout_classifier.pkl"))
    productivity_model = joblib.load(os.path.join(MODEL_DIR, "productivity_model.pkl"))
    focus_model        = joblib.load(os.path.join(MODEL_DIR, "focus_model.pkl"))
    print("✅ Tüm modeller başarıyla yüklendi.")
except Exception as e:
    print(f"❌ Model yükleme hatası: {e}")
    # Hata devam ederse hangi ismin eksik olduğunu buradan göreceğiz
    raise e

RAW_FEATURES = [
    "age", "study_hours", "self_study_hours", "online_classes_hours",
    "social_media_hours", "gaming_hours", "sleep_hours", "exercise_minutes",
    "caffeine_intake_mg", "part_time_job", "upcoming_deadline",
    "mental_health_score", "gender", "academic_level", "internet_quality",
]

def make_predictions(input_data: dict) -> dict:
    df = pd.DataFrame([input_data])
    
    # Not: Modellerin içinde bu fonksiyonlar otomatik çağrılmıyorsa 
    # (yani Pipeline kullanmadıysan), burada elinle çağırman gerekebilir:
    # df = add_exam_features(df) 
    
    exam_score         = exam_model.predict(df)[0]
    burnout_pred       = burnout_model.predict(df)[0]
    burnout_confidence = max(burnout_model.predict_proba(df)[0])
    productivity_score = productivity_model.predict(df)[0]
    focus_index        = focus_model.predict(df)[0]

    return {
        "exam_score":          float(exam_score),
        "burnout_risk":         str(burnout_pred),
        "burnout_confidence":  float(burnout_confidence),
        "productivity_score":  float(productivity_score),
        "focus_index":         float(focus_index),
    }
