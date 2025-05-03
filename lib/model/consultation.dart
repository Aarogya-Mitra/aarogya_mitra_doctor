import 'package:cloud_firestore/cloud_firestore.dart';

class Consultation {
  final String id;
  final String patientId;
  final String? doctorId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String patientComplaint;
  final String patientName;
  final String? phoneNumber;

  Consultation({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.patientComplaint,
    required this.patientName,
    this.phoneNumber,
  });

  factory Consultation.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      try {
        if (value is Timestamp) return value.toDate();
        if (value is String) {
          final cleaned = value.startsWith('/') ? value.substring(1) : value;
          return DateTime.parse(cleaned);
        }
      } catch (_) {
        // Fallback to current time if parsing fails
      }
      return DateTime.now();
    }

    return Consultation(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'],
      title: map['title'] ?? '',
      status: map['status'] ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      patientComplaint: map['patientComplaint'] ?? '',
      patientName: map['patientName'] ?? '',
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'title': title,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'patientComplaint': patientComplaint,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
    };
  }
}
