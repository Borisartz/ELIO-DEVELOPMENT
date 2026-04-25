import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'Screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ElioApp());
}

class ElioApp extends StatelessWidget {
  final FirebaseAuth? auth;
  const ElioApp({super.key, this.auth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ELIO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
        useMaterial3: true,
      ),
      home: SplashScreen(auth: auth ?? FirebaseAuth.instance),
    );
  }
}
