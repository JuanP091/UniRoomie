class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String university;
  final String major;
  final String bio;
  final List<String> interests;
  final String? profileImageUrl;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.university,
    required this.major,
    required this.bio,
    required this.interests,
    this.profileImageUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      firstName: map['First Name'] ?? '',
      lastName: map['Last Name'] ?? '',
      university: map['University'] ?? '',
      major: map['Major'] ?? '',
      bio: map['Bio'] ?? '',
      interests: List<String>.from(map['Interests'] ?? []),
      profileImageUrl: map['Profile Image URL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'First Name': firstName,
      'Last Name': lastName,
      'University': university,
      'Major': major,
      'Bio': bio,
      'Interests': interests,
      'Profile Image URL': profileImageUrl,
    };
  }
} 