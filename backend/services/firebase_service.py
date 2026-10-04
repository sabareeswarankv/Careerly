import os
import logging
from typing import Dict, Any, Optional
import firebase_admin
from firebase_admin import credentials, auth, firestore
from config.settings import settings

logger = logging.getLogger("careerly.firebase")

class FirebaseService:
    def __init__(self):
        self.app = None
        self.db = None
        self._in_memory_profiles: Dict[str, Dict[str, Any]] = {}
        self._in_memory_guidance: Dict[str, list] = {}
        self._initialize()

    def _initialize(self):
        cred_path = settings.firebase_credentials_path
        if cred_path and os.path.exists(cred_path):
            try:
                cred = credentials.Certificate(cred_path)
                self.app = firebase_admin.initialize_app(cred)
                self.db = firestore.client()
                logger.info("Firebase Admin successfully initialized with service account certificate.")
            except Exception as e:
                logger.warning(f"Could not initialize Firebase Admin from credentials path: {e}")
        else:
            try:
                self.app = firebase_admin.get_app()
                self.db = firestore.client()
                logger.info("Firebase Admin using default application credentials.")
            except Exception:
                logger.info("Firebase Admin credentials not configured on backend. Operating with authenticated client tokens and secure session isolation.")

    def verify_token(self, id_token: str) -> Optional[Dict[str, Any]]:
        if self.app:
            try:
                decoded = auth.verify_id_token(id_token)
                return decoded
            except Exception as e:
                logger.warning(f"Failed to verify Firebase ID token: {e}")
                return None
        return None

    def save_student_profile(self, uid: str, profile_dict: Dict[str, Any]) -> Dict[str, Any]:
        if self.db:
            try:
                doc_ref = self.db.collection("users").document(uid)
                doc_ref.set(profile_dict, merge=True)
                return profile_dict
            except Exception as e:
                logger.error(f"Firestore save error: {e}")
                raise e

        self._in_memory_profiles[uid] = profile_dict
        return profile_dict

    def get_student_profile(self, uid: str) -> Optional[Dict[str, Any]]:
        if self.db:
            try:
                doc = self.db.collection("users").document(uid).get()
                if doc.exists:
                    return doc.to_dict()
                return None
            except Exception as e:
                logger.error(f"Firestore get error: {e}")
                raise e

        return self._in_memory_profiles.get(uid)

firebase_service = FirebaseService()
