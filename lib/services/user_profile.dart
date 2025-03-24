import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String university;
  final String major;
  final String sleepSchedule;
  final String partyOrStudy;
  final List<String> hobbies;
  final String gender;
  final String uid;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.university,
    required this.major,
    required this.sleepSchedule,
    required this.partyOrStudy,
    required this.hobbies,
    required this.gender,
    required this.uid,
  });
  factory UserProfile.fromDocument(String id, Map<String,dynamic> doc) {
    return UserProfile(
      uid: id,
      firstName: doc['First Name'] ?? '',
      lastName: doc['Last Name'] ?? '',
      university: doc['university'] ?? '',
      major: doc['major'] ?? '',
      sleepSchedule: doc['sleepSchedule'] ?? '',
      partyOrStudy: doc['partyOrStudy'] ?? '',
      hobbies: List<String>.from(doc['hobbies'] ?? []),
      gender: doc['gender'] ?? '',
    );
  }
}

  class UserProfileService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Used to fetch profiles from database
    Future<Map<String, dynamic>> fetchProfiles() async {
     String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("Could not retrieve current user.");
    }

    QuerySnapshot userDocs = await _firestore.collection('users').get();

    // Put all Profiles in a List
    List<UserProfile> allProfiles = userDocs.docs.map((doc) {
      return UserProfile.fromDocument(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    // We want to seperate the current profile and other profiles to seperate them in the UI
    UserProfile? currentUserProfile;
    List<UserProfile> otherProfiles = [];

    // Look for current profile
    for (var profile in allProfiles) {
      if (profile.uid == currentUserId) {
        currentUserProfile = profile;
      } else {
        otherProfiles.add(profile);
      }
    }

    // Throw exception if we cannot load profile
    if (currentUserProfile == null) {
      throw Exception("Current user profile not found in Firestore.");
    }

    return {
      "currentUserProfile": currentUserProfile,
      "otherProfiles": otherProfiles,
    };
   }
  }