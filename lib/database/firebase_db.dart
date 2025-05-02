import 'dart:convert';
import 'dart:io';

import 'package:arogya_mitra_doctor/model/doctor_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FirebaseDb {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static DoctorProfile? currentUserProfile;

  static Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create a new user document in Firestore
      currentUserProfile = DoctorProfile(
        id: auth.currentUser!.uid,
        name: email.split('@')[0],
        contact: '',
        address: '',
        documentUrl: '',
        gender: '',
        isVerified: false,
      );
      await saveDoctorProfile(currentUserProfile!);

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<void> saveDoctorProfile(DoctorProfile profile) async {
    final docRef = FirebaseDb.firestore
        .collection('doctor_profile')
        .doc(profile.id);
    await docRef.set(profile.toMap());
  }

  static Future<DoctorProfile?> getDoctorProfile(String id) async {
    final docRef = FirebaseDb.firestore.collection('doctor_profile').doc(id);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return DoctorProfile.fromMap(id, snapshot.data()!);
    } else {
      return null;
    }
  }

  static Future<List<DoctorProfile>> getAllDoctorProfiles() async {
    final snapshot =
        await FirebaseDb.firestore.collection('doctor_profile').get();
    return snapshot.docs.map((doc) {
      return DoctorProfile.fromMap(doc.id, doc.data());
    }).toList();
  }

  static createNewProfile(DoctorProfile profile) async {
    final docRef = FirebaseDb.firestore
        .collection('doctor_profile')
        .doc(profile.id);
    await docRef.set(profile.toMap());
  }

  static Future<String?> uploadImageToPDFCo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final file = File(picked.path);
    final apiKey =
        "ay654995@gmail.com_F3KN810Jv41CXQ4V6qkNDkSbKr28GioHRfjmjVjHKyOBe1Px6PNIPPLM91R3BgU9";

    final uri = Uri.parse("https://api.pdf.co/v1/file/upload");
    final request =
        http.MultipartRequest("POST", uri)
          ..headers["x-api-key"] = apiKey
          ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final result = json.decode(responseBody);

    if (response.statusCode == 200 && result['url'] != null) {
      return result['url']; // Permanent public link
    } else {
      print("Error: ${result['message']}");
      return null;
    }
  }
}
