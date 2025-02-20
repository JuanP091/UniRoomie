import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uniroomie/main.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isSecure = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Used to write to firebase database
  void writeData() async {
    FirebaseFirestore.instance.collection('users').add({
      'First Name': _firstNameController.text,
      'Last Name': _lastNameController.text,
      'Email': _emailController.text,
      'Password': _passwordController.text,
    });
  }

  // Used to check if there is something in all text fields
  bool _validateFields() {
    return _firstNameController.text.isNotEmpty &&
           _lastNameController.text.isNotEmpty &&
           _emailController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty;
  }

  // Forces UI update when text changes
  void _updateButtonState() {
    setState(() {}); 
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Name Container
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _firstNameController, 
                    onChanged: (text) => _updateButtonState(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "First Name",
                    ),
                  ),
                ),
                // Last Name Container
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _lastNameController, 
                    onChanged: (text) => _updateButtonState(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Last Name",
                    ),
                  ),
                ),
              ],
            ),
            // Email Container
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _emailController, 
                onChanged: (text) => _updateButtonState(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
            ),
            // Password Container
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController, 
                      obscureText: _isSecure,
                      onChanged: (text) => _updateButtonState(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSecure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye, // Changes icon depending on state of _isSecure
                    ),
                    onPressed: () {
                      setState(() {
                        _isSecure = !_isSecure; // Change _isSecure
                      });
                    },
                  )
                ],
              ),
            ),
            TextButton(
              onPressed: _validateFields()
                  ? () {
                      writeData();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Welcome!')),
                      );
                    }
                  : null, // Button is disabled if fields are empty
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
