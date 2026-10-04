import json
import logging
import time
from typing import Dict, Any, List
from google import genai
from config.settings import settings
from models.guidance import CareerGuidanceResponse
from models.interview import (
    InterviewGenerateResponse,
    InterviewEvaluateResponse,
)
from models.resume import AtsAnalyzeResponse

logger = logging.getLogger("careerly.gemini")

class GeminiService:
    CANDIDATE_MODELS: List[str] = [
        "gemini-3.8-flash",
        "gemini-3.5-flash",
        "gemini-3.1-flash-lite",
    ]

    def __init__(self):
        self.api_key = settings.gemini_api_key
        self.primary_model = settings.gemini_model
        self.client = None
        if self.api_key:
            try:
                self.client = genai.Client(api_key=self.api_key)
            except Exception as e:
                logger.error(f"Failed to initialize Gemini client: {e}")

    def _execute_gemini_request(self, prompt: str, schema_class: Any):
        if not self.client:
            if not self.api_key:
                raise ValueError("GEMINI_API_KEY is not configured on the backend server.")
            self.client = genai.Client(api_key=self.api_key)

        models_to_attempt = [self.primary_model] + [m for m in self.CANDIDATE_MODELS if m != self.primary_model]
        last_error = None

        for model_name in models_to_attempt:
            for attempt in range(2):
                try:
                    logger.info(f"Executing request with model {model_name} (attempt {attempt + 1})...")
                    response = self.client.models.generate_content(
                        model=model_name,
                        contents=prompt,
                        config={
                            'response_mime_type': 'application/json',
                            'response_schema': schema_class,
                        }
                    )

                    raw_text = response.text.strip()
                    if raw_text.startswith("```json"):
                        raw_text = raw_text[7:]
                    if raw_text.startswith("```"):
                        raw_text = raw_text[3:]
                    if raw_text.endswith("```"):
                        raw_text = raw_text[:-3]
                    raw_text = raw_text.strip()

                    return schema_class.model_validate_json(raw_text)

                except Exception as e:
                    last_error = e
                    err_str = str(e)
                    logger.warning(f"Model {model_name} attempt {attempt + 1} failed: {err_str}")
                    if "503" in err_str or "UNAVAILABLE" in err_str:
                        time.sleep(1.0)
                        continue
                    break

        raise RuntimeError(f"AI generation encountered an error: {str(last_error)}")

    def generate_career_guidance(self, profile_data: Dict[str, Any]) -> CareerGuidanceResponse:
        degree = profile_data.get("degree", "Undergraduate")
        department = profile_data.get("department", "Engineering")
        semester = profile_data.get("semester", 5)
        cgpa = profile_data.get("cgpa", 7.5)
        technical_skills = profile_data.get("technical_skills") or profile_data.get("skills", [])
        non_tech_skills = profile_data.get("non_technical_skills") or profile_data.get("nonTechnicalSkills", [])
        interests = profile_data.get("interests", [])
        career_goal = profile_data.get("career_goal") or profile_data.get("careerGoal", "Software Professional")
        preferred_roles = profile_data.get("preferred_roles") or profile_data.get("preferredRoles", [])
        improvement_areas = profile_data.get("improvement_areas") or profile_data.get("improvementAreas", [])

        prompt = f"""
You are an expert student career counselor and industry mentor.
Analyze the following student profile and generate structured, actionable, and personalized career guidance.

STUDENT PROFILE:
- Degree: {degree}
- Department: {department}
- Current Semester: Semester {semester}
- CGPA: {cgpa} / 10.0
- Technical Skills: {', '.join(technical_skills) if technical_skills else 'None specified'}
- Soft / Non-Technical Skills: {', '.join(non_tech_skills) if non_tech_skills else 'None specified'}
- Interests & Passions: {', '.join(interests) if interests else 'General technology'}
- Primary Career Goal: {career_goal}
- Preferred Roles: {', '.join(preferred_roles) if preferred_roles else 'Open'}
- Desired Areas for Improvement: {', '.join(improvement_areas) if improvement_areas else 'General technical growth'}

INSTRUCTIONS & GUIDELINES:
1. Provide a primary career recommendation that fits the student's background, current progress, and stated goals.
2. Formulate 3-4 clear reasons explaining why this career path may be a strong fit for their profile.
3. Identify 3-4 current strengths based on what they already know.
4. Highlight 4-6 skill gaps. For each skill, evaluate the status strictly as one of: 'Strong', 'Developing', or 'Needs Improvement', and provide actionable recommendations. Do not fabricate numerical percentages.
5. Create a 5-step structured learning roadmap with realistic timelines and clear action items.
6. Provide specific placement preparation advice across 5 key areas: 'Aptitude', 'Technical Interview', 'Coding', 'HR Interview', and 'Resume'.
7. Tone: Encouraging, realistic, constructive, and tailored. Never present outcomes as guaranteed.
"""
        return self._execute_gemini_request(prompt, CareerGuidanceResponse)

    def generate_interview_questions(
        self,
        role: str,
        experience_level: str,
        interview_type: str,
        skills: List[str],
        num_questions: int = 4
    ) -> InterviewGenerateResponse:
        prompt = f"""
You are an expert technical interviewer and HR hiring manager conducting college campus placement interviews.
Create {num_questions} realistic and challenging interview questions for a candidate aiming for the role of '{role}'.

CANDIDATE DETAILS:
- Target Role: {role}
- Experience Level: {experience_level}
- Interview Focus Type: {interview_type}
- Key Skills / Tech Stack: {', '.join(skills) if skills else 'Core Computer Science fundamentals and problem solving'}

GUIDELINES:
1. If Interview Focus is 'Mixed', generate a realistic distribution of Technical questions, System/Logic scenarios, and Behavioral/HR questions.
2. For each question:
   - id: a unique identifier e.g. "q1", "q2", "q3"
   - question: the exact interviewer prompt
   - category: strictly one of 'Technical', 'System / Logic', 'Behavioral', 'HR'
   - context_hint: a 1-sentence tip indicating what key qualities or concepts the interviewer is assessing
   - sample_approach: a structured 2-3 bullet point recommendation on how a successful candidate structures their response
"""
        return self._execute_gemini_request(prompt, InterviewGenerateResponse)

    def evaluate_interview_answer(
        self,
        role: str,
        question: str,
        category: str,
        student_answer: str
    ) -> InterviewEvaluateResponse:
        prompt = f"""
You are a senior technical hiring lead and campus placement evaluator.
Evaluate the candidate's answer for the following placement interview question:

Role: {role}
Category: {category}
Question: {question}

CANDIDATE'S SUBMITTED ANSWER:
\"\"\"{student_answer}\"\"\"

EVALUATION GUIDELINES:
1. score: Integer between 0 and 100 based on technical accuracy, structure, clarity, and relevance.
2. verdict: Strictly one of 'Excellent', 'Strong', 'Needs Improvement', or 'Incomplete'.
3. strengths: 2-3 specific positive aspects of their answer.
4. areas_for_improvement: 2-3 clear, constructive gaps or missing concepts.
5. suggested_ideal_answer: A model, comprehensive, and professional answer demonstrating how a top candidate would answer this question.
6. communication_tips: 2 actionable delivery or phrasing tips.
"""
        return self._execute_gemini_request(prompt, InterviewEvaluateResponse)

    def analyze_resume_ats(
        self,
        resume_text: str,
        target_role: str,
        job_description: str = ""
    ) -> AtsAnalyzeResponse:
        prompt = f"""
You are an enterprise ATS (Applicant Tracking System) architect and senior technical recruiter.
Evaluate the following student resume for the target role: '{target_role}'.

OPTIONAL JOB POSTING DESCRIPTION:
\"\"\"{job_description if job_description.strip() else 'Standard industry job description and competencies for ' + target_role}\"\"\"

STUDENT RESUME TEXT:
\"\"\"{resume_text}\"\"\"

ATS AUDIT GUIDELINES:
1. ats_score: Realistic score from 0 to 100 based on keyword match, role competency alignment, quantifiable achievements, and clear project impact.
2. verdict: Concise assessment e.g. 'High ATS Match', 'Moderate Fit - Skill Gaps Detected', or 'Needs Keyword & Structure Overhaul'.
3. matching_skills: List of detected technical and soft skills that match the target role.
4. missing_critical_skills: List of essential skills, frameworks, or concepts absent in the resume that recruiters look for.
5. formatting_feedback: 2-4 professional formatting, section hierarchy, or ATS readability suggestions.
6. bullet_optimizations: 2-3 examples transforming passive or generic resume lines into high-impact, metrics-driven STAR statements. Each item must have 'original_text', 'optimized_text', and 'reason'.
7. executive_summary: A 2-3 sentence recruiter synthesis of the candidate's current profile competitiveness.
"""
        return self._execute_gemini_request(prompt, AtsAnalyzeResponse)

gemini_service = GeminiService()
