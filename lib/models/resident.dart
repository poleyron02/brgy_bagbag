import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:brgy_bagbag/models/valid_id.dart';

class Resident {
  String id;
  String status;
  String? reasonForDecline;
  String userId;
  String firstName;
  String? middleName;
  String lastName;
  String suffix;
  String gender;
  String civilStatus;
  Timestamp birthday;
  String contactNumber;
  // String address;
  String street;
  String barangay;
  String city;
  String placeOfBirth;
  String occupation;
  bool isVoter;
  bool isMarried;
  // String purokNumber;
  String residentSince;
  String residentType;
  ValidId firstValidId;
  ValidId secondValidId;
  Timestamp createdAt;
  Timestamp updatedAt;

  String get fullName => '$firstName${(middleName?.toLowerCase() ?? 'none') == 'none' || (middleName ?? '').isEmpty ? '' : ' ${middleName![0]}.'} $lastName${suffix == 'None' ? '' : ' $suffix'}';
  String get address => '$street, $barangay, $city';

  Resident({
    required this.id,
    this.status = 'Pending',
    this.reasonForDecline,
    required this.userId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.gender,
    this.civilStatus = 'Single',
    required this.birthday,
    required this.contactNumber,
    // required this.address,
    required this.street,
    required this.barangay,
    required this.city,
    required this.placeOfBirth,
    required this.occupation,
    required this.isVoter,
    this.isMarried = false,
    // required this.purokNumber,
    required this.residentSince,
    required this.residentType,
    required this.firstValidId,
    required this.secondValidId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'userId': userId
    });
    result.addAll({
      'status': status
    });
    result.addAll({
      'reasonForDecline': reasonForDecline
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
      'suffix': suffix
    });
    result.addAll({
      'gender': gender
    });
    result.addAll({
      'civilStatus': civilStatus
    });
    result.addAll({
      'birthday': birthday
    });
    result.addAll({
      'contactNumber': contactNumber
    });
    // result.addAll({
    //   'address': address
    // });
    result.addAll({
      'street': street
    });
    result.addAll({
      'barangay': barangay
    });
    result.addAll({
      'city': city
    });
    result.addAll({
      'placeOfBirth': placeOfBirth
    });
    result.addAll({
      'occupation': occupation
    });
    result.addAll({
      'isVoter': isVoter
    });
    result.addAll({
      'isMarried': isMarried
    });
    // result.addAll({
    //   'purokNumber': purokNumber
    // });
    result.addAll({
      'resident_since': residentSince
    });
    result.addAll({
      'residentType': residentType
    });
    result.addAll({
      'firstValidId': firstValidId.toMap()
    });
    result.addAll({
      'secondValidId': secondValidId.toMap()
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      id: map['id'] ?? '',
      status: map['status'] ?? 'Pending',
      reasonForDecline: map['reasonForDecline'],
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: ((map['middleName'] ?? '') as String).isEmpty ? null : map['middleName'],
      lastName: map['lastName'] ?? '',
      suffix: map['suffix'] ?? '',
      gender: map['gender'] ?? '',
      civilStatus: map['civilStatus'] ?? 'Single',
      birthday: map['birthday'],
      contactNumber: map['contactNumber'] ?? '',
      // address: map['address'] ?? '',
      street: map['address'] ?? map['street'] ?? '',
      barangay: map['barangay'] ?? 'Bagbag',
      city: map['city'] ?? 'Quezon City',
      placeOfBirth: map['placeOfBirth'] ?? '',
      occupation: map['occupation'] ?? '',
      isVoter: map['isVoter'] ?? false,
      isMarried: map['isMarried'] ?? false,
      // purokNumber: map['purokNumber'] ?? '',
      residentSince: map['resident_since'] ?? '',
      residentType: map['residentType'] ?? 'Resident',
      firstValidId: ValidId.fromMap(map['firstValidId']),
      secondValidId: ValidId.fromMap(map['secondValidId']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory Resident.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return Resident.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory Resident.fromJson(String source) => Resident.fromMap(json.decode(source));
}
