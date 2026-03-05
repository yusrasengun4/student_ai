import streamlit as st
import sys
import os

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(ROOT_DIR)

from src.database import save_daily_record, get_student
from src.predict import make_predictions


def render_metric_card(label, value, unit="", color="#4F8EF7", icon=""):
    st.markdown(f"""
    <div style="
        background: linear-gradient(135deg, {color}18 0%, {color}08 100%);
        border: 1.5px solid {color}40;
        border-radius: 16px;
        padding: 20px 18px 14px 18px;
        text-align: center;
        min-height: 110px;
        display: flex;
        flex-direction: column;
        justify-content: center;
    ">
        <div style="font-size: 28px; margin-bottom: 4px;">{icon}</div>
        <div style="
            font-size: 2rem;
            font-weight: 800;
            color: {color};
            letter-spacing: -1px;
            line-height: 1;
        ">{value}<span style="font-size: 0.9rem; font-weight: 500; color: #888; margin-left: 3px;">{unit}</span></div>
        <div style="
            font-size: 0.75rem;
            color: #888;
            margin-top: 6px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-weight: 600;
        ">{label}</div>
    </div>
    """, unsafe_allow_html=True)


def render_burnout_badge(risk, confidence):
    colors = {
        "Low":    ("#22c55e", "🟢", "Düşük Risk"),
        "Medium": ("#f59e0b", "🟡", "Orta Risk"),
        "High":   ("#ef4444", "🔴", "Yüksek Risk"),
    }
    color, dot, label = colors.get(risk, ("#888", "⚪", risk))
    conf_pct = int(confidence * 100)

    st.markdown(f"""
    <div style="
        background: linear-gradient(135deg, {color}18, {color}06);
        border: 2px solid {color}60;
        border-radius: 20px;
        padding: 24px;
        text-align: center;
    ">
        <div style="font-size: 3rem; margin-bottom: 8px;">{dot}</div>
        <div style="font-size: 1.5rem; font-weight: 800; color: {color};">{label}</div>
        <div style="font-size: 0.8rem; color: #999; margin-top: 6px;">Tükenmişlik Riski</div>
        <div style="
            margin-top: 14px;
            background: #1a1a2e;
            border-radius: 999px;
            height: 8px;
            overflow: hidden;
        ">
            <div style="
                height: 100%;
                width: {conf_pct}%;
                background: {color};
                border-radius: 999px;
                transition: width 1s ease;
            "></div>
        </div>
        <div style="font-size: 0.72rem; color: #666; margin-top: 5px;">Model güveni: %{conf_pct}</div>
    </div>
    """, unsafe_allow_html=True)

def render_burnout_warning(score):
    # Skor aralıklarına göre renk ve mesaj belirleme
    if score < 35:
        color = "#22c55e"  # Yeşil
        label = "GÜVENLİ BÖLGE"
        desc = "Enerjin yerinde, dengeyi koruyorsun."
    elif score < 55:
        color = "#f59e0b"  # Turuncu
        label = "DİKKAT: SINIRDA"
        desc = "Tükenmişlik sinyalleri başlıyor, dinlenmeye vakit ayır."
    else:
        color = "#ef4444"  # Kırmızı
        label = "ERKEN UYARI: KRİTİK"
        desc = "Tükenmişlik riski çok yüksek! Hemen mola vermelisin."

    st.markdown(f"""
    <div style="
        background: #1a1a2e;
        border-left: 5px solid {color};
        padding: 15px 20px;
        border-radius: 8px;
        margin: 10px 0;
    ">
        <div style="color: {color}; font-weight: 800; font-size: 0.8rem; text-transform: uppercase;">{label}</div>
        <div style="font-size: 1.8rem; font-weight: 700; color: #fff; margin: 5px 0;">%{score:.1f}</div>
        <div style="color: #888; font-size: 0.85rem;">{desc}</div>
    </div>
    """, unsafe_allow_html=True)
