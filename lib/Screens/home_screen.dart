import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Grab the current user to show who is logged in (useful for testing)
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ELIO Home'),
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home — coming soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Show user info for testing
            Text(
              'Logged in as: ${user?.isAnonymous == true ? "Guest" : user?.email ?? "Unknown"}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            
            const SizedBox(height: 40),

            // Temporary Sign Out Button
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(auth: FirebaseAuth.instance),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out (Testing)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}