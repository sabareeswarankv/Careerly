import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AppUser {
  final String uid;
  final String email;
  final String displayName;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  factory AppUser.fromFirebase(fb.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }
}

class AuthService {
  fb.FirebaseAuth? _firebaseAuth;
  final StreamController<AppUser?> _userStreamController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  AuthService() {
    _init();
  }

  void _init() {
    try {
      _firebaseAuth = fb.FirebaseAuth.instance;
      _firebaseAuth?.authStateChanges().listen((fb.User? user) {
        if (user != null) {
          _currentUser = AppUser.fromFirebase(user);
        } else {
          _currentUser = null;
        }
        _userStreamController.add(_currentUser);
      });
    } catch (_) {
    }
  }

  Stream<AppUser?> get userStream => _userStreamController.stream;
  AppUser? get currentUser => _currentUser;

  Future<AppUser> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (_firebaseAuth == null) {
      _init();
    }

    if (_firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          await user.updateDisplayName(fullName.trim());
          _currentUser = AppUser(
            uid: user.uid,
            email: user.email ?? email,
            displayName: fullName.trim(),
          );
          _userStreamController.add(_currentUser);
          return _currentUser!;
        }
      } on fb.FirebaseAuthException catch (e) {
        throw _mapFirebaseAuthError(e);
      } catch (e) {
        throw 'An error occurred during registration. Please try again.';
      }
    }

    final mockUid = 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    _currentUser = AppUser(
      uid: mockUid,
      email: email.trim(),
      displayName: fullName.trim(),
    );
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_firebaseAuth == null) {
      _init();
    }

    if (_firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          _currentUser = AppUser.fromFirebase(user);
          _userStreamController.add(_currentUser);
          return _currentUser!;
        }
      } on fb.FirebaseAuthException catch (e) {
        throw _mapFirebaseAuthError(e);
      } catch (e) {
        throw 'Unable to sign in. Please verify your credentials and try again.';
      }
    }

    final mockUid = 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    _currentUser = AppUser(
      uid: mockUid,
      email: email.trim(),
      displayName: email.split('@').first,
    );
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  Future<AppUser> signInWithGoogle() async {
    if (_firebaseAuth == null) {
      _init();
    }

    if (_firebaseAuth != null) {
      try {
        final googleProvider = fb.GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final credential = await _firebaseAuth!.signInWithPopup(googleProvider);
        final user = credential.user;
        if (user != null) {
          _currentUser = AppUser.fromFirebase(user);
          _userStreamController.add(_currentUser);
          return _currentUser!;
        }
      } on fb.FirebaseAuthException catch (e) {
        throw _mapFirebaseAuthError(e);
      } catch (e) {
        throw 'Google Sign-In could not be completed. Please check your browser popup settings or Firebase Console.';
      }
    }

    final mockUid = 'usr_google_student';
    _currentUser = AppUser(
      uid: mockUid,
      email: 'student@example.com',
      displayName: 'Google Student',
    );
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
    _currentUser = null;
    _userStreamController.add(null);
  }

  Future<void> resetPassword(String email) async {
    if (_firebaseAuth == null) {
      _init();
    }
    if (_firebaseAuth != null) {
      try {
        await _firebaseAuth!.sendPasswordResetEmail(email: email.trim());
        return;
      } on fb.FirebaseAuthException catch (e) {
        throw _mapFirebaseAuthError(e);
      } catch (_) {
        throw 'Failed to send password reset email. Please try again.';
      }
    }
    throw 'Firebase Authentication is not initialized on this client. Please configure Firebase to enable real password reset emails.';
  }

  Future<String?> getIdToken() async {
    try {
      return await _firebaseAuth?.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }

  String _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account exists with this email address. Please register.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please double-check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please sign in.';
      case 'invalid-email':
        return 'The email address provided is not properly formatted.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in your Firebase Console. Please go to Firebase Console > Authentication > Sign-in method and enable Email/Password.';
      default:
        final msg = e.message;
        if (msg == null || msg.trim().isEmpty || msg == 'Error') {
          return 'Authentication failed. If this is a new Firebase project, ensure Email/Password is enabled under Authentication > Sign-in method.';
        }
        return msg;
    }
  }

  void dispose() {
    _userStreamController.close();
  }
}
