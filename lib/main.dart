import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options_loader.dart';
import 'Screens/home_shell.dart';
import 'Screens/login_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const envName = String.fromEnvironment('ELIO_ENV', defaultValue: 'dev');
  await dotenv.load(fileName: '.env.$envName');

  await Firebase.initializeApp(options: createFirebaseOptionsByEnv());
  runApp(const ElioApp());
}

class ElioApp extends StatelessWidget {
  final FirebaseAuth? auth;
  const ElioApp({super.key, this.auth});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'ELIO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
          useMaterial3: true,
        ),
        home: _AuthGate(auth: auth ?? FirebaseAuth.instance),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  final FirebaseAuth auth;

  const _AuthGate({required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Keep native splash visible until Firebase resolves auth state.
          return const SizedBox();
        }

        FlutterNativeSplash.remove();

        if (snapshot.hasData) {
          return HomeShell(auth: auth);
        }
        return LoginScreen(auth: auth);
      },
    );
  }
}
