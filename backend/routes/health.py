from fastapi import APIRouter
from config.settings import settings
from services.gemini_service import gemini_service

router = APIRouter(tags=["Health"])

@router.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": settings.app_name,
        "ai_engine": "ready" if gemini_service.api_key else "key_not_configured"
    }
