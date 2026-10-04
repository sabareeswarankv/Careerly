import pytest
from pydantic import ValidationError
from models.student import StudentProfile, StudentProfileUpdate
from models.guidance import (
    CareerRecommendation,
    SkillGapItem,
    RoadmapStep,
    PlacementPrepItem,
    CareerGuidanceResponse
)

def test_student_profile_model_validation():
    data = {
        "uid": "user_12345",
        "fullName": "Alex Kumar",
        "email": "alex.kumar@example.com",
        "degree": "B.Tech",
        "department": "Computer Science Engineering",
        "semester": 6,
        "cgpa": 8.4,
        "skills": ["Python", "SQL", "Git"],
        "nonTechnicalSkills": ["Problem Solving", "Communication"],
        "interests": ["Machine Learning", "Web Development"],
        "careerGoal": "AI/ML Engineer",
        "preferredRoles": ["Machine Learning Engineer", "Data Scientist"],
        "improvementAreas": ["Deep Learning", "System Design"]
    }
    profile = StudentProfile.model_validate(data)
    assert profile.uid == "user_12345"
    assert profile.full_name == "Alex Kumar"
    assert profile.semester == 6
    assert profile.cgpa == 8.4
    assert "Python" in profile.technical_skills
    assert profile.career_goal == "AI/ML Engineer"

def test_student_profile_invalid_semester():
    with pytest.raises(ValidationError):
        StudentProfile.model_validate({
            "uid": "1",
            "fullName": "Test",
            "email": "test@test.com",
            "degree": "B.Tech",
            "department": "CSE",
            "semester": 15, # Invalid
            "cgpa": 7.0,
            "careerGoal": "Software Engineer"
        })

def test_career_guidance_response_model():
    sample_response = {
        "career_recommendation": {
            "title": "Machine Learning Engineer",
            "description": "Design and build AI algorithms and production machine learning pipelines."
        },
        "why_it_fits": [
            "Matches strong Python foundation and analytical mindset.",
            "Aligns with stated interest in Artificial Intelligence."
        ],
        "current_strengths": [
            "Solid programming basics in Python",
            "Good foundational grasp of relational databases and SQL"
        ],
        "skill_gaps": [
            {
                "skill": "Deep Learning Frameworks (PyTorch/TensorFlow)",
                "status": "Developing",
                "recommendation": "Build end-to-end computer vision or NLP projects on GitHub."
            }
        ],
        "learning_roadmap": [
            {
                "step": 1,
                "title": "Foundation",
                "description": "Master linear algebra, probability, and advanced Python data structures.",
                "skills_to_learn": ["NumPy", "Pandas", "Linear Algebra"],
                "estimated_timeline": "Weeks 1-3"
            }
        ],
        "placement_preparation": [
            {
                "area": "Technical Interview",
                "advice": "Review ML model evaluation metrics, bias-variance tradeoff, and regularizations.",
                "key_tips": ["Explain ROC-AUC vs Precision-Recall curve", "Practice coding gradient descent from scratch"]
            }
        ]
    }

    guidance = CareerGuidanceResponse.model_validate(sample_response)
    assert guidance.career_recommendation.title == "Machine Learning Engineer"
    assert len(guidance.why_it_fits) == 2
    assert guidance.skill_gaps[0].status == "Developing"
    assert guidance.learning_roadmap[0].step == 1
    assert guidance.placement_preparation[0].area == "Technical Interview"
