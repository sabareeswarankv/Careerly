# Careerly

> **Your career, your next step.**

Careerly is a full-stack, AI-powered student career guidance and placement preparation application designed to help students discover tailored career pathways, identify skill gaps, track personalized learning roadmaps, and prepare for campus placements and technical interviews.

---

## 1. Product Overview

Careerly is an independent career platform built for students across engineering and technology disciplines. Rather than giving generic suggestions, it analyzes a student's real background:
- Academic foundation (degree, department, semester, CGPA)
- Current technical & non-technical proficiencies
- Personal interests & aspirations
- Primary career goal & target roles
- Self-identified improvement areas

From this structured profile, Careerly uses Google Gemini to generate:
1. **Personalized Career Recommendations** – High-fit career pathways explained in student-friendly terms.
2. **"Why This Fits You"** – Clear explanations linking the student's background to the recommended role.
3. **Current Strengths** – Recognition of existing technical competencies.
4. **Skill Gaps** – Clear proficiency indicators (`Strong`, `Developing`, `Needs Improvement`) with actionable next steps.
5. **Interactive Learning Roadmap** – Step-by-step milestones (Foundation, Core Skills, Projects, Advanced Learning, Placement Preparation) with completion tracking.
6. **Placement Preparation** – Actionable guidance across 5 core pillars: Aptitude, Technical Interview, Coding, HR Interview, and Resume.
7. **Progress Tracking** – Real stored metrics reflecting profile completion, saved guidance sessions, and roadmap milestones.

---

## 2. Architecture & Data Flow

Careerly follows a clean, decoupled architecture:

```
┌────────────────────────────────────────────────────────┐
│            Flutter Application (Frontend)              │
│       Responsive: Mobile, Tablet, Laptop, Web          │
└──────────────────────────┬─────────────────────────────┘
                           │
                           │ REST / JSON API Calls
                           ▼
┌────────────────────────────────────────────────────────┐
│             FastAPI Backend (Python 3.14)              │
│           Validation (Pydantic), Port 8000             │
└──────────────┬───────────────────────────┬─────────────┘
               │                           │
               ▼                           ▼
┌───────────────────────────────┐ ┌──────────────────────┐
│       Google Gemini API       │ │ Firebase Firestore & │
│ (gemini-3.8-flash, Structured │ │ Firebase Auth        │
│          JSON Schema)         │ │ (User isolation)     │
└───────────────────────────────┘ └──────────────────────┘
```

### Complete End-to-End Workflow:
```
User Profile Input
       │
       ▼
Structured Pydantic Model
       │
       ▼
Secure Server-Side Gemini Request (Server-side API key)
       │
       ▼
JSON Schema Enforcement (CareerGuidanceResponse)
       │
       ▼
Pydantic Response Validation & Sanitization
       │
       ▼
Flutter UI Rendering & State Management (Provider)
       │
       ▼
Firestore Persistence & Roadmap Milestone Tracking
```

---

## 3. Technology Stack

- **Frontend:** Flutter 3.41+ (Dart 3.11+), Provider (State Management), Google Fonts (Plus Jakarta Sans).
- **Backend:** Python 3.14+, FastAPI, Uvicorn, Pydantic v2.
- **AI Engine:** Google Gemini API (`gemini-3.8-flash` with multi-model fallback to `gemini-3.5-flash`), official `google-genai` SDK.
- **Database & Authentication:** Firebase Cloud Firestore & Firebase Authentication.
- **Testing:** `pytest` & `httpx` (Backend), `flutter test` & `flutter analyze` (Frontend).

---

## 4. Project Structure

