import pytest
from pydantic import ValidationError
from models.interview import (
    InterviewGenerateRequest,
    InterviewQuestion,
    InterviewGenerateResponse,
    InterviewEvaluateRequest,
    InterviewEvaluateResponse,
)
from models.resume import (
    AtsAnalyzeRequest,
    AtsAnalyzeResponse,
    BulletOptimization,
)

def test_interview_models_validation():
    req = InterviewGenerateRequest(
        role="Frontend Engineer",
        skills=["Flutter", "Dart", "JavaScript"],
        num_questions=3
    )
    assert req.role == "Frontend Engineer"
    assert req.num_questions == 3
    assert len(req.skills) == 3

    q = InterviewQuestion(
        id="q1",
        question="Explain how Flutter manages state using InheritedWidget.",
        category="Technical",
        context_hint="Assesses knowledge of Flutter widget tree and reactivity.",
        sample_approach="Define InheritedWidget, explain of(context) method, contrast with setState."
    )
    assert q.category == "Technical"

    resp = InterviewGenerateResponse(
        role="Frontend Engineer",
        interview_type="Technical",
        questions=[q]
    )
    assert len(resp.questions) == 1

def test_interview_evaluate_models():
    req = InterviewEvaluateRequest(
        role="Software Engineer",
        question="What is the difference between TCP and UDP?",
        student_answer="TCP is connection-oriented and reliable, while UDP is connectionless and faster."
    )
    assert req.role == "Software Engineer"

    resp = InterviewEvaluateResponse(
        score=85,
        verdict="Strong",
        strengths=["Clear concise distinction", "Accurately noted reliability differences"],
        areas_for_improvement=["Could mention 3-way handshake or packet headers"],
        suggested_ideal_answer="TCP ensures ordered, reliable delivery via 3-way handshake...",
        communication_tips=["Structure answer with definition, comparison, then real-world use cases."]
    )
    assert resp.score == 85
    assert resp.verdict == "Strong"

def test_resume_ats_models():
    req = AtsAnalyzeRequest(
        resume_text="Experienced in building Flutter applications with Firebase backend and REST APIs.",
        target_role="Flutter Developer"
    )
    assert req.target_role == "Flutter Developer"

    resp = AtsAnalyzeResponse(
        ats_score=82,
        verdict="Strong Match",
        matching_skills=["Flutter", "Firebase", "REST APIs"],
        missing_critical_skills=["State Management (Bloc/Provider)", "CI/CD", "Unit Testing"],
        formatting_feedback=["Quantify app downloads or user engagement", "Include links to GitHub repositories"],
        bullet_optimizations=[
            BulletOptimization(
                original_text="Built a mobile app for students",
                optimized_text="Architected and deployed Flutter career preparation application serving 500+ active students with 99.8% uptime",
                reason="Added measurable metrics, action verb, and production scale"
            )
        ],
        executive_summary="Solid foundation in modern mobile development with clear upside upon adding testing and state management depth."
    )
    assert resp.ats_score == 82
    assert len(resp.bullet_optimizations) == 1

def test_extract_resume_text_txt():
    from fastapi.testclient import TestClient
    from main import app
    client = TestClient(app)
    content = b"Sabareeswaran - Full Stack Developer\nSkills: Python, Dart, Flutter."
    response = client.post(
        "/api/resume/extract-text",
        files={"file": ("resume.txt", content, "text/plain")}
    )
    assert response.status_code == 200
    data = response.json()
    assert "Full Stack Developer" in data["text"]
    assert data["filename"] == "resume.txt"
