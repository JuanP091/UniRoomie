import 'dart:math';

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
  final String city;
  final String state;
  final double latitude;
  final double longitude;

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
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
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
      city: doc['city'] ?? '',
      state: doc['state'] ?? '',
      latitude: doc['latitude'] ?? 0.0,
      longitude: doc['longitude'] ?? 0.0,
    );
  }
}

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double distanceDifference(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;

    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  bool isSimilar(String str1, String str2) {
    return str1.toLowerCase().contains(str2.toLowerCase()) ||
        str2.toLowerCase().contains(str1.toLowerCase());
  }

  bool isSameUniversity(String university1, String university2) {
    return university1.toLowerCase() == university2.toLowerCase();
  }

  Future<Map<String, dynamic>> fetchProfiles() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception("Could not retrieve current user.");
    }

    QuerySnapshot userDocs = await _firestore.collection('users').get();

    List<UserProfile> allProfiles = userDocs.docs.map((doc) {
      return UserProfile.fromDocument(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    UserProfile? currentUserProfile;
    List<UserProfile> otherProfiles = [];

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

    List<UserProfile> similarProfiles = [];
    List<UserProfile> nonSimilarProfiles = [];

    for (var profile in otherProfiles) {
      bool isClose = distanceDifference(
              currentUserProfile.latitude,
              currentUserProfile.longitude,
              profile.latitude,
              profile.longitude) <=
          30;

      if (!isClose) continue;

      bool sameMajor = isSimilar(currentUserProfile.major, profile.major);
      bool sameUniversity = isSameUniversity(
          currentUserProfile.university, profile.university);
      bool sameSleep = isSimilar(
          currentUserProfile.sleepSchedule, profile.sleepSchedule);

      if (sameMajor && sameUniversity && sameSleep) {
        similarProfiles.add(profile);
      } else {
        nonSimilarProfiles.add(profile);
      }
    }

    List<UserProfile> combinedProfiles = [...similarProfiles, ...nonSimilarProfiles];

    return {
      "currentUserProfile": currentUserProfile,
      "otherProfiles": combinedProfiles,
    };
  }

  Future<void> swipeUser(String swipedUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('swipes')
        .doc(currentUserId)
        .collection('right')
        .doc(swipedUserId)
        .set({'timestamp': FieldValue.serverTimestamp()});
  }
}
