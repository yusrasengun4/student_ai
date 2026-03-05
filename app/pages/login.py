import streamlit as st
from src.auth import login_user, register_user

def run():
    st.title("🔐 Giriş / Kayıt")

    menu = st.radio("Seçim", ["Login", "Register"])

    email = st.text_input("Email")
    password = st.text_input("Şifre", type="password")

    if menu == "Register":

        age = st.number_input("Yaş", 15, 40, 20)
        gender = st.selectbox("Cinsiyet", ["Male", "Female", "Other"])
        academic_level = st.selectbox("Akademik Seviye", ["Undergraduate", "Postgraduate"])
        part_time = st.radio("Part-time İş", ["Yok", "Var"])

        if st.button("Kayıt Ol"):
            user_id = register_user(
                email,
                password,
                age,
                gender,
                academic_level,
                1 if part_time == "Var" else 0
            )

            st.success("Kayıt başarılı! Giriş yapabilirsiniz.")

    else:

        if st.button("Giriş Yap"):
            user, error = login_user(email, password)

            if error:
                st.error(error)
            else:
                st.session_state["student_id"] = user["id"]
                st.session_state["email"] = user["email"]
                st.session_state["age"] = user["age"]
                st.session_state["gender"] = user["gender"]
                st.session_state["academic_level"] = user["academic_level"]
                st.session_state["part_time_job"] = user["part_time_job"]

                st.success("Giriş başarılı")
                st.rerun()