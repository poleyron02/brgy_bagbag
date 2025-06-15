import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAccount {
  String id;
  String firstName;
  String middleName;
  String lastName;
  String username;
  String email;
  String password;
  String deviceId;
  String position;

  String get fullName => '$firstName ${middleName[0]}. $lastName';
  bool get isSuper => position == 'Admin';

  AdminAccount({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.deviceId,
    required this.position,
  });

  AdminAccount copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? username,
    String? email,
    String? password,
    String? deviceId,
    String? position,
  }) {
    return AdminAccount(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      deviceId: deviceId ?? this.deviceId,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'id': id
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
      'username': username
    });
    result.addAll({
      'email': email
    });
    result.addAll({
      'password': password
    });
    result.addAll({
      'deviceId': deviceId
    });
    result.addAll({
      'position': position
    });

    return result;
  }

  factory AdminAccount.fromMap(Map<String, dynamic> map) {
    return AdminAccount(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      deviceId: map['deviceId'] ?? '',
      position: map['position'] ?? '',
    );
  }

  factory AdminAccount.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return AdminAccount.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory AdminAccount.fromJson(String source) => AdminAccount.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AdminAccount(firstName: $firstName, middleName: $middleName, lastName: $lastName, username: $username, email: $email, password: $password, deviceId: $deviceId, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminAccount && other.firstName == firstName && other.middleName == middleName && other.lastName == lastName && other.username == username && other.email == email && other.password == password && other.deviceId == deviceId && other.position == position;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^ middleName.hashCode ^ lastName.hashCode ^ username.hashCode ^ email.hashCode ^ password.hashCode ^ deviceId.hashCode ^ position.hashCode;
  }
}
