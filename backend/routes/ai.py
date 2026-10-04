from fastapi import APIRouter, HTTPException, Depends
from models.guidance import CareerGuidanceResponse, CareerGuidanceRequest
from services.gemini_service import gemini_service
import logging

logger = logging.getLogger("careerly.routes.ai")
router = APIRouter(prefix="/api/ai", tags=["AI Guidance"])

@router.post("/career-guidance", response_model=CareerGuidanceResponse)
async def generate_career_guidance(request: CareerGuidanceRequest):
    """
    Generate personalized student career guidance, roadmap, and placement recommendations.
    """
    profile = request.profile
    if not profile:
        raise HTTPException(status_code=400, detail="Student profile data is required.")

    career_goal = profile.get("career_goal") or profile.get("careerGoal")
    skills = profile.get("technical_skills") or profile.get("skills", [])
    if not career_goal and not skills:
        raise HTTPException(
            status_code=400,
            detail="Profile must contain at least a career goal or technical skills to personalize guidance."
        )

    try:
        guidance = gemini_service.generate_career_guidance(profile)
        return guidance
    except ValueError as ve:
        logger.error(f"Configuration error: {ve}")
        raise HTTPException(status_code=500, detail=str(ve))
    except Exception as e:
        logger.error(f"Guidance generation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Unable to generate career guidance at this moment. Please check your inputs and try again."
        )
