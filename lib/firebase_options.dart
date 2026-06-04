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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAS-ZoTlS3f6Yd-CNf8JkKvSFLzGUOX4lA',
    appId: '1:194877359566:android:2829364312ae5fe98ad79f',
    messagingSenderId: '194877359566',
    projectId: 'moversec-ae404',
    storageBucket: 'moversec-ae404.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCb56EjhTmluvW4XRk4smCM24XrYY0yRcM',
    appId: '1:194877359566:web:55a7e3949f7421d58ad79f',
    messagingSenderId: '194877359566',
    projectId: 'moversec-ae404',
    authDomain: 'moversec-ae404.firebaseapp.com',
    storageBucket: 'moversec-ae404.firebasestorage.app',
  );

}