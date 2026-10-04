import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDH7rRATvsTlivjOh7X68B5K7nDG23RycM',
    appId: '1:756631027509:web:653dd32de443c004f4967c',
    messagingSenderId: '756631027509',
    projectId: 'careerly-641e0',
    authDomain: 'careerly-641e0.firebaseapp.com',
    storageBucket: 'careerly-641e0.firebasestorage.app',
    measurementId: 'G-3XES9E3YNZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDH7rRATvsTlivjOh7X68B5K7nDG23RycM',
    appId: '1:756631027509:android:653dd32de443c004f4967c',
    messagingSenderId: '756631027509',
    projectId: 'careerly-641e0',
    storageBucket: 'careerly-641e0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDH7rRATvsTlivjOh7X68B5K7nDG23RycM',
    appId: '1:756631027509:ios:653dd32de443c004f4967c',
    messagingSenderId: '756631027509',
    projectId: 'careerly-641e0',
    storageBucket: 'careerly-641e0.firebasestorage.app',
  );
}
