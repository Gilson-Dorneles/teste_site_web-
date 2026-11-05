import os
import re
import secrets
import sqlite3
from pathlib import Path

from flask import Flask, flash, g, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash, generate_password_hash


app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY") or secrets.token_hex(32)
app.config["DATABASE"] = os.environ.get(
    "DATABASE_PATH", str(Path(__file__).with_name("users.sqlite3"))
)
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024
app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"

SEX_LABELS = {
    "feminino": "Feminino",
    "masculino": "Masculino",
    "outro": "Outro",
    "nao_informar": "Prefiro não informar",
}


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(app.config["DATABASE"])
        g.db.row_factory = sqlite3.Row
    return g.db


@app.teardown_appcontext
def close_db(_error=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def init_db():
    with app.app_context():
        get_db().execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                age INTEGER NOT NULL CHECK (age BETWEEN 0 AND 130),
                sex TEXT NOT NULL,
                username TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
            """
        )
        get_db().commit()


@app.before_request
def protect_forms():
    if request.method == "POST":
        submitted = request.form.get("csrf_token", "")
        expected = session.get("csrf_token", "")
        if not expected or not secrets.compare_digest(submitted, expected):
            flash("Sua sessão expirou. Tente novamente.", "error")
            return redirect(url_for("index"))


@app.context_processor
def inject_template_values():
    def csrf_token():
        if "csrf_token" not in session:
            session["csrf_token"] = secrets.token_urlsafe(32)
        return session["csrf_token"]

    return {"csrf_token": csrf_token, "sex_labels": SEX_LABELS}


@app.get("/")
def index():
    if session.get("user_id"):
        return redirect(url_for("dashboard"))
    return render_template("index.html", active_form=request.args.get("form", "login"))


@app.post("/register")
def register():
    name = request.form.get("name", "").strip()
    age_text = request.form.get("age", "").strip()
    sex = request.form.get("sex", "")
    username = request.form.get("username", "").strip()
    password = request.form.get("password", "")

    if not name or len(name) > 100:
        flash("Informe um nome com até 100 caracteres.", "error")
        return redirect(url_for("index", form="register"))
    if not age_text.isdecimal() or not 0 <= int(age_text) <= 130:
        flash("Informe uma idade entre 0 e 130 anos.", "error")
        return redirect(url_for("index", form="register"))
    if sex not in SEX_LABELS:
        flash("Selecione uma opção de sexo.", "error")
        return redirect(url_for("index", form="register"))
    if not re.fullmatch(r"[A-Za-z0-9_.-]{3,30}", username):
        flash("O usuário deve ter de 3 a 30 caracteres: letras, números, ponto, hífen ou sublinhado.", "error")
        return redirect(url_for("index", form="register"))
    if len(password) < 8:
        flash("A senha deve ter pelo menos 8 caracteres.", "error")
        return redirect(url_for("index", form="register"))

    try:
        db = get_db()
        db.execute(
            "INSERT INTO users (name, age, sex, username, password_hash) VALUES (?, ?, ?, ?, ?)",
            (name, int(age_text), sex, username, generate_password_hash(password)),
        )
        db.commit()
    except sqlite3.IntegrityError:
        flash("Este usuário já está cadastrado.", "error")
        return redirect(url_for("index", form="register"))

    flash("Cadastro realizado. Entre com seu usuário e senha.", "success")
    return redirect(url_for("index", form="login"))


@app.post("/login")
def login():
    username = request.form.get("username", "").strip()
    password = request.form.get("password", "")
    user = get_db().execute(
        "SELECT id, password_hash FROM users WHERE username = ?", (username,)
    ).fetchone()

    if user is None or not check_password_hash(user["password_hash"], password):
        flash("Usuário ou senha inválidos.", "error")
        return redirect(url_for("index", form="login"))

    session.clear()
    session["user_id"] = user["id"]
    return redirect(url_for("dashboard"))


@app.get("/dashboard")
def dashboard():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("index"))

    db = get_db()
    current_user = db.execute(
        "SELECT name, username FROM users WHERE id = ?", (user_id,)
    ).fetchone()
    if current_user is None:
        session.clear()
        return redirect(url_for("index"))

    users = db.execute(
        "SELECT id, name, age, sex, username, created_at FROM users ORDER BY name COLLATE NOCASE"
    ).fetchall()
    return render_template("dashboard.html", current_user=current_user, users=users)


@app.post("/users/<int:user_id>/delete")
def delete_user(user_id):
    current_user_id = session.get("user_id")
    if not current_user_id:
        return redirect(url_for("index"))

    db = get_db()
    result = db.execute("DELETE FROM users WHERE id = ?", (user_id,))
    db.commit()
    if result.rowcount == 0:
        flash("Cadastro não encontrado.", "error")
    else:
        flash("Cadastro excluído.", "success")

    if user_id == current_user_id and result.rowcount:
        session.clear()
        return redirect(url_for("index"))
    return redirect(url_for("dashboard"))


@app.post("/logout")
def logout():
    session.clear()
    flash("Você saiu da sua conta.", "success")
    return redirect(url_for("index"))


if __name__ == "__main__":
    init_db()
    app.run(host="127.0.0.1", port=int(os.environ.get("PORT", "5000")))