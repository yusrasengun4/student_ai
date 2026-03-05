import hashlib
from src.database import create_user, get_user_by_email

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


def register_user(email, password, age, gender, academic_level, part_time_job):
    hashed_pw = hash_password(password)
    return create_user(
        email,
        hashed_pw,
        age,
        gender,
        academic_level,
        part_time_job
    )


def login_user(email, password):
    user = get_user_by_email(email)

    if not user:
        return None, "Kullanıcı bulunamadı"

    hashed_input = hash_password(password)

    if hashed_input != user["password"]:
        return None, "Şifre yanlış"

    return user, None