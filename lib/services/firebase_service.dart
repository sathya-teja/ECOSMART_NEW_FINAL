import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
// import 'package:google_ml_vision/google_ml_vision.dart'; // Correct import for Firebase ML Vision

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

   // Method to listen to user profile changes in real-time
  Stream<DocumentSnapshot> getUserStream() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore.collection('users').doc(currentUser.uid).snapshots();
    } else {
      throw Exception("No current user found");
    }
  }

  // Method to update points
  Future<void> updatePoints(String uid, int points) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'points': points,
      });
    } catch (e) {
      print('Error updating points: $e');
    }
  }
  



  // Method to update disposals
  Future<void> updateDisposals(String uid, int disposals) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'disposals': disposals,
      });
    } catch (e) {
      print('Error updating disposals: $e');
    }
  }

  // Method to update level
  Future<void> updateLevel(String uid, int level) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'level': level,
      });
    } catch (e) {
      print('Error updating level: $e');
    }
  }



  // Additional methods you already implemented
  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  Future<void> createUserProfile(String uid, String name, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'points': 0,
        'disposals': 0,
        'level': 1,
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }
  // Method to record a waste disposal (passed as a string, e.g., waste type)
  Future<bool> recordDisposal(String wasteType) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Increment the user's disposal count
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'disposals': FieldValue.increment(1), // Increment disposals
      });

      // Optionally, add waste disposal details to the waste_records collection
      await _firestore.collection('waste_records').add({
        'user_id': userId,
        'waste_type': wasteType,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Recalculate user's level based on disposals
      await updateUserLevel(userId);

      return true;
    } catch (e) {
      print("Error recording disposal: $e");
      return false;
    }
  }
    // Method to update the user's level and points based on the number of disposals
  Future<void> updateUserLevel(String userId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        int disposals = userSnapshot['disposals'];
        int level = (disposals ~/ 10) + 1; // Level increases based on disposals
        int points = disposals * 10; // 10 points per disposal

        // Update level and points in Firestore
        await userRef.update({
          'level': level,
          'points': points,
        });
      }
    } catch (e) {
      print("Error updating user level: $e");
    }
  }


 // Method to identify waste type using Google ML Vision
//   Future<String> identifyWaste(String imagePath) async {
//   try {
//     final File imageFile = File(imagePath);  // Get the image file
//     final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(imageFile);  // Correct class

//     final ImageLabeler labeler = GoogleVision.instance.imageLabeler();  // Initialize labeler
//     final List<ImageLabel> labels = await labeler.processImage(visionImage);  // Get image labels

//     String wasteType = "Unknown";

//     // Check the labels for waste type classification (Plastic, Glass, etc.)
//     for (ImageLabel label in labels) {
//       // Use null check to safely call toLowerCase() on label.text
//       final labelText = label.text?.toLowerCase();  // Safely get lower case text

//       if (labelText != null) {
//         if (labelText.contains("plastic")) {
//           wasteType = "Plastic";
//         } else if (labelText.contains("glass")) {
//           wasteType = "Glass";
//         }
//         // Add more conditions as needed
//       }
//     }

//     return wasteType;
//   } catch (e) {
//     print("Error identifying waste: $e");
//     return "Unknown";
//   }
// }

 // Get user points from Firestore
  Future<int> getUserPoints() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (userSnapshot.exists) {
        return userSnapshot['totalPoints'] ?? 0; // Return total points, default to 0 if not set
      }
    }
    return 0;
  }

  // Get the count of user disposals
  Future<int> getDisposalsCount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot disposalsSnapshot = await _firestore.collection('users').doc(user.uid).collection('disposals').get();
      return disposalsSnapshot.size; // Count the number of documents (disposals)
    }
    return 0;
  }

}
