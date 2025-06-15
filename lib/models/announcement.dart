import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  String id;
  String category;
  String receiver;
  String title;
  String content;
  String image;
  Timestamp createdAt;
  Timestamp updatedAt;

  Announcement({
    required this.id,
    required this.category,
    required this.receiver,
    required this.title,
    required this.content,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'category': category
    });
    result.addAll({
      'receiver': receiver
    });
    result.addAll({
      'title': title
    });
    result.addAll({
      'content': content
    });
    result.addAll({
      'image': image
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      category: map['category'],
      receiver: map['receiver'],
      title: map['title'],
      content: map['content'],
      image: map['image'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory Announcement.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return Announcement.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory Announcement.fromJson(String source) => Announcement.fromMap(json.decode(source));
}
