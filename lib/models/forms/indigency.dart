import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Indigency {
  String id;
  String uid;
  String firstName;
  String middleName;
  String lastName;
  String address;
  String yearsOfStay;
  String purpose;
  String studentName;
  String studentAddress;
  String studentContactNumber;
  String relationshipWithStudent;
  Timestamp createdAt;
  Timestamp updatedAt;

  String get fullName => '$firstName $middleName $lastName';

  Indigency({
    required this.id,
    required this.uid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.address,
    required this.yearsOfStay,
    required this.purpose,
    required this.studentName,
    required this.studentAddress,
    required this.studentContactNumber,
    required this.relationshipWithStudent,
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
      'address': address
    });
    result.addAll({
      'yearsOfStay': yearsOfStay
    });
    result.addAll({
      'purpose': purpose
    });
    result.addAll({
      'studentName': studentName
    });
    result.addAll({
      'studentAddress': studentAddress
    });
    result.addAll({
      'studentContactNumber': studentContactNumber
    });
    result.addAll({
      'relationshipWithStudent': relationshipWithStudent
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory Indigency.fromMap(Map<String, dynamic> map) {
    return Indigency(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      address: map['address'] ?? '',
      yearsOfStay: map['yearsOfStay'] ?? '',
      purpose: map['purpose'] ?? '',
      studentName: map['studentName'] ?? '',
      studentAddress: map['studentAddress'] ?? '',
      studentContactNumber: map['studentContactNumber'] ?? '',
      relationshipWithStudent: map['relationshipWithStudent'] ?? '',
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory Indigency.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return Indigency.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory Indigency.fromJson(String source) => Indigency.fromMap(json.decode(source));
}
