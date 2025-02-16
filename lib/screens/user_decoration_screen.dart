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
        body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gender Drop Down
            const Text("Gender:", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text("Select Gender"),
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                // Display Male , Female , and Other
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
                      _customGenderController
                          .clear(); // clear controller if user chooses male or female
                    }
                  });
                },
              ),
            ),
            // Give user option to choose other and specify their gender
            if (_selectedGender == "Other")
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _customGenderController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Specify Gender",
                  ),
                ),
              ),
            // University Field
            const Text("University:", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _universityController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Input your University!",
                ),
              ),
            ),
            // Major Field
            const Text("Major:", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _majorController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Input Your Major!",
                ),
              ),
            ),
            // Sleep schedule dropdown
            const Text("Night Owl or Morning Person? :",
                style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                value: _selectedSchedule,
                hint: const Text("Preferred Schedule"),
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
            // Party or study drop down
            const Text("Party Animal or Book Worm? :", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                value: _partyOrStudy,
                hint: const Text("Party or Study?"),
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
            // Hobbies Field
            const Text("Hobbies:", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _hobbyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Add Hobbies seperate with comma!",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed:
                    _validateRequiredFields() // checks that required fields are filled if not disables button
                        ? () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WelcomePageScreen()),
                            );
                            await _updateUserProfile();
                          }
                        : null,
                child: const Text("Decorate Account!"),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}