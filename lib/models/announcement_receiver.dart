import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementReceiver {
  String id;
  String name;
  Timestamp createdAt;
  Timestamp updatedAt;

  AnnouncementReceiver({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'name': name
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory AnnouncementReceiver.fromMap(Map<String, dynamic> map) {
    return AnnouncementReceiver(
      id: map['id'],
      name: map['name'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory AnnouncementReceiver.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return AnnouncementReceiver.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory AnnouncementReceiver.fromJson(String source) => AnnouncementReceiver.fromMap(json.decode(source));
}