def run():
    # ── Inject custom CSS ──────────────────────────────────────────────────
    st.markdown("""
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap');

    html, body, [class*="css"] {
        font-family: 'DM Sans', sans-serif;
    }

    h1, h2, h3 {
        font-family: 'Syne', sans-serif !important;
    }

    .section-title {
        font-family: 'Syne', sans-serif;
        font-size: 1rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.12em;
        color: #4F8EF7;
        margin: 28px 0 12px 0;
        padding-left: 10px;
        border-left: 3px solid #4F8EF7;
    }

    .stSlider > div > div > div > div {
        background: #4F8EF7 !important;
    }

    div[data-testid="stForm"] {
        background: transparent !important;
        border: none !important;
    }

    .result-header {
        font-family: 'Syne', sans-serif;
        font-size: 1.4rem;
        font-weight: 800;
        color: #e2e8f0;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid #2a2a3e;
    }
    </style>
    """, unsafe_allow_html=True)

    # ── Sayfa Başlığı ──────────────────────────────────────────────────────
    st.markdown("""
    <div style="margin-bottom: 28px;">
        <h1 style="font-family: 'Syne', sans-serif; font-size: 2rem; font-weight: 800;
                   margin-bottom: 4px; color: #e2e8f0;">
            📊 Günlük Analiz
        </h1>
        <p style="color: #64748b; font-size: 0.9rem; margin: 0;">
            Bugünkü verilerini gir, yapay zeka performansını analiz etsin.
        </p>
    </div>
    """, unsafe_allow_html=True)

    student_id = st.session_state.get("student_id")
    if not student_id:
        st.error("Lütfen önce giriş yapın.")
        return

    student = get_student(student_id)
    if not student:
        st.error("Öğrenci bilgisi bulunamadı.")
        return

    # ── Form ───────────────────────────────────────────────────────────────
    with st.form("daily_form", clear_on_submit=False):

        # — ÇALIŞMA —
        st.markdown('<div class="section-title">📚 Çalışma Saatleri</div>', unsafe_allow_html=True)
        col1, col2, col3 = st.columns(3)
        with col1:
            study_hours = st.slider("Toplam Çalışma", 0.0, 16.0, 4.0, 0.5,
                                    help="Gün içinde toplam kaç saat çalıştın?")
        with col2:
            self_study_hours = st.slider("Bireysel Çalışma", 0.0, 12.0, 2.0, 0.5)
        with col3:
            online_classes_hours = st.slider("Online Ders", 0.0, 12.0, 1.0, 0.5)

        # — YAŞAM —
        st.markdown('<div class="section-title">🌙 Yaşam Dengesi</div>', unsafe_allow_html=True)
        col4, col5, col6 = st.columns(3)
        with col4:
            sleep_hours = st.slider("Uyku", 0.0, 12.0, 7.0, 0.5,
                                    help="Kaç saat uyudun?")
        with col5:
            social_media_hours = st.slider("Sosyal Medya", 0.0, 10.0, 2.0, 0.5)
        with col6:
            gaming_hours = st.slider("Oyun", 0.0, 10.0, 0.0, 0.5)

        # — SAĞLIK —
        st.markdown('<div class="section-title">💪 Sağlık & Odak</div>', unsafe_allow_html=True)
        col7, col8, col9 = st.columns(3)
        with col7:
            exercise_minutes = st.slider("Egzersiz (dk)", 0, 180, 30, 5)
        with col8:
            caffeine_intake_mg = st.slider("Kafein (mg)", 0, 600, 100, 25,
                                           help="1 fincan kahve ≈ 80-100mg")
        with col9:
            mental_health_score = st.slider("Ruh Hali (1-10)", 1, 10, 7,
                                            help="1 = çok kötü, 10 = mükemmel")

        # — BAĞLAM —
        st.markdown('<div class="section-title">🌐 Ortam & Bağlam</div>', unsafe_allow_html=True)
        col10, col11 = st.columns(2)
        with col10:
            internet_quality = st.selectbox(
                "İnternet Kalitesi",
                ["Poor", "Average", "Good"],
                index=1,
                format_func=lambda x: {"Poor": "🔴 Zayıf", "Average": "🟡 Orta", "Good": "🟢 İyi"}[x]
            )
        with col11:
            upcoming_deadline = st.selectbox(
                "Yaklaşan Teslim Tarihi?",
                [0, 1],
                format_func=lambda x: "✅ Hayır" if x == 0 else "⚠️ Evet"
            )

        st.markdown("<br>", unsafe_allow_html=True)
        submitted = st.form_submit_button(
            "🚀 Analizi Başlat",
            use_container_width=True,
            type="primary"
        )

    # ── Tahmin & Sonuçlar ──────────────────────────────────────────────────
    if submitted:
        input_data = {
            "age":                  student["age"],
            "gender":               student["gender"],
            "academic_level":       student["academic_level"],
            "part_time_job":        student["part_time_job"],
            "study_hours":          study_hours,
            "self_study_hours":     self_study_hours,
            "online_classes_hours": online_classes_hours,
            "sleep_hours":          sleep_hours,
            "social_media_hours":   social_media_hours,
            "gaming_hours":         gaming_hours,
            "exercise_minutes":     exercise_minutes,
            "caffeine_intake_mg":   caffeine_intake_mg,
            "mental_health_score":  mental_health_score,
            "internet_quality":     internet_quality,
            "upcoming_deadline":    upcoming_deadline,
        }

        with st.spinner("🧠 Modeller analiz yapıyor..."):
            try:
                raw = make_predictions(input_data)
            except Exception as e:
                st.error(f"Model hatası: {e}")
                return

        # predicted_score = exam_score
        predictions = {
            "predicted_score":    raw["exam_score"],
            "burnout_risk":       raw["burnout_risk"],
            "burnout_confidence": raw["burnout_confidence"],
            "productivity_score": raw["productivity_score"],
            "focus_index":        raw["focus_index"],
        }

        # Kaydet
        daily_data = {k: v for k, v in input_data.items()
                      if k not in ("age", "gender", "academic_level", "part_time_job")}
        save_daily_record(student_id, daily_data, predictions)

        # ── Sonuç Paneli ──
        st.markdown("---")
        st.markdown('<div class="result-header">✨ Analiz Sonuçları</div>', unsafe_allow_html=True)

        # Tükenmişlik – tam genişlik
        col_left, col_right = st.columns([1, 1])
        
        with col_left:
            # Mevcut badge
            render_burnout_badge(raw["burnout_risk"], raw["burnout_confidence"])
            
        with col_right:
            # YENİ: Early Warning Sistemi (Skor 100 üzerinden hesaplanıyor)
            burnout_score_pct = raw["burnout_confidence"] * 100
            render_burnout_warning(burnout_score_pct)

        st.markdown("<br>", unsafe_allow_html=True)

        # 3 metrik kart
        c1, c2, c3 = st.columns(3)
        with c1:
            render_metric_card(
                "Tahmin Edilen Sınav Puanı",
                f"{raw['exam_score']:.1f}",
                "/100",
                "#4F8EF7",
                "🎓"
            )
        with c2:
            render_metric_card(
                "Verimlilik Skoru",
                f"{raw['productivity_score']:.1f}",
                "/100",
                "#a855f7",
                "⚡"
            )
        with c3:
            render_metric_card(
                "Odak İndeksi",
                f"{raw['focus_index']:.1f}",
                "/100",
                "#06b6d4",
                "🎯"
            )

        st.markdown("<br>", unsafe_allow_html=True)

        # ── Akıllı Öneriler ──
        st.markdown('<div class="section-title">💡 Kişisel Öneriler</div>', unsafe_allow_html=True)
        tips = _generate_tips(raw, sleep_hours, social_media_hours,
                              exercise_minutes, mental_health_score, caffeine_intake_mg)
        for tip in tips:
            st.info(tip)

        st.success("✅ Bugünkü veriler kaydedildi.")


