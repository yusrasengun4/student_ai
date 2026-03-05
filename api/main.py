import sys
import os

# 🔥 api/ klasöründen çalıştırılınca src/ bulunamıyor — proje kökünü ekle
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from src.predict import make_predictions

app = FastAPI(
    title="EduBoost AI API",
    description="Student performance, burnout, productivity & focus prediction",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------------------------------
# Schema
# --------------------------------------------------

class StudentInput(BaseModel):
    age: int                    = Field(..., ge=15, le=60,  example=20)
    study_hours: float          = Field(..., ge=0,  le=16,  example=5.0)
    self_study_hours: float     = Field(..., ge=0,  le=12,  example=2.0)
    online_classes_hours: float = Field(..., ge=0,  le=12,  example=1.5)
    social_media_hours: float   = Field(..., ge=0,  le=10,  example=2.0)
    gaming_hours: float         = Field(..., ge=0,  le=10,  example=0.0)
    sleep_hours: float          = Field(..., ge=0,  le=12,  example=7.0)
    exercise_minutes: int       = Field(..., ge=0,  le=180, example=30)
    caffeine_intake_mg: int     = Field(..., ge=0,  le=600, example=100)
    part_time_job: int          = Field(..., ge=0,  le=1,   example=0)
    upcoming_deadline: int      = Field(..., ge=0,  le=1,   example=0)
    mental_health_score: int    = Field(..., ge=1,  le=10,  example=7)
    gender: str                 = Field(..., example="Male")
    academic_level: str         = Field(..., example="Undergraduate")
    internet_quality: str       = Field(..., example="Good")

    # 🔥 Değer validasyonu — modelin bilmediği değer gelirse erken yakala
    from pydantic import field_validator

    @field_validator("gender")
    @classmethod
    def validate_gender(cls, v):
        allowed = {"Male", "Female", "Other"}
        if v not in allowed:
            raise ValueError(f"gender '{v}' geçersiz. Olası değerler: {allowed}")
        return v

    @field_validator("academic_level")
    @classmethod
    def validate_academic_level(cls, v):
        allowed = {"Undergraduate", "Postgraduate"}
        if v not in allowed:
            raise ValueError(f"academic_level '{v}' geçersiz. Olası değerler: {allowed}")
        return v

    @field_validator("internet_quality")
    @classmethod
    def validate_internet_quality(cls, v):
        allowed = {"Poor", "Average", "Good"}
        if v not in allowed:
            raise ValueError(f"internet_quality '{v}' geçersiz. Olası değerler: {allowed}")
        return v


class PredictionResponse(BaseModel):
    predicted_score:    float
    burnout_risk:       str
    burnout_confidence: float
    productivity_score: float
    focus_index:        float


# --------------------------------------------------
# Endpoints
# --------------------------------------------------

@app.get("/")
def root():
    return {"status": "ok", "message": "EduBoost AI API is running 🚀"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/predict", response_model=PredictionResponse)
def predict(data: StudentInput):
    try:
        raw = make_predictions(data.model_dump())  # 🔥 .dict() Pydantic v2'de deprecated → model_dump()
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Model hatası: {str(e)}")

    return PredictionResponse(
        predicted_score    = round(raw["exam_score"], 2),
        burnout_risk       = raw["burnout_risk"],
        burnout_confidence = round(raw["burnout_confidence"], 4),
        productivity_score = round(raw["productivity_score"], 2),
        focus_index        = round(raw["focus_index"], 2),
    )