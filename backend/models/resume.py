from pydantic import BaseModel, Field
from typing import List, Dict, Optional

class BulletOptimization(BaseModel):
    original_text: str
    optimized_text: str
    reason: str

class AtsAnalyzeRequest(BaseModel):
    resume_text: str = Field(..., min_length=20, description="Raw text of the resume or portfolio summary")
    target_role: str = Field(..., description="Target job role")
    job_description: Optional[str] = Field(default="", description="Optional job posting description")

class AtsAnalyzeResponse(BaseModel):
    ats_score: int = Field(..., ge=0, le=100)
    verdict: str
    matching_skills: List[str]
    missing_critical_skills: List[str]
    formatting_feedback: List[str]
    bullet_optimizations: List[BulletOptimization]
    executive_summary: str
