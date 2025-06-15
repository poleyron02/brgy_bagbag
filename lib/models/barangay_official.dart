import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BarangayOfficial {
  String id;
  String firstName;
  String? middleName;
  String lastName;
  String suffix;
  String gender;
  String position;
  String image;
  Timestamp appointedAt;
  Timestamp? endedAt;
  Timestamp createdAt;
  Timestamp updatedAt;

  String get fullName => '$firstName${middleName == null ? '' : ' ${middleName![0]}.'} $lastName${suffix == 'None' ? '' : ' $suffix'}';

  BarangayOfficial({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.gender,
    required this.position,
    required this.image,
    required this.appointedAt,
    required this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

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
      'suffix': suffix
    });
    result.addAll({
      'gender': gender
    });
    result.addAll({
      'position': position
    });
    result.addAll({
      'image': image
    });
    result.addAll({
      'appointedAt': appointedAt
    });
    result.addAll({
      'endedAt': endedAt
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory BarangayOfficial.fromMap(Map<String, dynamic> map) {
    return BarangayOfficial(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'],
      lastName: map['lastName'] ?? '',
      suffix: map['suffix'] ?? '',
      gender: map['gender'] ?? '',
      position: map['position'] ?? '',
      image: map['image'] ?? '',
      appointedAt: map['appointedAt'],
      endedAt: map['endedAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory BarangayOfficial.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return BarangayOfficial.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory BarangayOfficial.fromJson(String source) => BarangayOfficial.fromMap(json.decode(source));
}
