import sqlite3
import pandas as pd

DB_NAME = "eduboost_data.db"


def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()

    # STUDENTS TABLE
    c.execute('''
        CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            age INTEGER,
            gender TEXT,
            academic_level TEXT,
            part_time_job INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # DAILY RECORDS TABLE
    c.execute('''
        CREATE TABLE IF NOT EXISTS daily_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            date DATE DEFAULT CURRENT_DATE,

            study_hours REAL,
            self_study_hours REAL,
            online_classes_hours REAL,
            sleep_hours REAL,
            social_media_hours REAL,
            gaming_hours REAL,
            exercise_minutes INTEGER,
            caffeine_intake_mg INTEGER,
            mental_health_score INTEGER,
            internet_quality TEXT,
            upcoming_deadline INTEGER,

            predicted_score REAL,
            burnout_risk TEXT,
            burnout_confidence REAL,
            productivity_score REAL,
            focus_index REAL,

            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(student_id) REFERENCES students(id)
        )
    ''')

    conn.commit()
    conn.close()


# -----------------------------
# STUDENT OPERATIONS
# -----------------------------

def create_user(email, password, age, gender, academic_level, part_time_job):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO students (email, password, age, gender, academic_level, part_time_job)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (email, password, age, gender, academic_level, part_time_job))

    conn.commit()
    user_id = cursor.lastrowid
    conn.close()

    return user_id


def get_user_by_email(email):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, email, password, age, gender, academic_level, part_time_job
        FROM students
        WHERE email = ?
    """, (email,))

    row = cursor.fetchone()
    conn.close()

    if row:
        return {
            "id": row[0],
            "email": row[1],
            "password": row[2],
            "age": row[3],
            "gender": row[4],
            "academic_level": row[5],
            "part_time_job": row[6]
        }
    return None


def get_student(student_id):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT age, gender, academic_level, part_time_job
        FROM students
        WHERE id = ?
    """, (student_id,))

    result = cursor.fetchone()
    conn.close()

    if result:
        return {
            "age": result[0],
            "gender": result[1],
            "academic_level": result[2],
            "part_time_job": result[3]
        }

    return None  # 🔥 DÜZELTİLDİ


def update_student(student_id, age, gender, academic_level, part_time_job):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE students
        SET age = ?, gender = ?, academic_level = ?, part_time_job = ?
        WHERE id = ?
    """, (age, gender, academic_level, part_time_job, student_id))

    conn.commit()
    conn.close()


# -----------------------------
# DAILY RECORD OPERATIONS
# -----------------------------

def save_daily_record(student_id, data, predictions):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO daily_records (
            student_id,
            study_hours,
            self_study_hours,
            online_classes_hours,
            sleep_hours,
            social_media_hours,
            gaming_hours,
            exercise_minutes,
            caffeine_intake_mg,
            mental_health_score,
            internet_quality,
            upcoming_deadline,
            predicted_score,
            burnout_risk,
            burnout_confidence,
            productivity_score,
            focus_index
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        student_id,
        data["study_hours"],
        data["self_study_hours"],
        data["online_classes_hours"],
        data["sleep_hours"],
        data["social_media_hours"],
        data["gaming_hours"],
        data["exercise_minutes"],
        data["caffeine_intake_mg"],
        data["mental_health_score"],
        data["internet_quality"],
        data["upcoming_deadline"],
        predictions["predicted_score"],   # 🔥 exam_score yerine predicted_score
        predictions["burnout_risk"],
        predictions["burnout_confidence"],
        predictions["productivity_score"],
        predictions["focus_index"]
    ))

    conn.commit()
    conn.close()


def get_last_7_days(student_id):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT date, predicted_score, burnout_risk, productivity_score, focus_index
        FROM daily_records
        WHERE student_id = ?
        ORDER BY date DESC
        LIMIT 7
    """, (student_id,))

    rows = cursor.fetchall()
    conn.close()
    return rows


def get_last_7_days_burnout(student_id):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT date, burnout_risk
        FROM daily_records
        WHERE student_id = ?
        ORDER BY date DESC
        LIMIT 7
    """, (student_id,))

    rows = cursor.fetchall()
    conn.close()
    return rows