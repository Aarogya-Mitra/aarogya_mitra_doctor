import 'package:arogya_mitra_doctor/database/firebase_db.dart';
import 'package:arogya_mitra_doctor/pages/home_page.dart';
import 'package:arogya_mitra_doctor/pages/login_page.dart';
import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseDb.auth.currentUser != null) {
      return HomePage();
    } else {
      return const LoginPage();
    }
  }
}
