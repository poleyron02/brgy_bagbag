import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class Request {
  String id;
  String uid;
  bool archived;
  String status;
  String collection;
  String collectionId;
  Timestamp createdAt;
  Timestamp updatedAt;

  bool isPickedUp;
  bool isPrinted;

  String? orReferenceNumber;

  Request({
    required this.id,
    required this.uid,
    this.archived = false,
    this.status = 'Pending',
    required this.collection,
    required this.collectionId,
    required this.createdAt,
    required this.updatedAt,
    this.isPickedUp = false,
    this.isPrinted = false,
    this.orReferenceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'archived': archived,
      'status': status,
      'collection': collection,
      'collectionId': collectionId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isPickedUp': isPickedUp,
      'isPrinted': isPrinted,
      'orReferenceNumber': orReferenceNumber,
    };
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      archived: map['archived'] ?? false,
      status: map['status'] ?? '',
      collection: map['collection'] ?? '',
      collectionId: map['collectionId'] ?? '',
      createdAt: (map['createdAt']),
      updatedAt: (map['updatedAt']),
      isPickedUp: map['isPickedUp'] ?? false,
      isPrinted: map['isPrinted'] ?? false,
      orReferenceNumber: map['orReferenceNumber'],
    );
  }

  factory Request.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return Request.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory Request.fromJson(String source) => Request.fromMap(json.decode(source));

  Request copyWith({
    String? id,
    String? uid,
    bool? archived,
    String? status,
    String? collection,
    String? collectionId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isPickedUp,
    bool? isPrinted,
    ValueGetter<String?>? orReferenceNumber,
  }) {
    return Request(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      archived: archived ?? this.archived,
      status: status ?? this.status,
      collection: collection ?? this.collection,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      isPrinted: isPrinted ?? this.isPrinted,
      orReferenceNumber: orReferenceNumber != null ? orReferenceNumber() : this.orReferenceNumber,
    );
  }

  @override
  String toString() {
    return 'Request(id: $id, uid: $uid, archived: $archived, status: $status, collection: $collection, collectionId: $collectionId, createdAt: $createdAt, updatedAt: $updatedAt, isPickedUp: $isPickedUp, isPrinted: $isPrinted, orReferenceNumber: $orReferenceNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Request && other.id == id && other.uid == uid && other.archived == archived && other.status == status && other.collection == collection && other.collectionId == collectionId && other.createdAt == createdAt && other.updatedAt == updatedAt && other.isPickedUp == isPickedUp && other.isPrinted == isPrinted && other.orReferenceNumber == orReferenceNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^ uid.hashCode ^ archived.hashCode ^ status.hashCode ^ collection.hashCode ^ collectionId.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode ^ isPickedUp.hashCode ^ isPrinted.hashCode ^ orReferenceNumber.hashCode;
  }
}
