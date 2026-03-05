# src/feature_engineering.py

import numpy as np
import pandas as pd


# --------------------------------------------------
# EXAM FEATURES
# --------------------------------------------------

def add_exam_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["total_leisure_screen_time"] = df["social_media_hours"] + df["gaming_hours"]
    df["screen_time_hours"]         = df["social_media_hours"] + df["gaming_hours"] + df["online_classes_hours"]
    df["self_study_ratio"]          = df["self_study_hours"] / (df["study_hours"] + 1)
    df["sleep_deficit"]             = np.abs(df["sleep_hours"] - 8.0)
    df["study_screen_ratio"]        = df["study_hours"] / (df["screen_time_hours"] + 1)
    df["is_active"]                 = (df["exercise_minutes"] >= 30).astype(int)
    df["high_caffeine"]             = (df["caffeine_intake_mg"] > 200).astype(int)
    df["high_stress"]               = (df["upcoming_deadline"] & df["part_time_job"]).astype(int)
    df["effective_study_hours"]     = df["study_hours"] * (df["mental_health_score"] / 10)
    df["mental_study_interaction"]  = df["mental_health_score"] * df["study_hours"]
    df["study_sleep_interaction"]   = df["study_hours"] * df["sleep_hours"]
    df["distraction_ratio"]         = df["total_leisure_screen_time"] / (df["study_hours"] + 1)
    df["wellness_score"]            = (
        df["sleep_hours"] * 0.4 +
        (df["exercise_minutes"] / 60) * 0.3 +
        df["mental_health_score"] * 0.3
    )
    return df


# --------------------------------------------------
# BURNOUT FEATURES (9 yeni özellik → toplam 33 kolon)
# --------------------------------------------------

def add_burnout_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    # 1️⃣ Total leisure screen time
    df["total_leisure_screen_time"] = df["social_media_hours"] + df["gaming_hours"]
    print("Created total_leisure_screen_time ✅")

    # 2️⃣ Self study ratio
    df["self_study_ratio"] = df["self_study_hours"] / (df["study_hours"] + 1)
    print("Created self_study_ratio ✅")

    # 3️⃣ Sleep deficit
    df["sleep_deficit"] = 8 - df["sleep_hours"]
    print("Created sleep_deficit ✅")

    # 4️⃣ Study / screen ratio
    df["study_screen_ratio"] = df["study_hours"] / (df["total_leisure_screen_time"] + 1)
    print("Created study_screen_ratio ✅")

    # 5️⃣ Exercise category + is_active
    df["exercise_category"] = pd.cut(
        df["exercise_minutes"],
        bins=[0, 30, 60, 200],
        labels=["Low", "Moderate", "High"]
    )
    df["is_active"] = (df["exercise_minutes"] >= 30).astype(int)
    print("Created exercise_category and is_active ✅")

    # 6️⃣ High caffeine + caffeine category
    df["caffeine_category"] = pd.cut(
        df["caffeine_intake_mg"],
        bins=[0, 100, 300, 500],
        labels=["Low", "Moderate", "High"]
    )
    df["high_caffeine"] = (df["caffeine_intake_mg"] > 200).astype(int)
    print("Created high_caffeine and caffeine_category ✅")

    # 7️⃣ High stress indicator
    df["high_stress"] = (df["mental_health_score"] < 5).astype(int)
    print("Created high_stress indicator ✅")

    # 8️⃣ Focus per study hour (mental health proxy)
    df["focus_per_study_hour"] = df["mental_health_score"] / (df["study_hours"] + 1)
    print("Created focus_per_study_hour ✅")

    print(f"\n   Original features: {len(df.columns) - 9}")
    print(f"   New features:      9")
    print(f"   Total features:    {len(df.columns)}")

    return df


# productivity burnout ile aynı feature seti kullanır
add_productivity_features = add_burnout_features