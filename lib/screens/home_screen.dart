import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../screens/capture_waste_screen.dart'; // Ensure this import is correct
import '../screens/qr_scanning_screen.dart';  // Assuming you have the QR scanner screen
import '../screens/rewards_screen.dart'; // Import the Rewards Screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String userName = "Loading..."; // Placeholder until data is fetched
  int _currentIndex = 0; // To keep track of the current tab
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // Fetch user information (name, points, disposals, etc.)
  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // Fetching user's display name, and using email if displayName is not available
        userName = user.displayName ?? user.email ?? "Anonymous";
      });

      // Fetch the user's name from Firestore if displayName is null
      if (user.displayName == null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? user.email ?? "Anonymous"; // Assuming Firestore has a 'name' field
          });
        }
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the login screen or show login screen
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? "";

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("EcoSmart", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to the ProfileScreen when the avatar is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(user?.email ?? "Not Signed In"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.account_circle, color: Colors.white),
              ),
            ),
            ListTile(
              title: Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Screen Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Details Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Welcome, $userName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // StreamBuilder for dynamic points, level, and disposals
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator()); // Show loading indicator if data is not available
                      }

                      var userData = snapshot.data!;
                      int points = userData['points'] ?? 0;
                      int disposals = userData['disposals'] ?? 0;
                      int level = (points ~/ 100) + 1; // Example logic: 1 level per 100 points

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Dispose Card
                              Expanded(
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.green.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Total Disposals",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "$disposals",
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Points Card
                              Expanded(
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.blue.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Your Points",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "$points",
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Level Card
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Your Level",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "$level",
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Capture Waste Screen
          CaptureWasteScreen(),
          // QR Scanning Screen
          const QRScannerScreen(),
          // Rewards Screen (Placeholder)
          const RewardsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Capture Waste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rewards', // Add Rewards tab
          ),
        ],
        backgroundColor: Colors.green[800], // Dark green background for the bottom nav bar
        selectedItemColor: Colors.white, // White color for selected item
        unselectedItemColor: Colors.green.shade200, // Lighter green color for unselected items
        type: BottomNavigationBarType.fixed, // Use fixed type for better item layout
        elevation: 10, // Adds elevation to the bottom navigation for a floating effect
      ),
    );
  }
}
