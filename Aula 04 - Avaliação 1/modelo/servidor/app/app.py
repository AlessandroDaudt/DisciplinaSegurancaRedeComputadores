from flask import Flask, jsonify, redirect, render_template, request, send_file, session, url_for
import hashlib
import hmac
import json
import os
from pathlib import Path


app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET", "lab-only-secret")

USERS_FILE = Path("/app/dados/usuarios.json")
MATERIAL_DIR = Path("/app/dados/materiais")
SALT = "lab-salt-2026:"


def load_users() -> dict:
    with USERS_FILE.open("r", encoding="utf-8") as stream:
        records = json.load(stream)
    return {record["username"]: record for record in records}


USERS = load_users()


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def valid_credentials(username: str, password: str) -> bool:
    record = USERS.get(username)
    if not record:
        return False
    return (
        hmac.compare_digest(sha256_text(username), record["user_sha256"])
        and hmac.compare_digest(sha256_text(SALT + password), record["password_sha256"])
    )


def authenticate(username: str, password: str):
    if not valid_credentials(username, password):
        return None
    return USERS[username]


@app.get("/")
def index():
    return render_template("login.html", error=None, account_count=len(USERS))


@app.post("/login")
def login():
    username = request.form.get("username", "")
    password = request.form.get("password", "")
    record = authenticate(username, password)
    if record:
        session["auth"] = True
        session["username"] = record["username"]
        return redirect(url_for("area"))
    return render_template(
        "login.html",
        error="Usuário ou senha inválidos.",
        account_count=len(USERS),
    ), 401


@app.post("/api/login")
def api_login():
    username = request.form.get("username", "")
    password = request.form.get("password", "")
    if authenticate(username, password):
        return jsonify({"ok": True})
    return jsonify({"ok": False}), 401


@app.get("/area")
def area():
    if not session.get("auth"):
        return redirect(url_for("index"))
    record = USERS.get(session.get("username"))
    if not record:
        session.clear()
        return redirect(url_for("index"))
    return render_template(
        "area.html",
        username=record["username"],
        material_name=record["material"],
        account_count=len(USERS),
    )


@app.get("/download/material.enc")
def download():
    if not session.get("auth"):
        return redirect(url_for("index"))
    record = USERS.get(session.get("username"))
    if not record:
        session.clear()
        return redirect(url_for("index"))
    material = MATERIAL_DIR / record["material"]
    return send_file(material, as_attachment=True, download_name=record["material"])


@app.get("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))


@app.get("/health")
def health():
    return jsonify({"status": "ok", "accounts": len(USERS)})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, threaded=True)
