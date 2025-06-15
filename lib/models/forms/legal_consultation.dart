import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class LegalConsultation {
  String id;
  String uid;
  String firstName;
  String middleName;
  String lastName;
  String contactNumber;
  String email;
  String concerns;
  Timestamp createdAt;
  Timestamp updatedAt;

  LegalConsultation({
    required this.id,
    required this.uid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.contactNumber,
    required this.email,
    required this.concerns,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'id': id
    });
    result.addAll({
      'uid': uid
    });
    result.addAll({
      'firstName': firstName
    });
    result.addAll({
      'middleName': middleName
    });
    result.addAll({
      'lastName': lastName
    });
    result.addAll({
      'contactNumber': contactNumber
    });
    result.addAll({
      'email': email
    });
    result.addAll({
      'concerns': concerns
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory LegalConsultation.fromMap(Map<String, dynamic> map) {
    return LegalConsultation(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'] ?? '',
      concerns: map['concerns'] ?? '',
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
  factory LegalConsultation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return LegalConsultation.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory LegalConsultation.fromJson(String source) => LegalConsultation.fromMap(json.decode(source));
}
