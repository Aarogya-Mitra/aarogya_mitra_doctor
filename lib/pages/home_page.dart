import 'package:arogya_mitra_doctor/database/firebase_db.dart';
import 'package:arogya_mitra_doctor/model/consultation.dart';
import 'package:arogya_mitra_doctor/model/doctor_profile.dart';
import 'package:arogya_mitra_doctor/pages/call_page.dart';
import 'package:arogya_mitra_doctor/pages/login_page.dart';
import 'package:arogya_mitra_doctor/pages/profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DoctorProfile? profile;
  List<Consultation> consultations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final userId = FirebaseDb.auth.currentUser?.uid;
      if (userId == null) return;

      final fetchedProfile = await FirebaseDb.getDoctorProfile(userId);
      if (fetchedProfile != null && fetchedProfile.isVerified) {
        await _getConsultation();
      }

      setState(() {
        profile = fetchedProfile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getConsultation() async {
    try {
      consultations = await FirebaseDb.getOpenConsultations();
    } catch (_) {}
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Consultation consult) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          consult.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Complaint: ${consult.patientComplaint}"),
            Text("Status: ${consult.status}"),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallPage(callID: 'roomId'),
              ),
            );
          },
        ),
        onTap: () {
          // TODO: Navigate to consultation detail
        },
      ),
    );
  }

  Widget _buildConsultationSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Open Consultations",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                consultations.isEmpty
                    ? const Center(child: Text("No consultations available"))
                    : ListView.builder(
                      itemCount: consultations.length,
                      itemBuilder:
                          (context, index) =>
                              _buildConsultationCard(consultations[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnverifiedCard() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Hello Dr. ${profile!.name}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                "Contact",
                profile!.contact.isNotEmpty ? profile!.contact : "Not Provided",
              ),
              _buildInfoRow(
                "Address",
                profile!.address.isNotEmpty ? profile!.address : "Not Provided",
              ),
              _buildInfoRow(
                "Completed Profile",
                profile!.isVerified ? "Yes" : "No",
              ),
              const SizedBox(height: 10),
              const Text(
                "Please complete and verify your profile to start consultations.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
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
        title: const Text('Arogya Mitra - Doctor'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade300,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                ? const Center(
                  child: Text(
                    "Doctor profile not found.\nPlease try again later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : profile!.isVerified
                ? _buildConsultationSection()
                : _buildUnverifiedCard(),
      ),
    );
  }
}
