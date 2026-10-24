
from app import app


def test_health_endpoint():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_home_endpoint():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200
    data = response.get_json()

    assert data["application"] == "Progress Partners Assessment App"
    assert data["status"] == "running"
