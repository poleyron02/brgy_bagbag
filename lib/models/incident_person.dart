import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentPerson {
  String? residentId;
  String name;
  String gender;
  String phoneNumber;
  Timestamp birthday;
  String address;
  String description;

  IncidentPerson({
    this.residentId,
    required this.name,
    required this.gender,
    required this.phoneNumber,
    required this.birthday,
    required this.address,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (residentId != null) {
      result.addAll({
        'residentId': residentId
      });
    }
    result.addAll({
      'name': name
    });
    result.addAll({
      'gender': gender
    });
    result.addAll({
      'phoneNumber': phoneNumber
    });
    result.addAll({
      'birthday': birthday
    });
    result.addAll({
      'address': address
    });
    result.addAll({
      'description': description
    });

    return result;
  }

  factory IncidentPerson.fromMap(Map<String, dynamic> map) {
    return IncidentPerson(
      residentId: map['residentId'],
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthday: map['birthday'],
      address: map['address'] ?? '',
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory IncidentPerson.fromJson(String source) => IncidentPerson.fromMap(json.decode(source));
}
