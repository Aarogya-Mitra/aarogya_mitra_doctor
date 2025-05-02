import 'package:arogya_mitra_doctor/database/firebase_db.dart';
import 'package:arogya_mitra_doctor/model/doctor_profile.dart';
import 'package:arogya_mitra_doctor/pages/login_page.dart';
import 'package:arogya_mitra_doctor/pages/profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DoctorProfile profile;
  @override
  void initState() {
    super.initState();
    FirebaseDb.getDoctorProfile(FirebaseDb.auth.currentUser!.uid).then((value) {
      setState(() {
        profile = value!;
        FirebaseDb.currentUserProfile = profile;
      });
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          child: IconButton(
            icon: const Icon(Icons.person),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseDb.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        title: const Text('Hello Doctor'),
        centerTitle: true,
      ),
      body:
          profile.isVerified
              ? Center(child: Column()) // You can customize this part as needed
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 64,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Hello Dr. ${profile.name}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            "Contact",
                            profile.contact.isNotEmpty
                                ? profile.contact
                                : "Not Provided",
                          ),
                          _buildInfoRow(
                            "Address",
                            profile.address.isNotEmpty
                                ? profile.address
                                : "Not Provided",
                          ),
                          _buildInfoRow(
                            "Completed Profile",
                            profile.isVerified ? "Yes" : "No",
                          ),
                          _buildInfoRow(
                            "Is Verified",
                            profile.isVerified ? "Yes" : "No",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