def _generate_tips(raw, sleep_hours, social_media_hours,
                   exercise_minutes, mental_health_score, caffeine_intake_mg):
    tips = []

    if sleep_hours < 6:
        tips.append("😴 Uyku süren 6 saatin altında. Bilişsel performans için 7-9 saat önerilir.")
    elif sleep_hours > 9:
        tips.append("🛌 Fazla uyku da yorgunluğa yol açabilir. Rutini düzenlemeyi dene.")

    if raw["burnout_risk"] == "High":
        tips.append("🔥 Yüksek tükenmişlik riski tespit edildi! Mola ver, nefes egzersizleri dene.")
    elif raw["burnout_risk"] == "Medium":
        tips.append("⚠️ Orta düzey tükenmişlik belirtisi var. Hobine zaman ayırmayı unutma.")

    if social_media_hours > 4:
        tips.append("📱 Sosyal medyada çok zaman geçiriyorsun. Pomodoro tekniği dene.")

    if exercise_minutes < 20:
        tips.append("🏃 Bugün yeterince hareket etmedin. 20 dakika yürüyüş odak artırır.")

    if mental_health_score <= 4:
        tips.append("💙 Ruh halin düşük görünüyor. Güvendiğin biriyle konuşmak iyi gelebilir.")

    if caffeine_intake_mg > 400:
        tips.append("☕ Kafein alımın yüksek. Öğleden sonra kahve içmemen uyku kaliteni artırır.")

    if raw["focus_index"] < 50:
        tips.append("🎯 Odak indeksin düşük. Dağıtıcı unsurları kapat, tek işe odaklan.")

    if not tips:
        tips.append("🌟 Harika! Bugün dengeli bir gün geçirdin. Böyle devam et.")

    return tips