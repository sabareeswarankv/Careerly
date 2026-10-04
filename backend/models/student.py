from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict

class StudentProfile(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    uid: str = Field(..., description="Unique Firebase User ID")
    full_name: str = Field(..., alias="fullName", description="Student full name")
    email: str = Field(..., description="Student email address")
    degree: str = Field(..., description="Degree (e.g. B.Tech, B.E., B.Sc, M.C.A.)")
    department: str = Field(..., description="Department (e.g. Computer Science, Information Technology)")
    semester: int = Field(..., ge=1, le=12, description="Current semester number")
    cgpa: float = Field(..., ge=0.0, le=10.0, description="Current CGPA on 10-point scale")
    technical_skills: List[str] = Field(default_factory=list, alias="skills", description="List of technical skills")
    non_technical_skills: List[str] = Field(default_factory=list, alias="nonTechnicalSkills", description="List of soft / non-technical skills")
    interests: List[str] = Field(default_factory=list, description="Career and technology interests")
    career_goal: str = Field(..., alias="careerGoal", description="Target career goal or dream role")
    preferred_roles: List[str] = Field(default_factory=list, alias="preferredRoles", description="Roles of interest")
    improvement_areas: List[str] = Field(default_factory=list, alias="improvementAreas", description="Areas student wants to improve")
    created_at: Optional[str] = Field(default=None, alias="createdAt")
    updated_at: Optional[str] = Field(default=None, alias="updatedAt")

class StudentProfileUpdate(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    full_name: Optional[str] = Field(default=None, alias="fullName")
    degree: Optional[str] = None
    department: Optional[str] = None
    semester: Optional[int] = Field(default=None, ge=1, le=12)
    cgpa: Optional[float] = Field(default=None, ge=0.0, le=10.0)
    technical_skills: Optional[List[str]] = Field(default=None, alias="skills")
    non_technical_skills: Optional[List[str]] = Field(default=None, alias="nonTechnicalSkills")
    interests: Optional[List[str]] = None
    career_goal: Optional[str] = Field(default=None, alias="careerGoal")
    preferred_roles: Optional[List[str]] = Field(default=None, alias="preferredRoles")
    improvement_areas: Optional[List[str]] = Field(default=None, alias="improvementAreas")
    updated_at: Optional[str] = Field(default=None, alias="updatedAt")
