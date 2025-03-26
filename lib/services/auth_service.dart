import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User to Firebase
  Future<String?> registerUser(String firstName, String lastName, String email, String password, bool isadmin, String zipcode ,String city, String state) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'First Name': firstName,
        'Last Name': lastName,
        'Email': email,
        'UID': uid,
        'Created At': Timestamp.now(),
        'admin' : isadmin,
        'Zipcode' : zipcode,
        'City' : city,
        'State' : state,
      });

      return null; // No error, user created successfully

      // Handle email/password authentication
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format.";
      } else if (e.code == 'weak-password') {
        return "The password is too weak.";
      }
      return "An error occurred. Please try again.";
    }
  }

  // Checks if User is an admin
  Future<bool> isUserAdmin(String uid) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (userDoc.exists && userDoc.data() != null) {
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return userData['admin'] ?? false; // Returns true if "admin" is true, otherwise false
  }

  return false; // Default to false if document doesn't exist
  }

  // Used for login screen to log in the user if given existing credentials
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    // Step 1: Check if the user exists in Firestore
    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      return {
        "success": false,
        "user": null,
        "message": "No user found with this email."
      };
    }

    // Step 2: Attempt to sign in
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return {
      "success": true,
      "user": userCredential.user,
      "message": "Login successful"
    };
  } on FirebaseAuthException catch (e) {
    print("FirebaseAuthException: ${e.code}"); // Used for debugging

    String errorMessage;
    switch (e.code) {
      case 'invalid-credential': 
        errorMessage = "Incorrect password.";
        break;
      default:
        errorMessage = "An unknown error occurred: ${e.code}";
        break;
    }

    return {
      "success": false,
      "user": null,
      "message": errorMessage,
    };
  }
}
}