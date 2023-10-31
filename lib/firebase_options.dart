// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
/// 
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDB7P_no_aLxW5IMNWRjNxcpyf8X1RlIUs',
    appId: '1:1007943652157:web:bb136e3a4731889df0ab54',
    messagingSenderId: '1007943652157',
    projectId: 'sleeptrackingapp-2f0d1',
    authDomain: 'sleeptrackingapp-2f0d1.firebaseapp.com',
    storageBucket: 'sleeptrackingapp-2f0d1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCF_iqyk2P8-7ubQxXkwfRWBC0UP9HJrV0',
    appId: '1:1007943652157:android:52023982bdb345eff0ab54',
    messagingSenderId: '1007943652157',
    projectId: 'sleeptrackingapp-2f0d1',
    storageBucket: 'sleeptrackingapp-2f0d1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtXgPfv63lHqnV69ZrMf9K8euiimVzxw4',
    appId: '1:1007943652157:ios:805c18a2a99f63e2f0ab54',
    messagingSenderId: '1007943652157',
    projectId: 'sleeptrackingapp-2f0d1',
    storageBucket: 'sleeptrackingapp-2f0d1.appspot.com',
    iosBundleId: 'com.example.sleeptrackerapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBtXgPfv63lHqnV69ZrMf9K8euiimVzxw4',
    appId: '1:1007943652157:ios:ad935882a871048df0ab54',
    messagingSenderId: '1007943652157',
    projectId: 'sleeptrackingapp-2f0d1',
    storageBucket: 'sleeptrackingapp-2f0d1.appspot.com',
    iosBundleId: 'com.example.sleeptrackerapp.RunnerTests',
  );
}
