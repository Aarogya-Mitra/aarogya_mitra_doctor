import 'package:arogya_mitra_doctor/database/firebase_db.dart';
import 'package:arogya_mitra_doctor/model/doctor_profile.dart';
import 'package:arogya_mitra_doctor/pages/login_page.dart';
import 'package:arogya_mitra_doctor/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker picker = ImagePicker();
  late String? pdfUrl;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  void getProfileData() async {
    // Fetch the profile data from Firestore and populate the text fields
    DoctorProfile? profile = await FirebaseDb.getDoctorProfile(
      FirebaseDb.auth.currentUser!.uid,
    );
    if (profile != null) {
      fullNameController.text = profile.name;
      phoneNumberController.text = profile.contact;
      genderController.text = profile.gender;
      addressController.text = profile.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 44,
              ), // Replace with actual image URL
            ),
            Text(
              "Hello Dr. ${FirebaseDb.currentUserProfile!.name}",
              style: const TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text("(${FirebaseDb.auth.currentUser!.email})"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: genderController,
              decoration: InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.document_scanner),
              label: const Text('Upload Certificates'),
              onPressed: () async {
                CustomDialog.showLoadingDialog(
                  context,
                  message: 'Uploading...',
                );
                pdfUrl = await FirebaseDb.uploadImageToPDFCo();
                // Implement document upload functionality here
                CustomDialog.hideLoadingDialog(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Upload Documents')));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Save the profile data to Firestore
                CustomDialog.showLoadingDialog(
                  context,
                  message: 'Saving Profile...',
                );
                final profile = DoctorProfile(
                  id: FirebaseDb.auth.currentUser!.uid,
                  name: fullNameController.text,
                  contact: phoneNumberController.text,
                  gender: genderController.text,
                  address: addressController.text,
                  documentUrl: pdfUrl ?? '', // Use the uploaded PDF URL
                );

                await FirebaseDb.saveDoctorProfile(profile);
                CustomDialog.hideLoadingDialog(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile saved successfully!')),
                );
              },
              child: const Text('Save Profile'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseDb.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
