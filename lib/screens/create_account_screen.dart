import 'package:flutter/material.dart';
import 'package:uniroomie/screens/user_decoration_screen.dart';
import 'package:uniroomie/services/auth_service.dart'; 


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthService _authService = AuthService();
  bool _isSecure = true;
  bool _isLoading = false; // To show loading state

  final bool _isadmin = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to validate email format
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }


  // Function to register user with Firebase Authentication
  Future<void> _registerUser() async {
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

  // Function to check length of password to make sure it is over 6 characters long
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Waits for firebase auth to register user to database
    String? error = await _authService.registerUser(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      _passwordController.text,
      _isadmin,
    );

    setState(() {
      _isLoading = false;
    });

    // If we get no error we will ensure that the user knows their account was created and lead them to decoration page
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserDecorationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  // Makes sure that all fields are not empty
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
              // First Name Field
              Flexible(
                child: Padding(
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
              ),
              // Last Name Field
              Flexible(
                child: Padding(
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
              ),
            ],
          ),
          // Email Field
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: TextField(
                controller: _emailController,
                onChanged: (text) => _updateButtonState(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
            ),
          ),
          // Password Field
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
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
          ),
          _isLoading
              ? const CircularProgressIndicator()
              : TextButton(
                  onPressed: _validateFields() ? _registerUser : null,
                  child: const Text("Create Account"),
                ),
        ],
      ),
    ),
  );
  }
}