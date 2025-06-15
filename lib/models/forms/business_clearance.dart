import 'dart:convert';

import 'package:brgy_bagbag/models/valid_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessClearance {
  String id;
  String uid;
  String ownerFirstName;
  String ownerMiddleName;
  String ownerLastName;
  String ownerAddress;
  String businessName;
  String businessAddress;
  String businessType;
  String contactNumber;
  String property;
  String dtiSecRegNumber;
  String twoByTwoPicture;
  ValidId firstGovernmentId;
  ValidId secondGovernmentId;
  Timestamp createdAt;
  Timestamp updatedAt;

  BusinessClearance({
    required this.id,
    required this.uid,
    required this.ownerFirstName,
    required this.ownerMiddleName,
    required this.ownerLastName,
    required this.ownerAddress,
    required this.businessName,
    required this.businessAddress,
    required this.businessType,
    required this.contactNumber,
    required this.property,
    required this.dtiSecRegNumber,
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
      'ownerFirstName': ownerFirstName
    });
    result.addAll({
      'ownerMiddleName': ownerMiddleName
    });
    result.addAll({
      'ownerLastName': ownerLastName
    });
    result.addAll({
      'ownerAddress': ownerAddress
    });
    result.addAll({
      'businessName': businessName
    });
    result.addAll({
      'businessAddress': businessAddress
    });
    result.addAll({
      'businessType': businessType
    });
    result.addAll({
      'contactNumber': contactNumber
    });
    result.addAll({
      'property': property
    });
    result.addAll({
      'dtiSecRegNumber': dtiSecRegNumber
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

  factory BusinessClearance.fromMap(Map<String, dynamic> map) {
    return BusinessClearance(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      ownerFirstName: map['ownerFirstName'] ?? '',
      ownerMiddleName: map['ownerMiddleName'] ?? '',
      ownerLastName: map['ownerLastName'] ?? '',
      ownerAddress: map['ownerAddress'] ?? '',
      businessName: map['businessName'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      businessType: map['businessType'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      property: map['property'] ?? '',
      dtiSecRegNumber: map['dtiSecRegNumber'] ?? '',
      twoByTwoPicture: map['twoByTwoPicture'] ?? '',
      firstGovernmentId: ValidId.fromMap(map['firstGovernmentId']),
      secondGovernmentId: ValidId.fromMap(map['secondGovernmentId']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
  factory BusinessClearance.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return BusinessClearance.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory BusinessClearance.fromJson(String source) => BusinessClearance.fromMap(json.decode(source));
}
