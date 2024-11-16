
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSmart',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if the user is logged in
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            return user == null ? SignInPage() : HomeScreen();
          }
          // Show a loading spinner while waiting for the auth state
          return const Center(child: CircularProgressIndicator());
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
