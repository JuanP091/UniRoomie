import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Register User to Firebase
  Future<String?> registerUser(String firstName, String lastName, String email, String password, bool isadmin) async {
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
}