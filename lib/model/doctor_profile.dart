class DoctorProfile {
  final String id; // Firestore document ID (optional)
  final String name;
  final String contact;
  final String gender;
  final String address;
  final String documentUrl;
  final bool isVerified; // Optional field for verification status

  DoctorProfile({
    required this.id,
    required this.name,
    required this.contact,
    required this.gender,
    required this.address,
    required this.documentUrl,
    this.isVerified = false, // Default value for isVerified
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'gender': gender,
      'address': address,
      'documentUrl': documentUrl,
      'isVerified': isVerified, // Include isVerified in the map
    };
  }

  // Create model from Firestore document
  factory DoctorProfile.fromMap(String id, Map<String, dynamic> map) {
    return DoctorProfile(
      id: id,
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      gender: map['gender'] ?? '',
      address: map['address'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
      isVerified: map['isVerified'] ?? false, // Include isVerified in the model
    );
  }
}
