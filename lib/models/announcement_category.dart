import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementCategory {
  String id;
  String name;
  Timestamp createdAt;
  Timestamp updatedAt;

  AnnouncementCategory({
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

  factory AnnouncementCategory.fromMap(Map<String, dynamic> map) {
    return AnnouncementCategory(
      id: map['id'],
      name: map['name'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory AnnouncementCategory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return AnnouncementCategory.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory AnnouncementCategory.fromJson(String source) => AnnouncementCategory.fromMap(json.decode(source));
}
