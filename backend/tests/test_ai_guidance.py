from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_career_guidance_empty_payload():
    response = client.post("/api/ai/career-guidance", json={"profile": {}})
    assert response.status_code == 400

def test_career_guidance_generation():
    """
    Test invoking the career guidance endpoint with a complete student profile.
    Since GEMINI_API_KEY is available in the environment, this tests the real Gemini pipeline!
    """
    payload = {
        "profile": {
            "uid": "test_student_ai_01",
            "fullName": "Rahul Verma",
            "email": "rahul@example.com",
            "degree": "B.Tech",
            "department": "Computer Science",
            "semester": 6,
            "cgpa": 8.2,
            "skills": ["Python", "Pandas", "SQL", "Git"],
            "nonTechnicalSkills": ["Problem Solving", "Teamwork"],
            "interests": ["Data Science", "Machine Learning"],
            "careerGoal": "Data Scientist",
            "preferredRoles": ["Data Scientist", "Data Analyst"],
            "improvementAreas": ["Deep Learning", "Statistics"]
        }
    }

    response = client.post("/api/ai/career-guidance", json=payload)
    assert response.status_code == 200
    data = response.json()

    assert "career_recommendation" in data
    assert "title" in data["career_recommendation"]
    assert "description" in data["career_recommendation"]

    assert "why_it_fits" in data
    assert isinstance(data["why_it_fits"], list)
    assert len(data["why_it_fits"]) > 0

    assert "current_strengths" in data
    assert isinstance(data["current_strengths"], list)
    assert len(data["current_strengths"]) > 0

    assert "skill_gaps" in data
    assert isinstance(data["skill_gaps"], list)
    for gap in data["skill_gaps"]:
        assert "skill" in gap
        assert gap["status"] in ["Strong", "Developing", "Needs Improvement"]
        assert "recommendation" in gap

    assert "learning_roadmap" in data
    assert isinstance(data["learning_roadmap"], list)
    for step in data["learning_roadmap"]:
        assert "step" in step
        assert "title" in step
        assert "description" in step

    assert "placement_preparation" in data
    assert isinstance(data["placement_preparation"], list)
    for prep in data["placement_preparation"]:
        assert "area" in prep
        assert "advice" in prep
