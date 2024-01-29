import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // FirebaseCrashlytics.instance.crash();
  runApp(const GuestManagementApp());
}

class GuestManagementApp extends StatelessWidget {
  const GuestManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Система учета гостей',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
