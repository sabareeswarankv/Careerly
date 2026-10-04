from fastapi import APIRouter, HTTPException
import logging
from models.interview import (
    InterviewGenerateRequest,
    InterviewGenerateResponse,
    InterviewEvaluateRequest,
    InterviewEvaluateResponse,
)
from services.gemini_service import gemini_service

logger = logging.getLogger("careerly.routes.interview")
router = APIRouter(prefix="/api/interview", tags=["AI Interview Simulator"])

@router.post("/generate", response_model=InterviewGenerateResponse)
async def generate_questions(request: InterviewGenerateRequest):
    if not request.role.strip():
        raise HTTPException(status_code=400, detail="Target role is required.")

    try:
        response = gemini_service.generate_interview_questions(
            role=request.role,
            experience_level=request.experience_level,
            interview_type=request.interview_type,
            skills=request.skills,
            num_questions=request.num_questions,
        )
        return response
    except ValueError as ve:
        logger.error(f"Configuration error: {ve}")
        raise HTTPException(status_code=500, detail=str(ve))
    except Exception as e:
        logger.error(f"Interview question generation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Unable to generate interview questions right now. Please try again."
        )

@router.post("/evaluate", response_model=InterviewEvaluateResponse)
async def evaluate_answer(request: InterviewEvaluateRequest):
    if not request.question.strip() or not request.student_answer.strip():
        raise HTTPException(
            status_code=400,
            detail="Both the interview question and the student answer are required."
        )

    try:
        response = gemini_service.evaluate_interview_answer(
            role=request.role,
            question=request.question,
            category=request.category,
            student_answer=request.student_answer,
        )
        return response
    except ValueError as ve:
        logger.error(f"Configuration error: {ve}")
        raise HTTPException(status_code=500, detail=str(ve))
    except Exception as e:
        logger.error(f"Answer evaluation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Unable to evaluate interview answer right now. Please try again."
        )
