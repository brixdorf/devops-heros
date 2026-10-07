import pytest

import app as app_module


@pytest.fixture
def client():
    app_module.TASKS.clear()
    app_module.app.config["TESTING"] = True
    return app_module.app.test_client()


def test_home(client):
    res = client.get("/")
    assert res.status_code == 200
    assert "message" in res.get_json()


def test_health(client):
    assert client.get("/health").get_json() == {"status": "ok"}


def test_add_and_list_tasks(client):
    res = client.post("/tasks", json={"title": "write README"})
    assert res.status_code == 201
    assert client.get("/tasks").get_json()[0]["title"] == "write README"


def test_add_task_requires_title(client):
    assert client.post("/tasks", json={}).status_code == 400
