import 'dart:convert';

import 'package:brgy_bagbag/models/valid_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessClearanceId {
  String id;
  String uid;
  String firstName;
  String middleName;
  String lastName;
  String address;
  Timestamp birthday;
  String placeOfBirth;
  String precinctNumber;
  String precinctAddress;
  String precinctContactNumber;
  String gender;
  String civilStatus;
  String purpose;
  String height;
  String weight;
  String parentFirstName;
  String parentMiddleName;
  String parentLastName;
  String parentAddress;
  String parentContactNumber;
  String parentRelationship;
  String twoByTwoPicture;
  ValidId firstGovernmentId;
  ValidId secondGovernmentId;
  Timestamp createdAt;
  Timestamp updatedAt;

  BusinessClearanceId({
    required this.id,
    required this.uid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.address,
    required this.birthday,
    required this.placeOfBirth,
    required this.precinctNumber,
    required this.precinctAddress,
    required this.precinctContactNumber,
    required this.gender,
    required this.civilStatus,
    required this.purpose,
    required this.height,
    required this.weight,
    required this.parentFirstName,
    required this.parentMiddleName,
    required this.parentLastName,
    required this.parentAddress,
    required this.parentContactNumber,
    required this.parentRelationship,
    required this.twoByTwoPicture,
    required this.firstGovernmentId,
    required this.secondGovernmentId,
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
      'birthday': birthday
    });
    result.addAll({
      'placeOfBirth': placeOfBirth
    });
    result.addAll({
      'precinctNumber': precinctNumber
    });
    result.addAll({
      'precinctAddress': precinctAddress
    });
    result.addAll({
      'precinctContactNumber': precinctContactNumber
    });
    result.addAll({
      'gender': gender
    });
    result.addAll({
      'civilStatus': civilStatus
    });
    result.addAll({
      'purpose': purpose
    });
    result.addAll({
      'height': height
    });
    result.addAll({
      'weight': weight
    });
    result.addAll({
      'parentFirstName': parentFirstName
    });
    result.addAll({
      'parentMiddleName': parentMiddleName
    });
    result.addAll({
      'parentLastName': parentLastName
    });
    result.addAll({
      'parentAddress': parentAddress
    });
    result.addAll({
      'parentContactNumber': parentContactNumber
    });
    result.addAll({
      'parentRelationship': parentRelationship
    });
    result.addAll({
      'twoByTwoPicture': twoByTwoPicture
    });
    result.addAll({
      'firstGovernmentId': firstGovernmentId.toMap()
    });
    result.addAll({
      'secondGovernmentId': secondGovernmentId.toMap()
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory BusinessClearanceId.fromMap(Map<String, dynamic> map) {
    return BusinessClearanceId(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      address: map['address'] ?? '',
      birthday: map['birthday'],
      placeOfBirth: map['placeOfBirth'] ?? '',
      precinctNumber: map['precinctNumber'] ?? '',
      precinctAddress: map['precinctAddress'] ?? '',
      precinctContactNumber: map['precinctContactNumber'] ?? '',
      gender: map['gender'] ?? '',
      civilStatus: map['civilStatus'] ?? '',
      purpose: map['purpose'] ?? '',
      height: map['height'] ?? '',
      weight: map['weight'] ?? '',
      parentFirstName: map['parentFirstName'] ?? '',
      parentMiddleName: map['parentMiddleName'] ?? '',
      parentLastName: map['parentLastName'] ?? '',
      parentAddress: map['parentAddress'] ?? '',
      parentContactNumber: map['parentContactNumber'] ?? '',
      parentRelationship: map['parentRelationship'] ?? '',
      twoByTwoPicture: map['twoByTwoPicture'] ?? '',
      firstGovernmentId: ValidId.fromMap(map['firstGovernmentId']),
      secondGovernmentId: ValidId.fromMap(map['secondGovernmentId']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory BusinessClearanceId.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return BusinessClearanceId.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory BusinessClearanceId.fromJson(String source) => BusinessClearanceId.fromMap(json.decode(source));
}
