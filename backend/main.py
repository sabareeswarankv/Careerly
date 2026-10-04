import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config.settings import settings
from routes.health import router as health_router
from routes.ai import router as ai_router
from routes.student import router as student_router
from routes.interview import router as interview_router
from routes.resume import router as resume_router

app = FastAPI(
    title=settings.app_name,
    description="Careerly - Student Career Guidance & Placement Backend",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router)
app.include_router(ai_router)
app.include_router(student_router)
app.include_router(interview_router)
app.include_router(resume_router)

@app.get("/")
def root():
    return {
        "app": "Careerly Backend",
        "tagline": "Your career, your next step.",
        "status": "online",
        "docs": "/docs"
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=True
    )
