import os

from flask import Flask, jsonify, request

app = Flask(__name__)

TASKS = []


@app.get("/")
def home():
    return jsonify(
        message=os.environ.get("APP_GREETING", "Hello from the Session 16 CI/CD demo"),
        version=os.environ.get("APP_VERSION", "dev"),
    )


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/tasks")
def list_tasks():
    return jsonify(TASKS)


@app.post("/tasks")
def add_task():
    data = request.get_json(silent=True) or {}
    title = str(data.get("title", "")).strip()
    if not title:
        return jsonify(error="title is required"), 400
    task = {"id": len(TASKS) + 1, "title": title, "done": False}
    TASKS.append(task)
    return jsonify(task), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
