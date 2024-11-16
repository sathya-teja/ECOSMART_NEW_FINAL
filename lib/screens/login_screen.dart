import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController(); // Added name controller
  bool isRegistering = false; // Boolean to toggle between sign-in and register

  // Sign in method
  Future<void> signIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    User? user = await _authService.signIn(email, password);
    if (user != null) {
      bool userExists = await _firebaseService.userExists(user.uid);
      if (!userExists) {
        await _firebaseService.createUserProfile(user.uid, "Name", email);
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print("Sign-in failed.");
    }
  }

  // Register method
  Future<void> register() async {
    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text; // Get name from nameController

    if (name.isNotEmpty) {
      User? user = await _authService.register(email, password);
      if (user != null) {
        await _firebaseService.createUserProfile(user.uid, name, email); // Creates profile for new user
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        print("Registration failed.");
      }
    } else {
      print("Name is required.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        backgroundColor: Colors.green, // Customizing AppBar color
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Only show name input field if registering
                  if (isRegistering) 
                    TextField(
                      controller: nameController, // Name input
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16),
                  // Email TextField
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  // Password TextField
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  // Sign In Button
                  if (!isRegistering) // Show Sign In button if not registering
                    ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  // Register Button
                  if (isRegistering) // Show Register button if registering
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Toggle between Sign In and Register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isRegistering = !isRegistering; // Toggle between sign in and register
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      isRegistering 
                          ? "Already have an account? Sign In here" 
                          : "Don't have an account? Register here",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
