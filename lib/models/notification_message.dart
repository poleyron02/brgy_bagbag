import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:brgy_bagbag/models/notification_link.dart';

class NotificationMessage {
  String id;
  String fromUid;
  String toUid;
  bool isRead;
  String title;
  String content;
  List<NotificationLink> links;
  Timestamp createdAt;
  Timestamp updatedAt;

  NotificationMessage({
    required this.id,
    required this.fromUid,
    required this.toUid,
    this.isRead = false,
    required this.title,
    required this.content,
    required this.links,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUid': fromUid,
      'toUid': toUid,
      'isRead': isRead,
      'title': title,
      'content': content,
      'links': links.map((x) => x.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory NotificationMessage.fromMap(Map<String, dynamic> map) {
    return NotificationMessage(
      id: map['id'] ?? '',
      fromUid: map['fromUid'] ?? '',
      toUid: map['toUid'] ?? '',
      isRead: map['isRead'] ?? false,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      links: List<NotificationLink>.from(map['links']?.map((x) => NotificationLink.fromMap(x))),
      createdAt: (map['createdAt']),
      updatedAt: (map['updatedAt']),
    );
  }
  factory NotificationMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return NotificationMessage.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory NotificationMessage.fromJson(String source) => NotificationMessage.fromMap(json.decode(source));

  NotificationMessage copyWith({
    String? id,
    String? fromUid,
    String? toUid,
    bool? isRead,
    String? title,
    String? content,
    List<NotificationLink>? links,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      fromUid: fromUid ?? this.fromUid,
      toUid: toUid ?? this.toUid,
      isRead: isRead ?? this.isRead,
      title: title ?? this.title,
      content: content ?? this.content,
      links: links ?? this.links,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationMessage(id: $id, fromUid: $fromUid, toUid: $toUid, isRead: $isRead, title: $title, content: $content, links: $links, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationMessage && other.id == id && other.fromUid == fromUid && other.toUid == toUid && other.isRead == isRead && other.title == title && other.content == content && listEquals(other.links, links) && other.createdAt == createdAt && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ fromUid.hashCode ^ toUid.hashCode ^ isRead.hashCode ^ title.hashCode ^ content.hashCode ^ links.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }
}
