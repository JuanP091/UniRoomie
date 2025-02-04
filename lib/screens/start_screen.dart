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

  void writeData() async {
    FirebaseFirestore.instance.collection('users').add({
      'First Name': _firstNameController.text,
      'Last Name': _lastNameController.text,
      'Email': _emailController.text,
      'Password': _passwordController.text,
    });
  }

  bool _validateFields() {
    return _firstNameController.text.isNotEmpty &&
           _lastNameController.text.isNotEmpty &&
           _emailController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty;
  }

  void _updateButtonState() {
    setState(() {}); // Forces UI update when text changes
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _firstNameController, // ✅ FIXED
                    onChanged: (text) => _updateButtonState(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "First Name",
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _lastNameController, // ✅ FIXED
                    onChanged: (text) => _updateButtonState(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Last Name",
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _emailController, // ✅ FIXED
                onChanged: (text) => _updateButtonState(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController, // ✅ FIXED
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
                      _isSecure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSecure = !_isSecure;
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