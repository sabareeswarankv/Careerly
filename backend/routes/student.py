from fastapi import APIRouter, HTTPException, Header, Depends
from typing import Optional
from models.student import StudentProfile, StudentProfileUpdate
from services.firebase_service import firebase_service
import logging

logger = logging.getLogger("careerly.routes.student")
router = APIRouter(prefix="/api/student", tags=["Student Profile"])

def get_current_user_id(authorization: Optional[str] = Header(None)) -> Optional[str]:
    """
    Extracts and validates user ID from Authorization Bearer token if provided.
    """
    if not authorization or not authorization.startswith("Bearer "):
        return None
    token = authorization.split(" ")[1]
    decoded = firebase_service.verify_token(token)
    if decoded and "uid" in decoded:
        return decoded["uid"]
    return None

@router.post("/profile", response_model=StudentProfile)
def create_or_update_profile(profile: StudentProfile):
    """
    Create or update a student profile.
    """
    try:
        profile_dict = profile.model_dump(by_alias=True)
        saved = firebase_service.save_student_profile(profile.uid, profile_dict)
        return StudentProfile.model_validate(saved)
    except Exception as e:
        logger.error(f"Error creating/updating profile: {e}")
        raise HTTPException(status_code=500, detail="Failed to save student profile.")

@router.get("/profile/{user_id}", response_model=StudentProfile)
def get_profile(user_id: str, authenticated_uid: Optional[str] = Depends(get_current_user_id)):
    """
    Fetch a student profile by UID. Enforces user isolation when auth token is present.
    """
    if authenticated_uid and authenticated_uid != user_id:
        raise HTTPException(status_code=403, detail="Access denied: Cannot access another student's profile.")

    profile_dict = firebase_service.get_student_profile(user_id)
    if not profile_dict:
        raise HTTPException(status_code=404, detail="Student profile not found.")
    return StudentProfile.model_validate(profile_dict)

@router.put("/profile/{user_id}", response_model=StudentProfile)
def update_profile(user_id: str, updates: StudentProfileUpdate, authenticated_uid: Optional[str] = Depends(get_current_user_id)):
    """
    Update specific student profile fields.
    """
    if authenticated_uid and authenticated_uid != user_id:
        raise HTTPException(status_code=403, detail="Access denied: Cannot modify another student's profile.")

    existing = firebase_service.get_student_profile(user_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Student profile not found to update.")

    update_data = {k: v for k, v in updates.model_dump(by_alias=True, exclude_unset=True).items() if v is not None}
    existing.update(update_data)
    saved = firebase_service.save_student_profile(user_id, existing)
    return StudentProfile.model_validate(saved)
