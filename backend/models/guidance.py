from typing import List, Optional
from pydantic import BaseModel, Field

class CareerRecommendation(BaseModel):
    title: str = Field(..., description="Recommended career path title")
    description: str = Field(..., description="Professional overview of why this career is a strong match")

class SkillGapItem(BaseModel):
    skill: str = Field(..., description="Skill name")
    status: str = Field(..., description="Proficiency assessment: Strong, Developing, or Needs Improvement")
    recommendation: str = Field(..., description="Actionable recommendation on how to build or improve this skill")

class RoadmapStep(BaseModel):
    step: int = Field(..., description="Step index, starting at 1")
    title: str = Field(..., description="Stage title (e.g. Foundation, Core Skills, Projects, Advanced Learning, Placement Preparation)")
    description: str = Field(..., description="Detailed description of what to study and build in this stage")
    skills_to_learn: List[str] = Field(default_factory=list, description="Specific skills, libraries, or tools to master in this phase")
    estimated_timeline: str = Field(..., description="Suggested timeframe (e.g. 2-3 weeks, Month 1)")

class PlacementPrepItem(BaseModel):
    area: str = Field(..., description="Category: Aptitude, Technical Interview, Coding, HR Interview, or Resume")
    advice: str = Field(..., description="Tailored preparation guidance for this area")
    key_tips: List[str] = Field(default_factory=list, description="Specific high-impact tips or questions to prepare")

class CareerGuidanceResponse(BaseModel):
    career_recommendation: CareerRecommendation = Field(..., description="Primary recommended career path")
    why_it_fits: List[str] = Field(..., description="Reasons why this path aligns with the student profile")
    current_strengths: List[str] = Field(..., description="Student's identified key strengths and foundational competencies")
    skill_gaps: List[SkillGapItem] = Field(..., description="Specific skills evaluated with status and recommendations")
    learning_roadmap: List[RoadmapStep] = Field(..., description="Step-by-step personalized learning milestones")
    placement_preparation: List[PlacementPrepItem] = Field(..., description="Placement and interview preparation roadmap across core domains")
    disclaimer: str = Field(
        default="Guidance and suggestions are based on your current profile to help guide your preparation. Outcomes depend on your dedication and practice.",
        description="Responsible AI disclaimer"
    )

class CareerGuidanceRequest(BaseModel):
    profile: dict = Field(..., description="Student profile dictionary or full student profile")
