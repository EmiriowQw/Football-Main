import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:basketvibe/core/app/app.dart';
import 'package:basketvibe/core/app/demo_mode.dart';
import 'package:basketvibe/core/network/injection.dart';
import 'package:basketvibe/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env', isOptional: true);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  if (demoMode) {
    final demoApp = await Firebase.initializeApp(
      name: demoProjectId,
      options: const FirebaseOptions(
        apiKey: 'demo-api-key',
        appId: '1:1234567890:android:1234567890abcdef',
        messagingSenderId: '1234567890',
        projectId: demoProjectId,
      ),
    );
    final auth = FirebaseAuth.instanceFor(app: demoApp);
    final firestore = FirebaseFirestore.instanceFor(app: demoApp);
    await auth.useAuthEmulator(demoHost, 9099);
    firestore.useFirestoreEmulator(demoHost, 8088);
    await configureDependencies(auth: auth, firestore: firestore);
  } else {
    await configureDependencies();
  }

  runApp(const App());

  // Updates
}