```
careerly/
├── firebase.json                   # Firebase hosting and Firestore config
├── firestore.rules                 # Security rules enforcing student data isolation
├── README.md                       # Comprehensive project documentation
│
├── backend/                        # Python FastAPI Backend
│   ├── .env                        # Local environment variables
│   ├── .env.example                # Example environment configuration
│   ├── requirements.txt            # Python dependencies
│   ├── main.py                     # FastAPI application entrypoint & CORS
│   │
│   ├── config/
│   │   └── settings.py             # App settings loaded via python-dotenv
│   │
│   ├── models/
│   │   ├── student.py              # StudentProfile & update Pydantic models
│   │   └── guidance.py             # CareerGuidance, Roadmap, Placement models
│   │
│   ├── services/
│   │   ├── gemini_service.py       # Gemini API client with schema enforcement
│   │   └── firebase_service.py     # Firebase Admin & Firestore sync service
│   │
│   ├── routes/
│   │   ├── health.py               # Health check endpoint (/health)
│   │   ├── ai.py                   # Career guidance AI endpoint (/api/ai/career-guidance)
│   │   └── student.py              # Profile CRUD endpoints (/api/student/profile)
│   │
│   └── tests/
│       ├── test_health.py          # Health & root endpoint tests
│       ├── test_models.py          # Pydantic validation tests
│       ├── test_student.py         # Student profile CRUD & isolation tests
│       └── test_ai_guidance.py     # AI career guidance integration tests
│
└── frontend/                       # Flutter Application
    ├── pubspec.yaml                # Flutter packages & dependencies
    │
    ├── lib/
    │   ├── main.dart               # App entrypoint, Firebase init & MultiProvider
    │   │
    │   ├── config/
    │   │   ├── app_theme.dart      # Color palette, Material 3 theme & typography
    │   │   └── constants.dart      # Career options, skills, and configuration
    │   │
    │   ├── models/
    │   │   ├── student_profile.dart# StudentProfile model & completion metrics
    │   │   ├── career_guidance.dart# CareerGuidance, RoadmapStep, PlacementPrepItem
    │   │   └── user_progress.dart  # Aggregated progress model
    │   │
    │   ├── services/
    │   │   ├── api_service.dart    # Centralized HTTP client for FastAPI backend
    │   │   ├── auth_service.dart   # Firebase Auth service with friendly error mapping
    │   │   └── storage_service.dart# Firestore persistence & local cache mirror
    │   │
    │   ├── providers/
    │   │   ├── auth_provider.dart  # Auth state management
    │   │   ├── profile_provider.dart# Student profile state
    │   │   └── guidance_provider.dart# Guidance generation, roadmap & progress state
    │   │
    │   ├── widgets/
    │   │   ├── app_buttons.dart    # PrimaryButton & SecondaryButton
    │   │   ├── app_text_field.dart # Form text fields
    │   │   ├── chip_selector.dart  # Multi-select chip input with custom addition
    │   │   ├── feature_card.dart   # Interactive dashboard cards
    │   │   ├── roadmap_tile.dart   # Visual timeline milestone with completion toggle
    │   │   ├── responsive_scaffold.dart # Responsive layout: Desktop sidebar + Mobile bottom nav
    │   │   └── state_views.dart    # LoadingView, EmptyState, ErrorBanner, SectionHeader
    │   │
    │   └── screens/
    │       ├── splash/             # Minimal brand splash screen
    │       ├── auth/               # Login, Register & Password reset screens
    │       ├── home/               # Dashboard & primary responsive navigation
    │       ├── profile/            # Profile view & comprehensive edit screen
    │       ├── guidance/           # Guidance generator, results, and saved history
    │       ├── skill_gap/          # Skill gap analysis with status badges
    │       ├── roadmap/            # Interactive visual timeline roadmap
    │       ├── placement/          # Placement preparation by category
    │       ├── explore/            # Career pathways & engineering domains
    │       ├── progress/           # Real stored progress metrics
    │       └── settings/           # User-facing preferences & about info
    │
    └── test/
        ├── models_test.dart        # Model serialization & completion tests
        └── widget_test.dart        # FeatureCard, RoadmapTile & EmptyState widget tests
```

---

## 5. Security & Credentials Management

To guarantee security:
- **No Gemini API keys are inside the Flutter application or client code.**
- The Gemini API key resides solely on the FastAPI backend as `GEMINI_API_KEY`.
- No sensitive service account private keys are committed.
- Firestore Security Rules enforce strict UID isolation (`request.auth.uid == userId`).

---

## 6. How to Run the Backend

### Prerequisites
- Python 3.10+ (tested on Python 3.14.3)
- Google Gemini API Key

### Steps
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Activate the virtual environment:
   - Windows PowerShell:
     ```powershell
     .\venv\Scripts\Activate.ps1
     ```
   - macOS / Linux:
     ```bash
     source venv/bin/activate
     ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Configure your `.env` file:
   ```bash
   cp .env.example .env
   ```
   Add your Gemini API key:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   PORT=8000
   HOST=0.0.0.0
   ```
5. Run the backend server:
   ```bash
   python main.py
   # or with uvicorn directly:
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
6. Verify:
   Open `http://localhost:8000/health` or `http://localhost:8000/docs` in your browser.

---

## 7. How to Run the Frontend

### Prerequisites
- Flutter SDK (3.41+ with Dart 3.11+)
- Google Chrome (for web) or an Android / iOS device / emulator

### Steps
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   - On Chrome (Web):
     ```bash
     flutter run -d chrome
     ```
   - On Windows Desktop:
     ```bash
     flutter run -d windows
     ```
   - On Android:
     ```bash
     flutter run -d <device_id>
     ```

---

## 8. Firebase Configuration Guide

The codebase is built with official Firebase SDKs (`firebase_auth`, `cloud_firestore`, `firebase_core`).

### For Flutter Web & Mobile:
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password sign-in provider).
3. Enable **Cloud Firestore** in production mode.
4. Run the FlutterFire CLI from `frontend/`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This automatically generates `lib/firebase_options.dart`.
5. For Android: Place your `google-services.json` in `frontend/android/app/`.
6. Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

*(Note: If live Firebase credentials are not yet linked in your local environment, Careerly's client-side fallback layer provides seamless session isolation and local persistence so the app remains fully functional for demonstration and testing.)*

---

## 9. API Endpoints Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Health status and AI engine status check |
| `GET` | `/` | Root info and API version |
| `POST` | `/api/ai/career-guidance` | Generates structured AI career guidance via Gemini |
| `POST` | `/api/student/profile` | Creates or saves student profile |
| `GET` | `/api/student/profile/{user_id}` | Retrieves student profile by UID with data isolation |
| `PUT` | `/api/student/profile/{user_id}` | Updates student profile fields |

---

## 10. Verification & Test Suite

### Running Backend Tests
From `backend/`:
```bash
pytest -v
```
All 9 test cases validate:
- Root & `/health` endpoint status
- Pydantic models for both camelCase and snake_case aliases
- Semester & CGPA range validation
- End-to-end AI career guidance generation with structured JSON schema
- Student profile creation, retrieval, and updating

### Running Frontend Tests & Analysis
From `frontend/`:
```bash
flutter analyze
flutter test
flutter build web
```
- `flutter analyze` reports 0 issues.
- `flutter test` executes all model and widget test suites.
- `flutter build web` compiles the release production bundle.
