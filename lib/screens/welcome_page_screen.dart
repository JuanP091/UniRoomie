import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uniroomie/services/auth_service.dart';

class WelcomePageScreen extends StatefulWidget {
  const WelcomePageScreen({super.key});

  @override
  State<WelcomePageScreen> createState() => _WelcomePageScreenState();
}

class _WelcomePageScreenState extends State<WelcomePageScreen> {
  final AuthService _authService = AuthService();

  String firstName = "Loading...";
  String lastName = "";

  Future<void> getUserFullName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          firstName = data['First Name'] ?? "Unknown";
          lastName = data['Last Name'] ?? "Unknown";
        });
      } else {
        // User does not exist
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserFullName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Welcome, $firstName $lastName",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ],
    )));
  }
}
