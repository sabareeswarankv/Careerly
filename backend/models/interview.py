from pydantic import BaseModel, Field
from typing import List, Optional

class InterviewGenerateRequest(BaseModel):
    role: str = Field(..., description="Target role, e.g. Full Stack Developer")
    experience_level: str = Field(default="Fresher / Entry-Level", description="Target experience level")
    interview_type: str = Field(default="Mixed", description="Technical, HR & Behavioral, or Mixed")
    skills: List[str] = Field(default_factory=list, description="Candidate skills or tech stack")
    num_questions: int = Field(default=4, ge=1, le=8, description="Number of questions to generate")

class InterviewQuestion(BaseModel):
    id: str
    question: str
    category: str
    context_hint: str
    sample_approach: str

class InterviewGenerateResponse(BaseModel):
    role: str
    interview_type: str
    questions: List[InterviewQuestion]

class InterviewEvaluateRequest(BaseModel):
    role: str
    question: str
    category: str = "Technical"
    student_answer: str

class InterviewEvaluateResponse(BaseModel):
    score: int
    verdict: str
    strengths: List[str]
    areas_for_improvement: List[str]
    suggested_ideal_answer: str
    communication_tips: List[str]
