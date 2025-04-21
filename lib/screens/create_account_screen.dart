import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uniroomie/screens/login_screen.dart';
import 'package:uniroomie/screens/user_decoration_screen.dart';
import 'package:uniroomie/services/auth_service.dart';
import 'package:uniroomie/services/geocoding_api.dart';
import 'dart:developer' as developer;

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthService _authService = AuthService();
  final GeocodingAPI = GeocodingApi();

  bool _isSecure = true;
  bool _isLoading = false; // To show loading state
  late bool serviceEnabled;
  late LocationPermission permission;
  Position? position;
  final bool _isadmin = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Function to validate email format

  @override
  void initState() {
    super.initState();
    _initLocation(); // Request location when screen is initialized
  }

  Future<void> _initLocation() async {
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Location services are disabled.', name: 'CreateAccountScreen');
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log('Location permissions are denied', name: 'CreateAccountScreen');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log('Location permissions are permanently denied.', name: 'CreateAccountScreen');
      return;
    }

    // Get the current location
    position = await Geolocator.getCurrentPosition();
    developer.log('Location: ${position?.latitude}, ${position?.longitude}', name: 'CreateAccountScreen');
    setState(() {}); // Rebuild UI if needed
  }

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
        const SnackBar(
            content: Text("Password must be at least 6 characters long")),
      );
      return;
    }

    if (position == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Location not available. Please enable location services and try again.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // try to get city and state from Geocoding api
      final location = await GeocodingAPI.getCityAndState(position!.latitude, position!.longitude);
      final city = location['city']!;
      final state = location['state']!;
      // Wait to register user
      String? error = await _authService.registerUser(
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        _isadmin,
        city,
        state,
        position!.latitude,
        position!.longitude,
      );

      setState(() {
        _isLoading = false;
      });
      // If we get no error we will register the user
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
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
                          filled: true, // fill the background
                          fillColor:
                              Colors.white, // Make the input background white
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(30)), // Round the corners
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
                          filled: true, // Add this to fill the background
                          fillColor: Colors.white, // Make the background white
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(30)), // Round the corners
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
                      filled: true, // Add this to fill the background
                      fillColor: Colors.white, // Make the background white
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(30)), // Round the corners
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            hintText: "Password",
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSecure
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye,
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
                    height: 50, // Set a fixed height for the button
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
                        backgroundColor:
                            _validateFields() ? Colors.blue : Colors.grey,
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
