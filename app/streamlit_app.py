import streamlit as st
import sys
import os

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(ROOT_DIR)

from src.database import init_db

init_db()

st.set_page_config(
    page_title="EduBoost AI",
    page_icon="🎓",
    layout="wide"
)

st.title("🎓 EduBoost AI")

if "student_id" not in st.session_state:
    import pages.login as login
    login.run()

else:
    st.sidebar.title("Navigasyon")

    page = st.sidebar.selectbox(
        "Sayfa Seçin",
        ["Profil", "Günlük Analiz", "Haftalık Rapor", "Çıkış"]
    )

    if page == "Profil":
        import pages.profil as profil
        profil.run()

    elif page == "Günlük Analiz":
        import pages.gunluk_analiz as gunluk_analiz
        gunluk_analiz.run()

    elif page == "Haftalık Rapor":
        import pages.haftalik_rapor as haftalik_rapor
        haftalik_rapor.run()

    elif page == "Çıkış":
        st.session_state.clear()
        st.success("Çıkış yapıldı.")
        st.rerun()
        