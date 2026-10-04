from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_student_profile_lifecycle():
    profile_data = {
        "uid": "student_test_99",
        "fullName": "Priya Sharma",
        "email": "priya@example.com",
        "degree": "B.E.",
        "department": "Information Science",
        "semester": 6,
        "cgpa": 8.7,
        "skills": ["Java", "Spring Boot", "SQL"],
        "nonTechnicalSkills": ["Leadership", "Presentation"],
        "interests": ["Backend Engineering", "Distributed Systems"],
        "careerGoal": "Backend Engineer",
        "preferredRoles": ["Java Developer", "Backend Engineer"],
        "improvementAreas": ["Microservices", "Docker"]
    }

    post_res = client.post("/api/student/profile", json=profile_data)
    assert post_res.status_code == 200
    res_data = post_res.json()
    assert res_data["uid"] == "student_test_99"
    assert res_data["fullName"] == "Priya Sharma"

    get_res = client.get("/api/student/profile/student_test_99")
    assert get_res.status_code == 200
    assert get_res.json()["careerGoal"] == "Backend Engineer"

    update_data = {
        "cgpa": 8.9,
        "careerGoal": "Senior Backend Architect"
    }
    put_res = client.put("/api/student/profile/student_test_99", json=update_data)
    assert put_res.status_code == 200
    updated_json = put_res.json()
    assert updated_json["cgpa"] == 8.9
    assert updated_json["careerGoal"] == "Senior Backend Architect"

def test_get_nonexistent_profile():
    res = client.get("/api/student/profile/non_existent_uid_12345")
    assert res.status_code == 404
