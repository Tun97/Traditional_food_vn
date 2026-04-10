
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCYdlc9yz7MvGb6PGhnjjsQ6crmdS2MKGI',
    appId: '1:635852375737:web:b0b24c4085847d3b247d68',
    messagingSenderId: '635852375737',
    projectId: 'foodvn-f63e2',
    authDomain: 'foodvn-f63e2.firebaseapp.com',
    storageBucket: 'foodvn-f63e2.firebasestorage.app',
    measurementId: 'G-5Q5LV7BS30',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzmBpVefnzTMaCXkf4ENvW2Fa186YVTw4',
    appId: '1:635852375737:android:3dd6ef1465dbed99247d68',
    messagingSenderId: '635852375737',
    projectId: 'foodvn-f63e2',
    storageBucket: 'foodvn-f63e2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8lNq0nnhZaQfPud4iOVa1yO3OSP89QTs',
    appId: '1:635852375737:ios:61b9a28820732a01247d68',
    messagingSenderId: '635852375737',
    projectId: 'foodvn-f63e2',
    storageBucket: 'foodvn-f63e2.firebasestorage.app',
    iosBundleId: 'com.example.foodApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8lNq0nnhZaQfPud4iOVa1yO3OSP89QTs',
    appId: '1:635852375737:ios:61b9a28820732a01247d68',
    messagingSenderId: '635852375737',
    projectId: 'foodvn-f63e2',
    storageBucket: 'foodvn-f63e2.firebasestorage.app',
    iosBundleId: 'com.example.foodApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCYdlc9yz7MvGb6PGhnjjsQ6crmdS2MKGI',
    appId: '1:635852375737:web:8cb97604ccd92a4c247d68',
    messagingSenderId: '635852375737',
    projectId: 'foodvn-f63e2',
    authDomain: 'foodvn-f63e2.firebaseapp.com',
    storageBucket: 'foodvn-f63e2.firebasestorage.app',
    measurementId: 'G-WK30GH37Z4',
  );
}
