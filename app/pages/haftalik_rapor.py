import streamlit as st
import matplotlib.pyplot as plt
import pandas as pd                     # ← add this
from src.database import get_last_7_days
import plotly.express as px             # ensure plotly is installed
# …rest of file…

from src.database import get_last_7_days

def run():
    st.title("📊 Haftalık Performans Raporu")

    if "student_id" not in st.session_state:
        st.warning("Önce giriş yapın.")
        st.stop()

    student_id = st.session_state["student_id"]
    data = get_last_7_days(student_id)

    if not data:
        st.warning("Henüz yeterli veri yok. Analiz için birkaç gün kayıt yapmalısın.")
        st.stop()

    # 1. VERİ HAZIRLAMA
    # Sütunlar: date, predicted_score, burnout_risk, productivity_score, focus_index
    df = pd.DataFrame(data, columns=["Tarih", "Başarı", "Tükenmişlik", "Verimlilik", "Odak"])
    df = df.iloc[::-1]  # Grafikler için kronolojik sırala (eskiden yeniye)

    # 2. ÜST ÖZET METRİKLERİ
    avg_score = df["Başarı"].mean()
    avg_prod = df["Verimlilik"].mean()
    avg_focus = df["Odak"].mean()
    
    m1, m2, m3 = st.columns(3)
    m1.metric("Ort. Sınav Puanı", f"{avg_score:.1f}")
    m2.metric("Ort. Verimlilik", f"{avg_prod:.1f}%")
    m3.metric("Ort. Odak İndeksi", f"{avg_focus:.1f}")

    st.markdown("---")

    # 3. KORELASYON GRAFİĞİ (Başarı vs Odak vs Verimlilik)
    st.subheader("📈 Performans Bileşenleri Trendi")
    fig = px.line(df, x="Tarih", y=["Başarı", "Verimlilik", "Odak"], 
                  title="Başarı, Verimlilik ve Odak İlişkisi",
                  markers=True, line_shape="spline")
    fig.update_layout(hovermode="x unified")
    st.plotly_chart(fig, use_container_width=True)

    # 4. TÜKENMİŞLİK ANALİZİ (Isı Haritası Tarzı)
    st.subheader("🔥 Tükenmişlik Takibi")
    # Burnout'u numerik yapalım (Renklendirme için)
    risk_map = {"Low": 1, "Medium": 2, "High": 3}
    df["Risk_Sayı"] = df["Tükenmişlik"].map(risk_map)
    
    fig_burn = px.bar(df, x="Tarih", y="Risk_Sayı", color="Tükenmişlik",
                      color_discrete_map={"Low": "#22c55e", "Medium": "#f59e0b", "High": "#ef4444"},
                      title="Günlük Tükenmişlik Seviyeleri")
    fig_burn.update_layout(yaxis_visible=False) # Sayıları gizle, renkler yetsin
    st.plotly_chart(fig_burn, use_container_width=True)

    # 5. AKILLI HAFTALIK ÖNERİ MOTORU
    st.markdown("### 🧠 Haftalık Zeka Analizi")
    
    # Trend analizi için son iki günü kıyasla
    if len(df) >= 2:
        last_score = df["Başarı"].iloc[-1]
        prev_score = df["Başarı"].iloc[-2]
        
        with st.container():
            col_a, col_b = st.columns(2)
            
            # Verimlilik-Odak İlişkisi Analizi
            if avg_focus < avg_prod:
                col_a.info("🎯 **Analiz:** Verimliliğin yüksek olsa da odaklanma süren kısa kalmış. 'Deep Work' seansları denemelisin.")
            else:
                col_a.success("🌟 **Analiz:** Odaklanma becerin verimliliğini besliyor. Bu disiplini koru.")

            # Tükenmişlik Uyarısı
            high_burnout_days = len(df[df["Tükenmişlik"] == "High"])
            if high_burnout_days >= 3:
                col_b.error(f"⚠️ **Kritik:** Bu hafta {high_burnout_days} gün yüksek tükenmişlik yaşadın. Programını hafifletmelisin.")
            elif last_score > prev_score:
                col_b.success(f"📈 **Gelişim:** Düne göre puanını {last_score - prev_score:.1f} birim artırdın. Yükseliş devam ediyor!")

    st.markdown("---")
    if st.button("📥 Haftalık Raporu PDF Olarak İndir (Yakında)", disabled=True):
        pass