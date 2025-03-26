import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniroomie/services/zipcode_service.dart';

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
  final String zipcode;
  final String city;
  final String state;

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
    required this.zipcode,
    required this.city,
    required this.state,
  });
  factory UserProfile.fromDocument(String id, Map<String, dynamic> doc) {
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
      zipcode: doc['Zipcode'] ?? '',
      city: doc['City'] ?? '',
      state: doc['State'] ?? '',
    );
  }
}

class UserProfileService {
  final ZipcodeService = ZipcodeApiService();
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
      return UserProfile.fromDocument(
          doc.id, doc.data() as Map<String, dynamic>);
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

    if (currentUserProfile == null) {
      throw Exception("Current user profile not found in Firestore.");
    }

    List<UserProfile> filteredProfiles = [];

    for (var profile in otherProfiles) {
      double distance = await ZipcodeService.distanceDifference(
        currentUserProfile.zipcode,
        profile.zipcode,
      );
      if (distance <= 30) {
        filteredProfiles.add(profile);
      }
    }

    return {
      "currentUserProfile": currentUserProfile,
      "otherProfiles": filteredProfiles,
    };
  }
}