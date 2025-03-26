import 'package:flutter/material.dart';
import 'package:uniroomie/screens/login_screen.dart';
import 'package:uniroomie/screens/user_decoration_screen.dart';
import 'package:uniroomie/services/auth_service.dart';
import 'package:uniroomie/services/zipcode_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}
class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthService _authService = AuthService();
  final ZipcodeService = ZipcodeApiService();

  bool _isSecure = true;
  bool _isLoading = false; // To show loading state
  final bool _isadmin = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
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
  // Check if we are given a correct amount of character for the zipcode
    if(_zipcodeController.text.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zipcode must be 5 characters long"))
      );
      return;
    }
  // Checks if given an existing zipcode
    if(ZipcodeService.getCityByZip(_zipcodeController.text) == 'Failed to get city info') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zipcode does not exist"))
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
      _zipcodeController.text,
      await ZipcodeService.getCityByZip(_zipcodeController.text),
      await ZipcodeService.getStateByZip(_zipcodeController.text),
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
        _passwordController.text.isNotEmpty && 
        _zipcodeController.text.isNotEmpty;
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
    _zipcodeController.dispose();
    super.dispose();
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.orange[800],
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Name Field
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _firstNameController,
                      onChanged: (text) => _updateButtonState(),
                      decoration: const InputDecoration(
                        filled: true,  // fill the background
                        fillColor: Colors.white,  // Make the input background white
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)), // Round the corners
                        ),
                        // Make all border states (enabled, focused, etc.) match the rounded style
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        hintText: "First Name",
                      ),
                    ),
                  ),
                ),
              ),
              // Last Name Field
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        filled: true,  // Add this to fill the background
                        fillColor: Colors.white,  // Make the background white
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)), // Round the corners
                        ),
                        // Make all border states (enabled, focused, etc.) match the rounded style
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        hintText: "Last Name",
                      ),
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
              child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      onChanged: (text) => _updateButtonState(),
                      decoration: const InputDecoration(
                            filled: true,  // Add this to fill the background
                            fillColor: Colors.white,  // Make the background white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)), // Round the corners
                            ),
                            // Make all border states (enabled, focused, etc.) match the rounded style
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            hintText: "Email",
                      ),
                    ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _zipcodeController,
                      onChanged: (text) => _updateButtonState(),
                      decoration: const InputDecoration(
                            filled: true,  // Add this to fill the background
                            fillColor: Colors.white,  // Make the background white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)), // Round the corners
                            ),
                            // Make all border states (enabled, focused, etc.) match the rounded style
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            hintText: "Enter Zipcode",
                      ),
                    ),
              ),
            ),
          ),

          // Password Field ----------------------------

          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _isSecure,
                        onChanged: (text) => _updateButtonState(),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                          hintText: "Password",
                        ),
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
          const SizedBox(height: 20),
          _isLoading
          ? const CircularProgressIndicator()
          : Container(
              width: 200, // Set a fixed width for the button
              height: 50,  // Set a fixed height for the button
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // Round edges
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(

                onPressed: _validateFields() ? _registerUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _validateFields() ? Colors.blue : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0, // Remove default button elevation
                ),
                
                child: const Text(

                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),


            // Already have an account text button
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              "Already have an account?",
              style: TextStyle(
                //decoration: TextDecoration.underline,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ],
      ),
    ),
  );
  }
}