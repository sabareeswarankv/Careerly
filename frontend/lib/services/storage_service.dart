import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/career_guidance.dart';
import '../models/student_profile.dart';

class StorageService {
  fs.FirebaseFirestore? _firestore;

  final Map<String, StudentProfile> _profilesCache = {};
  final Map<String, List<CareerGuidance>> _guidanceCache = {};

  StorageService() {
    _init();
  }

  void _init() {
    try {
      _firestore = fs.FirebaseFirestore.instance;
    } catch (_) {
    }
  }

  Future<void> saveProfile(StudentProfile profile) async {
    _profilesCache[profile.uid] = profile;

    if (_firestore == null) {
      _init();
    }

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(profile.uid)
            .set(
              profile.toJson(),
              fs.SetOptions(merge: true),
            )
            .timeout(const Duration(seconds: 3));
      } catch (_) {
      }
    }
  }

  Future<StudentProfile?> getProfile(String uid) async {
    if (_profilesCache.containsKey(uid)) {
      return _profilesCache[uid];
    }

    if (_firestore == null) {
      _init();
    }

    if (_firestore != null) {
      try {
        final doc = await _firestore!
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 3));
        if (doc.exists && doc.data() != null) {
          final profile = StudentProfile.fromJson(doc.data()!);
          _profilesCache[uid] = profile;
          return profile;
        }
      } catch (_) {}
    }

    return _profilesCache[uid];
  }

  Future<void> saveGuidance(String uid, CareerGuidance guidance) async {
    if (!_guidanceCache.containsKey(uid)) {
      _guidanceCache[uid] = [];
    }
    _guidanceCache[uid]!.removeWhere((g) => g.id == guidance.id);
    _guidanceCache[uid]!.insert(0, guidance);

    if (_firestore == null) {
      _init();
    }

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(uid)
            .collection('guidance')
            .doc(guidance.id)
            .set(guidance.toJson())
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
  }

  Future<List<CareerGuidance>> getSavedGuidance(String uid) async {
    if (_firestore == null) {
      _init();
    }

    if (_firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection('users')
            .doc(uid)
            .collection('guidance')
            .orderBy('createdAt', descending: true)
            .get()
            .timeout(const Duration(seconds: 3));

        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map((doc) => CareerGuidance.fromJson(doc.data(), id: doc.id))
              .toList();
          _guidanceCache[uid] = list;
          return list;
        }
      } catch (_) {}
    }

    return _guidanceCache[uid] ?? [];
  }

  Future<void> updateRoadmapStep(
    String uid,
    String guidanceId,
    int stepNumber,
    bool isCompleted,
  ) async {
    final list = _guidanceCache[uid];
    if (list != null) {
      final index = list.indexWhere((g) => g.id == guidanceId);
      if (index != -1) {
        final guidance = list[index];
        final updatedRoadmap = guidance.learningRoadmap.map((s) {
          if (s.step == stepNumber) {
            return s.copyWith(isCompleted: isCompleted);
          }
          return s;
        }).toList();

        final updatedGuidance = guidance.copyWith(learningRoadmap: updatedRoadmap);
        list[index] = updatedGuidance;

        if (_firestore != null) {
          try {
            await _firestore!
                .collection('users')
                .doc(uid)
                .collection('guidance')
                .doc(guidanceId)
                .update({
              'learningRoadmap': updatedRoadmap.map((s) => s.toJson()).toList(),
            }).timeout(const Duration(seconds: 3));
          } catch (_) {}
        }
      }
    }
  }

  Future<void> saveSecurityQuestion(String email, String question, String answer) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sec_q_$cleanEmail', question);
      await prefs.setString('sec_a_$cleanEmail', answer.trim().toLowerCase());
    } catch (_) {}

    if (_firestore != null) {
      try {
        await _firestore!.collection('security_questions').doc(cleanEmail).set({
          'question': question,
          'answer': answer.trim().toLowerCase(),
        }, fs.SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<String?> getSecurityQuestion(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final prefs = await SharedPreferences.getInstance();
      final q = prefs.getString('sec_q_$cleanEmail');
      if (q != null && q.isNotEmpty) return q;
    } catch (_) {}

    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('security_questions').doc(cleanEmail).get();
        if (doc.exists && doc.data() != null) {
          return doc.data()!['question'] as String?;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<bool> verifySecurityAnswer(String email, String answer) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanAnswer = answer.trim().toLowerCase();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnswer = prefs.getString('sec_a_$cleanEmail');
      if (savedAnswer != null && savedAnswer.isNotEmpty) {
        return savedAnswer == cleanAnswer;
      }
    } catch (_) {}

    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('security_questions').doc(cleanEmail).get();
        if (doc.exists && doc.data() != null) {
          final savedAnswer = doc.data()!['answer'] as String?;
          if (savedAnswer != null && savedAnswer.isNotEmpty) {
            return savedAnswer == cleanAnswer;
          }
        }
      } catch (_) {}
    }
    return false;
  }
}
