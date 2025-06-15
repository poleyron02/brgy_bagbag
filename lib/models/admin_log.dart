import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLog {
  String id;
  String adminId;
  String adminName;
  String action;
  Timestamp loggedAt;
  Timestamp createdAt;
  Timestamp updatedAt;
  AdminLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.loggedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  AdminLog copyWith({
    String? id,
    String? adminId,
    String? adminName,
    String? action,
    Timestamp? loggedAt,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return AdminLog(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      action: action ?? this.action,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'id': id
    });
    result.addAll({
      'adminId': adminId
    });
    result.addAll({
      'adminName': adminName
    });
    result.addAll({
      'action': action
    });
    result.addAll({
      'loggedAt': loggedAt
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory AdminLog.fromMap(Map<String, dynamic> map) {
    return AdminLog(
      id: map['id'] ?? '',
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      action: map['action'] ?? '',
      loggedAt: map['loggedAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory AdminLog.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return AdminLog.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory AdminLog.fromJson(String source) => AdminLog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AdminLog(id: $id, adminId: $adminId, adminName: $adminName, action: $action, loggedAt: $loggedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminLog && other.id == id && other.adminId == adminId && other.adminName == adminName && other.action == action && other.loggedAt == loggedAt && other.createdAt == createdAt && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ adminId.hashCode ^ adminName.hashCode ^ action.hashCode ^ loggedAt.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }
}
