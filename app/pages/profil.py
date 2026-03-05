import streamlit as st
from src.database import get_student, update_student

def run():

    if "student_id" not in st.session_state:
        st.warning("Lütfen giriş yapın.")
        st.stop()

    st.markdown("""
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap');
    html, body, [class*="css"] { font-family: 'DM Sans', sans-serif; }
    h1, h2, h3 { font-family: 'Syne', sans-serif !important; }
    .section-title {
        font-family: 'Syne', sans-serif;
        font-size: 1rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.12em;
        color: #4F8EF7;
        margin: 24px 0 12px 0;
        padding-left: 10px;
        border-left: 3px solid #4F8EF7;
    }
    </style>
    """, unsafe_allow_html=True)

    st.markdown("""
    <div style="margin-bottom: 28px;">
        <h1 style="font-family: 'Syne', sans-serif; font-size: 2rem; font-weight: 800;
                   margin-bottom: 4px; color: #e2e8f0;">👤 Profil</h1>
        <p style="color: #64748b; font-size: 0.9rem; margin: 0;">
            Kişisel bilgilerini güncel tut — modeller bu verileri kullanır.
        </p>
    </div>
    """, unsafe_allow_html=True)

    student_id = st.session_state["student_id"]
    student = get_student(student_id)

    if not student:
        st.error("Öğrenci bilgisi bulunamadı.")
        return

    # ── E-posta (salt okunur) ──────────────────────────────────────────────
    if "email" in st.session_state:
        st.markdown('<div class="section-title">📧 Hesap</div>', unsafe_allow_html=True)
        st.text_input("E-posta", value=st.session_state["email"], disabled=True)

    # ── Kişisel Bilgiler ──────────────────────────────────────────────────
    st.markdown('<div class="section-title">🎓 Kişisel Bilgiler</div>', unsafe_allow_html=True)

    col1, col2 = st.columns(2)

    with col1:
        age = st.number_input("Yaş", min_value=15, max_value=60,
                               value=student["age"])

    with col2:
        gender_options = ["Male", "Female", "Other"]
        gender = st.selectbox(
            "Cinsiyet",
            gender_options,
            index=gender_options.index(student["gender"])
                  if student["gender"] in gender_options else 0
        )

    academic_options = ["Undergraduate", "Postgraduate"]
    academic_level = st.selectbox(
        "Akademik Seviye",
        academic_options,
        index=academic_options.index(student["academic_level"])
              if student["academic_level"] in academic_options else 0,
        format_func=lambda x: {"Undergraduate": "🎓 Lisans", "Postgraduate": "📚 Lisansüstü"}[x]
    )

    # ── Part-time İş ─────────────────────────────────────────────────────
    st.markdown('<div class="section-title">💼 Çalışma Durumu</div>', unsafe_allow_html=True)

    part_time_val = st.radio(
        "Part-time iş çalışıyor musun?",
        options=[0, 1],
        index=1 if student["part_time_job"] == 1 else 0,
        format_func=lambda x: "✅ Hayır, sadece öğrenciyim" if x == 0 else "💼 Evet, part-time çalışıyorum",
        horizontal=True
    )

    st.markdown("<br>", unsafe_allow_html=True)

    # ── Güncelle Butonu ───────────────────────────────────────────────────
    if st.button("💾 Değişiklikleri Kaydet", use_container_width=True, type="primary"):
        update_student(
            student_id,
            age,
            gender,
            academic_level,
            int(part_time_val)   # 🔥 BUG DÜZELTMESİ: "Var"/"Yok" string yerine 0/1 int
        )
        # Session'ı da güncelle (günlük analizde kullanılır)
        st.session_state["student_age"]            = age
        st.session_state["student_gender"]         = gender
        st.session_state["student_academic_level"] = academic_level
        st.session_state["student_part_time_job"]  = int(part_time_val)

        st.success("✅ Profil başarıyla güncellendi!")
        st.balloons()