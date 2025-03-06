// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uniroomie/screens/welcome_page_screen.dart';
class UserDecorationScreen extends StatefulWidget {
  const UserDecorationScreen({super.key});
  @override
  State<UserDecorationScreen> createState() => _UserDecorationScreenState();
}
class _UserDecorationScreenState extends State<UserDecorationScreen> {
  final TextEditingController _hobbyController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _universityController =
      TextEditingController(); // Require this field
  final TextEditingController _customGenderController =
      TextEditingController(); // Require this field
  final TextEditingController _partyOrStudyController = TextEditingController();
  String? _selectedGender;
  String? _selectedSchedule;
  String? _partyOrStudy;
  List<String> genderOptions = ["Male", "Female", "Other"];
  List<String> sleepScheduleOptions = ["Night Owl", "Morning Person"];
  List<String> partyOrStudyOptions = ["Party", "Study"];
  List<String> hobbies = [];
  @override
  void initState() {
    super.initState();
    _universityController.addListener(() {
      setState(() {}); // Ensures the button updates when university changes
    });
    _customGenderController.addListener(() {
      setState(() {}); // Ensures the button updates when custom gender changes
    });
  }
  @override
  void dispose() {
    _hobbyController.dispose();
    _majorController.dispose();
    _universityController.dispose();
    _customGenderController.dispose();
    _partyOrStudyController.dispose();
    super.dispose();
  }
  // Function to check that required fields are filled
  bool _validateRequiredFields() {
    bool isGenderValid = (_selectedGender != null &&
            _selectedGender != "Other") ||
        (_selectedGender == "Other" && _customGenderController.text.isNotEmpty);
    return _universityController.text.isNotEmpty && isGenderValid;
  }
  // Will refactor into auth_service later
  Future<void> _updateUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      } else {
        String uid = user.uid;
        // check if gender is predefined or other
        String genderToStore = _selectedGender == "Other"
            ? _customGenderController.text
            : _selectedGender ?? "";
        List<String> newHobbies = _hobbyController.text
            .split(',')
            .map((hobby) => hobby.trim()) // Trim spaces
            .where((hobby) => hobby.isNotEmpty) // Remove empty strings
            .toSet() // Remove duplicates
            .toList();
        setState(() {
          hobbies.addAll(newHobbies.where((hobby) =>
              !hobbies.contains(hobby))); // Append only unique hobbies
          _hobbyController.clear(); // Clear input field
        });
        Map<String, dynamic> userData = {
          "hobbies": hobbies,
          "major": _majorController.text,
          "university": _universityController.text,
          "sleepSchedule": _selectedSchedule ?? "",
          "partyOrStudy": _partyOrStudy ?? "",
          "gender": genderToStore
        };
        // Reference the user's document in firebase
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        // Update user document
        await userRef.update(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[800],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Tell us about yourself", 
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )
                ),
                const SizedBox(height: 20),
                
                // Gender Drop Down

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("*", 
                      style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 123, 0, 0), fontWeight: FontWeight.w500),
                    ),
                    Text("Gender:", 
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Padding(
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
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      hint: const Text("Select Gender"),
                      isExpanded: true,
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      items: genderOptions.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                          if (value != "Other") {
                            _customGenderController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                
                // Custom Gender Field (conditionally displayed)
                if (_selectedGender == "Other")
                  Padding(
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
                        controller: _customGenderController,
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
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: "Specify Gender",
                        ),
                      ),
                    ),
                  ),

            // University Field
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("*", 
                      style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 123, 0, 0), fontWeight: FontWeight.w500),
                    ),
                    Text("University:", 
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
            Padding(
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
                  controller: _universityController,
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: "Input your University!",
                          ),
                ),
              ),
            ),
            // Major Field
            const Text("Major:", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
            Padding(
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
                  controller: _majorController,
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: "Input your Major!",
                          ),
                ),
              ),
            ),
            // Sleep schedule dropdown
            const Text("Night Owl or Morning Person? :",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
            Padding(
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
                child: DropdownButtonFormField<String>(
                  value: _selectedSchedule,
                  hint: const Text("Preferred Schedule"),
                  isExpanded: true,
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                  items: sleepScheduleOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedSchedule = value;
                    });
                  },
                ),
              ),
            ),
            // Party or study drop down
            const Text("Party Animal or Book Worm? :", 
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
            Padding(
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
                child: DropdownButtonFormField<String>(
                  value: _partyOrStudy,
                  hint: const Text("Party or Study?"),
                  isExpanded: true,
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                  items: partyOrStudyOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _partyOrStudy = value;
                    });
                  },
                ),
              ),
            ),
            // Hobbies Field
            const Text("Hobbies:", 
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
            Padding(
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
                  controller: _hobbyController,
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: "Add Hobbies seperate with a comma!",
                          ),
                ),
              ),
            ),
            // Button at the end
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
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
                  onPressed: _validateRequiredFields()
                      ? () async {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WelcomePageScreen()),
                          );
                          await _updateUserProfile();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _validateRequiredFields() ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Decorate Account!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    ));
  }
}