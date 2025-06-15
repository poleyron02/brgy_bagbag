import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Concern {
  String id;
  String uid;
  String firstName;
  String middleName;
  String lastName;
  String email;
  String contactNumber;
  String messages;
  Timestamp createdAt;
  Timestamp updatedAt;

  Concern({
    required this.id,
    required this.uid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.messages,
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
      'email': email
    });
    result.addAll({
      'contactNumber': contactNumber
    });
    result.addAll({
      'messages': messages
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory Concern.fromMap(Map<String, dynamic> map) {
    return Concern(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      messages: map['messages'] ?? '',
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory Concern.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return Concern.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory Concern.fromJson(String source) => Concern.fromMap(json.decode(source));
}
