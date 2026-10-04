import io
import logging
from fastapi import APIRouter, File, HTTPException, UploadFile
from models.resume import AtsAnalyzeRequest, AtsAnalyzeResponse
from pypdf import PdfReader
from services.gemini_service import gemini_service

logger = logging.getLogger("careerly.routes.resume")
router = APIRouter(prefix="/api/resume", tags=["ATS Resume Analyzer"])

@router.post("/analyze-ats", response_model=AtsAnalyzeResponse)
async def analyze_resume_ats(request: AtsAnalyzeRequest):
    if not request.resume_text.strip():
        raise HTTPException(status_code=400, detail="Resume text is required.")
    if len(request.resume_text.strip()) < 30:
        raise HTTPException(
            status_code=400,
            detail="Resume text is too short. Please provide at least a few sentences or project details."
        )
    if not request.target_role.strip():
        raise HTTPException(status_code=400, detail="Target job role is required.")

    try:
        response = gemini_service.analyze_resume_ats(
            resume_text=request.resume_text,
            target_role=request.target_role,
            job_description=request.job_description or "",
        )
        return response
    except ValueError as ve:
        logger.error(f"Configuration error: {ve}")
        raise HTTPException(status_code=500, detail=str(ve))
    except Exception as e:
        logger.error(f"ATS analysis failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Unable to perform ATS analysis at this time. Please try again."
        )

@router.post("/extract-text")
async def extract_resume_file_text(file: UploadFile = File(...)):
    filename = (file.filename or "").lower()
    if not (filename.endswith(".pdf") or filename.endswith(".txt")):
        raise HTTPException(
            status_code=400,
            detail="Only PDF and TXT document formats are supported."
        )

    contents = await file.read()
    if len(contents) == 0:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")
    if len(contents) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File size exceeds the 10MB limit.")

    extracted_text = ""
    if filename.endswith(".txt"):
        try:
            extracted_text = contents.decode("utf-8")
        except UnicodeDecodeError:
            extracted_text = contents.decode("latin-1", errors="ignore")
    else:
        try:
            reader = PdfReader(io.BytesIO(contents))
            extracted_pages = [page.extract_text() or "" for page in reader.pages]
            extracted_text = "\n".join(extracted_pages).strip()
        except Exception as e:
            logger.error(f"PDF parsing error: {e}")
            raise HTTPException(
                status_code=400,
                detail="Unable to read text from the provided PDF file."
            )

    if not extracted_text.strip():
        raise HTTPException(
            status_code=400,
            detail="No readable text found in the uploaded file. Please ensure it contains selectable text."
        )

    return {
        "text": extracted_text,
        "filename": file.filename,
        "character_count": len(extracted_text)
    }
