import 'dart:convert';

class ValidId {
  String idNo;
  String type;
  String path;

  ValidId({
    this.idNo = '',
    required this.type,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'idNo': idNo
    });
    result.addAll({
      'type': type
    });
    result.addAll({
      'path': path
    });

    return result;
  }

  factory ValidId.fromMap(Map<String, dynamic> map) {
    return ValidId(
      idNo: map['idNo'] ?? '',
      type: map['type'] ?? '',
      path: map['path'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ValidId.fromJson(String source) => ValidId.fromMap(json.decode(source));
}
